# ConvexHull of two 2D Ball2
b1 = Ball2([0., 0.], 1.)
b2 = Ball2([1., 2.], 1.)
# Test Construction
ch1 = ConvexHull(b1, b2)
ch2 = CH(b1, b2)
@test ch1 == ch2
# Test Dimension
@test dim(ch1) == 2
# Test Support Vector
d = [1., 0.]
@test σ(d, ch1) == [2., 2.]
d = [-1., 0.]
@test σ(d, ch1) == [-1., 0.]
d = [0., 1.]
@test σ(d, ch1) == [1., 3.]
d = [0., -1.]
@test σ(d, ch1) == [0., -1.]

# test convex hull of a set of points using the default algorithm
points = [[0.9,0.2], [0.4,0.6], [0.2,0.1], [0.1,0.3], [0.3,0.28]]
@test convex_hull(points) == [ [0.1,0.3],[0.2,0.1], [0.9,0.2],[0.4,0.6] ]
