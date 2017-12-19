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
    snd::Int
    rcv::Int
    Registers(insts::Vector) = begin
        d = Dict{Symbol,Int}()
        for i in insts
            i[2] isa Symbol && setindex!(d, 0, i[2])
        end
        new(d, typemax(Int), typemin(Int))
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
    elseif op == :snd
        r.snd = r[args[1]]
    elseif op == :add
        r[args[1]] += r[args[2]]
    elseif op == :mul
        r[args[1]] *= r[args[2]]
    elseif op == :mod
        r[args[1]] = mod(r[args[1]], r[args[2]])
    elseif op == :rcv
        r[args[1]] > 0 && (r.rcv = r.snd)
    elseif op == :jgz
        if r[args[1]] > 0
            return r[args[2]]
        end
    end
    return 1
end


insts = split(chomp(insts_test), "\n") |> parse_insts

function foo(insts)
    rs = Registers(insts)
    idx = 1
    while !rcvd(rs)
        @show idx, insts[idx]
        idx += rs(insts[idx]...)
    end
    rs
end

foo(insts)

eachline("day18.input") |> parse_insts |> foo
