include("day10.jl")

# count number of set bits in hex number

key = "stpzcrnm"

total_used = 0

count_bits(i::I) where I<:Integer = reduce(+, c=='1' for c in bits(i))

for row in 0:127
    @show row_key = "$key-$row"
    @show row_hash = knot_hash(row_key)
    @show row_int = eval(parse("0x$(row_hash)"))
    total_used += count_bits(row_int)
end

# part 2: count number of connected components. can re-use paint with a type
# where getindex is overloaded?

grid = Array{Char}(128, 128)
for row in 1:128
    row_hash = knot_hash("$key-$(row-1)")
    grid[row, :] = [c for c in bits(eval(parse("0x$(row_hash)")))]
end

struct GridEdges{T}
    grid::Matrix{T}
    occupied::T
end

# get edges
function Base.getindex(g::GridEdges, i::Int...)
    [is for is in neighbors(i) if (checkbounds(Bool, g.grid, is...) && g.grid[is...] == g.occupied)]
end

neighbors(i::Tuple{Int,Int}) = ((i[1]+1, i[2]), (i[1]-1, i[2]), (i[1], i[2]+1), (i[1], i[2]-1))


## copied from day 12
function paint(i, color, edges, components)
    if components[i...] == 0
        components[i...] = color
        for j in edges[i...]
            components = paint(j, color, edges, components)
        end
    end
    return components
end

components = zeros(Int, size(grid))
components[grid.=='0'] = -1


ge = GridEdges(grid, '1')
comp_i = 0
while findfirst(components, 0) > 0
    @show comp_i += 1
    components = paint(ind2sub(components, findfirst(components, 0)),
                       comp_i,
                       ge,
                       components)
end
