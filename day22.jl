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


# star 2:
#
# clean -> weak -> infected -> flagged -> clean
#
# weakend: += 0
# infected: += 1
# flagged: += 2
# clean: += 3
#
# state = (state + 1) % 4
mutable struct SuperVirus{A}
    infection::A
    infections::Int
    pos::Tuple{Int,Int}
    heading::UInt8
end

function SuperVirus(input; n=10_000)
    infection = OffsetArray(Array{UInt8}(2*n+1, 2*n+1), -n:n, -n:n)
    fill!(infection, 0x3)
    halfsize = size(input,1) ÷ 2
    infection[-halfsize:halfsize, -halfsize:halfsize] .= input
    SuperVirus(infection, 0, (0,0), 1)
end

function step!(v::SuperVirus)
    v.heading += v.infection[v.pos...]
    v.infection[v.pos...] += 0x01
    v.infections += (v.infection[v.pos...] % 0x4 == 0x01)
    v.pos = v.pos .+ headings[v.heading]
    v
end

states = CircularVector(['#', 'F', '.', 'W'])

function Base.show(io::IO, sv::SuperVirus)
    rows, cols = indices(sv.infection)
    for i in rows
        for j in cols
            c = states[svt.infection[i,j]]
            if (i,j) == sv.pos
                print(io, "[$c]")
            else
                print(io, " $c ")
            end
        end
        print(io, "\n")
    end
end

super_test_input =
    [0x3 0x3 0x1
     0x1 0x3 0x3
     0x3 0x3 0x3]

svt = SuperVirus(super_test_input, n=10_000);
for _ in 1:10_000_000
    step!(svt);
end


# initialize to 3 for clean, 1 for infected
@_ super_input =
    readlines("day22.input") |>
    Vector{Char}.(_) |>
    hcat(_...) |>
    permutedims(_, (2,1)) |>
    ifelse.(_ .== '#', 0x1, 0x3)

sv = SuperVirus(super_input);

for _ in 1:10_000_000
    step!(sv);
end
