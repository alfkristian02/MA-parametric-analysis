include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters
using .Utils

all_x = [i for i in 0:(2^number_of_features-1)]

count_optima::Int = 0

for x in all_x
    current_fitness = round(fitness_function(x), digits=3)

    binary = decimal_to_binary(x, number_of_features)
    neighborhood = get_neighborhood(binary, 1)

    best_fitness = maximum(round.(fitness_function.(binary_to_decimal.(neighborhood)), digits=3))

    if current_fitness >= best_fitness
        global count_optima += 1
    end
end

println("Number of local optima: ", count_optima)