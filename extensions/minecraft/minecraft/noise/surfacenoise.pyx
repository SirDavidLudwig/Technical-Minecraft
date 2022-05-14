cdef class SurfaceNoise:
	cdef double getValue(self, double x, double y, double yScale, double yMax):
		raise NotImplementedError()
