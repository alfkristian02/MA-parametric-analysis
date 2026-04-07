using StatsBase
using Random

Random.seed!(42) # 42 is always the answer

N::Int64 = 25 #number of features
K::Int64 = 24 #size of neighborhood


interaction_sets = Dict{Int, Vector{Int}}()
fitness_component_tables = Dict{Int, Vector{Float64}}()

for i = 1:N
    options = setdiff(1:N, [i]) #create the set of options
    neighbors = sample(options, K; replace=false) # select the neighborhood, no duplicates

    interaction_sets[i] = [i; sort(neighbors)] # consistent ordering

    # fill the fitness component tables here as well
    fitness_component_tables[i] = rand(2^(K+1))
end

function binary_to_decimal(bit_vector)
    return sum(bit_vector .* 2 .^(length(bit_vector) .- eachindex(bit_vector))) + 1 # need to correct for Julia's 1-indexing
end

function fitness_function(x::BitVector, interaction_sets, tables, N)
    
    running_sum = .0

    for i in 1:N
        idx = interaction_sets[i] # is ordered
        running_sum += tables[i][binary_to_decimal(x[idx])]
    end

    return 1/N * running_sum
end

function decimal_to_binary(decimal::Int, length::Int)
    return BitVector(((decimal >> (length - i)) & 1) == 1 for i in 1:length)
end

res = Vector{Float64}(undef, 2^N)

for i = 0:(2^N-1)
    res[i+1] = fitness_function(decimal_to_binary(i, N), interaction_sets, fitness_component_tables, N)
end

# sanity checks
# println(res)
# println(minimum(res))
# println(maximum(res))
# println(length(res) == 2^N)
# println(mean(res))

struct NKLandscape
    table::Vector{Float64}
    N::Int
    K::Int
end

nk = NKLandscape(res, N, K)

using JLD2
path = "NK_dataset_generation/precomputed_synthetic/nk_K$(K).jld2"
@save path nk

# @load path nk

# print(nk)
