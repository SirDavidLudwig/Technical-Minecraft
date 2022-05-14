from minecraft.gen.biomesource cimport BiomeSource
from minecraft.noise.doubleperlinnoisesampler cimport DoublePerlinNoiseSampler

cdef class NoiseParams:
	cdef int firstOctave
	cdef double[:] amplitudes

cdef class MultiNoiseBiomeSource(BiomeSource):

	cdef DoublePerlinNoiseSampler temperatureNoise
	cdef DoublePerlinNoiseSampler humidityNoise
	cdef DoublePerlinNoiseSampler continentalnessNoise
	cdef DoublePerlinNoiseSampler erosionNoise
	cdef DoublePerlinNoiseSampler weirdnessNoise
	cdef DoublePerlinNoiseSampler offsetNoise
	cdef long long seed

	cdef double getOffset(self, int x, int y, int z)
	cdef double getTemperature(self, double x, double y, double z)
	cdef double getHumidity(self, double x, double y, double z)
	cdef double getContinentalness(self, double x, double y, double z)
	cdef double getErosion(self, double x, double y, double z)
	cdef double getWeirdness(self, double x, double y, double z)
	cpdef void getNoiseBiome(self, int x, int y, int z)
