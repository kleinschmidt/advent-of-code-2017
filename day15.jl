# two streams of ints: generate next element by multiplying by stream specific
# int and then reming by shared number (0x00000000ffffffff).

println(bits(2147483647)); println(bits(0x000000007fffffff))

match(a,b) = xor(a,b) & UInt(0xffff) === zero(UInt)

function foo(state::Tuple{UInt,UInt}, n::Int)
    mults = (UInt(16807), UInt(48271))
    divisor = UInt(2147483647)

    total = 0
    
    for _ in 1:n
        state = (state .* mults) .% divisor
        total += match(state...)
    end

    return total
end



test_seeds = (UInt(65), UInt(8921))
foo(test_seeds, 5)
foo(test_seeds, 40_000_000)

seeds = (UInt(634), UInt(301))

struct Generator
    seed::UInt
    mult::UInt
    divisor::UInt
end

import Base: start, done, next, iteratorsize

start(g::Generator) = g.seed
next(g::Generator, state::UInt) = (state = (state * g.mult) % g.divisor; (state, state))
done(g::Generator, state::UInt) = false
iteratorsize(::Type{Generator}) = Base.IsInfinite()

A = Generator(65, 16807, 2147483647)
B = Generator(8921, 48271, 2147483647)


function foo2(seeds::Tuple{UInt, UInt}, n::Int)
    A = Generator(seeds[1], 16807, 2147483647)
    B = Generator(seeds[2], 48271, 2147483647)
    reduce(+, 0, match(a,b) for (a,b) in take(zip(A,B), n))
end

foo2(seeds, 40_000_000) == foo(seeds, 40_000_000)

using BenchmarkTools
@benchmark foo2((UInt(634), UInt(301)), 10_000)
@benchmark foo((UInt(634), UInt(301)), 10_000)

# something like a 4x perf penalty for using the iterator :-/

mult4(x) = (xor(x, 0x3) & 0x3) === UInt(0x3)
mult8(x) = (xor(x, 0x7) & 0x7) === UInt(0x7)

function foo3(seeds::Tuple{UInt, UInt}, n::Int)
    A = Iterators.filter(mult4, Generator(seeds[1], 16807, 2147483647))
    B = Iterators.filter(mult8, Generator(seeds[2], 48271, 2147483647))
    reduce(+, 0, match(a,b) for (a,b) in take(zip(A,B), n))
end

foo3(test_seeds, 5_000_000)
foo3(seeds, 5_000_000)
