using DataFrames, CSV

file = "runs/heart_13_04212141.csv"
output = "runs/heart_13.csv"
difficulty_value = .378

df = CSV.read(file, DataFrame)

df[!, :ds_diff] .= difficulty_value

CSV.write(output, df)