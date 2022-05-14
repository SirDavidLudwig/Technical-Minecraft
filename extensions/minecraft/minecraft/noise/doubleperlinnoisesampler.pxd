# Based off yarn mappings: 

from minecraft.noise.octaveperlinnoisesampler cimport OctavePerlinNoiseSampler
from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef extern from "limits.h":
	cdef int INT_MAX
	cdef int INT_MIN

cdef double createAmplitude(int octaves)

cdef class DoublePerlinNoiseSampler:
	cdef double amplitude
	cdef OctavePerlinNoiseSampler firstSampler
	cdef OctavePerlinNoiseSampler secondSampler

	cdef double sample(self, double x, double y, double z)
