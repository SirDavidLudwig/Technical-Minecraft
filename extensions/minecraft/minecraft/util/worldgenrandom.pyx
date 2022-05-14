from javarand cimport Random

cdef class WorldGenRandom(Random):

	cpdef void skip(self, int count):
		cdef int i
		for i in range(count):
			self.nextInt()
