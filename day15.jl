# two streams of ints: generate next element by multiplying by stream specific
# int and then reming by shared number (0x00000000ffffffff).

println(bits(2147483647)); println(bits(0x000000007fffffff))

function foo(state::Tuple{UInt,UInt}, n::Int)
    mults = (UInt(16807), UInt(48271))
    divisor = UInt(2147483647)
    low16mask = UInt(0xffff)

    total = 0
    
    for _ in 1:n
        state = (state .* mults) .% divisor
        # println.(bits.(state))
        # println(bits(xor(state...)))
        # println(bits((xor(state...) & low16mask)))
        # println((xor(state...) & low16mask) === zero(UInt))
        total += (xor(state...) & low16mask === zero(UInt))
    end

    return total
end



test_seeds = (UInt(65), UInt(8921))
foo(test_seeds, 5)
foo(test_seeds, 40_000_000)

@btime foo((UInt(634), UInt(301)), 40_000_000)


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

    total = 0
    for (a,b) in take(zip(A,B), n)
        total += (xor(a,b) & 0xffff === zero(UInt))
    end
    return total
end

foo2((UInt(634), UInt(301)), 40_000_000) == foo((UInt(634), UInt(301)), 40_000_000)
@benchmark foo2((UInt(634), UInt(301)), 10_000)
@benchmark foo((UInt(634), UInt(301)), 10_000)

# something like a 4x perf penalty for using the iterator :-/

Int.(collect(take(Iterators.filter(x->xor(x, 0x3)&0x3 === 0x3, A), 10)))
