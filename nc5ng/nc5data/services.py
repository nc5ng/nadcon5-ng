"""
Static NADCON Data  Services
============================

Services to access certain static nadcon input data
e.g. Grid Bound points


.. autofunc: nc5ng.nc5data.region_bounds
"""

from .nadcon5_input import RegionData



s = RegionData()

def region_bounds(region):
    """ Compute Region Bounds from singleton data"""
    if region in s:
        return s[region].bounds
    else:
        return None


def regions():
    return list(s.indices)


    
