using DataFrames, CSV
include("../types.jl")
include("../config.jl")
using .ConfigParameters

# Normalize the best_found for each dataset.
x = [i for i in 0:(2^number_of_features-1)]
y = fitness_function.(x)
min = minimum(y)
max = maximum(y)

# println(min, "-------", max)

# add bf_normalized, set it to (best_found - min)/(max - min)
file = joinpath("runs", dataset_filename*".csv")

df = CSV.read(file, DataFrame)

df.normalized_best_found .= (df.best_found .- min) ./ (max .-min)
df.K .= ruggedness_k
df.N .= number_of_features

CSV.write(file, df)

println("Finished normalization")