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


s(p::Programs, n::Int) = (p.shift = (p.shift+n)%p.n; p)

function x(p::Programs, a::Int, b::Int)
    a, b = mod.((a,b) .- p.shift, p.n) .+ 1
    p.programs[a], p.programs[b] = p.programs[b], p.programs[a]
    p.revindex[p.programs[a]] = a
    p.revindex[p.programs[b]] = b
    return p
end

function p(p::Programs, a::Char, b::Char)
    ai = p.revindex[a]
    bi = p.revindex[b]
    p.programs[ai], p.programs[bi] = b, a
    p.revindex[a] = bi
    p.revindex[b] = ai
    return p
end

function parse_inst(inst::AbstractString)
    op = eval(Symbol(inst[1]))
    args = (split(inst[2:end], '/')...)
    if op == p
        args = getindex.(args, 1)
    else
        args = parse.(Int, args)
    end
    op, args
end


function dance!(ps::Programs, instructions::Vector)
    for (op, args) in instructions
        op(ps, args...)
    end
    ps
end


test_str = "s1,x3/4,pe/b" 
instructions_test = parse_inst.(split(test_str, ","))
x_test = Programs(collect('a':'e'))
dance!(x_test, instructions_test)



ps = Programs(collect('a':'p'))
instructions = parse_inst.(split(chomp(readstring("day16.input")), ","))
dance!(ps, instructions)

using BenchmarkTools
@benchmark dance!($ps, $instructions)

@profile foreach((i)->dance!(ps, instructions), 1:1_000)

ps = Programs(collect('a':'p'))
for i in 1:1_000_000_000
    dance!(ps, instructions)
    i % 1_000_000 == 0 && println(i)
end
