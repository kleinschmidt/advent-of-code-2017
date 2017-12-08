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

# keep track of ring number and ring idx in loop.  If we're in ring r, each side
# is 2*r long.  "side index" is idx % (2*r)

# middle of side: shift one off, push one on.
# one before corner side_idx==2*r-1: shift one off.
# corner side_idx==0: shift one off
# after corner side_idx==1: push one on, unshift one from outer ring

# special cases:
# start of new ring: move new rnig to old ring. seed old ring context with [0,
# last[end], last[1]].
# end of ring: AGH you need to manage the wrap around. so that the start of the
# current ring gets picked up at the end.  so when ring_idx == 8*r-1 pick up
# cur[1]

# an iterator
mutable struct FibSpiral
    cur::Vector{Int}
    prev::Vector{Int}
    neighbors::Vector{Int}
end

using Base: start, next, done
function start(f::FibSpiral)
    f.cur=Int[]
    f.prev=[1]
    neighbors=[1]
    (1, 1)                      # ring number, within-ring idx
end

function next(f::FibSpiral, state::Tuple{Int})
    r, idx = state
    side_idx = idx % 2r
    # compute current value
    
end

done(::FibSpiral, state) = false       # never done spiraling

# fuck this. just do it directly.  use an offset array and an iterator to
# generate cartesian indices

# what ring are we in 
function spiral2xy(idx::Int)
    r = rind_dist(idx)
    spoke_idx = spoke_i(idx)
    side_number = spoke_idx ÷ (2r)
end



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
start(::Spiral) = (1,0)
function next(s::Spiral, state::NTuple{2,Int})
    # are we at end of a ring?
    if abs(state[1]) == abs(state[2])
        if all(sign.(state) .== -1)
            state .+= s.heading
            turn!(s)
        else
            turn!(s)
            state .+= s.heading
        end
    else
        state .+= s.heading
    end
    return state, state
end



# we have two sources: prev. ring and current ring.
#
# prev ring: start iwith [last, first].  to move, shift one on, except moving
# onto corner or before.  shift one off, except when moving off corner or one
# after.
#
# current ring start empty.  compute value based on current context.  always
# push on


# shift one on.  first one on a new ring: we have last and first of last ring.
# generally shift one on, one off. except that when you arrive a corner


# alternatively, explicitly compute which indices are adjacent in this and
# prev. ring.  take ring index 1:(2r+1)^2.  convert to spoke distance, get
# neighbors +/-1.  if neighbors spoke dist is more than max of previous ring,
# truncate.
