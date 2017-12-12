__precompile__(true)

"""
Main module for `LazySets.jl` -- a Julia package for calculus with convex sets.
"""
module LazySets

using RecipesBase, IterTools

export LazySet,
       ρ, support_function,
       σ, support_vector,
       dim,
       Approximations

"""
    LazySet

Abstract type for a lazy set.

### Notes

Every concrete `LazySet` must define a function `σ(d, X)`, representing the
support vector of `X` in a given direction `d`, and `dim`, the ambient dimension
of the set `X`.

`LazySet` types should be parameterized with a type `N`, typically `N<:Real`, to
support computations with different numeric types.
"""
abstract type LazySet end

# ============================
# Auxiliary types or functions
# ============================
include("LinearConstraints.jl")
include("helper_functions.jl")

# ===============================
# Types that inherit from LazySet
# ===============================
include("EmptySet.jl")
include("ZeroSet.jl")
include("Singleton.jl")
include("Ball2.jl")
include("BallInf.jl")
include("Ball1.jl")
include("Ballp.jl")
include("Hyperrectangle.jl")
#include("Polyhedron.jl")  # optional (long startup time!)
include("HPolygon.jl")
include("HPolygonOpt.jl")
include("VPolygon.jl")
include("Zonotope.jl")

# =================================
# Types representing set operations
# =================================
include("ConvexHull.jl")
include("CartesianProduct.jl")
include("ExponentialMap.jl")
include("LinearMap.jl")
include("MinkowskiSum.jl")

# =================================================================
# Algorithms for approximation of convex sets using support vectors
# =================================================================
include("support_function.jl")
include("Approximations/Approximations.jl")
include("plot_recipes.jl")

end # module
