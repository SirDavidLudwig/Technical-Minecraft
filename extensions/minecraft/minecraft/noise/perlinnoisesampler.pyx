from libc.math cimport floor
from minecraft.noise.simplexnoisesampler cimport GRADIENTS, dot
from minecraft.util.mathhelper import lerp2, lerp3
from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef double grad(int hash, double x, double y, double z):
	return dot(GRADIENTS[hash & 15], x, y, z)

cdef inline double perlinFade(double value):
	return value**3 * (value * (value*6.0 - 15.0) + 10.0)

cdef inline double perlinFadeDerivative(double value):
	return 30 * value**2 * (value - 1.0)**2

cdef class PerlinNoiseSampler:

	def __init__(self, WorldGenRandom random):
		cdef int j, k, l
		self.originX = random.nextDouble() * 256.0
		self.originY = random.nextDouble() * 256.0
		self.originZ = random.nextDouble() * 256.0

		for j in range(256):
			self.permutations[j] = <char>j

		for j in range(256):
			k = random.nextIntBounded(256 - j)
			l = self.permutations[j]
			self.permutations[j] = self.permutations[k + j]
			self.permutations[k + j] = l

	cpdef double sample(self, double x, double y, double z, double yScale, double yMax):
		cdef double d, e, f, g, h, l, n, p
		cdef int i, j, k
		d = x + self.originX
		e = y + self.originY
		f = z + self.originZ
		i = <int>floor(d)
		j = <int>floor(e)
		k = <int>floor(f)
		g = d - <double>i
		h = e - <double>j
		l = f - <double>k
		if yScale != 0.0:
			n = yMax if (yMax >= 0.0 and yMax < h) else h
			p = floor(n / yScale + 1.0000000116860974E-7) * yScale
		else:
			p = 0.0
		return self.sampleSections(i, j, k, g, h - p, l, h)

	cpdef double sampleDerivative(self, double x, double y, double z, double [:] ds):
		cdef double d, e, f
		cdef int i, j, k
		d = x + self.originX
		e = y + self.originY
		f = z + self.originZ
		i = <int>floor(d)
		j = <int>floor(e)
		k = <int>floor(f)
		return self.sampleSectionsDerivative(i, j, k, d - i, e - j, f - k, ds)

	cdef inline int getGradient(self, int hash):
		return self.permutations[hash & 255] & 255

	cdef double sampleSections(self, int sectionX, int sectionY, int sectionZ, double localX, double localY, double localZ, double fadeLocalX):
		cdef int i, j, k, l, m, n
		cdef double d, e, f, g, h, o, p, q, r, s, t
		i = self.getGradient(sectionX)
		j = self.getGradient(sectionX + 1)
		k = self.getGradient(i + sectionY)
		l = self.getGradient(i + sectionY + 1)
		m = self.getGradient(j + sectionY)
		n = self.getGradient(j + sectionY + 1)
		d = grad(self.getGradient(k + sectionZ), localX, localY, localZ)
		e = grad(self.getGradient(m + sectionZ), localX - 1.0, localY, localZ)
		f = grad(self.getGradient(l + sectionZ), localX, localY - 1.0, localZ)
		g = grad(self.getGradient(n + sectionZ), localX - 1.0, localY - 1.0, localZ)
		h = grad(self.getGradient(k + sectionZ + 1), localX, localY, localZ - 1.0)
		o = grad(self.getGradient(m + sectionZ + 1), localX - 1.0, localY, localZ - 1.0)
		p = grad(self.getGradient(l + sectionZ + 1), localX, localY - 1.0, localZ - 1.0)
		q = grad(self.getGradient(n + sectionZ + 1), localX - 1.0, localY - 1.0, localZ - 1.0)
		r = perlinFade(localX)
		s = perlinFade(fadeLocalX)
		t = perlinFade(localZ)
		return lerp3(r, s, t, d, e, f, g, h, o, p, q)

	cdef double sampleSectionsDerivative(self, int sectionX, int sectionY, int sectionZ, double localX, double localY, double localZ, double [:] ds):
		cdef double d, e, f, g, h, w, x, y, z, aa, ab, ac, ad, ae, af, ag, ah, ai, aj, ak
		cdef int i, j, k, l, m, n, o, p, q, r, s, t, u, v
		i = self.getGradient(sectionX)
		j = self.getGradient(sectionX + 1)
		k = self.getGradient(i + sectionY)
		l = self.getGradient(i + sectionY + 1)
		m = self.getGradient(j + sectionY)
		n = self.getGradient(j + sectionY + 1)
		o = self.getGradient(k + sectionZ)
		p = self.getGradient(m + sectionZ)
		q = self.getGradient(l + sectionZ)
		r = self.getGradient(n + sectionZ)
		s = self.getGradient(k + sectionZ + 1)
		t = self.getGradient(m + sectionZ + 1)
		u = self.getGradient(l + sectionZ + 1)
		v = self.getGradient(n + sectionZ + 1)
		cdef int[3] is1 = GRADIENTS[o & 15]
		cdef int[3] js = GRADIENTS[p & 15]
		cdef int[3] ks = GRADIENTS[q & 15]
		cdef int[3] ls = GRADIENTS[r & 15]
		cdef int[3] ms = GRADIENTS[s & 15]
		cdef int[3] ns = GRADIENTS[t & 15]
		cdef int[3] os = GRADIENTS[u & 15]
		cdef int[3] ps = GRADIENTS[v & 15]
		d = dot(is1, localX, localY, localZ)
		e = dot(js, localX - 1.0, localY, localZ)
		f = dot(ks, localX, localY - 1.0, localZ)
		g = dot(ls, localX - 1.0, localY - 1.0, localZ)
		h = dot(ms, localX, localY, localZ - 1.0)
		w = dot(ns, localX - 1.0, localY, localZ - 1.0)
		x = dot(os, localX, localY - 1.0, localZ - 1.0)
		y = dot(ps, localX - 1.0, localY - 1.0, localZ - 1.0)
		z = perlinFade(localX)
		aa = perlinFade(localY)
		ab = perlinFade(localZ)
		ac = lerp3(z, aa, ab, <double>is1[0], <double>js[0], <double>ks[0], <double>ls[0], <double>ms[0], <double>ns[0], <double>os[0], <double>ps[0])
		ad = lerp3(z, aa, ab, <double>is1[1], <double>js[1], <double>ks[1], <double>ls[1], <double>ms[1], <double>ns[1], <double>os[1], <double>ps[1])
		ae = lerp3(z, aa, ab, <double>is1[2], <double>js[2], <double>ks[2], <double>ls[2], <double>ms[2], <double>ns[2], <double>os[2], <double>ps[2])
		af = lerp2(aa, ab, e - d, g - f, w - h, y - x)
		ag = lerp2(ab, z, f - d, x - h, g - e, y - w)
		ah = lerp2(z, aa, h - d, w - e, x - f, y - g)
		ai = perlinFadeDerivative(localX)
		aj = perlinFadeDerivative(localY)
		ak = perlinFadeDerivative(localZ)
		ds[0] += ac + ai * af
		ds[1] += ad + aj * ag
		ds[2] += ae + ak * ah
		return lerp3(z, aa, ab, d, e, f, g, h, w, x, y)
