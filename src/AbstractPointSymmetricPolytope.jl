export AbstractPointSymmetricPolytope,
       center,
       an_element,
       vertices_list,
       singleton_list

"""
    AbstractPointSymmetricPolytope{N<:Real} <: LazySet

Abstract type for point symmetric, polytopic sets.
It combines the `AbstractPointSymmetric` and `AbstractPolytope` interfaces.
Such a type combination is necessary as long as Julia does not support
[multiple inheritance](https://github.com/JuliaLang/julia/issues/5).

### Notes

Every concrete `AbstractPointSymmetricPolytope` must define the following
functions:
- from `AbstractPointSymmetric`:

  - `center(::AbstractPointSymmetric{N})::Vector{N}` -- return the center point
- from `AbstractPolytope`:
  - `vertices_list(::AbstractPointSymmetricPolytope{N})::Vector{Vector{N}}`
     -- return a list of all vertices

```jldoctest
julia> subtypes(AbstractPointSymmetricPolytope)
3-element Array{Union{DataType, UnionAll},1}:
 LazySets.AbstractHyperrectangle
 LazySets.Ball1
 LazySets.Zonotope
```
"""
abstract type AbstractPointSymmetricPolytope{N<:Real} <: LazySet end


# --- LazySet interface functions ---


"""
    ⊆(P::AbstractPointSymmetricPolytope, S::LazySet)::Bool

Check whether a polytope is contained in a convex set.

### Input

- `P` -- polytope (containee?)
- `S` -- convex set (container?)

### Output

`true` iff ``P ⊆ S``.

### Algorithm

Since ``S`` is convex, ``P ⊆ S`` iff ``v_i ∈ S`` for all vertices ``v_i`` of
``P``.
"""
function ⊆(P::AbstractPointSymmetricPolytope, S::LazySet)::Bool
    @assert dim(P) == dim(S)

    for v in vertices_list(P)
        if !∈(v, S)
            return false
        end
    end
    return true
end


# --- common AbstractPointSymmetric functions (copy-pasted) ---


"""
    dim(P::AbstractPointSymmetricPolytope)::Int

Return the ambient dimension of a point symmetric set.

### Input

- `P` -- set

### Output

The ambient dimension of the set.
"""
@inline function dim(P::AbstractPointSymmetricPolytope)::Int
    return length(center(P))
end


"""
    an_element(P::AbstractPointSymmetricPolytope{N})::Vector{N} where {N<:Real}

Return some element of a point symmetric polytope.

### Input

- `P` -- point symmetric polytope

### Output

The center of the point symmetric polytope.
"""
function an_element(P::AbstractPointSymmetricPolytope{N}
                   )::Vector{N} where {N<:Real}
    return center(P)
end


# --- common AbstractPolytope functions (copy-pasted) ---


"""
    singleton_list(P::AbstractPointSymmetricPolytope{N}
                  )::Vector{Singleton{N}} where {N<:Real}

Return the vertices of a polytopic as a list of singletons.

### Input

- `P` -- a polytopic set

### Output

List containing a singleton for each vertex.
"""
function singleton_list(P::AbstractPointSymmetricPolytope{N}
                       )::Vector{Singleton{N}} where {N<:Real}
    return [Singleton(vi) for vi in P.vertices_list]
end
