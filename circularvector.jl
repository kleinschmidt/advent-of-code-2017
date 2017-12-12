# need some kind of circular vector.

mutable struct CircularVector{T} <: AbstractArray{T,1}
    elements::Vector{T}
    length::Int
    first_i::Int
end

CircularVector(elements::Any) = CircularVector(Vector(elements))
CircularVector(elements::Vector{T}) where T = CircularVector(elements, 1)
CircularVector(elements::Vector{T}, first_i::Int) where T =
    CircularVector{T}(elements, length(elements), first_i)

circindex(cv::CircularVector, idx::Int) = mod(idx-cv.first_i, cv.length) + cv.first_i

import Base: linearindices, getindex, setindex!, show, display, size

size(cv::CircularVector) = size(cv.elements)

# need these methods to handle reverse!
linearindices(cv::CircularVector) = cv.first_i:typemax(Int)
getindex(cv::CircularVector, idx::Int) = cv.elements[circindex(cv, idx)]
setindex!(cv::CircularVector{T}, val::T, idx::Int) where T =
    setindex!(cv.elements, val, circindex(cv, idx))

display(cv::CircularVector{T}) where T = display(cv.elements)
show(cv::CircularVector{T}, io) where T = show(cv.elements, io)
