using DataFrames, StatsBase, CSV, Plots

# might want to make a type for this

# gather data
files::Vector{String} = ["nk_K16.csv", "nk_K2.csv", "nk_K9.csv", "heart_13.csv", "letter_16.csv", "hep_19.csv"]
included_columns::Vector{String} = ["population_size", "number_of_generations", "crossover_probability", "mutation_rate", "ls_p_value", "ls_max_steps", "avg_ga_improvement", "avg_ls_improvement", "best_found", "fitness_function_accesses", "ds_diff"]

load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]

combined = reduce(vcat, load_data, cols=:union)

# print(nrow(combined))

# one hot encode dataset
# for ds in unique(combined.ds)
#     combined[!, Symbol(ds)] = [x==ds ? 1 : 0 for x in combined.ds]
# end

# numeric_df = select(combined, Not(:ds))

# handle NaN values (from when the pops are initialised with the best solution)
cols_to_fix = [:avg_ga_improvement, :avg_ls_improvement] 

for col in cols_to_fix
    # replace!() modifies the column in-place
    replace!(combined[!, col], NaN => 0.0)
end

# for all pairs of variables compute pearson correlation coefficients
correlation_matrix = cor(Matrix(combined))

# print it in some format
# print(correlation_matrix)

labels = names(combined)

display(heatmap(
    labels,
    labels,
    correlation_matrix,
    xrotation = 45,
    size =(900, 800),
))

readline()