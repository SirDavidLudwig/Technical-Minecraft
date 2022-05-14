import os, sys
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

# scan the 'minecraft' directory for extension files, converting
# them to extension names in dotted notation
def scandir(dir, files=[]):
    for file in os.listdir(dir):
        path = os.path.join(dir, file)
        if os.path.isfile(path) and path.endswith(".pyx"):
            files.append(path.replace(os.path.sep, ".")[:-4])
        elif os.path.isdir(path):
            scandir(path, files)
    return files


# generate an Extension object from its dotted name
def makeExtension(extName):
    extPath = extName.replace(".", os.path.sep)+".pyx"
    return Extension(
        extName,
        [extPath],
        include_dirs = ["."],   # adding the '.' to include_dirs is CRUCIAL!!
        extra_compile_args = ["-O3", "-Wall"],
        extra_link_args = ['-g'],
        libraries = [],
	)

# get the list of extensions
extNames = scandir("minecraft")

# and build up the set of Extension objects
extensions = [makeExtension(name) for name in extNames]

for e in extensions:
    e.cython_c_in_temp = True
    e.cython_directives = {"language_level": "3"}

setup(
	name="minecraft",
	version='0.1',
	packages=["minecraft", "minecraft.gen", "minecraft.noise", "minecraft.util"],
	ext_modules=extensions,
    include_dirs=[numpy.get_include()],
	cmdclass={'build_ext': build_ext},
	package_data={
		"minecraft": ["**/*.pxd"],
	}
)
