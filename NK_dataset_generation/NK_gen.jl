using StatsBase
using Random

Random.seed!(42) # for reproducibility

N::Int64 = 5 #number of features
K::Int64 = 2 #number of neighborhood


random_neighborhood = Dict{Int, Vector{Int}}()
fitness_component_tables = Dict{Int, Vector{Float64}}()

for i = 1:N
    options = setdiff(1:N, [i]) #create the set of options
    neighbors = sample(options, K; replace=false) # select the neighborhood, no duplicates

    random_neighborhood[i] = neighbors;

    # fill the fitness component tables here as well
    fitness_component_tables[i] = rand(2^(K+1))
end

function binary_to_decimal(bit_vector)
    return sum(bit_vector .* 2 .^(length(bit_vector) .- eachindex(bit_vector))) + 1 # need to correct for Julia's 1-indexing
end

function fitness_function(x::BitVector)
    
    running_sum = 0

    for (key, value) in random_neighborhood
        running_sum += fitness_component_tables[key][binary_to_decimal(x[[key, value...]])]
    end

    return 1/N * running_sum
end

println(fitness_function(BitVector([1, 1, 1, 1, 1])))

# now, next step is to go over all bitstrings, run the fitness function, and then save it to a table that can be used as precomputed. coolcool