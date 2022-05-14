from libc.math cimport floor
from minecraft.noise.surfacenoise cimport SurfaceNoise
from minecraft.util.worldgenrandom cimport WorldGenRandom
from sortedcontainers import SortedSet
import numpy as np
cimport numpy as np

cpdef inline double maintainPrecision(double value):
	# Minecraft uses lfloor here, but I'm not sure why...
	return value - floor(value / 3.3554432E7 + 0.5) * 3.3554432E7

cdef class OctavePair:
	cdef public int first
	cdef public double[:] second
	def __init__(self, int first, double[:] second):
		self.first = first
		self.second = second

def calculateAmplitudes(octaves: SortedSet) -> OctavePair:
	cdef int i, j, k, l
	cdef double[:] doubleList
	if len(octaves) == 0:
		raise Exception("Need some octaves!")

	i = -octaves[0]
	j = octaves[-1]
	k = i + j + 1
	if k < 1:
		raise Exception("Total number of octaves needs to be >= 1")

	doubleList = np.zeros(k, dtype=np.float64)
	for l in octaves:
		doubleList[l+i] = 1.0

	return OctavePair(-i, doubleList)

cdef class OctavePerlinNoiseSampler(SurfaceNoise):

	def __init__(self, WorldGenRandom random, int offset, double[:] amplitudes):
		cdef int j, k
		cdef double d, e
		cdef PerlinNoiseSampler perlinNoiseSampler
		i = offset
		self.amplitudes = amplitudes
		perlinNoiseSampler = PerlinNoiseSampler(random)
		j = len(self.amplitudes)
		k = -offset
		self.octaveSamplers = [None]*j
		if k >= 0 and k < j:
			d = self.amplitudes[k]
			if d != 0.0:
				self.octaveSamplers[k] = perlinNoiseSampler

		for l in range(k-1, -1, -1):
			if l < j:
				e = self.amplitudes[l]
				if e != 0.0:
					self.octaveSamplers[l] = PerlinNoiseSampler(random)
				else:
					random.skip(262)
			else:
				random.skip(262)

		if k < j - 1:
			raise Exception("Positive octaves are temporarily disabled")
		else:
			self.lacunarity = 2.0**<double>(-k)
			self.persistence = 2.0**<double>(j - 1) / (2.0**<double>j - 1.0)

	cpdef double sampleXYZ(self, double x, double y, double z):
		return self.sample(x, y, z, 0.0, 0.0, False)

	cpdef double sample(self, double x, double y, double z, double yScale, double yMax, bint useOrigin):
		cdef double d, e, f, g
		cdef perlinNoiseSampler
		d = 0.0
		e = self.lacunarity
		f = self.persistence

		for i, perlinNoiseSampler in enumerate(self.octaveSamplers):
			if perlinNoiseSampler is not None:
				g = perlinNoiseSampler.sample(maintainPrecision(x * e), -perlinNoiseSampler.originY if useOrigin else maintainPrecision(y * e), maintainPrecision(z * e), yScale * e, yMax * e)
				d += self.amplitudes.getDouble(i) * g * f
			e *= 2.0
			f /= 2.0

		return d

	cpdef getOctave(self, int octave):
		return self.octaveSamplers[len(self.octaveSamplers) - octave - 1]

	cpdef double getValue(self, double x, double y, double yScale, double yMax):
		return self.sample(x, y, 0.0, yScale, yMax, False)
