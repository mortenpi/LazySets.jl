import Base.∈

export Ball1

"""
    Ball1{N<:Real} <: AbstractPointSymmetricPolytope{N}

Type that represents a ball in the 1-norm, also known as Manhattan or Taxicab
norm.

It is defined as the set

```math
\\mathcal{B}_1^n(c, r) = \\{ x ∈ \\mathbb{R}^n : ∑_{i=1}^n |c_i - x_i| ≤ r \\},
```
where ``c ∈ \\mathbb{R}^n`` is its center and ``r ∈ \\mathbb{R}_+`` its radius.

### Fields

- `center` -- center of the ball as a real vector
- `radius` -- radius of the ball as a scalar (``≥ 0``)

### Examples

Unit ball in the 1-norm in the plane:

```jldoctest ball1_constructor
julia> B = Ball1(zeros(2), 1.)
LazySets.Ball1{Float64}([0.0, 0.0], 1.0)
julia> dim(B)
2
```

We evaluate the support vector in the East direction:

```jldoctest ball1_constructor
julia> σ([0.,1], B)
2-element Array{Float64,1}:
 0.0
 1.0
```
"""
struct Ball1{N<:Real} <: AbstractPointSymmetricPolytope{N}
    center::Vector{N}
    radius::N

    # default constructor with domain constraint for radius
    Ball1{N}(center, radius) where N =
        radius < zero(N) ? throw(DomainError()) : new(center, radius)
end
# type-less convenience constructor
Ball1(center::Vector{N}, radius::N) where {N<:Real} = Ball1{N}(center, radius)


# --- AbstractPointSymmetric interface functions ---


"""
    center(B::Ball1{N})::Vector{N} where {N<:Real}

Return the center of a ball in the 1-norm.

### Input

- `B` -- ball in the 1-norm

### Output

The center of the ball in the 1-norm.
"""
function center(B::Ball1{N})::Vector{N} where {N<:Real}
    return B.center
end


# --- AbstractPolytope interface functions ---


"""
    vertices_list(B::Ball1{N})::Vector{Vector{N}} where {N<:Real}

Return the list of vertices of a ball in the 1-norm.

### Input

- `B` -- ball in the 1-norm

### Output

A list containing the vertices of the ball in the 1-norm.
"""
function vertices_list(B::Ball1{N})::Vector{Vector{N}} where {N<:Real}
    vertices = Vector{Vector{N}}()
    sizehint!(vertices, 2 * dim(B))
    v = copy(B.center)
    for i in 1:dim(B)
        v[i] += B.radius
        push!(vertices, copy(v))
        v[i] = B.center[i] - B.radius
        push!(vertices, copy(v))
        v[i] = B.center[i]
    end
    return vertices
end


# --- LazySet interface functions ---


"""
    σ(d::AbstractVector{N}, B::Ball1)::AbstractVector{N} where {N<:Real}

Return the support vector of a ball in the 1-norm in a given direction.

### Input

- `d` -- direction
- `B` -- ball in the 1-norm

### Output

Support vector in the given direction.
"""
function σ(d::AbstractVector{N}, B::Ball1{N})::AbstractVector{N} where {N<:Real}
    res = copy(B.center)
    imax = indmax(abs.(d)) 
    res[imax] = sign(d[imax]) * B.radius
    return res
end

"""
    ∈(x::AbstractVector{N}, B::Ball1{N})::Bool where {N<:Real}

Check whether a given point is contained in a ball in the 1-norm.

### Input

- `x` -- point/vector
- `B` -- ball in the 1-norm

### Output

`true` iff ``x ∈ B``.

### Notes

This implementation is worst-case optimized, i.e., it is optimistic and first
computes (see below) the whole sum before comparing to the radius.
In applications where the point is typically far away from the ball, a fail-fast
implementation with interleaved comparisons could be more efficient.

### Algorithm

Let ``B`` be an ``n``-dimensional ball in the 1-norm with radius ``r`` and let
``c_i`` and ``x_i`` be the ball's center and the vector ``x`` in dimension
``i``, respectively.
Then ``x ∈ B`` iff ``∑_{i=1}^n |c_i - x_i| ≤ r``.

### Examples

```jldoctest
julia> B = Ball1([1., 1.], 1.);

julia> ∈([.5, -.5], B)
false
julia> ∈([.5, 1.5], B)
true
```
"""
function ∈(x::AbstractVector{N}, B::Ball1{N})::Bool where {N<:Real}
    @assert length(x) == dim(B)
    sum = zero(N)
    for i in eachindex(x)
        sum += abs(B.center[i] - x[i])
    end
    return sum <= B.radius
end
