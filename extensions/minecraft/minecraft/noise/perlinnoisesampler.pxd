cdef class PerlinNoiseSampler:

	cdef char[256] permutations
	cdef public double originX
	cdef public double originY
	cdef public double originZ

	cpdef double sample(self, double x, double y, double z, double yScale, double yMax)
	cpdef double sampleDerivative(self, double x, double y, double z, double [:] ds)

	cdef inline int getGradient(self, int hash)

	cdef double sampleSections(self, int sectionX, int sectionY, int sectionZ, double localX, double localY, double localZ, double fadeLocalX)
	cdef double sampleSectionsDerivative(self, int sectionX, int sectionY, int sectionZ, double localX, double localY, double localZ, double [:] ds)
