"""
    Implementation of the Simple Genetic Algorithm (SGA)
    
    The only alternation to the original one, is that there is an optional parameter (local_search)
    used to perform local search if present.
"""
function sga(population_size::Int, number_of_features::Int, number_of_generations::Int, fitness_function::Function, crossover_probability::Float64, mutation_probability::Float64, save_run::Bool, ls_frequency::Float64, ls_depth::Int, global_optima, local_search=nothing)
    population::BitMatrix = initialize_bit_matrix(population_size, number_of_features)

    current_best::Union{Nothing, Tuple{BitVector, Float64}} = nothing
    
    best_per_generation = save_run ? Float64[] : nothing
    
    for _ = 1:number_of_generations

        # ------------ update things
        fitness_map = map(fitness_function, eachrow(population))
        val, idx = findmax(fitness_map)
        best_individual = (population[idx, :], val)
        if isnothing(current_best) || best_individual[2] > current_best[2]
            current_best = best_individual
        end
        if save_run
            push!(best_per_generation, best_individual[2])
        end
        if best_individual[2] == global_optima
            # print("\nYay, found the global optimum\n")
            break
        end
        # ------------ end update things

        parents::Vector{BitVector} = roulette_wheel_selection(population, fitness_map, size(population, 1))
        shuffle!(parents) # in-place shuffle

        offspring::Vector{BitVector} = one_point_crossover(parents, crossover_probability)

        mutations::Vector{BitVector} = bit_flip_mutation(offspring, mutation_probability) 
        
        if local_search !== nothing && ls_depth !== nothing
            if rand() < ls_frequency 
                for i in eachindex(mutations)
                    mutations[i] = local_search(mutations[i], fitness_function, ls_depth)
                end
            end
        end

        population = reshape(reduce(vcat, mutations), population_size, number_of_features)
    end

    return current_best..., best_per_generation, average_hamming_distance([BitVector(population[i, :]) for i in 1:size(population, 1)])
end