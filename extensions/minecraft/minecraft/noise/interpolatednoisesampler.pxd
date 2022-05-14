from minecraft.noise.octaveperlinnoisesampler cimport OctavePerlinNoiseSampler

cdef class InterpolatedNoiseSampler:
	cdef OctavePerlinNoiseSampler lowerInterpolatedNoise
	cdef OctavePerlinNoiseSampler upperInterpolatedNoise
	cdef OctavePerlinNoiseSampler interpolationNoise

	cpdef double sample(self, int i, int j, int k, double horizontalScale, double verticalScale, double horizontalStretch, double verticalStretch)
