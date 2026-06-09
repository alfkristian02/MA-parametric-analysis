include("../types.jl")
include("../config.jl")
include("../utils/Utils.jl")

using .ConfigParameters, .Utils, Plots, Plots.Measures

gr() # Plots engine


all_decimal = [i for i in 0:(2^number_of_features-1)]
bitstrings = decimal_to_binary.(all_decimal, fill(number_of_features, length(all_decimal)))
fitness_values = fitness_function.(all_decimal)


half = Int(ceil(number_of_features / 2))

x = [binary_to_decimal(bs[1:half]) for bs in bitstrings]
y = [binary_to_decimal(bs[(half + 1):end]) for bs in bitstrings]


local_optima_idx = Int[]
for x in all_decimal
    current_fitness = fitness_function(x)

    binary = decimal_to_binary(x, number_of_features)
    neighborhood = get_neighborhood(binary, 1)

    best_fitness = maximum(fitness_function.(binary_to_decimal.(neighborhood)))

    if current_fitness >= best_fitness
        push!(local_optima_idx, x+1) #adjust for 1 indexing
    end
end


global_max        = maximum(fitness_values)
global_optima_idx = [i for i in local_optima_idx if fitness_values[i] == global_max]
strict_local_idx  = setdiff(local_optima_idx, global_optima_idx)

println("GO count: ", length(global_optima_idx))
println("LO count: ", length(strict_local_idx))


# the plots are of varying size so vary the plot size and text
grid_w = 2^half
grid_h = 2^(number_of_features - half)

cell_px = clamp(5000 ÷ max(grid_w, grid_h), 5, 30)

fig_w = max(grid_w * cell_px + 400, 1000)
fig_h = max(grid_h * cell_px + 200, 800)

scale = 1.4 * sqrt(max(fig_w, fig_h) / 1000)

fitness_grid = reshape(copy(fitness_values), grid_h, grid_w)

if dataset_filename == "heart_13"
    title_name = "Heart Disease"
elseif dataset_filename == "zoo_16"
    title_name = "Zoo"
elseif dataset_filename == "hep_19" 
    title_name = "Hepatitis"
elseif dataset_filename == "nk_19_10"
    title_name  = "NK; N=19, K=10"
elseif dataset_filename == "nk_20_16"
    title_name  = "NK; N=20, K=16"
else
    title_name  = "NK; N=21, K=4"
end

plt = heatmap(
    0:(grid_w - 1), 0:(grid_h - 1), fitness_grid;
    title = title_name,
    color = :RdYlGn,
    clims = (0, 1),
    colorbar = true,
    xlabel= "x",
    ylabel= "y",
    aspect_ratio = :equal,
    xlims = (-1.5, grid_w - 0.5 + 1),
    ylims = (-1.5, grid_h - 0.5 + 1),
    size = (fig_w, fig_h),
    dpi = 150,
    tickfontsize = round(Int, 16 * scale),
    guidefontsize = round(Int, 20 * scale),
    colorbar_tickfontsize = round(Int, 16 * scale),
    colorbar_titlefontsize = round(Int, 20 * scale),
    titlefontsize = round(Int, 24 * scale),
    left_margin = 10mm * scale,
    right_margin = 10mm * scale,
    top_margin = 10mm * scale,
    bottom_margin = 10mm * scale,
)

scatter!(plt,
    x[strict_local_idx], y[strict_local_idx];
    marker = :o,
    markercolor = :deepskyblue,
    markerstrokecolor = :deepskyblue,
    markersize = round(Int, 5 * scale),
    label             = "",
)

scatter!(plt,
    x[global_optima_idx], y[global_optima_idx];
    markersize = round(Int, 12 * scale),
    markerstrokewidth = 2 * scale,
    marker = :o,
    markercolor = :black,
    markerstrokecolor = :black,
    label = "",
)



output_dir = joinpath(@__DIR__, "hbm")
mkpath(output_dir)

output_path = joinpath(output_dir, "$(dataset_filename).png")
savefig(plt, output_path)

println("Saved heatmap to: ", output_path)