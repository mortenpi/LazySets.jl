export SymmetricIntervalHull

"""
    SymmetricIntervalHull{S<:LazySet} <: LazySet

Type that represents the symmetric interval hull of a convex set.

### Fields

- `X` -- convex set
"""
struct SymmetricIntervalHull{S<:LazySet} <: LazySet
    X::S
end

"""
    SymmetricIntervalHull(∅::EmptySet)::EmptySet

The symmetric interval hull of an empty set.

### Input

- `∅` -- an empty set

### Output

The empty set because it is absorbing for the symmetric interval hull.
"""
SymmetricIntervalHull(∅::EmptySet)::EmptySet = ∅

"""
    dim(sih::SymmetricIntervalHull)::Int

Return the dimension of a symmetric interval hull of a convex set.

### Input

- `sih` -- symmetric interval hull of a convex set

### Output

The ambient dimension of the symmetric interval hull of a convex set.
"""
function dim(sih::SymmetricIntervalHull)::Int
    return dim(sih.X)
end

"""
    σ(d::AbstractVector{N}, sih::SymmetricIntervalHull
     )::AbstractVector{<:Real} where {N<:Real}

Return the support vector of a symmetric interval hull of a convex set in a
given direction.

### Input

- `d`  -- direction
- `sih` -- symmetric interval hull of a convex set

### Output

the support vector of the symmetric interval hull of a convex set in the given
direction.
"""
function σ(d::AbstractVector{N}, sih::SymmetricIntervalHull
          )::AbstractVector{<:Real} where {N<:Real}
    zero_N = zero(N)
    index = 0
    for i in eachindex(d)
        if d[i] != zero_N
            if index > 0
                index = -1
                break
            end
            index = i
        end
    end

    if index == 0
        # d is the zero vector
        return σ(d, sih.X)
    elseif index == -1
        # d is a nonzero non-unit vector
        error("a SymmetricIntervalHull's support vector for arbitrary " *
            "directions is not implemented yet")
    else
        # d is a unit vector in dimension 'index'
        pos = σ(d, sih.X)
        neg = σ(-d, sih.X)
        if abs(pos[index]) >= abs(neg[index])
            return pos
        else
            neg[index] *= -1
            return neg
        end
    end
end
