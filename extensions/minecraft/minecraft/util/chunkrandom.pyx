from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef class ChunkRandom(WorldGenRandom):

	def __init__(self, seed=None):
		super(ChunkRandom, self).__init__(seed)

	cpdef int getSampleCount(self):
		return self.sampleCount

	cpdef int nextBits(self, int bits):
		self.sampleCount += 1
		return WorldGenRandom.nextBits(self, bits)

	cpdef long long setTerrainSeed(self, int chunkX, int chunkZ):
		"""
		* Seeds the randomizer to generate the surface terrain blocks (such as grass, sand, etc.)
		* and the bedrock patterns.
		*
		* <p>Note that the terrain seed does not depend on the world seed and only gets affected by
		* chunk coordinates.
		"""
		cdef long long l
		l = <long long>chunkX * 341873128712L + <long long>chunkZ * 132897987541L
		self.setSeed(l)
		return l

	cpdef long long setPopulationSeed(self, long long worldSeed, int blockX, int blockZ):
		"""
		* Seeds the randomizer to create population features such as decorators and animals.
		*
		* <p>This method takes in the world seed and the negative-most block coordinates of the
		* chunk. The coordinate pair provided is equivalent to (chunkX * 16, chunkZ * 16). The
		* three values are mixed together through some layers of hashing to produce the
		* population seed.
		*
		* <p>This function has been proved to be reversible through some exploitation of the underlying
		* nextLong() weaknesses. It is also important to remember that since setSeed()
		* truncates the 16 upper bits of world seed, only the 48 lowest bits affect the population
		* seed output.
		"""
		cdef long long l, m, n
		self.setSeed(worldSeed)
		l = self.nextLong() | 1L
		m = self.nextLong() | 1L
		n = <long long> blockX*l + <long long>blockZ*m ^ worldSeed
		self.setSeed(n)
		return n

	cpdef long long setDecoratorSeed(self, long long populationSeed, int index, int step):
		"""
		* Seeds the randomizer to generate a given feature.
		*
		* The salt, in the form of {@code index + 10000 * step} assures that each feature is seeded
		* differently, making the decoration feel more random. Even though it does a good job
		* at doing so, many entropy issues arise from the salt being so small and result in
		* weird alignments between features that have an index close apart.
		*
		* @param populationSeed the population seed computed in {@link #setPopulationSeed(long, int, int)}
		* @param index the index of the feature in the feature list
		* @param step the generation step's ordinal for this feature
		"""
		cdef long long l
		l = populationSeed + <long long>index + <long long>(10000 * step)
		self.setSeed(l)
		return l

	cpdef setCarverSeed(self, long long worldSeed, int chunkX, int chunkZ):
		"""
		* Seeds the randomizer to generate larger features such as caves, ravines, mineshafts
		* and strongholds. It is also used to initiate structure start behavior such as rotation.
		*
		* <p>Similar to the population seed, only the 48 lowest bits of the world seed affect the
		* output since it the upper 16 bits are truncated in the setSeed() call.
		"""
		cdef long long l, m, n
		self.setSeed(worldSeed)
		l = self.nextLong()
		m = self.nextLong()
		n = <long long>chunkX*l ^ <long long>chunkZ*m ^ worldSeed
		self.setSeed(n)
		return n

	cpdef setDeepslateSeed(self, long long worldSeed, int x, int y, int z):
		"""
		* Seeds the randomizer to determine the start position of structure features such as
		* temples, monuments and buried treasures within a region.
		*
		* <p>The region coordinates pair corresponds to the coordinates of the region the seeded
		* chunk lies in. For example, a swamp hut region is 32 by 32 chunks meaning that all
		* chunks that lie within that region get seeded the same way.
		*
		* <p>Similarly, the upper 16 bits of world seed also do not affect the region seed because
		* they get truncated in the setSeed() call.
		"""
		cdef long long l, m, n, o
		self.setSeed(worldSeed)
		l = self.nextLong()
		m = self.nextLong()
		n = self.nextLong()
		o = <long long>x*l ^ <long long>y*m ^ <long long>z*n ^ worldSeed
		self.setSeed(o)
		return o

	cpdef long long setRegionSeed(self, long long worldSeed, int regionX, int regionZ, int salt):
		"""
		* Seeds the randomizer to determine the start position of structure features such as
		* temples, monuments and buried treasures within a region.
		*
		* <p>The region coordinates pair corresponds to the coordinates of the region the seeded
		* chunk lies in. For example, a swamp hut region is 32 by 32 chunks meaning that all
		* chunks that lie within that region get seeded the same way.
		*
		* <p>Similarly, the upper 16 bits of world seed also do not affect the region seed because
		* they get truncated in the setSeed() call.
		"""
		cdef long long l
		l = <long long>regionX * 341873128712L + <long long>regionZ * 132897987541L + worldSeed + <long long>salt
		self.setSeed(l)
		return l
