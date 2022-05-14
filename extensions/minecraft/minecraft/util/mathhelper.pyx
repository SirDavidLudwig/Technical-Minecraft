cpdef inline float lerpf(float delta, float start, float end):
	return start + delta * (end - start)

cpdef inline double lerp(double delta, double start, double end):
	return start + delta * (end - start)

cpdef double lerp2(double dx, double dy, double x0y0, double x1y0, double x0y1, double x1y1):
	return lerp(dy, lerp(dx, x0y0, x1y0), lerp(dx, x0y1, x1y1))

cpdef double lerp3(double dx, double dy, double dz, double x0y0z0, double x1y0z0, double x0y1z0, double x1y1z0, double x0y0z1, double x1y0z1, double x0y1z1, double x1y1z1):
	return lerp(dz, lerp2(dx, dy, x0y0z0, x1y0z0, x0y1z0, x1y1z0), lerp2(dx, dy, x0y0z1, x1y0z1, x0y1z1, x1y1z1))

cpdef double clampedLerp(double start, double end, double delta):
	if delta < 0.0:
		return start
	return end if delta > 1.0 else lerp(delta, start, end)
