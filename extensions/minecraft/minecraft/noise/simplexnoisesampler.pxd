cdef int[16][3] GRADIENTS

cdef double dot(int[3] grads, double x, double y, double z)

cdef class SimplexNoiseSampler:

	cdef int[512] permutations
	cdef public double originX
	cdef public double originY
	cdef public double originZ

	cdef int getGradient(self, int hash)
	cdef double grad(self, int hash, double x, double y, double z, double distance)

	cpdef double sampleXY(self, double x, double y)
	cpdef double sampleXYZ(self, double x, double y, double z)
