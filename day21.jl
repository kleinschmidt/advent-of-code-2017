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
        if size(rhs) == (4,4)
            rhs = reshape([rhs[1:2, 1:2],
                           rhs[3:4, 1:2],
                           rhs[1:2, 3:4],
                           rhs[3:4, 3:4]],
                          (2,2))
        end
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

seed_test = ".#./..#/###" |> slash_to_mat

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
expand(tiles::Matrix, rules::Dict) = broadcast(expand, tiles, rules)
expand(tile::Matrix{Char}, rules::Dict) = getindex(rules, tile)

score(tiles::Matrix) = mapreduce(score, +, tiles)
score(x::Char) = x=='#' ? 1 : 0

rules = eachline("day21.input") |> parse_input


reduce(expand, seed, take(repeated(rules), 5)) |> score



reduce(expand, seed_test, take(repeated(rules_test), 2)) |> score
