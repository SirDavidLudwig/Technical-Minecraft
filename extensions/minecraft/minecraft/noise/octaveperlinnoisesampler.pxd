from minecraft.noise.surfacenoise cimport SurfaceNoise
from minecraft.noise.perlinnoisesampler cimport PerlinNoiseSampler
from minecraft.util.worldgenrandom cimport WorldGenRandom
from sortedcontainers import SortedSet
import numpy as np
cimport numpy as np

cpdef double maintainPrecision(double value)

cdef class OctavePerlinNoiseSampler(SurfaceNoise):

	cdef list octaveSamplers
	cdef double[:] amplitudes
	cdef double persistence
	cdef double lacunarity

	cpdef double sampleXYZ(self, double x, double y, double z)
	cpdef double sample(self, double x, double y, double z, double yScale, double yMax, bint useOrigin)

	cpdef getOctave(self, int octave)
	cpdef double getValue(self, double x, double y, double yScale, double yMax)
