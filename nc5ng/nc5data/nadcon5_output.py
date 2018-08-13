"""

NADCON5 Output Data Wrappers

.. autoclass:: VectorData
.. autoclass:: PointData

"""
from nc5ng.types.meta import FileBackedMetaBase
from nc5ng.types import DataPoint
from nc5ng.types.mixins import DataContainerMixin, MetaMixin, GMTMixin, GMTPointMixin

from ._parsers import VectorFileParser,  CoverageFileParser
from .services import region_bounds

import numpy as np
import pkg_resources




class VectorData(DataContainerMixin, MetaMixin, GMTMixin, metaclass = FileBackedMetaBase, Parser = VectorFileParser):
    """@ingroup nc5data

    """
        

    class VectorDataPoint(DataPoint, GMTPointMixin):
        def __init__(self, lon, lat, az, vector, dlatsec, dlatm, pid, **kwargs):
            super().__init__(lon=lon, lat=lat, az=az, vector=vector, dlatsec=dlatsec, dlatm=dlatm, pid=pid, **kwargs)
        def __mk_gmt_data__(self):
            return (self.lon, self.lat, self.az, self.vector)
            
    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.VectorDataPoint(*data, **self.meta) for data in self.data}


    @property
    def plot_data(self):
        return np.array(self.data)[:,:4].astype(float)
    def __mk_plot_args__(self):
        return {'data':np.array(self.data)[:,:4].astype(float),  'region':region_bounds(self.region), 'symbol':'V'}



class PointData(DataContainerMixin, MetaMixin, GMTMixin, metaclass=FileBackedMetaBase, Parser = CoverageFileParser):

    class PointDataPoint(DataPoint, GMTPointMixin):
        def __init__(self, lon, lat, _empty_, pid, **kwargs):
            super().__init__(lon=lon, lat=lat,  pid=pid, **kwargs)

        def __mk_gmt_data__(self):
            return (self.lon, self.lat)
            

    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.PointDataPoint(*data, **self.meta) for data in self.data}

    def __mk_plot_args__(self):
        return {'data':np.array(self.data)[:,:3].astype(float), 'region':region_bounds(self.region), 'symbol':'P'}
        
    @property
    def plot_data(self):
        return np.array(self.data)[:,:3].astype(float)


class GRDData(object):
    pass

class BData(object):
    pass

        
class XYZData(object):
    pass
