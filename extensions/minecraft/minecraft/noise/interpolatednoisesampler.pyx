from minecraft.noise.perlinnoisesampler cimport PerlinNoiseSampler
from minecraft.noise.octaveperlinnoisesampler cimport maintainPrecision, OctavePerlinNoiseSampler
from minecraft.util.mathhelper cimport clampedLerp
from minecraft.util.worldgenrandom cimport WorldGenRandom
cimport numpy as np
import numpy as np

cdef class InterpolatedNoiseSampler:

	def __init__(self, WorldGenRandom random):
		self.lowerInterpolatedNoise = OctavePerlinNoiseSampler(random, -15, np.array([
			1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
		], dtype=np.double))
		self.upperInterpolatedNoise = OctavePerlinNoiseSampler(random, -15, np.array([
			1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
		], dtype=np.double))
		self.interpolationNoise = OctavePerlinNoiseSampler(random, -7, np.array([
			1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0
		], dtype=np.double))

	cpdef double sample(self, int i, int j, int k, double horizontalScale, double verticalScale, double horizontalStretch, double verticalStretch):
		cdef double d, e, f, g, h, n, o, p, q
		cdef int l, m
		cdef perlinNoiseSampler
		d = e = f = 0.0
		g = 1.0

		for l in range(8):
			perlinNoiseSampler = self.interpolationNoise.getOctave(l)
			if perlinNoiseSampler is not None:
				f += perlinNoiseSampler.sample(
					maintainPrecision(<double>i * horizontalStretch * g),
					maintainPrecision(<double>j * verticalStretch * g),
					maintainPrecision(<double>k * horizontalStretch * g),
					verticalStretch * g, <double>j * verticalStretch * g) / g
			g /= 2.0

		h = (f/10.0 + 1.0)/2.0
		g = 1.0

		for m in range(16):
			n = maintainPrecision(<double>i*horizontalScale*g)
			o = maintainPrecision(<double>j*verticalScale*g)
			p = maintainPrecision(<double>k*horizontalScale*g)
			q = verticalScale*g
			if h < 1.0:
				perlinNoiseSampler = self.lowerInterpolatedNoise.getOctave(m)
				if perlinNoiseSampler is not None:
					d += perlinNoiseSampler.sample(n, o, p, q, <double>j * q) / g

			if h > 0.0:
				perlinNoiseSampler = self.upperInterpolatedNoise.getOctave(m)
				if perlinNoiseSampler is not None:
					e += perlinNoiseSampler.sample(n, o, p, q, <double>j * q) / g

			g /= 2.0

		return clampedLerp(d / 512.0, e / 512.0, h)
