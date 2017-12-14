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
