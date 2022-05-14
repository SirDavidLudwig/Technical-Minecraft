cdef class PointClosure:
	cpdef float apply(self, Point point):
		raise NotImplementedError()

cdef class PointCombinedClosure(PointClosure):
	def __init__(self, ):
		...

	def apply(self, Point point):
		pass

cdef class PointContinentsClosure(PointClosure):
	cpdef float apply(self, Point point):
		return point.continents

cdef class PointErosionClosure(PointClosure):
	cpdef float apply(self, Point point):
		return point.erosion

cdef class PointRidgesClosure(PointClosure):
	cpdef float apply(self, Point point):
		return point.ridges

cdef class Point:
	def __init__(self, float continents, float erosion, float ridges):
		self.continents = continents
		self.erosion = erosion
		self.ridges = ridges
