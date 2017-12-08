# convert "spiral index" to cartesian index:
# 5 4 3 12
# 6 1 2 11
# 7 8 9 10 etc...
#
# two steps: find ring and locate position within ring.  actually just on edge
# will do.
#
# size of rings go 1, 9, 25, ..., (2i-1)^2,
# get ring index as √x ≤ 2i-1 ⟹ √(x)/2-0.5 ≤ i
ring_dist(i::Int) = round(Int, ceil(sqrt(i)/2 - 0.5))

# to get spoke, first subtract off (ring-1)^2 to get "ring index".  this will
# start at 1 and to ring^2.  we want to get this relative to midpoint of each
# side: rem ring/4 (length of side), subtract ring/8 (midpoint), absolute value
spoke_i(i::Int) = i-(2*ring_dist(i)-1)^2
function signed_spoke_dist(i::Int)
    i == 1 && return 0
    r = ring_dist(i)
    quarter_len = 2*r
    return rem(spoke_i(i), quarter_len) - r
end
spoke_dist(i::Int) = abs(signed_spoke_dist(i))

dist(i) = ring_dist(i) + spoke_dist(i)

spoke_dist.(2:25)

hcat(2:35, ring_dist.(2:35), spoke_dist.(2:35))

dist(368078)

# some kinda fibonacci thing: each square gets sum of adjacent cells (including
# diagonals), in spiral order.  need to keep track of current and last ring:
#
# 147  142  133  122   59                         -2
# 304    5    4    2   57                          1
# 330   10    1    1   54  <- signed_ spoke_dist = 0
# 351   11   23   25   26                         -1
# 362  747  806--->   ...

import Base: start, next, done

mutable struct Spiral
    heading::NTuple{2,Int}
end

# turn counter clockwise:
# 1,0 -> 0,1
# 0,1 -> -1,0
# -1,0 -> 0,-1
# 0,-1 -> 1,0
# switch x,y.  switch sign if y!=0

turn!(s::Spiral) = (s.heading = (s.heading[2], s.heading[1]) .* (-1)^s.heading[2]; s)

Spiral() = Spiral((0,1))

done(::Spiral, state) = false
start(::Spiral) = (0,0)
function next(s::Spiral, state::NTuple{2,Int})
    # are we at end of a ring?
    if abs(state[1]) == abs(state[2])
        if state[1] ≥ 0 && state[2] ≥ 0
            state = state .+ s.heading
            turn!(s)
        else
            turn!(s)
            state = state .+ s.heading
        end
    else
        state = state .+ s.heading
    end
    return state, state
end

Base.iteratorsize(::Type{Spiral}) = Base.IsInfinite()

using OffsetArrays
grid = OffsetArray(Int, -3:3, -3:3)
fill!(grid, 0)
grid[0,0] = 1

for (i, xy) in enumerate(Iterators.take(Spiral(), 24))
    x, y = xy
    grid[xy...] = sum(grid[(x-1):(x+1), (y-1):(y+1)])
    @show i, grid[xy...]
end




input = 368078
grid_size = round(Int, ceil(sqrt(input))) ÷ 2
grid = OffsetArray(Int, -grid_size:grid_size, -grid_size:grid_size)
fill!(grid, 0)
grid[0,0] = 1

s = Spiral()
x,y = start(s)

while grid[x,y] ≤ input
    @show (x,y), _ = next(s, (x,y))
    grid[x,y] = sum(grid[(x-1):(x+1), (y-1):(y+1)])
end

output = grid[x,y]
