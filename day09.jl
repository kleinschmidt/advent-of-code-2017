using Base.Test

# "groups" of matching {} brackets. "garbage" of matching <> brackets. "!"
# nullifies next character.
#
# finite state machine: keep track of depth of currently open group, garbage or
# not, quoted or not.
#
# garbage - > -> base
# garbage - [any] -> garbage
# garbage - ! -> garbage!
# garbage! - [any] -> garbage
# base - { -> tot; group+1; base
# base - } -> tot+=group; group-1; base
# base - < -> tot; group; garbage
# base - ! -> 


@enum State garbage group garbage! group!


function score(stream)
    garbage = false
    quoted = false
    depth = 0
    total = 0
    total_garbage = 0
    for c in stream
        if quoted
            quoted = false
            continue
        elseif garbage
            if c == '>'
                garbage = false
            elseif c == '!'
                quoted = true
            else
                total_garbage += 1
            end
        else
            if c == '<'
                garbage = true
            elseif c == '!'
                quoted = true
            elseif c == '{'
                depth += 1
            elseif c == '}'
                total += depth
                depth -= 1
            end
        end
    end
    return total, total_garbage
end


@test score("{{{}}}")[1] == 6
@test score("{{{},{},{{}}}}")[1] == 16
@test score("{{<!!>},{<!!>},{<!!>},{<!!>}}")[1] == 9
@test score("{{<a!>},{<a!>},{<a!>},{<ab>}}")[1] == 3

score(readstring("day09.input"))
