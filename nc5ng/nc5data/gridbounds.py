from .nadcon5_files import GridParamFile as MyMeta
import pkg_resources

GRID_FILE = pkg_resources.resource_filename('nc5ng.nc5data', 'data/Data/grid.parameters')

class GridBounds(metaclass=MyMeta, fpath=GRID_FILE):
    
    
    def __init__(self, region):

        self._region = region
        self._n, self._s, self._w, self._e = GridBounds._indexed_data[region]


    @property
    def N(self):
        return self._n

    @property
    def S(self):
        return self._s

    @property
    def W(self):
        return self._w

    @property
    def E(self):
        return self._e


    @property
    def region(self):
        return self._region
