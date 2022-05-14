cimport numpy as np
import numpy as np

cdef class BiomeSource:
	def __init__(self):
		self.possibleBiomes = np.zeros(1)
