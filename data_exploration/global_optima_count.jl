include("../types.jl")
include("../config.jl")

using .ConfigParameters

all_x = [i for i in 0:(2^number_of_features-1)]

distribute = round.(fitness_function.(all_x), digits=3)

global_max_fitness = maximum(distribute)
count_global_optima = count(==(global_max_fitness), distribute)

println("Global optimum fitness value: ", global_max_fitness)
println("Number of global optima: ", count_global_optima)
