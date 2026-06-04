include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters, .Utils
using CSV, DataFrames, Dates, ProgressMeter


function fitness_function_wrapper(individual::AbstractVector{Bool}, log_access::Bool)::Float64
    return fitness_function(binary_to_decimal(BitVector(individual)))
end


const timestamp = Dates.format(now(), "mmddHHMM")
const filename  = joinpath(@__DIR__, "runs", dataset_filename * "_criterion_" * timestamp * ".csv")


# easier to just do it the same way. but there is just one combination
parameter_combinations = Iterators.product(
    population_sizes,
    number_of_generations,
    crossover_probabilities,
    mutation_rates,
    ls_p_values,
    ls_max_steps,
)


println("Starting computation...")

results = DataFrame(
    Dataset = String[],
    Run = Int[],
    Runtime = Float64[],
    GOReached = Bool[],
)

for combination in parameter_combinations
    @showprogress desc="Computing..." for run in 1:100
        start_time = time()

        _, best_fitness, _, _, _, _ = sga(combination[1], number_of_features, combination[2], fitness_function_wrapper, combination[3], combination[4], save_run, combination[5], combination[6], global_optimum, hill_climbing)

        runtime = time() - start_time
        go_reached = best_fitness >= global_optimum

        push!(results, (dataset_filename, run, runtime, go_reached))
    end
end

CSV.write(filename, results)

println("Finished computation!")
println("Results saved to: ", filename)
println("GO reached: $(sum(results.GOReached))/$(100) times")
println("Average runtime: $(round(sum(results.Runtime) / 100, digits=3)) seconds")