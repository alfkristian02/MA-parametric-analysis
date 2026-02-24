using CSV
using DataFrames
using Dates

include("config.jl")
include("data/get_fitness_pool.jl")
include("utils/Utils.jl")

using .ConfigParameters: dataset_file_name, fitness_function, population_size, number_of_generations, mutation_rate, local_search_frequencies, local_search_depths, save_run, crossover_probability, sls_p
using .GetFitnessPool: get_precomputed_fitness_pool
using .Utils

const base_fitness::Vector{Float64} = get_precomputed_fitness_pool(joinpath(@__DIR__, "data/precomputed_tables/", dataset_file_name))

function fitness_function_wrapper(individual_binary::AbstractVector{Bool})::Float64
    individual_copy::BitVector = BitVector(individual_binary)
    return fitness_function(base_fitness, individual_copy, binary_to_decimal(individual_copy))
end

const number_of_features::Int = log2(1+length(base_fitness))
const global_optima::Float64 = fitness_function_wrapper(decimal_to_binary(findmax(base_fitness)[2], number_of_features))

const timestamp = Dates.format(now(), "mmddHHMM")
const filename = joinpath(@__DIR__, "runs", "main_" * dataset_file_name * "_" * timestamp * ".csv")

println("Starting computation...")
for i in eachindex(local_search_frequencies)
    for j in eachindex(local_search_depths)
        for _ in 1:100
            best_individual, best_fitness, history, fitness_function_accesses, diversity = sga(population_size, number_of_features, number_of_generations, fitness_function_wrapper, crossover_probability, mutation_rate, save_run, local_search_frequencies[i], local_search_depths[j], sls_p, global_optima, SLS)

            if save_run
                df = DataFrame(
                    local_search_frequency = local_search_frequencies[i],
                    local_search_depth = local_search_depths[j],
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