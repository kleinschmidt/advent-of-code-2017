# find long-term min manhattan distance under acceleration.  distance is ~a^2 in
# long term, so find minimum sum(a^2)

input =  readlines("day20.input")

min_d = typemax(Int)
min_i = -1
for (i, line) in enumerate(readlines("day20.input"))
    p, v, a = [parse.(Int, split(x, ','))
               for x
               in match(r"p=<([^>]*)>, v=<([^>]*)>, a=<([^>]*)>", line).captures]
    d = sum(a.^2)
    @show i, d, line
    if d < min_d
        min_d = d
        min_i = i-1
    end        
end


# detect collisions!
