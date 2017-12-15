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


# can delay start by any T.  what's smallest T so that don't get caught?
# instead of mod(t, 2(d-1)) it's mod(t+T, 2(d-1)).  offsets that will get you
# caught are mod(-t, 2(d-1)).  can do some kinda sieve thing?  question is what
# the largest offset we need to consider is.  could be up to the smallest 

tds = [parse.(Int, split(l, ": ")) for l in eachline("day13.input")]

# these are all the things we have to avoid (mod 2(d-1))
catch_times = [(mod(-t, 2(d-1)), 2(d-1)) for (t,d) in tds]

T = 0
@time any( (T-t)÷d == 0 for (t,d) in catch_times)

function any_caught(T, catch_times)
    for i in eachindex(catch_times)
        t,d = catch_times[i]
        if (T-t) % d == 0
            T += 1
            # @show i, t, d
            return true
        end
    end
    return false
end

function safe_time(catch_times)
    T = 0
    while any_caught(T, catch_times)
        T+=1
    end
    return T
end

safe_T = safe_time(catch_times)
