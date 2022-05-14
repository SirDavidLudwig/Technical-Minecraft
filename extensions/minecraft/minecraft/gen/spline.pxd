from minecraft.gen.terrainpoint cimport Point, PointClosure

cdef class Spline:
	cdef PointClosure coordinate
	cdef float[:] locations
	cdef list values # PointClosure[:]
	cdef float[:] derivatives
	cdef unicode name

	cpdef float apply(self, Point point)

cdef class SplineConstant(PointClosure):
	cdef float value
	cpdef float apply(self, Point point)

cdef class SplineBuilder:

	cdef PointClosure coordinate
	cdef float[:] locations
	cdef list values
	cdef float[:] derivatives
	cdef float previousLocation
	cdef unicode name

	cpdef SplineBuilder named(self, unicode name)

	cpdef SplineBuilder addPoint(self, float x, float y, float z)
	cpdef SplineBuilder addPointFromSpline(self, float x, Spline spline, float z)
	cpdef SplineBuilder add(self, float x, PointClosure coordinate, float z)

	cpdef Spline build(self)
