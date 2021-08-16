from distutils.extension import Extension
from setuptools import Extension, setup
from Cython.Build import cythonize

extensions = [Extension("javarand", ["src/javarand.pyx"])]

setup(
	name='javarand',
	version='0.1',
	ext_modules = cythonize(extensions, language_level="3"),
	zip_safe=False
)
