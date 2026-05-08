"""
    Implementation of the Simple Genetic Algorithm (SGA)
    
    The only alternation to the original one, is that there is an optional parameter (local_search)
    used to perform local search if present.
"""
function sga(population_size::Int, number_of_features::Int, number_of_generations::Int, fitness_function::Function, crossover_probability::Float64, mutation_probability::Float64, save_run::Bool, ls_frequency::Float64, ls_depth::Int, global_optima, local_search=nothing)
    population::BitMatrix = initialize_bit_matrix(population_size, number_of_features)

    current_best::Union{Nothing, Tuple{BitVector, Float64}} = nothing
    
    # best_per_generation = save_run ? Float64[] : nothing

    total_ga_improvement::Float64 = .0
    total_ls_improvement::Float64 = .0
    
    last_generation = 0
    for i = 1:number_of_generations
        # ------------ update things
        last_generation += 1
        fitness_map = map(fitness_function, eachrow(population), trues(size(population, 1))) # trues to count fitness evals
        val, idx = findmax(fitness_map)
        best_individual = (population[idx, :], val)
        if isnothing(current_best) || best_individual[2] > current_best[2]
            current_best = best_individual
        end
        # if save_run
        #     push!(best_per_generation, best_individual[2])
        # end
        if best_individual[2] == global_optima
            # print("\nGlobal optimum reached\n")
            break
        end



        parents::Vector{BitVector} = roulette_wheel_selection(population, fitness_map, size(population, 1))
        shuffle!(parents) # in-place shuffle

        offspring::Vector{BitVector} = one_point_crossover(parents, crossover_probability)

        mutations::Vector{BitVector} = bit_flip_mutation(offspring, mutation_probability) 

        # log ga improvement
        mutations_map = map(fitness_function, mutations, falses(length(mutations))) # falses to not count fitness evals
        total_ga_improvement += (sum(mutations_map) - sum(fitness_map))
        
        if local_search !== nothing && ls_depth !== nothing && ls_frequency > .0 && ls_depth > 0
            for i in eachindex(mutations)
                if rand() < ls_frequency 
                    mutations[i] = local_search(mutations[i], fitness_function, ls_depth)
                end
            end

            # log ls improvement
            ls_map = map(fitness_function, mutations, falses(length(mutations))) # falses to not register fitness evals
            total_ls_improvement += (sum(ls_map) - sum(mutations_map))
        end

        population = reshape(reduce(vcat, mutations), population_size, number_of_features)
    end

    return current_best[1], current_best[2], last_generation, total_ga_improvement, total_ls_improvement
end