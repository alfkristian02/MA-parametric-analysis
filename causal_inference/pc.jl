using DataFrames, CSV, CausalInference, GraphRecipes, Plots, Plots.Measures

files::Vector{String} = ["nk_K2.csv", "nk_K9.csv", "nk_K16.csv", "heart_13.csv", "letter_16.csv", "hep_19.csv"]
included_columns::Vector{String} = ["population_size", "number_of_generations", "crossover_probability", "mutation_rate", "ls_p_value", "ls_max_steps", "avg_ga_improvement", "avg_ls_improvement", "best_found", "ds_diff"]
load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]
combined = reduce(vcat, load_data, cols=:union)

cols_to_fix = [:avg_ga_improvement, :avg_ls_improvement] 

for col in cols_to_fix
    replace!(combined[!, col], NaN => 0.0)
end

pc = pcalg(combined, .001, gausscitest)

p = graphplot(pc,
    names = names(combined),
    layout = circular_layout,
    nodeshape = :circle,
    markercolor = :white,
    linecolor = :black,
    fontsize = 8,
    nodesize = 0.12,

    linewidth = 1.5,
    size = (1200, 1000),
    shorten = 0.05,
    arrow = :arrow,

    title = "PC ALG."
)

display(p)

readline()