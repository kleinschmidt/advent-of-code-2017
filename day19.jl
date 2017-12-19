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

# path = parse_input(split(chomp(test_input), '\n'))

mutable struct Path
    path::Matrix{Char}
    letters::Vector{Char}
    Path(p::Matrix{Char}) = new(p, Char[])
end

Path(s::S) where S<:AbstractString = Path(parse_input(split(chomp(s), '\n')))

import Base: start, done, next, iteratorsize, show

function show(io::IO, p::Path)
    println(io, "Path:")
    for j in 1:size(p.path, 2)
        for i in 1:size(p.path, 1)
            print(io, p.path[i,j])
        end
        println(io)
    end
end

iteratorsize(::Path) = Base.SizeUnknown()
start(p::Path) = (ind2sub(p.path, findfirst(p.path, '|')), (0,1))

matches(heading::Tuple{Int,Int}, c::Char) = c != ' ' && heading[1] != 0 ? c!='|' : c!='-'

headings = [(0,1), (1,0), (0,-1), (-1,0)]
neighbors(pos::Tuple{Int,Int}, heading::Tuple{Int,Int}) =
    [(pos .+ h, h) for h in headings if h != heading .* -1]
function turn(p::Path, pos::Tuple{Int,Int}, heading::Tuple{Int,Int})
    for (nex, head) in neighbors(pos, heading)
        if checkbounds(Bool, p.path, nex...) && matches(head, p.path[nex...])
            return nex, head
        end
    end
    return ()
end

done(p::Path, state) = isempty(turn(p, state...))
function next(p::Path, state)
    c = p.path[state[1]...]
    c, (c == '+' ? turn(p, state...) : (state[1] .+ state[2], state[2]))
end

Base.length(p::Path) = sum(c != ' ' for c in p.path)
Base.isempty(p::Path) = length(p) === 0

p = Path(test_input)

chs = Char[]
for c in p
    push!(chs, c)
end

collect(take((c for c in p), 10))

