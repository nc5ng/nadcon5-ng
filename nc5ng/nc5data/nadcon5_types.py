"""
`nadcon5-ng` Data Types
-----------------------

DataPoint
~~~~~~~~~

DataPoint is the base DataPointType hierarchy for nadcon5-ng conversions

Other parts of this library may use a different hierarchy, but share a type generator


.. autoclass:: DataPoint
  :members:

Type Mixins
~~~~~~~~~~~

.. autoclass:: MetaMixin
.. autoclass:: DataContainerMixin
.. autoclass:: GMTMixin
.. autoclass:: GMTMetaMixin


"""


from os.path import basename
from nc5ng.types import DataPointType
import logging
    
class DataPoint(metaclass=DataPointType):
    """ 
    Base Data Point Type for `nadcon5-ng` conversion data
    """
    def __init__(self, *args, **kwargs):
        self._data = {}

        # for copy
        if args:
            if issubclass(args[0].__class__, DataPoint):
                kwargs = args[0]._data
        #initialize
        for k,v in kwargs.items():
            self._data[k] = v

    
    def __getattr__(self, name):
        if name in self._data:
            return self._data[name]
        else:
            raise AttributeError()
    

    @property
    def data(self):
        return self._data


    def __getitem__(self,name):
        if name in self._data:
            return self._data[name]
        else:
            raise KeyError()
    """
    def __eq__(self, other):
        if not issubclass(other.__class__, DataPoint) or self.type_shorthand != other.type_shorthand:
            return False
        else:
            for k in self.data:
                if not k in other.data or self.data[k] != other.data[k]:
                    return False
            for k in other.data:
                if not k in self.data:
                    return False
        return True
    """

    def __ge__(self, other):
        """ Superset """
        if  not issubclass(other.__class__, DataPoint):
            return False
        return other.__le__(self)
        
        
    def __gt__(self, other):
        """ Strict Superset """
        if not issubclass(other.__class__, DataPoint):
            return False
        return other.__lt__(self)
        
    def __le__(self, other):
        """ Subset, each element in our data is contained in the other
        """
        if not issubclass(other.__class__, DataPoint):
            return False

        if len(self.data) > len(other.data):
            return False
        else:
            for k in self.data:
                if not k in other.data or self[k] != other[k]:
                    return False
        return True

    def __lt__(self, other):
        """ Strict Subset 
        """
        if not issubclass(other.__class__, DataPoint):
            return False
        
        if len(self.data) >= len(other.data):
            return False

        ## equality requires same length, already checked equality 
        return self.__le__(other)

    
    def __contains__(self, other):
        if not issubclass(other.__class__, DataPoint):
            try:
                k,v = other
                if not k in self.data:
                    return False                
                return self[k] == v
            except (TypeError, ValueError):
                return other in self.data
        else:
            for k in other.data:
                if not k in self.data:
                    return False
        return True

    def __repr__(self):
        return "DataPoint('" + self.__class__.type_shorthand + "', **"+repr(self._data)+")"

    def __str__(self):
        return "Data Point('" + self.__class__.type_shorthand + "') : " + str(self._data)
    
    def __bool__(self):
        return self.data.__bool__()
    

    
class MetaMixin(object):
    """
    Mixin base type for standard meta information
    """    
    
    def _safe_meta_property(index):
        def getter(self):
            if self.meta and index in self.meta:
                return self.meta[index]
            else:
                return None
        return property(getter)
    
    
    
    @property
    def meta(self):
        if hasattr(self, '_meta'):
            return self._meta
        elif hasattr(self, '_data'):
            if 'meta' not in self._data:
                self._data['meta'] = {}
            return self._data['meta']
        else:
            return None

    source = _safe_meta_property('source')
    old_datum = _safe_meta_property('old_datum')
    new_datum = _safe_meta_property('new_datum')
    region = _safe_meta_property('region')
    subregion = _safe_meta_property('subregion')

    @property
    def shorthand(self):
        if self.source:
            return basename(self.source).split('.')[0]




class DataContainerMixin(object):
    """
    Mixin type for containers of DataPoints

    """
    
    @property
    def data(self):
        """
        Get underlying raw data 
        """
        if hasattr(self, '_data'):
            if 'data' not in self._data:
                self._data['data'] = None
            return self._data['data']
        else:
            return None

    @property
    def points(self):
        """
        Get indexed data points
        """
        if hasattr(self, '_indexed_data'):
            return self._indexed_data.values()
        else:
            return None
    
    @property
    def indices(self):
        """
        index values
        """
        if hasattr(self, '_indexed_data'):
            return self._indexed_data.keys()
        else:
            return None

    @property
    def index_tag(self):
        """
        DataPoint field used for indexing
        """
        if hasattr(self, '_index_tag'):
            return self._index_tag
        else:
            return None
    

    def __iter__(self):
        """
        Default Iterator
        """
        for index in self.indices:
            yield self[index]
            
    def __getitem__(self, index):
        if index in self.indices:
            return self._indexed_data[index]
        else:
            return None
    def __init__(self, *args, **kwargs):
        if hasattr(self.__class__, 'parser'):
            self._data = self.__class__.parser.fromfile(*args, **kwargs)
            
        self.__init_indexed_data__()

    def __len__(self):
        return len(self.data)

    def __contains__(self, item):
        if item in self.indices:
            return True
        elif item in self.indexed_data:
            return True
        return False
        






class GMTMixin(object):
        
    @property
    def plot_args(self):
        return self.__mk_plot_args__()
    
    def plot(self, figure, **kwargs):
        pkwargs = self.plot_args
        pkwargs.update(kwargs)
        figure.plot(**pkwargs)

    
        


        

class GMTPointMixin(object):

    @property
    def gmt_data(self):
        return self.__mk_gmt_data__()

    
    
    




class GMTMetaMixin(object):
    def _safe_gmt_meta_property(index):
        def getter(self):
            if self.gmt_meta and index in self.gmt_meta:
                return self.gmt_meta[index]
            else:
                return None
        return property(getter)

    @property
    def gmt_meta(self):
        if not(hasattr(self, '_gmt_meta')):
            self._gmt_meta = {}
        return self._gmt_meta



    gmt_region = _safe_gmt_meta_property('region')
    gmt_projection = _safe_gmt_meta_property('projection')
    gmt_rivers= _safe_gmt_meta_property('rivers')
    gmt_borders= _safe_gmt_meta_property('borders')
    gmt_water= _safe_gmt_meta_property('water')
    gmt_shorelines = _safe_gmt_meta_property('shorelines')
    gmt_land = _safe_gmt_meta_property('land')
    gmt_resolution = _safe_gmt_meta_property('resolution')
    gmt_frame = _safe_gmt_meta_property('frame')
