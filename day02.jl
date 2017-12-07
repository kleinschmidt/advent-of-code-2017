# "checksum" for spread sheets: range of values in row, summed across rows
x = readdlm("day02.input", Int)
mapreduce(x->x[2]-x[1], +, extrema(x, 2))

# find divisor and divisable in each row.
total = 0
for i in 1:size(x,1)
    for j in 1:(size(x,2)-1)
        ot = total
        for k in (j+1):size(x,2)
            if x[i,j] % x[i,k] == 0
                @show x[i,j], x[i,k]
                total += x[i,j] ÷ x[i,k] # integer division
                continue
            elseif x[i,k] % x[i,j] == 0
                @show x[i,j], x[i,k]
                total += x[i,k] ÷ x[i,j]
                continue
            end
        end
        ot != total && continue
    end
end
