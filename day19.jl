# follow path, starts at top of window.  list the letters in order they're
# encountered.

test_input = """
     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
"""

# this makes the first (row) index 'x', the second (col) 'y'.  need to transpose
# to show 
parse_input(lines::Vector) = reduce(hcat, [c for c in line] for line in lines)

headings = [(0,1), (1,0), (0,-1), (-1,0)]

function turn(path::Matrix{Char}, pos, heading)
    for h in filter(h -> h != heading .* -1, headings)
        next = pos .+ h
        if checkbounds(Bool, path, next...) &&
            path[next...] != ' ' &&
            path[next...] != (h[1]==0 ? '-' : '|')
            return (next, h)
        end
    end
    return (), ()
end

function foo(path::Matrix{Char})
    chars = Char[]
    pos = ind2sub(path, findfirst(path, '|'))
    heading = (0,1)
    c = path[pos...]
    steps = 1
    while true
        # @show c, pos, heading
        if c == '+'
            # turn
            # ...not backwards
            pos, heading = turn(path, pos, heading)
            if isempty(pos)
                return chars, steps
            end
            c = path[pos...]
        else
            c != '-' && c != '|' && push!(chars, c)
            pos = pos .+ heading
            if !checkbounds(Bool, path, pos...) || path[pos...] == ' '
                return chars, steps
            end
            c = path[pos...]
        end
        steps += 1
    end
end

path = parse_input(split(chomp(test_input), '\n'))
permutedims(path, (2,1))

foo(path)

parse_input(readlines("day19.input")) |> foo
