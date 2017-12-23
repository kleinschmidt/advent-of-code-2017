using OffsetArrays
include("underscore.jl")
include("circularvector.jl")

@_ input =
    readlines("day22.input") |>
    Vector{Char}.(_) |>
    hcat(_...) |>
    permutedims(_, (2,1)) |>
    (_ .== '#')


# loop:
# if infected, turn right; otherwise left
# toggle infected
# move one.

# start in middle facing up. (-1, 0)

const headings = CircularVector([(-1, 0), (0, 1), (1, 0), (0, -1)])

mutable struct Virus
    infection::OffsetArray{Bool,2,BitArray{2}}
    infections::Int
    pos::Tuple{Int,Int}
    heading::Int
end

function Virus(input; n=10_000)
    infection = OffsetArray(BitArray(2*n+1, 2*n+1), -n:n, -n:n)
    halfsize = size(input,1) ÷ 2
    infection[-halfsize:halfsize, -halfsize:halfsize] .= input
    Virus(infection, 0, (0,0), 1)
end

function step!(v::Virus)
    v.heading += v.infection[v.pos...] ? 1 : -1
    v.infection[v.pos...] = !v.infection[v.pos...]
    v.infections += v.infection[v.pos...]
    v.pos = v.pos .+ headings[v.heading]
    v
end


v = Virus(input)
for _ in 1:10000
    step!(v)
end
