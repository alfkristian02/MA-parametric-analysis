include("../types.jl")
include("../config.jl")

using .ConfigParameters
using Plots

gr() # plotting backend

x = [i for i in 0:(2^number_of_features-1)]
y = fitness_function.(x)

display(plot(x, y))

readline() # to make the plot stay open