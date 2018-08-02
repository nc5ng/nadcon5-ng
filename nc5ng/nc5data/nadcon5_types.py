from os.path import basename
import logging




class DataPointType(type):
    """ Metaclass for DataPoints, defines class creation and class/hierarchy member variables 
    
    The meta-class in part, hides some of the more rote requirements of our datapoint type
    from the actual object hierarchy

    This allows some magic like run-time casting to the correct datapoint without knowing the 
    type specifically, and a persisitent library-wide memory backed database for quick retrieval and to minimize replication

    To understand the meta class, there are a number of tutorials available online, roughly speaking this class is what is used to "create" the DataPoint class, and allows us to manipulate the class without needing any implementation details. 


    Defining a new DataPointType Hierarchy simply requires using this class as the metaclass

        class NewDataPoint(metaclass=DataPointType):
          pass

    By creating a new DataPointType, the following changes will be done to the final class

      - The type will have a database (dictionary) of types registered with the base class
      - Each type and subtype will have a point container (default set) created
      - The shorthand name will be generated from the class name
      - Instance Creation will be overidden and allow creation of any other data type by specifting the type shorthand as an argument
      

    Class Configuration:

    Each new type has some meta-configuration available

    1. To override data point registration 
       - Create a `@classmethod`  `__register__(cls, point)` to overide how a new point is registered/saved
       - Create a class member `_point_store` to change the underlying storage type (from set)
    2. Override shorthand name by specific '_type_shorthand' explicitly in the class
    
    
    Any class that uses this type as a metaclass will be registered 
    """
    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        """ Prepare the new class, here for completeness
        """
        logging.debug("Preparing Class %s"%name)
        return super().__prepare__(name, bases, **kargs)


    @property
    def type_shorthand(cls):
        """ Get the class shorthand name"""
        return cls._type_shorthand
    
    @property
    def point_store(cls):
        """ Return the type-specific Point Buffer"""
        return cls._point_store

    @property
    def point_database(cls):
        """ Return the Root Database of all DataPoints in this Hierarchy"""
        return cls._cbdb
    
    
    def __new__(metacls, name, bases, namespace,  **kargs):
        """ Create a new data point type, called on class load

        Creates class attributes level point set for storage
        
        metaclass __new__ is executed on load time for every
        class that uses it, it is executed after __prepare__ which
        constructs the class object
        """

    
        logging.debug("Creating Class %s"%name)
        cls = super().__new__(metacls, name, bases, namespace)
        
        if not(hasattr(cls, '_cbdb')):
            logging.debug("Creating Data Point Database")
            cls._cbdb = dict()


        # Shorthand Name
        cls._type_shorthand =  name.lower()
        while cls._type_shorthand in cls._cbdb:
            cls._type_shorthand = cls._type_shorthand + "_" # in case of name conflict, add underscore

        # Point Storage
        cls._point_store = namespace.get('_point_store', set() )
        
        
        logging.debug("Registering new Data Point Type %s with shorthand %s"%(name, cls._type_shorthand))

        
        cls._cbdb[cls.type_shorthand]={'type':cls, 'points': cls._point_store }
        return cls

    
    def __init__(cls, name, bases, namespace):
        """ Initialize a new FileBacked Class

        This is a slot method for class creation, __init__ is called when class is defined (load time)

        \param cls - reference to new type, similiar to @classmethod
        \param name - new class name
        \param bases - base classes
        \param namespace - new class attributes
        \param Parser - BaseFileParser underlying this type
        \param **kwargs - keywords passed to Parser initialization
        
        """        
        logging.debug("Creating Data Point Class %s"%name)

        super().__init__(name, bases, namespace)


    def __register__(cls, point):
        """ Register a point with the class buffer """
        cls._point_store.add(point)

    def __call__(cls, *args,  **kw):
        """ Create a new Point in this hierarchy"""

        """
        if typename is not None:
            if typename not in cls._cbdb:
                raise TypeError("Invalid Data Point Type with Shorthand %s"%typename)
            cls = cls._cbdb[typename]['type']
        """
        if args and (args[0] in cls.point_database.keys()):
            typename=args[0]
        elif kw and ('type' in kw):
            typename = kw['type']
        else:
            typename = cls.type_shorthand


        if typename == cls.type_shorthand:
            point = super().__call__(*args, **kw)
            if not getattr(point, 'ephemeral', False):
                cls.__register__(point)
        elif typename in cls.point_database.keys():
            point = cls.point_database[typename]['type'].__call__(*args, **kw)
        else:
            return None

        return point

    
    
class DataPoint(metaclass=DataPointType):
    """ 
    Base Data Point Type
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
