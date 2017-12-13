# caught if scanner is at "top" at entry time.

# depth of 3, goes from 0-2 then turns around. period of 4.
# [0] [1] [2]
# [4] [3]
# generally period of 2*(d-1)


severity = 0
for l in eachline("day13.input")
    t, d = parse.(Int, split(l, ": "))
    # arrive at time t, depth of d.
    if mod(t, 2(d-1)) == 0
        severity += t*d
    end
end


