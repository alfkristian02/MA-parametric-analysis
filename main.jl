using CSV
using DataFrames
using Dates

include("types.jl")
include("config.jl")
include("utils/Utils.jl")

using .ConfigParameters
using .Utils

function fitness_function_wrapper(individual::AbstractVector{Bool})::Float64
    return fitness_function(binary_to_decimal(BitVector(individual)))
end

# used to save run
const timestamp = Dates.format(now(), "mmddHHMM")
const filename = joinpath(@__DIR__, "runs", "main_" * timestamp * ".csv")

println("Starting computation...")
for i in eachindex(ls_frequencies_p)
    for j in eachindex(ls_depths)
        for _ in 1:1
            best_individual, best_fitness, history, fitness_function_accesses, diversity = sga(population_size, number_of_features, number_of_generations, fitness_function_wrapper, crossover_probability, mutation_rate, save_run, ls_frequencies_p[i], ls_depths[j], global_optimum, hill_climbing)

            if save_run
                df = DataFrame(
                    ls_frequency = ls_frequencies_p[i],
                    ls_depth = ls_depths[j],
                    average_hamming_distance = diversity,
                    fitness_function_accesses = fitness_function_accesses,
                    history = Ref(history)
                )

                CSV.write(filename, df; append=isfile(filename))
            end

        end
    end
end

println("Finished:)")