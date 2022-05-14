from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef class ChunkRandom(WorldGenRandom):
	cdef public int sampleCount

	cpdef int getSampleCount(self)
	cpdef int nextBits(self, int bits)
	cpdef long long setTerrainSeed(self, int chunkX, int chunkZ)
	cpdef long long setPopulationSeed(self, long long worldSeed, int blockX, int blockZ)
	cpdef long long setDecoratorSeed(self, long long populationSeed, int index, int step)
	cpdef setCarverSeed(self, long long worldSeed, int chunkX, int chunkZ)
	cpdef setDeepslateSeed(self, long long worldSeed, int x, int y, int z)
	cpdef long long setRegionSeed(self, long long worldSeed, int regionX, int regionZ, int salt)
