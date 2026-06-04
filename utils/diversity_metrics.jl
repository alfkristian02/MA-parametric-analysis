function average_hamming_distance(population::Vector{BitVector})::Float64
    
    n = length(population)
    if n < 2 return 0.0 end

    l = length(population[1])
    
    aggregate_distance = 0

    n_pairs = (n * (n - 1)) / 2

    for i in 1:n-1
        for j in i+1:n
            aggregate_distance += sum(@inbounds population[i] .!= population[j])
        end
    end

    return aggregate_distance / n_pairs 
end

function total_hamming_distance(population::Vector{BitVector})::Float64
    
    n = length(population)
    if n < 2 return 0.0 end

    aggregate_distance = 0

    for i in 1:n-1
        for j in i+1:n
            aggregate_distance += sum(@inbounds population[i] .!= population[j])
        end
    end

    return aggregate_distance 
end

if abspath(PROGRAM_FILE) == @__FILE__
    population = [BitVector([1, 0, 1]), BitVector([1, 1, 0])]

    print(DiversityMetrics.average_hamming_distance(population))
end