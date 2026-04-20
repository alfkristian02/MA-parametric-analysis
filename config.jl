module ConfigParameters
    export dataset_filename, number_of_features, fitness_function, global_optimum, save_run
    export population_sizes, number_of_generations, crossover_probabilities, mutation_rates, ls_p_values, ls_max_steps
    
    using JLD2

    # heart_13 || credit_15 || hep_19 || nk_K3 || nk_K13 || nk_K22
    const dataset_filename = "heart_13"
    const dataset_path::String = joinpath(@__DIR__, "data/",   dataset_filename*".jld2")

    @load dataset_path nk # the name nk is just cause I generated the NK datasets first, so the name is set in code. Arguably more solid than stone.
    const base_fitness = nk.table
    const number_of_features = nk.N

    const EPSILON::Float64 = .001

    function fitness_function(individual_decimal::Int)::Float64
        return base_fitness[individual_decimal + 1] - EPSILON * count_ones(individual_decimal) # +1 to adjust for 1-indexing
    end

    const global_optimum::Float64 = maximum(fitness_function, 0:(2^number_of_features - 1))

    save_run::Bool = 1

    # ------------- varying variables -------------
    population_sizes::Vector{Int} = [10, 20] 
    number_of_generations::Vector{Int} = [10, 20]
    crossover_probabilities::Vector{Float64} = [.0, 0.1]
    mutation_rates::Vector{Float64} = [.0, 0.1]

    ls_p_values::Vector{Float64} = [.0, 1.]
    ls_max_steps::Vector{Int} = [0, 1]
end
