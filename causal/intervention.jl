using GLM, DataFrames, Statistics, CSV, StatsModels

files::Vector{String} = ["nk_19_10.csv", "nk_20_16.csv", "nk_21_4.csv"]
dotname = "syn"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv"]
# dotname = "nat"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv", "nk_19_10.csv", "nk_20_16.csv", "nk_21_4.csv"]
# dotname = "com"

# files::Vector{String} = ["backup/nk_16_9.csv", "backup/nk_18_3.csv", "backup/nk_19_16.csv"]
# dotname = "syn"

included_columns::Vector{String} = ["NormalizedBestFound","CrossoverProbability","MutationRate","LSProbability","LSMaxSteps", "GAImprovement", "LSImprovement", "PopulationSize", "MaxGenerations", "Autocorrelation", "NumberOfFeatures", "NumberOfLOs"]
load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]
combined = reduce(vcat, load_data, cols=:union)


function backdoor_do(df, treat::Symbol, confounders::Vector{Symbol}, outcome::Symbol, treat_val)

    outcome_form = Term(outcome) ~ Term(treat) + sum(Term.(confounders))
    model = lm(outcome_form, df)

    df_do = copy(df)
    df_do[!, treat] .= treat_val

    return mean(predict(model, df_do))
end


function mediation_do(df, treat::Symbol, mediator::Symbol, outcome::Symbol, confounders::Vector{Symbol}, treat_low, treat_high)

    confounders_str = join(string.(confounders), ", ")
    println("Adjusting for confounders: $confounders_str")

    mediator_form = Term(mediator) ~ Term(treat) + sum(Term.(confounders))
    outcome_form = Term(outcome)  ~ Term(treat) + Term(mediator) + Term(:PopulationSize) + Term(:MaxGenerations)

    med_model = lm(mediator_form, df)
    out_model = lm(outcome_form, df)

    df_high = copy(df); df_high[!, treat] .= treat_high
    df_low = copy(df); df_low[!,  treat] .= treat_low

    df_high[!, mediator] .= predict(med_model, df_high)
    df_low[!,  mediator] .= predict(med_model, df_low)

    p_y_do_high = mean(predict(out_model, df_high))
    p_y_do_low = mean(predict(out_model, df_low))

    total_effect = p_y_do_high - p_y_do_low

    mediator_fixed = mean(df[!, mediator])

    df_high_cut = copy(df)
    df_high_cut[!, treat] .= treat_high
    df_high_cut[!, mediator] .= mediator_fixed

    df_low_cut = copy(df)
    df_low_cut[!, treat]    .= treat_low
    df_low_cut[!, mediator] .= mediator_fixed

    p_y_do_high_cut = mean(predict(out_model, df_high_cut))
    p_y_do_low_cut = mean(predict(out_model, df_low_cut))

    direct_effect = p_y_do_high_cut - p_y_do_low_cut
    indirect_effect = total_effect - direct_effect

    return (
        p_do_high = p_y_do_high,
        p_do_low = p_y_do_low,
        total = total_effect,
        other_channels = direct_effect,
        via_mediator = indirect_effect,
        mediated_proportion = indirect_effect / total_effect
    )
end

confounders = [:Autocorrelation, :NumberOfFeatures, :NumberOfLOs]

res_ga = mediation_do(combined, :CrossoverProbability, :GAImprovement, :NormalizedBestFound, confounders, 0.0, 1.0)
res_ls = mediation_do(combined, :LSProbability, :LSImprovement, :NormalizedBestFound, confounders, 0.0, 1.0)
res_mr = mediation_do(combined, :MutationRate, :GAImprovement, :NormalizedBestFound, confounders, 0.0, 0.2)
res_ls_steps = mediation_do(combined, :LSMaxSteps, :LSImprovement, :NormalizedBestFound, confounders, 1, 10)

for (name, res) in [("CP → GAImprovement → NBF", res_ga), ("LSP → LSImprovement → NBF", res_ls), ("MR → GAImprovement → NBF", res_mr), ("LSMaxSteps → LSImprovement → NBF", res_ls_steps)]
    println("\n=== $name ===")
    println("E[NBF | do(T=high)]: ", round(res.p_do_high, digits=4))
    println("E[NBF | do(T=low)]: ", round(res.p_do_low, digits=4))
    println("Total effect: ", round(res.total, digits=4))
    println("Via mediator: ", round(res.via_mediator, digits=4))
    println("Other channels: ", round(res.other_channels, digits=4))
    println("Mediated proportion: ", round(res.mediated_proportion, digits=4))
end


ga_model = lm(@formula(GAImprovement ~ CrossoverProbability + MutationRate + Autocorrelation + NumberOfFeatures + NumberOfLOs), combined)
ls_model = lm(@formula(LSImprovement ~ LSProbability + LSMaxSteps + Autocorrelation + NumberOfFeatures + NumberOfLOs), combined)


function summarize_model(model, df, outcome_sym, name)

    ct = coeftable(model)
    y_std = std(df[!, outcome_sym])

    println("\n=== $name (outcome std = $(round(y_std, digits=5))) ===")
    println("  $(rpad("term", 25)) $(rpad("coef", 14)) $(rpad("std_coef", 10))")

    for (i, term) in enumerate(ct.rownms)

        term == "(Intercept)" && continue

        coef = ct.cols[1][i]
        x_std = std(df[!, Symbol(term)])

        std_coef = coef * x_std / y_std
        println("  $(rpad(term, 25)) $(rpad(round(coef, digits=6), 14)) $(round(std_coef, digits=4))")
    end
end

summarize_model(ga_model, combined, :GAImprovement, "GAImprovement")
summarize_model(ls_model, combined, :LSImprovement, "LSImprovement")