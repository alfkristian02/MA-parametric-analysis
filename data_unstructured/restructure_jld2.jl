# i want the files in a different format, so it coincides with the data structure.
# aaaand, new name for the files as well: like heart_13, credit_15, hep_19

# oh fu**, i should prepend them with a .0 so that the fitness function is simplified

include("../types.jl")
using JLD2

ds = load("data_unstructured/precomputed_tables/10-hepatitis_dt_matG.jld2")
N::Int = 19

table::Vector{Float64} = ds["single_stored_object"][:, 1]

prepend!(table, .0)

println(log2(length(table)))

nk = PrecomputedDataset(table, N, 0)

path = "data/hep_19.jld2"

@save path nk

println("finished")