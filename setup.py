#!/usr/bin/env python
## -*- encoding: utf-8 -*-

import os
import sys
from setuptools import setup
from codecs import open # To open the README file with proper encoding
from setuptools.command.test import test as TestCommand # for tests
from setuptools.extension import Extension
from sage.env import sage_include_directories, SAGE_LOCAL
from Cython.Build import cythonize

# Get information from separate files (README, VERSION)
def readfile(filename):
    with open(filename,  encoding='utf-8') as f:
        return f.read()

# For the tests
class SageTest(TestCommand):
    def run_tests(self):
        errno = os.system("sage -t --force-lib pycontrolled_reduction")
        if errno != 0:
            sys.exit(1)

if not os.path.isfile(os.path.join(SAGE_LOCAL, "include", "controlled-reduction", "wrapper.h")):
    print("The controlled reduction library is not installed.")
    sys.exit(1)

cythonize_dir = "build"

kwds = {"include_dirs": sage_include_directories()}


extensions = [
    Extension('pycontrolled_reduction.controlled_reduction',
               sources = ['pycontrolled_reduction/controlled_reduction.pyx'],
               language='c++',
               libraries = ["gmp", "flint", "ntl", "mpir", "mpfr"], 
              **kwds)
]
extensions = [
    Extension("pydeformation.deformation", ["pydeformation/deformation.pyx"], **kwds)
]

setup(
    name="pycontrolled_reduction",
    author="Edgar Costa, Jennifer Balakrishnan",
    author_email="edgarcosta@math.dartmouth.edu",
    url="https://github.com/edgarcosta/pycontrolled_reduction",
    license="GNU General Public License, version 2 or 3",
    description="Wrapper for controlled reduction library by Edgar Costa",
    long_description = readfile("README.rst"), # get the long description from the README
    version = readfile("VERSION"), # the VERSION file is shared with the documentation
    classifiers=[
      # How mature is this project? Common values are
      #   3 - Alpha
      #   4 - Beta
      #   5 - Production/Stable
      'Development Status :: 4 - Beta',
      'Intended Audience :: Science/Research',
      'Topic :: Scientific/Engineering :: Mathematics',
      'License :: OSI Approved :: GNU General Public License v2 or v3',
      'Programming Language :: Python :: 2.7',
    ], # classifiers list: https://pypi.python.org/pypi?%3Aaction=list_classifiers
    keywords = "sagemath controlled reduction",
    setup_requires=["cython", "sagemath"], # currently useless, see https://www.python.org/dev/peps/pep-0518/
    install_requires=["cython", "sagemath"],
    packages=["pycontrolled_reduction"],
    include_package_data = True,
    ext_modules = cythonize(extensions),
    cmdclass = {'test': SageTest} # adding a special setup command for tests
    #ext_modules = extensions,
    #cmdclass = {'test': SageTest, 'build_ext': Cython.Build.build_ext} # adding a special setup command for tests and build_ext
)
