using Base.Test

# sum up digits that match following digit:
function f(s::String)
    total = 0
    for i in eachindex(s)
        if s[i] == s[i%length(s)+1]
            total += parse(Int, s[i])
        end
    end
    return total
end

@test f("1111") == 4
@test f("1122") == 3
@test f("91212129") == 9

f(readline("day01.input"))

# sum up digits match halway around
function g(s::String)
    total = 0
    len = length(s)
    offset = len >> 1
    for i in 1:offset
        if s[i] == s[i+offset]
            total += 2*parse(Int, s[i])
        end
    end
    return total
end

@test g("1212") == 6
@test g("1221") == 0
@test g("12131415") == 4
@test g("123425") == 4
@test g("123123") == 12

g(readline("day01.input"))
