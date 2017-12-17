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
    revindex::Vector{Int}
    Programs(ps::Vector{Char}) =
        new(ps, 0, length(ps), collect(1:length(ps)))
end

Base.show(io::IO, p::Programs) =
    println(io, "Programs: $(String(circshift(p.programs, p.shift)))")


s(p::Programs, n::Int) = (p.shift = (p.shift+n)%p.n; p)

function x(p::Programs, a::Int, b::Int)
    a, b = mod.((a,b) .- p.shift, p.n) .+ 1
    p.programs[a], p.programs[b] = p.programs[b], p.programs[a]
    p.revindex[p.programs[a]-'`'] = a
    p.revindex[p.programs[b]-'`'] = b
    return p
end

function p(p::Programs, a::Int, b::Int)
    ai = p.revindex[a]
    bi = p.revindex[b]
    p.programs[ai], p.programs[bi] = b+'a'-1, a+'a'-1
    p.revindex[a] = bi
    p.revindex[b] = ai
    return p
end

function parse_inst(inst::AbstractString)
    op = eval(Symbol(inst[1]))
    args = (split(inst[2:end], '/')...)
    if op == p
        args = getindex.(args, 1) .- 'a' .+ 1
    else
        args = parse.(Int, args)
    end
    return op, args
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


# Okay, this isn't going to work.  but easier: don't need to actually _do_ all
# the instructions.  keep track of the numerical indices and the mapping from
# indices to names.  The character thing is a red herring.  Actually, I think we
# need the _reverse_ names index (char-->index), because we need to do things
# like "swap the things called 'e' and 'b'", which requires finding 'e' and 'b'.


mutable struct Instructions
    # names[i] is the position of char i-1+'a'
    names::Vector{Int}
    # order[i] is the index of the ith element before shift is applied
    order::Vector{Int}
    shift::Int
    len::Int
end

Instructions(n::Int) = Instructions(collect(1:n), collect(1:n), 0, n)
Instructions(x::Any) = Instructions(length(x))

function Base.convert(::Type{String}, is::Instructions)
    # convert reverse char->position mapping to position->char mapping
    labels = ['a' - 1 + findfirst(is.names, i) for i in 1:is.len]
    inds = circshift(is.order, is.shift)
    return String(labels[inds])
end

function Base.show(io::IO, is::Instructions)
    println(io, "Instructions: ", String(is))
end


function parse_inst!(is::Instructions, inst::AbstractString)
    if inst[1] == 's'
        is.shift += parse(Int, inst[2:end])
        is.shift %= is.len
    elseif inst[1] == 'x'
        #a, b = mod.((a,b) .- is.shift, is.n) .+ 1
        a, b = mod.(parse.(Int, split(inst[2:end], '/')) .- is.shift, is.len) .+ 1
        is.order[a], is.order[b] = is.order[b], is.order[a]
    else # inst[1] == 'p'
        # convert chars a and b into 1-base indices in names:
        a, b = (inst[2], inst[end]) .- 'a' .+ 1
        is.names[a], is.names[b] = is.names[b], is.names[a]
    end
    return is
end


insts_test = reduce(parse_inst!, Instructions('a':'e'), split(test_str, ','))

inst_strings = split(chomp(readstring("day16.input")), ',')
insts = reduce(parse_inst!, Instructions('a':'p'), inst_strings)


function parse_inst!(a::Instructions, b::Instructions)
    a.order .= a.order[b.order]
    a.shift += b.shift
    a.names .= a.names[b.names]
    a
end

insts_test_again = reduce(parse_inst!, Instructions('a':'e'),
                          repeat(split(test_str, ','), outer=2))

dump(insts_test)
dump(insts_test_again)

parse_inst!(insts_test, insts_test)
