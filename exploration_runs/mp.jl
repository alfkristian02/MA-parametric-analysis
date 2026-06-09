include("../types.jl")
include("../config.jl")

using .ConfigParameters, DataFrames, StatsBase, CSV, Plots, Plots.PlotMeasures

files::Vector{String} = ["nk_19_10.csv", "nk_20_16.csv", "nk_21_4.csv"]
dotname = "syn"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv"]
# dotname = "nat"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv", "nk_19_10.csv", "nk_20_16.csv", "nk_21_4.csv"]
# dotname = "com"

included_columns::Vector{String} = ["NormalizedBestFound","CrossoverProbability","MutationRate","LSProbability","LSMaxSteps", "GAImprovement", "LSImprovement", "PopulationSize", "MaxGenerations", "Autocorrelation", "NumberOfFeatures", "NumberOfLOs"]
load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]
combined = reduce(vcat, load_data, cols=:union)


function prob_best_given(df, col, val)
    subset = filter(row -> row[col] == val, df)

    return mean(subset.NormalizedBestFound .== 1.0)
end


param_grid = Dict(
    :PopulationSize        => population_sizes,
    :MaxGenerations        => number_of_generations,
    :CrossoverProbability  => crossover_probabilities,
    :MutationRate          => mutation_rates,
    :LSProbability         => ls_p_values,
    :LSMaxSteps            => ls_max_steps,
)

marginal_probabilities = Dict{Symbol, Vector{Float64}}()

for (col, vals) in param_grid
    marginal_probabilities[col] = [prob_best_given(combined, col, v) for v in vals]
end


rows = []
for ps in population_sizes, ng in number_of_generations, cp in crossover_probabilities, mr in mutation_rates, lp in ls_p_values, ls in ls_max_steps

    subset = filter(row ->
                        row.PopulationSize == ps 
                        && row.MaxGenerations == ng 
                        && row.CrossoverProbability == cp
                        && row.MutationRate  == mr 
                        && row.LSProbability == lp 
                        && row.LSMaxSteps == ls
                    , combined)

    p = isempty(subset) ? NaN : mean(subset.NormalizedBestFound .== 1.0)

    push!(rows, (
        PopulationSize = ps,
        MaxGenerations = ng,
        CrossoverProbability = cp,
        MutationRate = mr,
        LSProbability = lp,
        LSMaxSteps = ls,
        P_best = p,
        N = nrow(subset),
    ))
end

results = DataFrame(rows)


param_labels = [
    :PopulationSize       => ("Population Size",        population_sizes),
    :MaxGenerations       => ("Max Generations",        number_of_generations),
    :CrossoverProbability => ("Crossover Probability",  crossover_probabilities),
    :MutationRate         => ("Mutation Rate",          mutation_rates),
    :LSProbability        => ("LS Probability",         ls_p_values),
    :LSMaxSteps           => ("LS Max Steps",           ls_max_steps),
]

plots = []
for (col, (label, vals)) in param_labels

    probs = marginal_probabilities[col]
    n = length(vals)

    p = bar(
        1:n, 
        probs,
        xlabel = label,
        ylabel = "P(GO reached)",
        ylims = (0, 1),
        legend = false,
        color = :steelblue,
        xticks = (1:n, string.(vals)))

    for (i, v) in enumerate(probs)
        annotate!(p, i, v/2, text(string(round(v, digits=2)), 7, :center, :white))
    end

    push!(plots, p)
end

fig = plot(plots..., layout=(3,2), size=(800,1100), margin=8mm, dpi=300)
savefig(fig, "exploration_runs/mp/mp_$(dotname).png")