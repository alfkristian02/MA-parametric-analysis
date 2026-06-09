include("../types.jl")
include("../config.jl")

using DataFrames, CSV, .ConfigParameters

x = [i for i in 0:(2^number_of_features-1)]
y = fitness_function.(x)
min = minimum(y)
max = maximum(y)

input_file = "backup/nk_19_16"
output_file = "backup/nk_19_16"

df = CSV.read("runs/"*input_file*".csv", DataFrame)

df.NormalizedBestFound .= (df.BestFound .- min) ./ (max .- min)

df.GAImprovement .= df.TotalGAImprovement ./ (df.PopulationSize .* df.ActualGenerations)
df.LSImprovement .= df.TotalLSImprovement ./ (df.PopulationSize .* df.ActualGenerations)
# df.HDDiversity .= df.TotalHDDiversity ./ (df.PopulationSize .* df.ActualGenerations)

df.NumberOfFeatures .= number_of_features
df.NumberOfLOs .= 18912


CSV.write("runs/"*output_file*".csv", df)