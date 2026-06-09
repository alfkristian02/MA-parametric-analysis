include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters, .Utils

all_x = [i for i in 0:(2^number_of_features-1)]

all_fitnesses = fitness_function.(all_x)

GO_value = maximum(all_fitnesses)
GO_count = count(==(GO_value), all_fitnesses)

LO_count = 0

for x in all_x
    current_fitness = all_fitnesses[x+1]

    binary = decimal_to_binary(x, number_of_features)
    neighborhood = get_neighborhood(binary, 1)

    best_fitness = maximum(fitness_function.(binary_to_decimal.(neighborhood)))

    if current_fitness >= best_fitness
        global LO_count += 1
    end
end

println("Number of GOs: ", GO_count)
println("Number of LOs: ", LO_count - GO_count)