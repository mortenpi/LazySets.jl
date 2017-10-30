import Base.*

export CartesianProduct, CartesianProductArray, is_contained, is_subset_box

"""
    CartesianProduct <: LazySet

Type that represents the cartesian product.

### Fields

- `X` -- convex set
- `Y` -- another convex set

For the cartesian product a several sets, there exists a special
type `CartesianProductArray`. 
"""
struct CartesianProduct <: LazySet
    X::LazySet
    Y::LazySet
    CartesianProduct(X::LazySet, Y::LazySet) = new(X, Y)
    CartesianProduct(Xarr::Array{LazySet, 1}) = length(Xarr) == 0 ?
            VoidSet(1) : (length(Xarr) == 1 ? Xarr[1] :
            new(Xarr[1], CartesianProduct(Xarr[2:length(Xarr)])))
end

function *(X::LazySet, Y::LazySet)::CartesianProduct
    CartesianProduct(X, Y)
end

"""
    dim(cp)

Ambient dimension of a Cartesian product.

### Input

- `cp` -- cartesian product
"""
function dim(cp::CartesianProduct)::Int64
    return dim(cp.X) + dim(cp.Y)
end

"""
    σ(d, cp)

Support vector of a Cartesian product.

### Input

- `d` -- direction

- `cp` -- cartesian product
"""
function σ(d::Vector{Float64}, cp::CartesianProduct)::Vector{Float64}
    return [σ(d[1:dim(cp.X)], cp.X); σ(d[dim(cp.X)+1:end], cp.Y)]
end


"""
    is_contained(d, cp)

Return whether a vector belongs to a given cartesian product set.

### Input

- `d`    --  a vector
- `cp`   -- a cartesian product

### Output

Return true iff d ∈ cp.
"""
function is_contained(d::Vector{Float64}, cp::CartesianProduct)::Bool
    return is_contained(d[1:dim(cp.X)], cp.X) && is_contained(d[dim(cp.X)+1:end], cp.Y)
end

# ==========================
#  Cartesian product of sets
# ==========================
"""
    CartesianProductArray <: LazySet

Type that represents the cartesian product of a finite number of sets.

### Fields

- `sfarray` -- array of sets
"""
mutable struct CartesianProductArray <: LazySet
    sfarray::Array{LazySet, 1}

    CartesianProductArray(sfarray) = new(sfarray)
end
CartesianProductArray() = CartesianProductArray(Array{LazySet, 1}(0))

"""
    dim(cp)

Ambient dimension of the Cartesian product of a finite number of sets.

### Input

- `cp` -- cartesian product array
"""
function dim(cp::CartesianProductArray)::Int64
    return length(cp.sfarray) == 0 ? 0 : sum([dim(sj) for sj in cp.sfarray])
end

"""
    σ(d, cp)

Support vector of the Cartesian product of a finite number of sets.

### Input

- `d` -- direction

- `cp` -- cartesian product array
"""
function σ(d::Union{Vector{Float64}, SparseVector{Float64,Int64}}, cp::CartesianProductArray)::Vector{Float64}
    svec = Vector{Float64}(length(d))
    jinit = 1
    for sj in cp.sfarray
        jend = jinit + dim(sj) - 1
        svec[jinit:jend] = σ(d[jinit:jend], sj)
        jinit = jend + 1
    end
    return svec
end

"""
    is_contained(d, cp)

Return whether a given vector is contained in the cartesian product of a
finite number of sets.

### Input

- `d` -- vector

- `cp` -- cartesian product array
"""
function is_contained(d::Vector{Float64}, cp::CartesianProductArray)::Bool
    contained = false
    jinit = 1
    for Xj in cp
        jend = dim(cp.Xj)
        contained = is_contained(d[jinit:jend], cp.Xj)
        if !contained
            break
        end
        jinit = jend + 1
    end
    return contained
end


"""
    is_subset_box(set, sets, indices)

Checks whether a given hyperrectangle-shaped Cartesian product set is a subset
of any of the other given hyperrectangle-shaped Cartesian product sets.

INPUT:

- ``set`` -- candidate hyperrectangle-shaped Cartesian product set
- ``sets`` -- array of other hyperrectangle-shaped Cartesian product sets
- ``indices`` -- indices for which we are interested in the subset relation
"""
@inline function is_subset_box(set::CartesianProductArray, sets::AbstractVector{CartesianProductArray}, indices::AbstractVector{Int64})::Bool
    arr1 = set.sfarray
    for s in sets
        arr2 = s.sfarray
        for idx in indices
            if !HPolygon.is_subset_single_box(arr1[idx], arr2[idx])
                @goto no_subset
            end
        end
        return true
        @label no_subset
    end
    return false
end
