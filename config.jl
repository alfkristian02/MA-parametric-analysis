module ConfigParameters
    export number_of_features, fitness_function, global_optimum, population_size, number_of_generations, mutation_rate, ls_frequencies_p, ls_depths, save_run, crossover_probability
    
    using JLD2

    # heart_13.jld2 || credit_15.jld2 || hep_19.jld2
    # nk_K3.jld2 || nk_K13.jld2 || nk_K22.jld2
    const dataset_filename = "heart_13.jld2"
    const dataset_path::String = joinpath(@__DIR__, "data/",   dataset_filename)

    @load dataset_path nk # the name nk is just cause I generated the NK datasets first and had that name
    const base_fitness = nk.table
    const number_of_features = nk.N

    const EPSILON::Float64 = 0.001

    function fitness_function(individual_decimal::Int)::Float64
        return base_fitness[individual_decimal + 1] - EPSILON * count_ones(individual_decimal) # adjust for 1-indexing
    end

    const global_optimum::Float64 = maximum(fitness_function(i) for i in 0:(2^number_of_features - 1))


    ls_frequencies_p::Vector{Float64} = [1.0]
    ls_depths::Vector{Int} = [2]
    
    population_size::Int = 250
    number_of_generations::Int = 5 # Maybe number of fitness evaluations is a better alternative. It is what the analysis will use.
    crossover_probability::Float64 = 0.10
    mutation_rate::Float64 = 0.05

    save_run::Bool = 0

end
