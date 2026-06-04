include("../utils/Utils.jl")
using .Utils, JSON, Plots, Plots.PlotMeasures
gr()

data = JSON.parsefile(joinpath("data_exploration", "mock.json"))
individuals = data["individuals"]
n = length(individuals)
bits_length = length(individuals[1]["bits"])
half = Int(ceil(bits_length / 2))

bits_list = [BitVector(ind["bits"]) for ind in individuals]
fitness_values = Float64[ind["fitness"] for ind in individuals]

x = [binary_to_decimal(b[1:half]) for b in bits_list]
y = [binary_to_decimal(b[(half+1):bits_length]) for b in bits_list]

local_optima_idx = Int[]
for i in 1:n
    current_fitness = fitness_values[i]
    neighborhood = get_neighborhood(bits_list[i], 1)
    neighbor_fitnesses = [fitness_values[findfirst(==(nb), bits_list)] for nb in neighborhood]
    best_neighbor = maximum(neighbor_fitnesses)
    if current_fitness >= best_neighbor
        push!(local_optima_idx, i)
    end
end

global_max = maximum(fitness_values)
global_optima_idx = [i for i in local_optima_idx if fitness_values[i] == global_max]
strict_local_idx = setdiff(local_optima_idx, global_optima_idx)

println("GO count: ", length(global_optima_idx))
println("LO count: ", length(strict_local_idx))

grid_w = 2^half
grid_h = 2^(bits_length - half)

plt = scatter(
    x[strict_local_idx], y[strict_local_idx];
    markersize = 10,
    marker = :circle,
    markercolor = :white,
    markerstrokecolor = :deepskyblue,
    markerstrokewidth = 2,
    label = "",
)

scatter!(
    plt,
    x[global_optima_idx], y[global_optima_idx];
    markersize = 10,
    marker = :circle,
    markercolor = :white,
    markerstrokecolor = :black,
    markerstrokewidth = 2,
    label = "",
)

scatter!(
    plt,
    x, y;
    zcolor = fitness_values,
    markersize = 5,
    marker = :circle,
    colorbar = true,
    color = :RdYlGn,
    clims = (0, 1),
    xlabel = "x",
    ylabel = "y",
    legend = false,
    xlims = (-.5, 3.5),
    ylims = (-.5, 3.5),
    aspect_ratio = :equal,
    size = (500, 500),
    dpi = 150,
    right_margin = 10mm,
)

savefig(plt, "data_exploration/hbm/mock.png")