include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters
using .Utils
using Plots

gr()

vals = [i for i in 0:(2^number_of_features-1)]
bitstrings = decimal_to_binary.(vals, fill(number_of_features, 2^number_of_features))

x = [binary_to_decimal.(bitstrings[i][1:Int(ceil(number_of_features/2))] for i in eachindex(bitstrings))]
y = [binary_to_decimal.(bitstrings[i][(Int(ceil(number_of_features/2))+1):number_of_features] for i in eachindex(bitstrings))]

xlims!(0, Int(ceil(number_of_features/2)))
ylims!(0, Int(ceil(number_of_features/2))+1)

display(scatter(x, y; markersize=3))
readline()

# scatter with ring etc for global vs. local plot. but still for 19 features, 2^10 = 
