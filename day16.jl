using ArgCheck

# instructions:
# xA/B exchange items at positions A and B
# sN take N from end and put at front (in same order)
# pA/B exchange position of A and B
#
# might make sense to maintain a char->int reverse index but updating that after
# shift would be expensive (because every index changes).


# numerical index only matters for the 'x' instructions. probably better to have
# dict for reverse index, and un-shift numeric indices for 'x'.


# Okay, brute force isn't going to work.  but easier: don't need to actually
# _do_ all the instructions.  keep track of the numerical indices and the
# mapping from indices to names.  The character thing is a red herring.
# Actually, I think we need the _reverse_ names index (char-->index), because we
# need to do things like "swap the things called 'e' and 'b'", which requires
# finding 'e' and 'b'.


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
    @argcheck a.len == b.len
    a.order = circshift(circshift(a.order, a.shift)[circshift(b.order, b.shift)],
                        -b.shift - a.shift)
    a.shift += b.shift
    a.names .= a.names[b.names]
    a
end

Base.run(is::Instructions, n::Int) = reduce(parse_inst!, Instructions(is.len),
                                            Iterators.repeated(is, n))

i2 = run(insts, 2)
i4 = run(insts, 4)
run(i2, 2)

ibil = run(insts, 10)
for _ in 2:9
    @show parse_inst!(ibil, ibil)
end
