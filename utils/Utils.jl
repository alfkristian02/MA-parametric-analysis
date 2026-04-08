module Utils

include("crossover.jl")
include("diversity_metrics.jl")
include("local_search.jl")
include("mutation.jl")
include("number_conversion.jl")
include("population.jl")
include("SGA.jl")

export one_point_crossover
export average_hamming_distance
export hamming_neighborhood_search, SLS, get_neighborhood, hill_climbing
export bit_flip_mutation
export binary_to_decimal, decimal_to_binary
export initialize_bit_matrix, random_selection, random_replacement, get_best_individual, roulette_wheel_selection
export sga

end