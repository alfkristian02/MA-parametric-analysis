using CSV, DataFrames

file = "nk_21_4"

df = CSV.read("runs/"*file*".csv", DataFrame)

# 1. find maximum in column "BestFound"
max_val = maximum(df.BestFound)

#  2. count occurrences of the maximum in column BestFound
max_count = count(==(max_val), df.BestFound)

println("Maximum: ", max_val)
println("Count: ", max_count)