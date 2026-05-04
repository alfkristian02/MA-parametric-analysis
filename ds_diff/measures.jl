using Statistics

include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters
using .Utils

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

function run_ds_diagnostic(n_bits::Int, walk_length::Int=2000)
    current_bv = BitVector(rand(Bool, n_bits))
    walk_f = Vector{Float64}(undef, walk_length)
    
    for i in 1:walk_length
        current_dec = binary_to_decimal(current_bv)
        walk_f[i] = fitness_function(current_dec)
        
        neighbors = get_neighborhood(current_bv, 1)
        current_bv = rand(neighbors)
    end
    
    r = autocorrelation(walk_f)
    tau = correlation_length(r)
    
    return r, tau
end

if abspath(PROGRAM_FILE) == @__FILE__
    println("Dataset: ", dataset_filename)
    
    num_samples = 100
    results = [run_ds_diagnostic(number_of_features) for _ in 1:num_samples]
    
    avg_r = mean(x[1] for x in results)
    avg_tau = mean(x[2] for x in results)
    
    println("------------------------------------")
    println("Autocorrelation:   ", round(avg_r, digits=4))
    println("Correlation length: ", round(avg_tau, digits=4))
    println("------------------------------------")
end