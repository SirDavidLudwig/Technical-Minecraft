from minecraft.noise.surfacenoise cimport SurfaceNoise
from minecraft.noise.simplexnoisesampler cimport SimplexNoiseSampler
from minecraft.util.chunkrandom cimport ChunkRandom
from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef class OctaveSimplexNoiseSampler(SurfaceNoise):

	def __init__(self, WorldGenRandom random, set octaves):
		cdef int i, j, k, l, m, o
		cdef long long n
		cdef SimplexNoiseSampler simplexNoiseSampler
		cdef WorldGenRandom worldGenRandom

		if len(octaves) == 0:
			raise Exception("Need some octaves!")

		i = -min(octaves)
		j = max(octaves)
		k = i + j + 1
		if k < 1:
			raise Exception("Total number of octaves needs to be >= 1")

		simplexNoiseSampler = SimplexNoiseSampler(random)
		l = j
		self.octaveSamplers = [None]*k
		if j >= 0 and j < k and 0 in octaves:
			self.octaveSamplers[j] = simplexNoiseSampler

		for m in range(j+1, k):
			if m >= 0 and (l - m) in octaves:
				self.octaveSamplers[m] = SimplexNoiseSampler(random)
			else:
				random.skip(262)

		if j > 0:
			n = <long long>(simplexNoiseSampler.sample(simplexNoiseSampler.originX, simplexNoiseSampler.originY, simplexNoiseSampler.originZ) * 9.223372036854776E18)
			worldGenRandom = ChunkRandom(n)
			for o in range(l-1, -1, -1):
				if o < k and (l - o) in octaves:
					self.octaveSamplers[o] = SimplexNoiseSampler(worldGenRandom)
				else:
					worldGenRandom.skip(262)

		self.lacunarity = 2.0**<double>j
		self.persistence = 1.0 / (2.0**<double>k - 1.0)


	cpdef double sample(self, double x, double y, bint useOrigin):
		cdef double d, e, f
		cdef simplexNoiseSampler
		d = 0.0
		e = self.lacunarity
		f = self.persistence

		for simplexNoiseSampler in self.octaveSamplers:
			if simplexNoiseSampler is not None:
				d += simplexNoiseSampler.sample(x*e + (simplexNoiseSampler.originX if useOrigin else 0.0), (simplexNoiseSampler.originY if useOrigin else 0.0)) * f
			e /= 2.0
			f *= 2.0

		return d

	cpdef double getValue(self, double x, double y, double yScale, double yMax):
		return self.sample(x, y, True) * 0.55
