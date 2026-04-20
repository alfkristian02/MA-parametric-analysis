using Random
using StatsBase

"""
    Initialize a bit matrix with m rows and n columns.
    All entries are random (1 or 0).
"""
function initialize_bit_matrix(m::Int, n::Int)::BitMatrix
    return Random.bitrand((m, n))
end

"""
    Select n random individuals from the population.

"""
function random_selection(population::BitMatrix, n::Int)::Vector{BitVector}
    indices = rand(1:size(population, 1), n)

    return eachrow(population)[indices]
end

"""
    Roulette wheel selection.
"""
function roulette_wheel_selection(population::BitMatrix, fitness_map::Vector{Float64}, n::Int)::Vector{BitVector}
    probability_proportions = fitness_map ./ sum(fitness_map)

    selected = sample(eachrow(population), Weights(probability_proportions), n)

    return Vector{BitVector}(selected)
end

"""
    Replace randomly selected individuals in the population with the incoming ones.

"""
function random_replacement(population::BitMatrix, incoming_individuals::Vector{BitVector})::BitMatrix
    indices = rand(1:size(population, 1), length(incoming_individuals))

    population[indices, :] = vcat(incoming_individuals...)

    return population
end

"""
    Get the best individual and fitness of the individual among the candidates, given a fitness pool.

"""
function get_best_individual(candidates::BitMatrix, fitness_function)::Tuple{BitVector, Float64}
    fitness, best_index = findmax(map(fitness_function, eachrow(candidates)))

    return candidates[best_index, :], fitness
end

if abspath(PROGRAM_FILE) == @__FILE__        
    test::BitMatrix = BitMatrix([1 0 1 ; 0 0 0])
    vector::BitVector = [1, 1, 1]

    println(PopulationOperators.binary_to_decimal(vector))
end