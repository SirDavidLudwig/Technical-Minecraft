from minecraft.noise.surfacenoise cimport SurfaceNoise
from minecraft.noise.simplexnoisesampler cimport SimplexNoiseSampler

cdef class OctaveSimplexNoiseSampler(SurfaceNoise):

	cdef list octaveSamplers
	cdef double persistence
	cdef double lacunarity

	cpdef double sample(self, double x, double y, bint useOrigin)
	cpdef double getValue(self, double x, double y, double yScale, double yMax)
