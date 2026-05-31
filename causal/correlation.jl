using DataFrames, StatsBase, CSV, Plots, Plots.PlotMeasures

# files::Vector{String} = ["heart_13.csv", "zoo_16.csv", "hep_19.csv"]
# files::Vector{String} = ["nk_16_9.csv", "nk_18_3.csv", "nk_19_16.csv"]
files::Vector{String} = ["nk_16_9.csv", "nk_18_3.csv", "nk_19_16.csv", "heart_13.csv", "zoo_16.csv", "hep_19.csv"]
included_columns::Vector{String} = ["NormalizedBestFound","CrossoverProbability","MutationRate","LSProbability","LSMaxSteps", "GAImprovement", "LSImprovement", "PopulationSize", "MaxGenerations", "Autocorrelation", "NumberOfFeatures", "NumberOfLOs"]

load_data = [select(CSV.read(joinpath("runs", file), DataFrame), included_columns) for file in files]

combined = reduce(vcat, load_data, cols=:union)

correlation_matrix = cor(Matrix(combined))

labels = names(combined)

display(heatmap(
    labels,
    labels,
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
))

readline()