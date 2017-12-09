# detect duplicate words in a line
input = split.(readlines("day04.input"))

function valid(pass::Vector)
    for i in eachindex(pass)
        if any(isequal.(pass[i], view(pass, (i+1):length(pass))))
            return false
        end
    end
    return true
end

valids = valid.(input)
output = sum(valids)


setify(s) = [Set([w...]) for w in s]

valids2 = valid.(setify.(input))

all(valids[valids2])            # sanity check
any(valids2[!valids])

sum(valids2)
