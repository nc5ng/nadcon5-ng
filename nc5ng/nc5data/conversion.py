from .nadcon5_files import ControlFileParser, InFileParser, FileBackedMetaBase, WorkEditsFileParser, SingletonFileBackedMeta, GridParamFileParser
from .nadcon5_types import DataPoint, DataContainerMixin, MetaMixin
import pkg_resources


class GridBounds(DataContainerMixin, MetaMixin, metaclass = SingletonFileBackedMeta, Parser = GridParamFileParser):
    """@ingroup nc5data

    """
        

    class GridBound(DataPoint):
        def __init__(self, region, n,s,w,e):
            super().__init__(region=region,N=n, S=s, W=w, E=e)
                        
        @classmethod
        def from_gridbound(cls, instance):
            return cls(instance.region, instance.N, instance.S, instance.W, instance.E)

        def __str__(self):
            return "%s : N%f S%f W%f E%f"%(self.region, self.N, self.S, self.W, self.E)

        def __repr__(self):
            return "GridBound( region = %s , n = %f, s = %f, w = %f, e = %f )"%(self.region, self.N, self.S, self.W, self.E)

    def __init_indexed_data__(self):
        self._indexed_data = { region:self.GridBound(region, *data) for region, *data in self.data}


                 
                   


def _extract_subregion(in_file):
    vals = in_file.split('.')
    if len(vals) == 4:
        return None
    if len(vals) == 5:
        return vals[-2]

class Conversion(DataContainerMixin, MetaMixin, metaclass=FileBackedMetaBase, Parser=ControlFileParser):
    class ConversionEntry(DataPoint):
        def __init__(self, region, old_datum, new_datum, in_file):
            
            super().__init__( region=region, old_datum=old_datum, new_datum=new_datum, in_file = in_file, subregion=_extract_subregion(in_file))
            
        


    def __init_indexed_data__(self):
        self._indexed_data = [ Conversion.ConversionEntry(self.region, self.source, self.target, in_file) for in_file in self.data ]
        self._index_tag = 'subregion'
        self._indexed_data = { point.subregion : point for point in self._indexed_data }
        

    @property
    def region(self):
        return self._data['meta']['REGION']

    @property
    def source(self):
        return self._data['meta']['DATUM1']

    @property
    def target(self):
        return self._data['meta']['DATUM2']
    
    @property
    def rejmet(self):
        return int(self._data['meta']['REJMET'])

    @property
    def n_infiles(self):
        return int(self._data['meta']['NFILES'])
        
    @property
    def infiles(self):
        return self._data['data']

            







class InData(DataContainerMixin, MetaMixin,  metaclass=FileBackedMetaBase, Parser=InFileParser):
    class InDataPoint(DataPoint):
        def __init__(self, pid, subregion, oldlat, oldlon, oldht, newlat, newlon, newht, **kwargs):
            super().__init__(pid=pid, subregion=subregion, oldlat=oldlat, oldlon=oldht, newlat=newlat, newlon=newlon, newht=newht, **kwargs)
            
           

    def __init_indexed_data__(self):
        self._index_tag = 'pid'
        self._indexed_data = { pid:self.InDataPoint(pid, *data) for pid, *data in self.data}

    @property
    def source(self):
        if 'meta' in self._data and 'source' in self._data['meta']:
            return self._data['meta']['source']

            
                 
        
            
    


class ExclusionData(DataContainerMixin, MetaMixin, metaclass=FileBackedMetaBase, Parser=WorkEditsFileParser):
    
    class ExclusionDataPoint(DataPoint):
        def __init__(self,  olddtm, newdtm, region,pid,rejlat, rejlon, rejeht, reason, **kwargs):
            super().__init__( olddtm=olddtm, newdtm=newdtm, region=region,pid=pid,rejlat=rejlat, rejlon=rejlon, rejeht=rejeht, reason=reason, **kwargs)


    def __init_indexed_data__(self):
        self._index_tag = 'pid'
        self._indexed_data = { data[3]:self.ExclusionDataPoint(*data) for data in self.data }
    
