# circular buffer: start with just 0.  jump by N, insert 1 at next.

function foo(N, M)
    buffer = [0]
    idx = 1
    for i in 1:M
        idx = (idx-1+N) % length(buffer) + 2
        insert!(buffer, idx, i)
    end
    return buffer, idx
end

buffer_test, idx_test = foo(3, 2017)
buffer_test[idx_test+1]

buffer_test, idx_test = foo(354, 2017)
buffer_test[idx_test+1]

using BenchmarkTools

@btime foo(354, 100_000)

# just need to know what's after 0 (e.g., idx=2), so only track insert for
# those.

function bar(N, M)
    second = -1
    idx = 0
    for m in 1:M
        idx = (idx+N) % m + 1
        if idx == 1
            second = m
        end
    end
    return second
end

foo(354, 2017)[1][2]
bar(354, 2017)

bar(354, 50_000_000)
