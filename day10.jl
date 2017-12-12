using Base.Test
include("circularvector.jl")

function knot!(cv::CircularVector, start::Int, skip::Int, lengths::Vector{Int})
    for length in lengths
        if length > 1
            reverse!(cv, start, start+length-1)
        end
        # don't worry about wrapping around because of circular magic
        start += skip + length
        skip += 1
    end
    cv, start, skip
end

cv, start, skip = knot!(CircularVector(0:4), 1, 0, [3, 4, 1, 5]);
cv[1] * cv[2]

input = "187,254,0,81,169,219,1,190,19,102,255,56,46,32,2,216"

cv, _ = knot!(CircularVector(0:255), 1, 0, parse.(Int, split(input, ",")))
cv[1] * cv[2]

# now:
#
# input is ASCII characters, conver to Int lengths
# append [17, 31, 73, 47, 23]
# run 64 rounds, but preserve skip size and position between rounds
# convert sparse hash to dense hash: XOR together blocks of 16
# convert bytes to hex string

function knot_hash(input::AbstractString)
    lengths = vcat([Int(c) for c in input], [17, 31, 73, 47, 23])
    skip = 0
    start = 1
    cv = CircularVector(0:255)
    for _ in 1:64
        cv, start, skip = knot!(cv, start, skip, lengths)
    end
    sparse_hash = reshape(cv, (16, 16))
    # column major: sparse_hash[:,1] is first 16.
    dense_hash = [reduce(xor, sparse_hash[:,i]) for i in 1:size(sparse_hash, 2)]
    join(hex.(dense_hash, 2))
end

@test knot_hash("") == "a2582a3a0e66e6e86e3812dcb672a272"
@test knot_hash("AoC 2017") == "33efeb34ea91902bb2f59c9920caa6cd"

knot_hash(input)
