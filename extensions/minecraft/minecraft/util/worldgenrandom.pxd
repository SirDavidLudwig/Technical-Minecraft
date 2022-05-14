from javarand cimport Random

cdef class WorldGenRandom(Random):

	cpdef void skip(self, int count)
