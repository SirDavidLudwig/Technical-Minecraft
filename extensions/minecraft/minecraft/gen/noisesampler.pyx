cpdef double computeDimensionDensity(double d, double e, double f, double g):
	cdef double h
	h = 1.0 - f/128.0 + g
	return h*d + e
