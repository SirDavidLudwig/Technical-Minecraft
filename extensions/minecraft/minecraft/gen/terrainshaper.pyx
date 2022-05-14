from minecraft.gen.terrainpoint cimport *
from minecraft.gen.spline cimport Spline, SplineBuilder
from minecraft.util.mathhelper cimport lerpf

cdef PointClosure pointContinents = PointContinentsClosure()
cdef PointClosure pointErosion = PointErosionClosure()
cdef PointClosure pointRidges = PointRidgesClosure()

cpdef float peaksAndValleys(float f):
	return -(abs(abs(f) - 0.6666667) - 0.33333334) * 3.0

cpdef bint isCoastal(float f, float g):
	return f >= -0.2 and (f < -0.05 or abs(g) < 0.15)

cpdef void init():
	cdef Spline beachSpline, lowSpline, midSpline, highSpline
	beachSpline = buildErosionOffsetSpline("beachSpline", -0.15, -0.05, 0.0, 0.0, 0.1, 0.0, -0.03, False, False)
	lowSpline = buildErosionOffsetSpline("lowSpline", -0.1, -0.1, 0.03, 0.1, 0.1, 0.01, -0.03, False, False)
	midSpline = buildErosionOffsetSpline("midSpline", -0.1, -0.1, 0.03, 0.1, 0.7, 0.01, -0.03, True, True)
	highSpline = buildErosionOffsetSpline("highSpline", -0.1, 0.3, 0.03, 0.1, 1.0, 0.01, 0.01, True, True)
	offsetSampler = SplineBuilder(pointContinents) \
		.named("offsetSampler") \
		.addPoint(-1.1, 0.044, 0.0) \
		.addPoint(-1.005, -0.2222, 0.0) \
		.addPoint(-0.51, -0.2222, 0.0) \
		.addPoint(-0.44, -0.12, 0.0) \
		.addPoint(-0.18, -0.12, 0.0) \
		.addPoint(-0.16, beachSpline, 0.0) \
		.addPoint(-0.15, beachSpline, 0.0) \
		.addPoint(-0.1, lowSpline, 0.0) \
		.addPoint(0.25, midSpline, 0.0) \
		.addPoint(1.0, highSpline, 0.0) \
		.build() \
		.sampler()
	factorSampler = SplineBuilder(pointContinents) \
		.named("Factor-Continents") \
		.addPoint(-0.19, 505.0, 0.0) \
		.addPoint(-0.15, getErosionFactor("erosionCoast", 800.0, True, "ridgeCoast-OldMountains"), 0.0) \
		.addPoint(-0.1, getErosionFactor("erosionInland", 700.0, True, "ridgeInland-OldMountains"), 0.0) \
		.addPoint(0.03, getErosionFactor("erosionMidInland", 650.0, True, "ridgeMidInland-OldMountains"), 0.0) \
		.addPoint(0.06, getErosionFactor("erosionFarInland", 600.0, False, "ridgeFarInland-OldMountains"), 0.0) \
		.build() \
		.sampler()

cpdef Spline buildErosionOffsetSpline(unicode name, float f, float g, float h, float i, float j, float k, float l, bint bl, bint bl2):
	cdef Spline spline = buildMountainRidgeSplineWithPoints(lerpf(j, 0.6, 2.0), bl2)
	cdef Spline spline2 = buildMountainRidgeSplineWithPoints(lerpf(j, 0.6, 1.0), bl2)
	cdef Spline spline3 = buildMountainRidgeSplineWithPoints(j, bl2)
	cdef Spline spline4 = ridgeSpline(name + "-widePlateau", f - 0.2, 0.5 * j, lerpf(0.5, 0.5, 0.5) * j, 0.5 * j, 0.6 * j)
	cdef Spline spline5 = ridgeSpline(name + "-narrowPlateau", f, k * j, h * j, 0.5 * j, 0.6 * j)
	cdef Spline spline6 = ridgeSpline(name + "-plains", f, k, k, h, i)
	cdef Spline spline7 = ridgeSpline(name + "-extremeHills", f, k, i + 0.07, i + 0.07, i + 0.1)
	cdef Spline spline8 = ridgeSpline(name + "-swamps", lerpf(0.5, f, l), l, l, h, i)
	cdef SplineBuilder builder = SplineBuilder(pointErosion).named(name).addPoint(-0.9, spline, 0.0).addPoint(-0.7, spline2, 0.0).addPoint(-0.4, spline3, 0.0).addPoint(-0.35, spline4, 0.0).addPoint(-0.1, spline5, 0.0).addPoint(0.2, spline6, 0.0)
	if bl:
		builder.addPoint(0.4, spline6, 0.0).addPoint(0.45, spline7, 0.0).addPoint(0.55, spline7, 0.0).addPoint(0.58, spline6, 0.0)
	builder.addPoint(0.7, spline8, 0.0)
	return builder.build()

cdef Spline buildMountainRidgeSplineWithPoints(float f, bint bl):
	cdef SplineBuilder builder
	cdef float i, k, l, u, o, p, q, r, s, t

	builder = SplineBuilder(pointRidges).named(f"M-spline for continentalness: {f:.02}")

	i = mountainContinentalness(-1.0, f, -0.7)
	k = mountainContinentalness(1.0, f, -0.7)
	l = calculateMountainRidgeZeroContinentalnessPoint(f)

	if -0.65 < l and l < 1.0:
		u = mountainContinentalness(-0.65, f, -0.7)
		o = -0.75
		p = mountainContinentalness(-0.75, f, -0.7)
		q = calculateSlope(i, p, -1.0, -0.75)
		builder.addPoint(-1.0, i, q)
		builder.addPoint(-0.75, p, 0.0)
		builder.addPoint(-0.65, u, 0.0)
		r = mountainContinentalness(l, f, -0.7)
		s = calculateSlope(r, k, l, 1.0)
		t = 0.01
		builder.addPoint(l - 0.01, r, 0.0)
		builder.addPoint(l, r, s)
		builder.addPoint(1.0, k, s)
	else:
		u = calculateSlope(i, k, -1.0, 1.0)
		if bl:
			builder.addPoint(-1.0, max(0.2, i), 0.0)
			builder.addPoint(0.0, lerpf(0.5, i, k), u)
		else:
			builder.addPoint(-1.0, i, u)

		builder.addPoint(1.0, k, u)

	return builder.build()

cdef float mountainContinentalness(float f, float g, float h):
	cdef float k = 1.0 - (1.0 - g) * 0.5
	cdef float l = 0.5 * (1.0 - g)
	cdef float m = (f + 1.17) * 0.46082947
	cdef float n = m * k - l
	return max(n, -0.2222) if f < h else max(n, 0.0)

cdef float calculateMountainRidgeZeroContinentalnessPoint(float f):
	cdef float i = 1.0 - (1.0 - f) * 0.5
	cdef float j = 0.5 * (1.0 - f)
	cdef float k = j / (0.46082947 * i) - 1.17
	return k

cdef float calculateSlope(float y0, float y1, float x0, float x1):
	return (y1 - y0) / (x1 - x0)

cdef Spline ridgeSpline(unicode name, float f, float g, float h, float i, float j):
	cdef float k, l
	cdef Spline builder
	k = max(0.5 * (g - f), 0.7)
	l = 5.0 * (h - g)
	return SplineBuilder(pointRidges).named(name).addPoint(-1.0, f, k).addPoint(-0.4, g, min(k, l)).addPoint(0.0, h, l).addPoint(0.4, i, 2.0 * (i - h)).addPoint(1.0, j, 0.7 * (j - i)).build()

cdef Spline getErosionFactor(unicode name, float f, bint bl, unicode other):
	cdef SplineBuilder builder
	cdef Spline spline
	builder = SplineBuilder(pointErosion).named(name).addPoint(-0.6, f, 0.0).addPoint(-0.5, 342.0, 0.0).addPoint(-0.35, f, 0.0).addPoint(-0.25, f, 0.0).addPoint(-0.1, 342.0, 0.0).addPoint(0.05, f, 0.0)
	if bl:
		spline = SplineBuilder(pointRidges).named("ridgesShattered").addPoint(-0.9, f, 0.0).addPoint(-0.69, 80.0, 0.0).build()
		builder.addPoint(0.35, f, 0.0).addPoint(0.48, spline, 0.0).addPoint(0.52, spline, 0.0).addPoint(0.62, f, 0.0)
	else:
		spline = SplineBuilder(pointRidges).named(other).addPoint(-0.7, f, 0.0).addPoint(-0.15, 175.0, 0.0).build()
		builder.addPoint(0.4, f, 0.0).addPoint(0.45, spline, 0.0).addPoint(0.55, spline, 0.0).addPoint(0.58, f, 0.0)

	return builder.build();

cdef class TerrainShaper:

	def __init__(self):
		init()

	cpdef Point makePoint(self, float f, float g, float h):
		return Point(f, g, peaksAndValleys(h))

	cpdef float offset(self, Point point):
		return offsetSampler.apply(point) + 0.015

	cpdef float factor(self, Point point):
		return factorSampler.apply(point)
