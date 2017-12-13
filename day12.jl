# find all the nodes connected to 0.
#
# keep track of visited nodes
#
# wait can't we build up connected components incrementally? each line in input
# is a set of nodes (since they're bidirectional).  union together all the sets
# that have any intersection.

parse_input(str) = [parse.(Int, split(nodes, ", ")) .+ 1 # convert to 1-based indexing
                    for (_, nodes)
                    in split.(split(chomp(str), "\n"), " <-> ")]

input = parse_input(readstring("day12.input"))

function paint(i, color, edges, components)
    if components[i] == 0
        components[i] = color
        for j in edges[i]
            paint(j, edges, components)
        end
    end
    return components
end

test = """0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5"""

test_input = parse_input(test)

paint(1, 1, test_input, zeros(Int, length(test_input)))

sum(paint(1, 1, input, zeros(Int, length(input))))

function components(edges)
    comps = zeros(Int, length(edges))
    comp_i = 1
    while(any(comps .== 0))
        comps = paint(findfirst(comps, 0), comp_i, edges, comps)
        comp_i += 1
    end
    return comps
end

maximum(components(input))
