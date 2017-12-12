import Base.*

export LinearMap

"""
    LinearMap{S<:LazySet, N<:Real} <: LazySet

Type that represents a linear transformation ``M⋅S`` of a convex set ``S``.

### Fields

- `M`  -- matrix/linear map
- `sf` -- convex set
"""
struct LinearMap{S<:LazySet, N<:Real} <: LazySet
    M::AbstractMatrix{N}
    sf::S
end
# constructor from a linear map: perform the matrix multiplication immediately
LinearMap(M::AbstractMatrix{N}, map::LinearMap{S}) where {S<:LazySet, N<:Real} =
    LinearMap{S,N}(M * map.M, map.sf)

"""
```
    *(M::AbstractMatrix{<:Real}, S::LazySet)
```

Return the linear map of a convex set.

### Input

- `M` -- matrix/linear map
- `S` -- convex set

### Output

If the matrix is null, a `ZeroSet` is returned; otherwise a lazy linear map.
"""
function *(M::AbstractMatrix, X::LazySet)
    if findfirst(M) != 0
        return LinearMap(M, X)
    else
        return ZeroSet(dim(X))
    end
end

"""
```
    *(a::Real, S::LazySet)::LinearMap
```

Return a linear map of a convex set by a scalar value.

### Input

- `a` -- real scalar
- `S` -- convex set

### Output

The linear map of the convex set.
"""
function *(a::Real, S::LazySet)::LinearMap
    return LinearMap(sparse(a*I, dim(S)), S)
end

"""
```
    *(M::AbstractMatrix, Z::ZeroSet)
````
Linear map of a zero set.

### Input

- `M` -- abstract matrix
- `Z` -- zero set

### Output

The zero set with the output dimension of the linear map. 
"""
function *(M::AbstractMatrix, Z::ZeroSet)
    @assert dim(Z) == size(M, 2)
    return ZeroSet(size(M, 1))
end

"""
    dim(lm::LinearMap)::Int

Return the dimension of a linear map.

### Input

- `lm` -- linear map

### Output

The ambient dimension of the linear map.
"""
function dim(lm::LinearMap)::Int
    return size(lm.M, 1)
end

"""
    σ(d::AbstractVector{<:Real}, lm::LinearMap)::AbstractVector{<:Real}

Return the support vector of the linear map.

### Input

- `d`  -- direction
- `lm` -- linear map

### Output

The support vector in the given direction.
If the direction has norm zero, the result depends on the wrapped set.

### Notes

If ``L = M⋅S``, where ``M`` is a matrix and ``S`` is a convex set, it follows
that ``σ(d, L) = M⋅σ(M^T d, S)`` for any direction ``d``.
"""
function σ(d::AbstractVector{<:Real}, lm::LinearMap)::AbstractVector{<:Real}
    return lm.M * σ(lm.M.' * d, lm.sf)
end
