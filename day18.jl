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

parse_insts(lines) = [(parse.(split(l))...) for l in lines]

mutable struct Registers
    d::Dict{Symbol,Int}
    snd::Channel{Int}
    rcv::Channel{Int}
    sent::Int
    recieving::Bool
    other::Union{Registers,Void}
    Registers(insts::Vector) = begin
        d = Dict{Symbol,Int}()
        for i in insts
            i[2] isa Symbol && setindex!(d, 0, i[2])
        end
        new(d, Channel{Int}(Inf), Channel{Int}(Inf), 0, false, nothing)
    end
end

rcvd(rs::Registers) = rs.rcv > typemin(Int)

Base.getindex(rs::Registers, s::Symbol) = rs.d[s]
Base.getindex(rs::Registers, i::Int) = i
Base.setindex!(rs::Registers, val::Int, key::Symbol) = setindex!(rs.d, val, key)

const DONE = typemin(Int)

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
        if !isready(r.other.snd) && r.other.recieving && !isready(r.snd)
            # handle blocking here...
            # this way might introduce a race condition...might need some kind
            # of lock.  unlikely though?

            # also, how to keep the other task from blocking???  maybe send a
            # sentinel value to it here.
            println("DONE (sender)")
            put!(r.snd, DONE)
            return
        end
        r.recieving = true
        r[args[1]] = take!(r.rcv)
        if r[args[1]] == DONE
            println("DONE (reciever)")
            return
        end
        r.recieving = false
    elseif op == :snd
        r.sent += 1
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
        idx_inc = rs(insts[idx]...)
        idx_inc === nothing && break
        idx += idx_inc
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
#
# each set of registers needs a way to check whether the other is trying to
# receive.  so need to set a bit before the possibly blocking call to take!, and
# keep a reference to the other around.
#
# other question is how to get the value out.  Maybe wrap both registers in a
# task, and return from the function 


function bar(rs, insts, n)
    idx = 1
    while (idx_inc = rs(insts[idx]...)) isa Int
        # @show n, idx, insts[idx]
        idx += idx_inc
    end
    return rs
end

function duet(insts)
    r0 = Registers(insts)
    r1 = Registers(insts)
    r1[:p] = 1

    r1.snd, r1.rcv = r0.rcv, r0.snd
    r0.other, r1.other = r1, r0
    @show r0, r1

    @sync begin
        @async bar(r0, insts, 0)
        @async bar(r1, insts, 1)
    end

    return r0, r1
end

insts_test2 = 
"""
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d
""" |> chomp |> (x) -> split(x, "\n") |> parse_insts

r0,r1 = duet(insts_test2)

r0,r1 = eachline("day18.input") |> parse_insts |> duet
