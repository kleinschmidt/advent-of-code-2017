# jumps: add to idx and increment value by 1

test = [0, 3, 0, 1, -3]

function f!(input)
    steps = 0
    idx = 1
    while idx <= length(input)
        input[idx], idx = input[idx]+1, idx+input[idx]
        steps += 1
    end
    return steps
end

f!(parse.(Int, readlines("day05.input")))

# if offset is 3 or more, decrease by one.
function g!(input)
    steps = 0
    idx = 1
    while idx <= length(input)
        input[idx], idx = input[idx] + (input[idx]≥3 ? -1 : 1), idx+input[idx]
        steps += 1
    end
    return steps
end

g!(test)
g!(parse.(Int, readlines("day05.input")))
