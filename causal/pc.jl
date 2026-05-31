using DataFrames, CSV, CausalInference, GraphPlot, Compose, Graphs

# files::Vector{String} = ["nk_16_9.csv", "nk_18_3.csv", "nk_19_16.csv"]
# dotname = "pc_syn"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv"]
# dotname = "pc_nat"
files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv", "nk_16_9.csv", "nk_18_3.csv", "nk_19_16.csv"]
dotname = "pc_com"
included_columns::Vector{String} = ["NormalizedBestFound","CrossoverProbability","MutationRate","LSProbability","LSMaxSteps", "GAImprovement", "LSImprovement", "PopulationSize", "MaxGenerations", "Autocorrelation", "NumberOfFeatures", "NumberOfLOs"]

load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]
combined = reduce(vcat, load_data, cols=:union)

accuracy = .005
pc = pcalg(combined, accuracy, gausscitest)

input_nodes = [
    findfirst(==("CrossoverProbability"), names(combined)),
    findfirst(==("MutationRate"), names(combined)),
    findfirst(==("LSProbability"), names(combined)),
    findfirst(==("LSMaxSteps"), names(combined)),
    findfirst(==("PopulationSize"), names(combined)),
    findfirst(==("MaxGenerations"), names(combined)),
    findfirst(==("Autocorrelation"), names(combined)),
    findfirst(==("NumberOfFeatures"), names(combined)),
    findfirst(==("NumberOfLOs"), names(combined)),
]

for v in input_nodes
    for u in 1:nv(pc)
        if has_edge(pc, u, v)
            rem_edge!(pc, u, v)
            add_edge!(pc, v, u)
        end
    end
end

dataset_nodes = [
    findfirst(==("Autocorrelation"), names(combined)),
    findfirst(==("NumberOfFeatures"), names(combined)),
    findfirst(==("NumberOfLOs"), names(combined)),
]

for i in dataset_nodes
    for j in dataset_nodes
        if i != j && has_edge(pc, i, j)
            rem_edge!(pc, i, j)
        end
    end
end

node_names = names(combined)
undirected_nodes = Set(["NormalizedBestFound"])

println(files)
println(accuracy)

open(joinpath("causal", "pc_res", dotname*".dot"), "w") do io
    println(io, "digraph {")
    println(io, "  rankdir=TB;")
    println(io, "  bgcolor=white;")
    println(io, "  node [shape=ellipse fontsize=20 fontname=\"Helvetica\" style=filled fillcolor=\"#ddeeff\" color=\"#336699\" penwidth=1.5 margin=0.1];")
    println(io, "  edge [penwidth=1.5 arrowsize=1.0];")

    println(io, "  subgraph cluster_dataset {")
    println(io, "    label=\"Dataset descriptor\"; style=dashed; color=\"#aaaaaa\"; fontsize=25")
    println(io, "    \"Autocorrelation\"; \"NumberOfFeatures\"; \"NumberOfLOs\";")
    println(io, "  }")

    println(io, "  subgraph cluster_ga {")
    println(io, "    label=\"GA Params\"; style=dashed; color=\"#aaaaaa\"; fontsize=25")
    println(io, "    \"CrossoverProbability\"; \"MutationRate\";")
    println(io, "  }")

    println(io, "  subgraph cluster_ls {")
    println(io, "    label=\"LS Params\"; style=dashed; color=\"#aaaaaa\"; fontsize=25")
    println(io, "    \"LSProbability\"; \"LSMaxSteps\";")
    println(io, "  }")

    println(io, "  subgraph cluster_general {")
    println(io, "    label=\"General Params\"; style=dashed; color=\"#aaaaaa\"; fontsize=25")
    println(io, "    \"PopulationSize\"; \"MaxGenerations\";")
    println(io, "  }")

    for e in edges(pc)
        src_name = node_names[src(e)]
        dst_name = node_names[dst(e)]
        if src_name in undirected_nodes || dst_name in undirected_nodes
            println(io, "  \"$src_name\" -> \"$dst_name\" [dir=none];")
        else
            println(io, "  \"$src_name\" -> \"$dst_name\";")
        end
    end

    println(io, "}")
end

using Graphviz_jll
run(`$(Graphviz_jll.fdp()) -Tpng $(joinpath("causal", "pc_res", dotname*".dot")) -o $(joinpath("causal", "pc_res", dotname*".png"))`)