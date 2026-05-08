include("types.jl")
include("config.jl")
include("utils/Utils.jl")

using .ConfigParameters, .Utils
using CSV, DataFrames, Dates, ProgressMeter

const FITNESS_FUNCTION_ACCESSES = Ref(0)

function fitness_function_wrapper(individual::AbstractVector{Bool}, log_access::Bool)::Float64
    if log_access
        FITNESS_FUNCTION_ACCESSES[] += 1
    end
    return fitness_function(binary_to_decimal(BitVector(individual)))
end

# used when save run is true
const timestamp = Dates.format(now(), "mmddHHMM")
const filename = joinpath(@__DIR__, "runs", dataset_filename*"_"*timestamp*".csv")

# Cartesian product of parameters
parameter_combinations = Iterators.product(population_sizes, number_of_generations, crossover_probabilities, mutation_rates, ls_p_values, ls_max_steps)

println("Starting computation...")
@showprogress desc="Computing..." for combination in parameter_combinations
    best_individual, best_fitness, generations, ga_improvement, ls_improvement = sga(combination[1], number_of_features, combination[2], fitness_function_wrapper, combination[3], combination[4], save_run, combination[5], combination[6], global_optimum, hill_climbing)

    if save_run
        df = DataFrame(
            Dataset = dataset_filename,
            PopulationSize = combination[1],
            MaxGenerations = combination[2],
            CrossoverProbability = combination[3],
            MutationRate = combination[4],
            LSProbability = combination[5],
            LSMaxSteps = combination[6],

            ActualGenerations = generations,
            TotalGAImprovement = ga_improvement,
            TotalLSImprovement = ls_improvement,
            BestFound = best_fitness,
            FitnessFunctionEvaluations = FITNESS_FUNCTION_ACCESSES
        )

        CSV.write(filename, df; append=isfile(filename))

        FITNESS_FUNCTION_ACCESSES[] = 0 # reset for next run
    end
end

println("Finished computation!")