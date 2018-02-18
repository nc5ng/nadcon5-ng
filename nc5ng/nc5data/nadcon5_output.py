from .nadcon5_files import VectorFileParser, FileBackedMetaBase, CoverageFileParser
from .nadcon5_types import DataPoint, DataContainerMixin, MetaMixin
import pkg_resources




class VectorData(DataContainerMixin, MetaMixin, metaclass = FileBackedMetaBase, Parser = VectorFileParser):
    """@ingroup nc5data

    """
        

    class VectorDataPoint(DataPoint):
        def __init__(self, lon, lat, az, vector, dlatsec, dlatm, pid, **kwargs):
            super().__init__(lon=lon, lat=lat, az=az, vector=vector, dlatsec=dlatsec, dlatm=dlatm, pid=pid, **kwargs)
                        
            
    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.VectorDataPoint(*data, **self.meta) for data in self.data}





class PointData(DataContainerMixin, MetaMixin, metaclass=FileBackedMetaBase, Parser = CoverageFileParser):

    class PointDataPoint(DataPoint):
        def __init__(self, lon, lat, _empty_, pid, **kwargs):
            super().__init__(lon=lon, lat=lat,  pid=pid, **kwargs)

    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.PointDataPoint(*data, **self.meta) for data in self.data}
        


class GRDData(object):
    pass

class BData(object):
    pass

        
class XYZData(object):
    pass
