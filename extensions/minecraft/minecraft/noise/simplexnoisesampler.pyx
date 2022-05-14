from libc.math cimport floor, sqrt
from minecraft.util.worldgenrandom cimport WorldGenRandom

cdef int[16][3] GRADIENTS = [
	[ 1,  1,  0],
	[-1,  1,  0],
	[ 1, -1,  0],
	[-1, -1,  0],
	[ 1,  0,  1],
	[-1,  0,  1],
	[ 1,  0, -1],
	[-1,  0, -1],
	[ 0,  1,  1],
	[ 0, -1,  1],
	[ 0,  1, -1],
	[ 0, -1, -1],
	[ 1,  1,  0],
	[ 0, -1,  1],
	[-1,  1,  0],
	[ 0, -1, -1]
]

cdef double SQRT_3 = sqrt(3.0)
cdef double SKEW_FACTOR_2D = 0.5 * (SQRT_3 - 1.0)
cdef double UNSKEW_FACTOR_2D = (3.0 - SQRT_3) / 6.0

cdef double dot(int[3] grads, double x, double y, double z):
	return x*grads[0] + y*grads[1] + z*grads[2]

cdef class SimplexNoiseSampler:

	def __init__(self, WorldGenRandom random):
		cdef int j, k, l
		self.originX = random.nextDouble() * 256.0
		self.originY = random.nextDouble() * 256.0
		self.originZ = random.nextDouble() * 256.0

		for j in range(256):
			self.permutations[j] = j

		for j in range(256):
			k = random.nextIntBounded(256 - j)
			l = self.permutations[j]
			self.permutations[j] = self.permutations[k + j]
			self.permutations[k + j] = l

	cdef int getGradient(self, int hash):
		return self.permutations[hash & 255]

	cdef double grad(self, int hash, double x, double y, double z, double distance):
		cdef double d, f
		d = distance - x*x - y*y - z*z
		if d < 0.0:
			return 0.0
		return d*d * dot(GRADIENTS[hash], x, y, z)

	cpdef double sampleXY(self, double x, double y):
		cdef double d, e, f, g, h, k, l, m, p, q, r, s, aa, ab, ac
		cdef char n, o
		cdef int i, j, t, u, v, w, z
		d = (x + y) * SKEW_FACTOR_2D
		i = <int>floor(x + d)
		j = <int>floor(y + d)
		e = <double>(i + j) * UNSKEW_FACTOR_2D
		f = <double>i - e
		g = <double>j - e
		h = x - f
		k = y - g

		n = <int>(h > k)
		o = <int>(not n)

		p = h - <double>n + UNSKEW_FACTOR_2D
		q = k - <double>o + UNSKEW_FACTOR_2D
		r = h - 1.0 + 2.0 * UNSKEW_FACTOR_2D
		s = k - 1.0 + 2.0 * UNSKEW_FACTOR_2D
		t = i & 255
		u = j & 255
		v = self.getGradient(t + self.getGradient(u)) % 12
		w = self.getGradient(t + n + self.getGradient(u + o)) % 12
		z = self.getGradient(t + 1 + self.getGradient(u + 1)) % 12
		aa = self.grad(v, h, k, 0.0, 0.5)
		ab = self.grad(w, p, q, 0.0, 0.5)
		ac = self.grad(z, r, s, 0.0, 0.5)
		return 70.0 * (aa + ab + ac)

	cpdef double sampleXYZ(self, double x, double y, double z):
		cdef double e, g, h, l, m, n, o, p, bd, be, bf, bg, bh, bi, bj, bk, bl, bt, bu, bv, bw
		cdef int i, j, k
		cdef char w, aa, ab, ac, ad, bc

		e = (x + y + z) * 0.3333333333333333
		i = <int>floor(x + e)
		j = <int>floor(y + e)
		k = <int>floor(z + e)
		g = <double>(i + j + k) * 0.16666666666666666
		h = <double>i - g
		l = <double>j - g
		m = <double>k - g
		n = x - h
		o = y - l
		p = z - m
		if (n >= o):
			if (o >= p):
				w = 1
				aa = 0
				ab = 0
				ac = 1
				ad = 1
				bc = 0
			elif (n >= p):
				w = 1
				aa = 0
				ab = 0
				ac = 1
				ad = 0
				bc = 1
			else:
				w = 0
				aa = 0
				ab = 1
				ac = 1
				ad = 0
				bc = 1
		elif (o < p):
			w = 0
			aa = 0
			ab = 1
			ac = 0
			ad = 1
			bc = 1
		elif (n < p):
			w = 0
			aa = 1
			ab = 0
			ac = 0
			ad = 1
			bc = 1
		else:
			w = 0
			aa = 1
			ab = 0
			ac = 1
			ad = 1
			bc = 0

		bd = n - <double>w + 0.16666666666666666
		be = o - <double>aa + 0.16666666666666666
		bf = p - <double>ab + 0.16666666666666666
		bg = n - <double>ac + 0.3333333333333333
		bh = o - <double>ad + 0.3333333333333333
		bi = p - <double>bc + 0.3333333333333333
		bj = n - 1.0 + 0.5
		bk = o - 1.0 + 0.5
		bl = p - 1.0 + 0.5
		bm = i & 255
		bn = j & 255
		bo = k & 255
		bp = self.getGradient(bm + self.getGradient(bn + self.getGradient(bo))) % 12
		bq = self.getGradient(bm + w + self.getGradient(bn + aa + self.getGradient(bo + ab))) % 12
		br = self.getGradient(bm + ac + self.getGradient(bn + ad + self.getGradient(bo + bc))) % 12
		bs = self.getGradient(bm + 1 + self.getGradient(bn + 1 + self.getGradient(bo + 1))) % 12
		bt = self.grad(bp, n, o, p, 0.6)
		bu = self.grad(bq, bd, be, bf, 0.6)
		bv = self.grad(br, bg, bh, bi, 0.6)
		bw = self.grad(bs, bj, bk, bl, 0.6)
		return 32.0 * (bt + bu + bv + bw)
