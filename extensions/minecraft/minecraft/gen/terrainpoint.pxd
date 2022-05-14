cdef class PointClosure:
	cpdef float apply(self, Point point)
	cpdef PointClosure combine(PointClosure other, PointClosureAdder adder)

cdef class PointContinentsClosure(PointClosure):
	cpdef float apply(self, Point point)

cdef class PointErosionClosure(PointClosure):
	cpdef float apply(self, Point point)

cdef class PointRidgesClosure(PointClosure):
	cpdef float apply(self, Point point)

cdef PointClosure pointContinents
cdef PointClosure pointErosion
cdef PointClosure pointRidges

cdef class Point:
	cdef public float continents
	cdef public float erosion
	cdef public float ridges
