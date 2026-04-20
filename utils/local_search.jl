"""
    Returns all index combinations, requiring bit flips, to represent the neighborhood with hamming distance equal to h.
"""
function combinations(n::Int, h::Int)::Vector{Vector{Int}}
    if h==0 return [[]] end
    if h > n return [] end

    result::Vector{Vector{Int}} = []

    for i in 1:(n-h+1)
        for tail in combinations(n-i, h-1)
            push!(result, [i; map(x -> x + i, tail)])
        end
    end

    return result
end

"""
    Get the neighbors of individual with hamming distance lower than, or equal to, depth.
"""
function get_neighborhood(individual::BitVector, depth::Int=1)::Vector{BitVector}
    n::Int = length(individual)
    neighbors::Vector{BitVector} = []

    indices::Vector{Vector{Int}} = []

    for h in 1:depth
        append!(indices, combinations(n, h))
    end
    
    for combination in indices
        c::BitVector = copy(individual)
        for index in combination 
            c[index] = !c[index]
        end
        push!(neighbors, c)
    end

    return neighbors
end

"""
    Find the best individual in each children’s neighborhood of hamming distance lower than, or equal to, depth. 
"""
function hamming_neighborhood_search(children::Vector{BitVector}, fitness_function::Function, depth::Int)::Vector{BitVector}
    best_children = Vector{BitVector}(undef, length(children))

    for i in eachindex(children)
        candidates = get_neighborhood(children[i], depth)
        push!(candidates, children[i])

        best_index = argmax(map(fitness_function, candidates))

        best_children[i] = candidates[best_index]
    end
    
    return best_children
end

"""
    SLS
"""
function SLS(individuals::Vector{BitVector}, fitness_function::Function, depth::Int, p::Float64)
    final_individuals = Vector{BitVector}(undef, length(individuals))
    
    for i in eachindex(individuals)
        current_individual = individuals[i]
        temp_depth = 1

        while temp_depth <= depth
            candidates = get_neighborhood(current_individual)

            if rand() < p # Go to random neighbor
                current_individual = rand(candidates)
            else
                pool = [candidates..., current_individual]
                current_individual = pool[argmax(fitness_function.(pool))]
            end

            temp_depth += 1
        end

        final_individuals[i] = current_individual
    end

    return final_individuals
end

function hill_climbing(individual::BitVector, fitness_function::Function, max_steps::Int)
    best_found = individual

    steps_taken = 0

    while steps_taken < max_steps
        candidates = get_neighborhood(best_found)
        pool = [best_found, candidates...]

        new_individual = pool[argmax(fitness_function.(pool, trues(length(pool))))]

        if new_individual == best_found # no improvement can be made
            break
        end

        best_found = new_individual

        steps_taken += 1
    end

    return best_found
end

if abspath(PROGRAM_FILE) == @__FILE__
    # fitnesses::Vector{Float64}=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
    # test::Tuple{BitVector, BitVector} = ([1, 1, 1], [1, 0, 0])
    # print(LocalSearch.hamming_one_neighborhood_search(test, fitnesses))
    
    print(LocalSearch.combinations(3, 2))
    print(LocalSearch.get_neighborhood(BitVector([0,0,0,0,0]),3))
end