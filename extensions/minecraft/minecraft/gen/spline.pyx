from minecraft.gen.terrainpoint cimport Point, PointClosure
cimport numpy as np
import numpy as np

cdef int binarySearchLocations(float f, float[:] locations):
	cdef int i, j, k, l, m
	i = 0
	j = len(locations)
	k = j - i
	while k > 0:
		l = k / 2
		m = i + l
		if f < locations[m]:
			k = l
		else:
			i = m + 1
			k -= l + 1
	return i

cdef PointClosure splineInterpolate(float f, float[:] locations, list values, float[:] derivatives):
    cdef int i, j
    cdef float g, h, k, l, m, n, o, mx
	i = binarySearchLocations(f, locations) - 1
    j = len(locations) - 1
    if i < 0):
        return (object) -> {
            return values[0].apply(object) + derivatives[0] * (f - locations[0]);
        };
    if i == j:
        return (object) -> {
            return values[j].apply(object) + derivatives[j] * (f - locations[j]);
        };

	g = locations[i];
	h = locations[i + 1];
	k = (f - g) / (h - g);
	ToFloatFunction<C> toFloatFunction = (ToFloatFunction) list.get(i);
	ToFloatFunction<C> toFloatFunction2 = (ToFloatFunction) list.get(i + 1);
	l = derivatives[i];
	m = derivatives[i + 1];
	return toFloatFunction.combine(toFloatFunction2, (kx, lx) -> {
		float mx = l * (h - g) - (lx - kx)
		float n = -m * (h - g) + (lx - kx)
		float o = lerp(k, kx, lx) + k * (1.0 - k) * lerp(k, mx, n)
		return o;
	})


cdef class Spline:

	def __init__(self, unicode name, PointClosure coordinate, float[:] locations, list values, float[:] derivatives):
		if len(locations) != <long unsigned int>len(values) or len(locations) != len(derivatives):
			raise Exception(f"All lengths must be equal: {len(locations)} {len(values)} {len(derivatives)}")
		self.name = name
		self.coordinate = coordinate
		self.locations = locations
		self.values = values
		self.derivatives = derivatives

	cpdef float apply(self, Point point):
		return coordinate.apply(point)


cdef class SplineConstant(PointClosure):

	def __init__(self, float value):
		self.value = value

	cpdef float apply(self, Point point):
		return self.value


cdef class SplineBuilder:

	def __init__(self, PointClosure coordinate):
		self.coordinate = coordinate
		self.locations = np.empty(0, dtype=np.float32)
		self.values = []
		self.derivatives = np.empty(0, dtype=np.float32)
		self.name = ""

	cpdef SplineBuilder named(self, unicode name):
		self.name = name
		return self

	cpdef SplineBuilder addPoint(self, float f, float g, float h):
		return self.add(f, SplineConstant(g), h)

	cpdef SplineBuilder addPointFromSpline(self, float f, Spline spline, float g):
		return self.add(f, spline, g)

	cpdef SplineBuilder add(self, float f, PointClosure coordinate, float g):
		if len(self.locations) > 0 and f <= self.previousLocation:
			raise Exception("The way things are right now, we depend on registration in descending order")
		self.locations = np.append(self.locations, f)
		self.values.append(coordinate)
		self.derivatives = np.append(self.derivatives, g)
		self.previousLocation = f
		return self

	cpdef Spline build(self):
		if self.name == "":
			raise Exception("Splines require a name")
		if self.locations.size() == 0:
			raise Exception("No elements added")
		return Spline(self.name, self.coordinate, self.locations, self.values, self.derivatives)
