using CSV, DataFrames, Plots

files = ["heart_13", "zoo_16", "hep_19", "nk_19_10", "nk_20_16", "nk_21_4"]
labels = ["Heart Disease", "Zoo", "Hepatitis", "NK1", "NK2", "NK3"]

reached_counts = []

for file in files
    df = CSV.read("runs/"*file*".csv", DataFrame)
    push!(reached_counts, count(==(1.0), df.NormalizedBestFound))
end

n = length(labels)

plt = bar(
    1:n,
    reached_counts,
    title = "Number of runs reaching the GO",
    xlabel = "Dataset",
    ylabel = "Count",
    legend = false,
    color = :steelblue,
    xticks = (1:n, labels),
    dpi = 300,
)

hline!(plt, [9000], linestyle = :dash)

for (i, v) in enumerate(reached_counts)
    annotate!(plt, i, v/2, text(string(v), 9, :center, :white))
end

savefig(plt, "exploration_runs/GO_reached.png")