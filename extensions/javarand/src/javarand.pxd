cdef class Random:
    cdef long long __seedUniquifier
    cdef long long seed
    cdef double nextNextGaussian
    cdef bint haveNextNextGaussian

    cdef long long seedUniquifier(self)
    cdef long long initialScramble(self, long long seed)
    cpdef void setSeed(self, long long seed)

    cdef int nextBits(self, int bits)

    cpdef int nextInt(self)
    cpdef int nextIntBounded(self, int bound)
    cpdef long long nextLong(self)
    cpdef bint nextBoolean(self)
    cpdef float nextFloat(self)
    cpdef double nextDouble(self)
    cpdef double nextGaussian(self)
