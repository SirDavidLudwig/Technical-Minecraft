from minecraft.noise.octaveperlinnoisesampler cimport OctavePerlinNoiseSampler
from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef double createAmplitude(int octaves):
	return 0.1 * (1.0 + 1.0/<double>(octaves + 1))

cdef class DoublePerlinNoiseSampler:

	def __init__(self, WorldGenRandom random, int offset, double[:] octaves):
		cdef int i, j
		self.firstSampler = OctavePerlinNoiseSampler(random, offset, octaves)
		self.secondSampler = OctavePerlinNoiseSampler(random, offset, octaves)
		i = INT_MAX
		j = INT_MIN
		for k, d in enumerate(octaves):
			if d != 0.0:
				i = min(i, k)
				j = max(j, k)
		self.amplitude = 0.16666666666666666 / createAmplitude(j - i)

	cdef double sample(self, double x, double y, double z):
		cdef double d, e, f
		d = x * 1.0181268882175227
		e = y * 1.0181268882175227
		f = z * 1.0181268882175227
		return (self.firstSampler.sampleXYZ(x, y, z) + self.secondSampler.sampleXYZ(d, e, f)) * self.amplitude
