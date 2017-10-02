# distutils: language = c++
# clang c++
# Copyright 2017 Jennifer Balakrishnan, Edgar Costa 
# See LICENSE file for license details.


from cysignals.signals cimport sig_on, sig_off
from sage.rings.integer_ring import ZZ
#from sage.rings.polynomial.polynomial_ring import PolynomialRing
from sage.all import PolynomialRing
from sage.libs.ntl.ntl_ZZX cimport ntl_ZZX

def controlledreduction(f, p, verbose = False):
    r"""
    Input: 
        -- ``f`` -- a homogeneous polynomial in ``n + 1`` variables with total degree ``d`` with ``d > n``
        -- ``p`` -- a prime of good reduction that does not divide ``d``
        -- ``verbose`` -- a boolean
    Output:
        The characteristic polynomial of Frobenius acting on the $n$-th cohomology group of the complement of the hypersurface defined by f(t = t_0) over F_q.
    
    Examples::

    sage: from pycontrolledreduction import controlledreduction

    sage: R.<x,y,z,w> = ZZ[];
    sage: controlledreduction(x^4 + y^4 + z^4 + w^4 + 1*x*y*z*w, 11, False)  # long time
    (-1) * (11*T + 1)^6 * (11*T - 1)^13 * (121*T^2 + 18*T + 1)
    
    sage: R.<x,y,z> = ZZ[];
    sage: controlledreduction(x^4 + y^4 + z^4 + 1*x^2*y*z, next_prime(10000), False).factor()
(10007*T^2 - 192*T + 1) * (10007*T^2 - 128*T + 1) * (10007*T^2 + 192*T + 1)
    
    sage: controlledreduction(y^2*z + y*z^2 - (x^3 + y*x^2 -2*x*z^2), 97, false).list() == EllipticCurve([0, 1, 1, -2, 0]).change_ring(GF(97)).frobenius_polynomial().reverse().list()
    True 
    """
    if not f.is_homogenous():
        raise TypeError('f must be homoegeneous');
    if not f.total_degree() >= len(f.variables()):
        raise TypeError('the degree of f must be larger than the dimension of the ambient projective space')
    if  f.total_degree() % p == 0:
        raise TypeError('the total degree of f cannot be zero modulo p')

    I = f.change_ring(GF(p)).jacobian_ideal().radical()
    if I != Ideal(I.gens()):
        raise TypeError('f is not smooth modulo p')

    cdef vector[int64_t] coef
    cdef vector[ vector[int64_t] ] keys
    for mvec, c in f.dict().iteritems():
        coef.push_back(c % p)
        keys.push_back(mvec)
    cdef ntl_ZZX zeta = ntl_ZZX()
    cdef int cverbose = int(verbose);
    
    sig_on()
    zeta_function(zeta.x, keys, coef, p, cverbose)
    sig_off()
    # convert zeta to a sage polynomial
    poly=[]
    for i in range(zeta.degree()+1):
        poly.append(zeta[i]._integer_())

    return PolynomialRing(ZZ, 'T')(poly).reverse()
