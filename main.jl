using CSV
using DataFrames
using Dates
using ProgressMeter

include("types.jl")
include("config.jl")
include("utils/Utils.jl")

using .ConfigParameters
using .Utils

const FITNESS_FUNCTION_ACCESSES = Ref(0)

function fitness_function_wrapper(individual::AbstractVector{Bool})::Float64
    FITNESS_FUNCTION_ACCESSES[] += 1
    return fitness_function(binary_to_decimal(BitVector(individual)))
end

# used when save run is true
const timestamp = Dates.format(now(), "mmddHHMM")
const filename = joinpath(@__DIR__, "runs", dataset_filename*"_"*timestamp*".csv")

# Cartesian product of parameters
parameter_combinations = Iterators.product(population_sizes, number_of_generations, crossover_probabilities, mutation_rates, ls_p_values, ls_max_steps)

println("Starting computation...")
@showprogress desc="Computing..." for combination in parameter_combinations
    best_individual, best_fitness, history, diversity = sga(combination[1], number_of_features, combination[2], fitness_function_wrapper, combination[3], combination[4], save_run, combination[5], combination[6], global_optimum, hill_climbing)

    if save_run
        df = DataFrame(
            # exogenous
            population_size = combination[1],
            number_of_generations = combination[2],
            crossover_probability = combination[3],
            mutation_rate = combination[4],
            ls_p_value = combination[5],
            ls_max_steps = combination[6],
            ds = dataset_filename,

            # endogenous
            ds_diff = "to be determined",
            # ls improvement
            # ga improvement
            best_found = best_fitness,

            # will probably be useful
            fitness_function_accesses = FITNESS_FUNCTION_ACCESSES,
            history = Ref(history)
        )

        CSV.write(filename, df; append=isfile(filename))

        FITNESS_FUNCTION_ACCESSES[] = 0 # reset for next run
    end
end

println("Finished computation!")