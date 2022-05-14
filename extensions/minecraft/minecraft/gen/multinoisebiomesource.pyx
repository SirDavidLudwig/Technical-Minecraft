from minecraft.gen.biomesource cimport BiomeSource
from minecraft.gen.noisesampler cimport computeDimensionDensity
from minecraft.noise.doubleperlinnoisesampler cimport DoublePerlinNoiseSampler
from minecraft.util.chunkrandom cimport ChunkRandom

cdef class NoiseParams:
	def __init__(self, int firstOctave, double[:] amplitudes):
		self.firstOctave = firstOctave
		self.amplitudes = amplitudes

cdef class MultiNoiseBiomeSource(BiomeSource):

	def __init__(self, long long seed, NoiseParams temperatureParams, NoiseParams humidityParams, NoiseParams continentalnessParams, NoiseParams erosionParams, NoiseParams weirdnessParams):
		self.seed = seed
		self.temperatureNoise = DoublePerlinNoiseSampler(ChunkRandom(seed), temperatureParams.firstOctave, temperatureParams.amplitudes)
		self.humidityNoise = DoublePerlinNoiseSampler(ChunkRandom(seed), humidityParams.firstOctave, humidityParams.amplitudes)
		self.continentalnessNoise = DoublePerlinNoiseSampler(ChunkRandom(seed), continentalnessParams.firstOctave, continentalnessParams.amplitudes)
		self.erosionNoise = DoublePerlinNoiseSampler(ChunkRandom(seed), erosionParams.firstOctave, erosionParams.amplitudes)
		self.weirdnessNoise = DoublePerlinNoiseSampler(ChunkRandom(seed), weirdnessParams.firstOctave, weirdnessParams.amplitudes)

	cdef inline double getOffset(self, int x, int y, int z):
		return self.offsetNoise.getValue(x, y, z) * 4.0

	cdef inline double getTemperature(self, double x, double y, double z):
		return self.temperatureNoise.getValue(x, y, z)

	cdef inline double getHumidity(self, double x, double y, double z):
		return self.humidityNoise.getValue(x, y, z)

	cdef inline double getContinentalness(self, double x, double y, double z):
		# NOTE: minecraft has an additional debug code here
		return self.continentalnessNoise.getValue(x, y, z)

	cdef inline double getErosion(self, double x, double y, double z):
		return self.erosionNoise.getValue(x, y, z)

	cdef inline double getWeirdness(self, double x, double y, double z):
		return self.weirdnessNoise.getValue(x, y, z)

	cpdef void getNoiseBiome(self, int x, int y, int z):
		cdef double dx, dy, dz
		cdef double m
		cdef float temperature, humidity, continentalness, erosion, weirdness, density

		dx = <double>x + self.getOffset(x, 0, z)
		dy = <double>y + self.getOffset(y, z, x)
		dz = <double>z + self.getOffset(z, x, 0)

		temperature = <float>self.getTemperature(dx, dy, dz)
		humidity = <float>self.getHumidity(dx, dy, dz)
		continentalness = <float>self.getContinentalness(dx, 0.0, dz)
		erosion = <float>self.getErosion(dx, 0.0, dz)
		weirdness = <float>self.getWeirdness(dx, 0.0, dz)

		m = <double>self.shaper.offset(self.shaper.makePoint(continentalness, erosion, weirdness))
		density = <float>computeDimensionDensity(1.0, -0.51875, <double>(y* 4), 0.0) + m

		print(density)
		# Climate.TargetPoint targetPoint = Climate.target(temperature, humidity, continentalness, erosion, density, weirdness)
		# return (Biome)this.parameters.findBiome(targetPoint, () -> {
		# 	return net.minecraft.data.worldgen.biome.Biomes.THE_VOID;
		# });

