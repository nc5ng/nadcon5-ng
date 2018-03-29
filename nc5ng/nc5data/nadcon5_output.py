from .nadcon5_files import VectorFileParser, FileBackedMetaBase, CoverageFileParser
from .nadcon5_input import RegionData
from .nadcon5_types import DataPoint, DataContainerMixin, MetaMixin, GMTMixin
import numpy as np
import pkg_resources




class VectorData(DataContainerMixin, MetaMixin, GMTMixin, metaclass = FileBackedMetaBase, Parser = VectorFileParser):
    """@ingroup nc5data

    """
        

    class VectorDataPoint(DataPoint):
        def __init__(self, lon, lat, az, vector, dlatsec, dlatm, pid, **kwargs):
            super().__init__(lon=lon, lat=lat, az=az, vector=vector, dlatsec=dlatsec, dlatm=dlatm, pid=pid, **kwargs)
                        
            
    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.VectorDataPoint(*data, **self.meta) for data in self.data}


    def _mk_plot_args(self):
        return {'data':np.array(self.data)[:,:4].astype(float), 'style':'v', 'region':RegionData.region_bounds(self.region)}



class PointData(DataContainerMixin, MetaMixin, GMTMixin, metaclass=FileBackedMetaBase, Parser = CoverageFileParser):

    class PointDataPoint(DataPoint):
        def __init__(self, lon, lat, _empty_, pid, **kwargs):
            super().__init__(lon=lon, lat=lat,  pid=pid, **kwargs)

    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.PointDataPoint(*data, **self.meta) for data in self.data}


    def _mk_plot_args(self):
        return {'data':np.array(self.data)[:,:3].astype(float), 'style':'p','region':RegionData.region_bounds(self.region)}
        


class GRDData(object):
    pass

class BData(object):
    pass

        
class XYZData(object):
    pass
