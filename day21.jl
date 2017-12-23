include("underscore.jl")

test_input = """
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
"""

function slash_to_mat(str)
    @_ str |>
        split(_, '/') |>
        mapreduce(Vector{Char}, hcat, _) |>
        permutedims(_, (2,1))
end

# to rotate: flip one dim and exchange
function rotations(x::AbstractMatrix)
    xrot = Matrix[]
    push!(xrot, x)
    for _ in 1:3
        x = permutedims(x[end:-1:1, :], (2,1))
        push!(xrot, x)
    end
    return xrot
end

fliprots(x::AbstractMatrix) = append!(rotations(x), rotations(x[end:-1:1, :]))

function parse_input(lines)
    rules = Dict()
    for line in lines
        lhs, rhs = slash_to_mat.(split(line, " => "))
        for l in fliprots(lhs)
            rules[l] = rhs
        end
    end
    rules
end

rules_test = @_ test_input |>
    chomp |>
    split(_, '\n') |>
    parse_input

seed = ".#./..#/###" |> slash_to_mat

# represent grid as array of tiles...view of underlying array?
#
# what do we need to do? expand a grid into a bigger grid. look up tiles in
# dict, replcae with bigger tiles, then combine.  we can predict the size of the
# bigger array based on the number of tiles and their size: for a k×k grid of
# 3-tiles, we get a 4k×4k, and a 3k×3k for 2-tiles.  so then we can initialize
# the underlying array and create parallel iterators over tile views...
#
# oh you don't even need to construct the actual grid, since the tile boundaries
# always align (as long as we convert the 4×4s into 2×2s

import Base.expand

score(tiles::Matrix) = mapreduce(score, +, tiles)
score(x::Char) = x=='#' ? 1 : 0

rules = eachline("day21.input") |> parse_input

# okay i was wrong; multiple of two rule takes precednece over multiple of 3 so
# do need to merge tiles.  is there a clever way to do this?  start with 3×3,
# then 4×4, then 6×6 (3×3 2 tiles), then 9×9

function split_tiles(chrs::Matrix{Char})
    rs, cs = size(chrs)
    tile_sz = rs % 2 == 0 ? 2 : 3
    inds = 1:tile_sz
    offsets = 0:tile_sz:(rs-2)
    [view(chrs, inds+i, inds+j) for i in offsets, j in offsets]
end



function merge_tiles(tiles)
    tile_sz = size(tiles[1], 1)
    rs, cs = tile_sz .* size(tiles)
    chrs = Matrix{Char}(rs, cs)
    for i in 1:size(tiles,1)
        r_inds = (1:tile_sz) + (i-1)*tile_sz
        for j in 1:size(tiles,2)
            c_inds = (1:tile_sz) + (j-1)*tile_sz
            chrs[r_inds, c_inds] .= tiles[i,j]
        end
    end
    chrs
end


function expand(chrs::Matrix{Char}, rules)
    tiles = split_tiles(chrs)
    merge_tiles(getindex.(rules, tiles))
end


reduce(expand, seed, take(repeated(rules), 5)) |> score
reduce(expand, seed, take(repeated(rules), 18)) |> score
