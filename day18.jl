parse_insts(lines) = [(parse.(split(l))...) for l in lines]

# insts = parse_insts(eachline("day18.input"))
insts_test = """
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
"""


mutable struct Registers
    d::Dict{Symbol,Int}
    snd::Channel{Int}
    rcv::Channel{Int}
    Registers(insts::Vector) = begin
        d = Dict{Symbol,Int}()
        for i in insts
            i[2] isa Symbol && setindex!(d, 0, i[2])
        end
        new(d, Channel{Int}(Inf), Channel{Int}(Inf))
    end
end

rcvd(rs::Registers) = rs.rcv > typemin(Int)

Base.getindex(rs::Registers, s::Symbol) = rs.d[s]
Base.getindex(rs::Registers, i::Int) = i
Base.setindex!(rs::Registers, val::Int, key::Symbol) = setindex!(rs.d, val, key)

# run one instruction, returning index offset
function (r::Registers)(op::Symbol, args...)
    if op == :set
        r[args[1]] = r[args[2]]
    elseif op == :add
        r[args[1]] += r[args[2]]
    elseif op == :mul
        r[args[1]] *= r[args[2]]
    elseif op == :mod
        r[args[1]] = mod(r[args[1]], r[args[2]])
    elseif op == :jgz
        if r[args[1]] > 0
            return r[args[2]]
        end
    elseif op == :rcv
        if r[args[1]] > 0
            ## only take the LAST one produced
            rcvd = 0
            while isready(r.snd)
                rcvd = take!(r.snd)
            end
            put!(r.rcv, rcvd)
        end
    elseif op == :snd
        put!(r.snd, r[args[1]])
    end
    return 1
end


function foo(out::Channel, insts)
    ## @show out
    rs = Registers(insts)
    rs.rcv = out
    idx = 1
    while true
        ## @show idx, insts[idx]
        idx += rs(insts[idx]...)
    end
    rs
end

foo(insts) = (c) -> foo(c, insts)

c = split(chomp(insts_test), "\n") |> parse_insts |> foo |> (c)->Channel(c, ctype=Int64)
take!(c)
close(c)


c = eachline("day18.input") |> parse_insts |> foo |> (c)->Channel(c, ctype=Int64)
r = take!(c)
close(c)

# star 2: snd and rcv are send and receive; two of these run in parallel, .p has
# 0 for the first and 1 for the second.
#
# use two Channels: one for 0->1 and one for 1<-0.  change snd and rcv to put!
# and take! from appropriate channel.
#
# need a coordinating function to initialize both registers and start tasks (?).
# I think the way to do this is to have the instructions loop run inside a task
# with a channel that will take the return value.  we need to know how many
# times program 1 (second one) sends a value.
