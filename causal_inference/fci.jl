using DataFrames, CSV, CausalInference, GraphPlot, Compose

files::Vector{String} = ["nk_K2.csv", "nk_K9.csv", "nk_K16.csv", "heart_13.csv", "zoo_16.csv", "hep_19.csv"] #"nk_K2.csv", "nk_K9.csv", "nk_K16.csv", "heart_13.csv", "zoo_16.csv", "hep_19.csv"
included_columns::Vector{String} = ["number_of_generations", "population_size", "mutation_rate", "crossover_probability", "avg_ga_improvement", "ls_p_value", "ls_max_steps", "avg_ls_improvement", "normalized_best_found"]
load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]
combined = reduce(vcat, load_data, cols=:union)

replace!(combined[!, :avg_ls_improvement], NaN => .0)

allowmissing!(combined)
foreach(col -> replace!(combined[!, col], NaN => missing), names(combined))
cop = dropmissing!(copy(combined))

# println(cop)

fci = fcialg(cop, .005, gausscitest)

gplothtml(pc,
    nodelabel = names(cop),
    title = "FCI"
)