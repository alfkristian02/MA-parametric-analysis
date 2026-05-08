using Statistics, DataFrames, CSV 

include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters
using .Utils

const global_opt_bv = decimal_to_binary(global_optimum_decimal, number_of_features)

function autocorrelation(f::Vector{Float64})
    n = length(f)
    f_bar = mean(f)
    variance = var(f)
    
    if variance == 0
        return 1.0 
    end
    
    autocovariance = 0.0

    for i in 1:(n - 1)
        autocovariance += (f[i] - f_bar) * (f[i+1] - f_bar)
    end

    autocovariance /= (n - 1)
    
    return autocovariance / variance
end

function correlation_length(R::Float64)
    if R <= 0 return .0 end

    return -1 / log(abs(R))
end

"""
    Information Hardness (k) - Technique 18
    Calculates the probability that a fitness increase is deceptive 
    (i.e., moves away from or stays same distance to the global optimum).
"""
function information_hardness(walk_f::Vector{Float64}, walk_bvs::Vector{BitVector}, target_bv::BitVector)
    upward_steps = 0
    deceptive_steps = 0
    n = length(walk_f)
    
    for i in 1:(n - 1)
        # We only care about steps where fitness improves
        if walk_f[i+1] > walk_f[i]
            upward_steps += 1
            
            # Hamming distance to the known global optimum
            dist_curr = sum(walk_bvs[i] .!= target_bv)
            dist_next = sum(walk_bvs[i+1] .!= target_bv)
            
            # If fitness increased but distance didn't decrease, it's deceptive
            if dist_next >= dist_curr
                deceptive_steps += 1
            end
        end
    end
    
    return upward_steps == 0 ? 0.0 : deceptive_steps / upward_steps
end

function run_ds_diagnostic(n_bits::Int, walk_length::Int=2000)
    current_bv = BitVector(rand(Bool, n_bits))
    
    # We now store both fitness and the vectors
    walk_f = Vector{Float64}(undef, walk_length)
    walk_bvs = Vector{BitVector}(undef, walk_length)
    
    for i in 1:walk_length
        current_dec = binary_to_decimal(current_bv)
        walk_f[i] = fitness_function(current_dec)
        walk_bvs[i] = copy(current_bv) # Important: store a copy
        
        neighbors = get_neighborhood(current_bv, 1)
        current_bv = rand(neighbors)
    end
    
    r = autocorrelation(walk_f)
    tau = correlation_length(r)
    k = information_hardness(walk_f, walk_bvs, global_opt_bv)
    
    return r, tau, k
end

if abspath(PROGRAM_FILE) == @__FILE__
    println("Dataset: ", dataset_filename)
    
    num_samples = 100
    results = [run_ds_diagnostic(number_of_features) for _ in 1:num_samples]
    
    avg_r = mean(x[1] for x in results)
    avg_tau = mean(x[2] for x in results)
    avg_k = mean(x[3] for x in results)

    tau_norm = avg_tau / number_of_features
    
    println("------------------------------------")
    println("Autocorrelation:          ", round(avg_r, digits=4))
    println("Correlation length:       ", round(avg_tau, digits=4))
    println("Normalized corr length:   ", round(tau_norm, digits=4))
    println("Information hardness:     ", round(avg_k, digits=4))
    println("------------------------------------")

    file = "runs/"*dataset_filename*".csv"
    output = "runs/"*dataset_filename*".csv"

    df = CSV.read(file, DataFrame)

    df[!, :ds_ls_diff] .= avg_r
    df[!, :ds_ga_diff] .= avg_k
    df[!, :tau_norm] .= tau_norm

    CSV.write(output, df)
end