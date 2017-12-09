# find max value, increment following blocks by 1 until used up.
# number of steps until infinite cycle is detected.

test = [0, 2, 7, 0]

function redist!(x)
    val, idx = findmax(x)
    x[idx] = 0
    for j in idx:(idx+val-1)
        @inbounds x[j % length(x) + 1] += 1
    end
    x
end

redist!([0, 2, 7, 0])

function detectloop!(state::Vector{Int})
    states = Dict{NTuple{length(state), Int}, Int}()
    steps = 0
    while !haskey(states, (state...))
        # showcompact(state)
        states[(state...)] = steps
        redist!(state)
        steps += 1
    end
    cycle_len = steps-states[(state...)]
    return steps, cycle_len
end

detectloop!([0, 2, 7, 0])

input = readdlm("day06.input", Int)[:]

steps, len = detectloop!(input)
