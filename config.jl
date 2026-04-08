module ConfigParameters
    export dataset_file_name, fitness_function, population_size, number_of_generations, mutation_rate, local_search_frequencies, local_search_depths, save_run, crossover_probability, sls_p
    
    # 05-heart-c_dt_mat-1.jld2 || 07-credit-a_dt_matG.jld2 || 10-hepatitis_dt_matG.jld2
    const dataset_file_name::String = "05-heart-c_dt_mat-1.jld2" 
    
    const EPSILON::Float64 = 0.001

    function fitness_function(base_fitness_vector::Vector{Float64}, individual_binary::BitVector, individual_decimal::Int)::Float64
        if individual_decimal == 0
            return .0
        end
        return base_fitness_vector[individual_decimal] - EPSILON * sum(individual_binary)
    end

    local_search_frequencies::Vector{Float64} = [.0, 1.0]
    local_search_depths::Vector{Int} = [2]
    ls_p::Float64 = 0.1 # make hill climbing with a probability of executing

    # could add initialization variable. and implement one thats a bit more deterministic. better stability. e.g evenly distributed in the search space.
    population_size::Int = 250
    number_of_generations::Int = 5 # Maybe number of fitness evaluations is a better alternative. It is what the analysis will use.
    crossover_probability::Float64 = 0.25
    mutation_rate::Float64 = 0.05

    save_run::Bool = 0

end
