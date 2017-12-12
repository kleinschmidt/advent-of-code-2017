using Base.Test
include("circularvector.jl")


headings = Dict("n" => 1, "ne" => 2, "se" => 3, "s" => 4, "sw" => 5, "nw" => 6)

function walk(directions)
    max_dist = 0
    cur_dist = 0
    steps = CircularVector(zeros(Int, 6))
    for step in split(directions, ",")
        heading = headings[step]
        if steps[heading + 3] > 0
            steps[heading + 3] -= 1
            cur_dist -= 1
        elseif steps[heading + 2] > 0
            # n + se = ne
            steps[heading + 2] -= 1
            steps[heading + 1] += 1
        elseif steps[heading - 2] > 0
            # n + sw = nw
            steps[heading - 2] -= 1
            steps[heading - 1] += 1
        else
            steps[heading] += 1
            cur_dist += 1
            if cur_dist > max_dist
                max_dist = cur_dist
            end
        end
    end
    steps, max_dist, cur_dist
end

steps, _ = walk("ne,ne,ne")
walk("ne,ne,sw,sw")
walk("ne,ne,s,s")
walk("se,sw,se,sw,sw")

steps, max_dist, cur_dist = walk(chomp(readstring("day11.input")))
