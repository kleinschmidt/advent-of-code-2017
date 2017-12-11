# instructions of the form
#
# a inc -10 if b > 1
#
# don't know all the names ahead of time.  use a dict to keep track of values in
# the register.  either parse directly or use a macro maybe
#
# we'll overload the get/setindex methods to default to 0.  then we can parse
# the instructions to be `+=` or `-=`

mutable struct Registers{S,T}
    registers::Dict{S,T}
    max::T
    Registers{S,T}() where {S,T} = new(Dict{S,T}(), zero(T))
end

Base.getindex(r::Registers{S,T}, key::S) where {S,T} =
    get(r.registers, key, zero(T))
function Base.setindex!(r::Registers{S,T}, val::T, key::S) where {S,T} 
    if val > r.max
        r.max = val
    end
    setindex!(r.registers, val, key)
end

inst_map = Dict(:inc => :+=,
                :dec => :-=)

ref_expr(r::Symbol, s::Symbol) = Expr(:ref, :r, QuoteNode(s))

function (r::Registers)(inst::AbstractString)
    inst, cond = split(inst, " if ")
    reg, inst, by, = parse.(split(inst))
    cond = parse(cond)
    # parse cond: replace comparison LHS with r[] reference
    cond.args[2] = ref_expr(:r, cond.args[2])
    if eval(cond)
        # parse instruction: replace inc/dec with +/-=, and register with r[] ref
        eval(Expr(inst_map[inst], ref_expr(:r, reg), by))
    end
    r
end

r = Registers{Symbol, Int64}()

instructions = [
    "b inc 5 if a > 1",
    "a inc 1 if b < 5",
    "c dec -10 if a >= 1",
    "c inc -20 if c == 10"
]
r.(instructions)
r.max

r = Registers{Symbol, Int64}()
for l in eachline("day08.input")
    r(l)
end

maximum(values(r.registers))
r.max
