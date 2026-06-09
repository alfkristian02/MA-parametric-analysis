using Statistics, DataFrames, CSV 

include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters, .Utils

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
    
    return r
end

num_samples = 1000
results = [run_ds_diagnostic(number_of_features) for _ in 1:num_samples]

avg_r = mean(x[1] for x in results)

println("Dataset: ", dataset_filename)
println("Autocorrelation: ", avg_r)

file = "runs/nk_21_4.csv"

df = CSV.read(file, DataFrame)

df.Autocorrelation .= avg_r

file2 = "runs/nk_21_4.csv"

CSV.write(file2, df)