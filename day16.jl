# instructions:
# xA/B exchange items at positions A and B
# sN take N from end and put at front (in same order)
# pA/B exchange position of A and B
#
# might make sense to maintain a char->int reverse index but updating that after
# shift would be expensive (because every index changes).


# numerical index only matters for the 'x' instructions. probably better to have
# dict for reverse index, and un-shift numeric indices for 'x'.


mutable struct Programs
    programs::Vector{Char}
    shift::Int
    n::Int
    revindex::Dict{Char,Int}
    Programs(ps::Vector{Char}) =
        new(ps, 0, length(ps), Dict(j=>i for (i,j) in enumerate(ps)))
end

Base.show(io::IO, p::Programs) =
    println(io, "Programs: $(String(circshift(p.programs, p.shift)))")

s(p::Programs, n::Int) = (p.shift += 



function step!(x, inst)
    if inst[1] == 's'
        x .= circshift(x, parse(Int, inst[2:end]))
    elseif inst[1] == 'x'
        a, b = parse.(Int, split(inst[2:end], "/")) .+ 1
        x[a], x[b] = x[b], x[a]
    else                        # p: exchange positions
        a, b = inst[2], inst[end]
        ai = findfirst(x, a)
        bi = findfirst(x, b)
        x[ai], x[bi] = x[bi], x[ai]
    end
    x
end

test_str = "s1,x3/4,pe/b" 
instructions = split(test_str, ",")
x = collect('a':'e')

for inst in instructions
    step!(x, inst)
    println(inst, "\t", String(x))
end


function dance!(x, instructions::Vector)
    for inst in instructions
        step!(x, inst)
    end
    x
end


x = collect('a':'p')
instructions = split(chomp(readstring("day16.input")), ",")
String(dance!(x, instructions))

using BenchmarkTools
@benchmark dance!($x, $instructions)

@profile foreach((i)->dance!(x, instructions), 1:1_000_000)

x = collect('a':'p')
for i in 1:1_000_000_000
    dance!(x, instructions)
    i % 1_000_000 == 0 && println(i)
end
