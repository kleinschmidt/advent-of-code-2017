function parse_line(line)
    m = match(r"([a-z]*) \(([0-9]*)\)(?: -> )?([a-z, ]*)?", line)
    children = split(m.captures[3], ", ")
    isempty(children[1]) && empty!(children)
    m.captures[1], m.captures[2], children
end

input = parse_line.(readlines("day07.input"))



# strategy is to build up an adjacency matrix one row at a time.  we need to
# know the linear index of each name.  once we have the full matrix we can start
# with any one we want and follow the edges back to the bottom-most.  use a
# NamedArray to do the lookup more easily 

n = length(input)
names = [i[1] for i in input]
using NamedArrays
edges = NamedArray(spzeros(Bool, n, n), (names, names), ("from", "to"))

for (name, weight, children) in input
    for child in children
        edges[child, name] = true
    end
end

name = names[1]
while any(edges[name, :])
    name = findfirst(edges[name, :])
end

@show root_idx, root = name, names[name]

# star 2: unbalanced.  find the one disk who's weight needs to be changed to
# balance
weights = NamedVector([parse(Int, i[2]) for i in input])
setnames!(weights, String.(names), 1)

# do a depth first search, recursively check whether a disk is balanced based on
# its children.  compute weight and whether balanced for each one

function w(idx, weights, edges)
    children = find(edges[:,idx])
    child_weights = Int[w(n, weights, edges) for n in children]
    if !all(x->x==child_weights[1], child_weights)
        @show child_weights, children
        error()
    end
    weights[idx] + sum(child_weights)
end



w(root_idx, weights, edges)
weights_balanced = copy(weights)
weights_balanced[988] -= 9
w(root_idx, weights_balanced, edges)
