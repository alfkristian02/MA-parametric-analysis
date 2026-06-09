module ConfigParameters
    export ruggedness_k, global_optimum_decimal, dataset_filename, number_of_features, fitness_function, global_optimum, save_run
    export population_sizes, number_of_generations, crossover_probabilities, mutation_rates, ls_p_values, ls_max_steps

    using JLD2

    # ------------- set by user -------------
    save_run::Bool = 1
    
    # heart_13 || zoo_16 || hep_19
    # nk_19_10 || nk_20_16 || nk_21_4
    const dataset_filename = "heart_13"

    # ------------- static -------------
    const dataset_path::String = joinpath(@__DIR__, "data/",   dataset_filename*".jld2")
    @load dataset_path nk # nk, since nk sets were saved first.
    const base_fitness = nk.table
    const number_of_features = nk.N
    const ruggedness_k = nk.K

    const EPSILON::Float64 = .001
    function fitness_function(individual_decimal::Int)::Float64
        return base_fitness[individual_decimal + 1] - EPSILON * count_ones(individual_decimal) # +1 to adjust for 1-indexing
    end

    const global_optimum::Float64, global_optimum_decimal = findmax(fitness_function, 0:(2^number_of_features - 1))

    # ------------- varying variables -------------
    # # --- dataset selection criteria ---
    # # runtime
    # population_sizes::Vector{Int} = [250] 
    # number_of_generations::Vector{Int} = [1000]
    # # ga
    # crossover_probabilities::Vector{Float64} = [.5]
    # mutation_rates::Vector{Float64} = [.05]
    # # ls
    # ls_p_values::Vector{Float64} = [.25]
    # ls_max_steps::Vector{Int} = [3]

    # # --- reduced sets for including diversity metric ---
    # # runtime
    # population_sizes::Vector{Int} = [250, 500, 1000] 
    # number_of_generations::Vector{Int} = [1000, 1500, 3000]
    # # ga
    # crossover_probabilities::Vector{Float64} = [.0, .5, 1.]
    # mutation_rates::Vector{Float64} = [.0, .01, .05, .1, .2]
    # # ls
    # ls_p_values::Vector{Float64} = [.0, .25, .5, .75, 1.]
    # ls_max_steps::Vector{Int} = [1, 3, 5]

    # --- The params used in thesis ---
    # runtime
    population_sizes::Vector{Int} = [250, 500, 750, 1000] 
    number_of_generations::Vector{Int} = [1000, 2000, 4000]
    # ga
    crossover_probabilities::Vector{Float64} = [.0, .25, .5, .75, 1.]
    mutation_rates::Vector{Float64} = [.0, .01, .05, .1, .2]
    # ls
    ls_p_values::Vector{Float64} = [.0, .01, .25, .5, .75, 1.]
    ls_max_steps::Vector{Int} = [1, 2, 3, 5, 10]
end
