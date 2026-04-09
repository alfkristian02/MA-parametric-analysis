"""
    Implementation of the Simple Genetic Algorithm (SGA)
    
    The only alternation to the original one, is that there is an optional parameter (local_search)
    used to perform local search if present.
"""
function sga(population_size::Int, number_of_features::Int, number_of_generations::Int, fitness_function::Function, crossover_probability::Float64, mutation_probability::Float64, save_run::Bool, ls_frequency::Float64, ls_depth::Int, global_optima, local_search=nothing)
    population::BitMatrix = initialize_bit_matrix(population_size, number_of_features)
    global_best_individual = get_best_individual(population, fitness_function)
    fitness_function_accesses::Int = 0

    best_per_generation = save_run ? Float64[] : nothing

    if save_run
        push!(best_per_generation, global_best_individual[2])
    end

    for _ = 1:number_of_generations
        parents::Vector{BitVector} = roulette_wheel_selection(population, fitness_function, size(population, 1))
        shuffle!(parents) # in-place shuffle

        fitness_function_accesses += population_size

        offspring::Vector{BitVector} = one_point_crossover(parents, crossover_probability)

        mutations::Vector{BitVector} = bit_flip_mutation(offspring, mutation_probability) 
        
        if local_search !== nothing && ls_frequency !== 0.0 && ls_depth !== nothing
            if rand() < ls_frequency 
                for i in eachindex(mutations)
                    mutations[i] = local_search([mutations[i]], fitness_function, ls_depth)[1]
                    # TODO: handle the fitness function access count.
                end
            end
        end

        population = reshape(reduce(vcat, mutations), population_size, number_of_features)

        best_individual = get_best_individual(population, fitness_function)
        fitness_function_accesses += population_size
        
        if best_individual[2] > global_best_individual[2]
            global_best_individual = best_individual
        end

        if save_run
            push!(best_per_generation, best_individual[2])
        end

        if best_individual[2] == global_optima
            println("Yay, found the global optimum")
            break
        end
    end

    return global_best_individual..., best_per_generation, fitness_function_accesses, average_hamming_distance([BitVector(population[i, :]) for i in 1:size(population, 1)])
end