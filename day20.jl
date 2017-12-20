using ArgCheck

# find long-term min manhattan distance under acceleration.  distance is ~a^2 in
# long term, so find minimum sum(a^2)

input =  readlines("day20.input")

parse_line(line) =
    [parse.(Int, split(x, ','))
     for x
     in match(r"p=<([^>]*)>, v=<([^>]*)>, a=<([^>]*)>", line).captures]

min_d = typemax(Int)
min_i = -1
for (i, line) in enumerate(readlines("day20.input"))
    p, v, a = parse_line(line)
    d = sum(a.^2)
    @show i, d, line
    if d < min_d
        min_d = d
        min_i = i-1
    end        
end


# detect collisions!  the paths follow a quadratic equation.  to determine if a
# pair will collide, subtract coefs and solve that system only integer solutions
# so it's probably easier.


# at each time step:
# v += a
# p += v
#
# at t=0, start at p, with velocity v and acc a.
# t=1: p + (v+a)
# t=2: p + (v+a) + (v+a+a)
# t=3: p + (v+a) + (v+2a) + (v+3a) = p + 3v + 6a
# t=4: p + (v+a) + (v+2a) + (v+3a) + (v+4a) = p + 4v + 10a
# t=n: p + n*a + ∑_i=1^n (i*a) = p + n*v + n*(n+1)/2*a = p + (v+a/2)n + a/2 n^2
#
# zeros when an^2 + (2v+a)n + 2p = 0


test_input = """
p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>    
p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>    -6 -5 -4 -3 -2 -1  0  1  2  3
p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>    (0)   (1)   (2)            (3)
p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>
"""

struct Particle{N,T}
    p::NTuple{N,T}
    v::NTuple{N,T}
    a::NTuple{N,T}
end

function Particle(p::Vector{T}, v::Vector{T}, a::Vector{T}) where T
    @argcheck length(p) == length(v) == length(a)
    N = length(p)
    # convert "raw" position/veloicity/accel to 2*quardict form, based on
    # t=n: p + n*a + ∑_i=1^n (i*a) = p + n*v + n*(n+1)/2*a = p + (v+a/2)n + a/2 n^2
    p = 2.*p
    v = 2.*v .+ a
    Particle{N,T}((p...), (v...), (a...))
end

(p::Particle)(t::Int) = (p.p .+ p.v.*t .+ p.a.*t^2) .÷ 2

function go(p::Particle, t::Int)
    # convert back to "original" p,v,a:
    x = p.p .÷ 2
    v = (p.v .- p.a) .÷ 2
    a = p.a
    for n in 1:t
        v = v .+ a
        x = x .+ v
    end
    x
end

Base.:-(a::Particle, b::Particle) = Particle(a.p .- b.p, a.v .- b.v, a.a .- b.a)

struct All end
Base.intersect(::All, x) = x
Base.intersect(x, ::All) = x
Base.intersect(::All, ::All) = All()
Base.zero(::All) = []
# find when p crosses (0,0,0), if ever.  use quadratic formula:
#
# root = (-v ± √(v^2 - 4pa)) / 2p
function roots(p::T, v::T, a::T) where T
    if iszero(p) && iszero(v) && iszero(a)
        # all zeros, everything is a root
        return All()
    elseif iszero(a) && isinteger(-p/v)
        # no acceleration: single root
        return round(Int, -p/v)
    else
        sqrt_part = v^2 - 4*p*a
        if sqrt_part >= 0 && isinteger(sqrt(sqrt_part))
            rs = ([-1,1] .* sqrt(sqrt_part) .- v) ./ (2*a)
            return [round(Int, r) for r in rs if isinteger(r)]
        else
            return Int[]
        end
    end
end

# roots for the whole thing are where all dimensions share a root
function roots(p::Particle{N}) where N
    reduce(intersect, roots(p.p[n], p.v[n], p.a[n]) for n in 1:N)
end





# what do we want to know from this? the first time after 0 that particles will
# collide.
function collide(a::Particle, b::Particle)
    if a == b
        return false, 0
    else
        ts = filter(x->x>0, roots(a-b))
        return isempty(ts) ? (false, 0) : (true, minimum(ts))
    end
end

function collisions(ps::Vector{Particle{N,T}}) where {N,T}
    collns = collide.(ps, reshape(ps, (1,length(ps))))
    collides = getindex.(collns, 1)
    
    ts = getindex.(collns, 2)

    collided = Set{Int}()
    while any(collides)
        min_t = minimum(ts[i] for i in find(collides))
        this_col = reduce(union!, Set{Int}(),
                          ind2sub(collides, i)
                          for i
                          in eachindex(collides)
                          if ts[i]==min_t)
        for i in this_col
            collides[i,:] .= false
            collides[:,i] .= false
        end
        union!(collided, this_col)
    end
    collided
end

foo(ps::Vector{Particle{N,T}}) where {N,T} = length(ps) - length(collisions(ps))

ps_test = [Particle(pva...) for pva in parse_line.(split(chomp(test_input), '\n'))]
foo(ps_test) == 1

ps = [Particle(parse_line(line)...) for line in eachline("day20.input")]

collisions(ps)
foo(ps)

