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


    
