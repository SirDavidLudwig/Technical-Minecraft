from minecraft.gen.terrainpoint cimport Point, PointClosure
from minecraft.gen.spline cimport Spline
# from minecraft.gen.spline cimport Spline, SplineBuilder

cdef offsetSampler
cdef factorSampler

cdef PointClosure pointContinents
cdef PointClosure pointErosion
cdef PointClosure pointRidges

cpdef void init()
cpdef Spline buildErosionOffsetSpline(unicode name, float f, float g, float h, float i, float j, float k, float l, bint bl, bint bl2)
cdef Spline buildMountainRidgeSplineWithPoints(float f, bint bl)
cdef float mountainContinentalness(float f, float g, float h)
cdef float calculateMountainRidgeZeroContinentalnessPoint(float f)
cdef float calculateSlope(float y0, float y1, float x0, float x1)
cdef Spline ridgeSpline(unicode name, float f, float g, float h, float i, float j)
cdef Spline getErosionFactor(unicode name, float f, bint bl, unicode other)

cpdef float peaksAndValleys(float f)
cpdef bint isCoastal(float f, float g)

cdef class TerrainShaper:

	cdef offsetSampler
	cdef factorSampler

	cpdef Point makePoint(self, float f, float g, float h)
	cpdef float offset(self, Point point)
	cpdef float factor(self, Point point)
