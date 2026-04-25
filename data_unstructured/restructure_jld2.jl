# i want the files in a different format, so it coincides with the data structure.
# aaaand, new name for the files as well: like heart_13, credit_15, hep_19

# oh fu**, i should prepend them with a .0 so that the fitness function is simplified

include("../types.jl")
using JLD2

ds = load("data_unstructured/precomputed_tables/09-letter-r_dt_matG.jld2")
save_path = "data/letter_16.jld2"

table::Vector{Float64} = ds["single_stored_object"][:, 1]
prepend!(table, .0)
N::Int = log2(length(table))

println(log2(length(table)))

nk = PrecomputedDataset(table, N, 0) # K has no meaning for these datasets


@save save_path nk

println("finished")