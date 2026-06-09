using DataFrames, StatsBase, CSV, Plots, Plots.PlotMeasures

files::Vector{String} = ["nk_19_10.csv", "nk_20_16.csv", "nk_21_4.csv"]
dotname = "corr_syn"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv"]
# dotname = "corr_nat"
# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv", "nk_19_10.csv", "nk_20_16.csv", "nk_21_4.csv"]
# dotname = "corr_com"

included_columns::Vector{String} = ["NormalizedBestFound","CrossoverProbability","MutationRate","LSProbability","LSMaxSteps", "PopulationSize", "MaxGenerations", "Autocorrelation", "NumberOfFeatures", "NumberOfLOs"]
load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]
combined = reduce(vcat, load_data, cols=:union)

correlation_matrix = cor(Matrix(combined))

labels = names(combined)

n = length(labels)

p = heatmap(
    1:n,
    1:n,
    correlation_matrix,
    c = :RdBu,
    clims = (-1, 1),
    xrotation = 45,
    size = (900, 800),
    title = "Correlation Matrix",
    margin = 10mm,
    tickfontsize = 12,
    titlefontsize = 16,
    guidefontsize = 12,
    xticks = (1:n, labels),
    yticks = (1:n, labels),
)

for i in 1:n, j in 1:n
    annotate!(p, j, i, text(string(round(correlation_matrix[i,j], digits=3)), 8, :center, :black))
end

savefig(p, joinpath("causal", "corr_res", dotname*".png"))