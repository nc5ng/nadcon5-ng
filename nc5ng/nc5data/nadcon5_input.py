from .nadcon5_files import ControlFileParser, InFileParser, FileBackedMetaBase, WorkEditsFileParser, SingletonFileBackedMeta, GridParamFileParser
from .nadcon5_types import DataPoint, DataContainerMixin, MetaMixin, GMTMixin, GMTPointMixin
import pkg_resources


class RegionData(DataContainerMixin, MetaMixin, metaclass = SingletonFileBackedMeta, Parser = GridParamFileParser):
    """@ingroup nc5data

    """
        

    class GridBound(DataPoint):
        def __init__(self, region, n,s,w,e, **kwargs):
            super().__init__(region=region,N=n, S=s, W=w, E=e, **kwargs)
        @property
        def bounds(self):
            return (self.W, self.E, self.S, self.N)

    def __init_indexed_data__(self):
        self._indexed_data = { region:self.GridBound(region, *data, **self.meta) for region, *data in self.data}




def _extract_subregion(in_file):
    vals = in_file.split('.')
    if len(vals) == 4:
        return None
    if len(vals) == 5:
        return vals[-2]

class ControlData(DataContainerMixin, MetaMixin, metaclass=FileBackedMetaBase, Parser=ControlFileParser):
    class ControlDataPoint(DataPoint):
        def __init__(self, in_file, **kwargs):
            
            super().__init__( in_file = in_file, subregion=_extract_subregion(in_file), **kwargs)
            
        


    def __init_indexed_data__(self):
        self._indexed_data = [ ControlData.ControlDataPoint(in_file, **self.meta)  for in_file in self.data ]
        self._index_tag = 'subregion'
        self._indexed_data = { point.subregion : point for point in self._indexed_data }
        

    @property
    def rejmet(self):
        return int(self._data['meta']['rejmet'])

    @property
    def n_infiles(self):
        return int(self._data['meta']['nfiles'])
        
    @property
    def infiles(self):
        return self._data['data']

            

    def __contains__(self, point):
        
        if not(super().__contains__(point)) and 'region' in point and point.region == self.region:
            return True
        else:
            return False




class InData(DataContainerMixin, MetaMixin,GMTMixin,  metaclass=FileBackedMetaBase, Parser=InFileParser):
            
    class InDataPoint(DataPoint):
        def __init__(self, pid, subr, oldlat, oldlon, oldht, newlat, newlon, newht, **kwargs):
            super().__init__(pid=pid, #subregion=subregion,
                             oldlat=oldlat, oldlon=oldlon, oldht=oldht, newlat=newlat, newlon=newlon, newht=newht, **kwargs)


    def __init_indexed_data__(self):
        self._index_tag = 'pid'
        self._indexed_data = { pid:InData.InDataPoint(pid, *data, **self.meta) for pid, *data in self.data}


    @property
    def source(self):
        if 'meta' in self._data and 'source' in self._data['meta']:
            return self._data['meta']['source']

    def __mk_plot_args__(self):
        return {'data':np.array(self.data)[:,2:3].astype(float), 'style':'p','region':RegionData.region_bounds(self.region)}

                 
        
            
    


class ExclusionData(DataContainerMixin, MetaMixin, metaclass=SingletonFileBackedMeta, Parser=WorkEditsFileParser):
    
    class ExclusionDataPoint(DataPoint):
        def __init__(self,  olddtm, newdtm, region,pid,rejlat, rejlon, rejeht, reason, **kwargs):
            super().__init__( olddtm=olddtm, newdtm=newdtm, region=region,pid=pid,rejlat=rejlat, rejlon=rejlon, rejeht=rejeht, reason=reason, **kwargs)


    def __init_indexed_data__(self):
        self._index_tag = 'pid'
        self._indexed_data = { (data[3], data[0], data[1]):self.ExclusionDataPoint(*data, **self.meta) for data in self.data }
    
