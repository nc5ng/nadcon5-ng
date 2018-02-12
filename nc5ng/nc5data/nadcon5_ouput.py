from .nadcon5_files import VectorFileParser, FileBackedMetaBase
from .nadcon5_types import DataPoint, DataContainerMixin, MetaMixin
import pkg_resources




class VectorData(DataContainerMixin, MetaMixin, metaclass = FileBackedMetaBase, Parser = VectorFileParser):
    """@ingroup nc5data

    """
        

    class VectorDataPoint(DataPoint):
        def __init__(self, xlonh, xlath, az, vector, dlatsec, dlatm, pid, **kwargs):
            super().__init__(xlonh=xlonh, xlath=xlath, az=az, vector=vector, dlatsec=dlatsec, dlatm=dlatm, pid=pid, **kwargs)
                        
            
    def __init_indexed_data__(self):
        self._indexed_data = { data[-1]:self.VectorDataPoint(*data) for data in self.data}




