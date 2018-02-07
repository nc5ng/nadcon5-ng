import logging


class DataPointType(type):
    
    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        """ Prepare the new class, here for completeness
        """
        logging.debug("Preparing Class %s"%name)
        return super().__prepare__(name, bases, **kargs)


    @property
    def type_shorthand(cls):
        return cls._type_shorthand
    
    @property
    def point_set(cls):
        return cls._point_set

    @property
    def point_database(cls):
        return cls._cbdb
    
    
    def __new__(metacls, name, bases, namespace,  **kargs):

        logging.debug("Creating Class %s"%name)
        cls = super().__new__(metacls, name, bases, namespace)
        
        if not(hasattr(cls, '_cbdb')):
            logging.debug("Creating Data Point Database")
            cls._cbdb = dict()

        cls._type_shorthand = name.lower()
        cls._point_set = set()
        
        logging.debug("Registering new Data Point Type %s with shorthand %s"%(name, cls._type_shorthand))
        cls._cbdb[cls.type_shorthand]={'type':cls, 'points': cls._point_set }
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


    def _register_point(cls, point):
        cls._point_set.add(point)

    def __call__(cls, *args,  **kw):

        """
        if typename is not None:
            if typename not in cls._cbdb:
                raise TypeError("Invalid Data Point Type with Shorthand %s"%typename)
            cls = cls._cbdb[typename]['type']
        """
        point = super().__call__(*args, **kw)
        cls._register_point(point)

        return point

    
    
class DataPoint(metaclass=DataPointType):
    def __init__(self, *args, **kwargs):
        self._data = {}

        # for copy
        if len(args) == 1:
            kwargs = args[0]._data

        #initialize
        for k,v in kwargs.items():
            self._data[k] = v

    def __getattr__(self, name):
        if name in self._data:
            return self._data[name]

    @property
    def data(self):
        return self._data

    def __getitem__(self,name):
        if name in self._data:
            return self._data[name]


    def __repr__(self):
        return "DataPoint(**"+repr(self._data)+")"

    def __str__(self):
        return "Data Point: " + str(self._data)
    




def _safe_meta_property(index):
    def getter(self):
        if self.meta and index in self.meta:
            return self.meta[index]
        else:
            return None
    return property(getter)
    
class MetaMixin(object):
    
    
    @property
    def meta(self):
        if hasattr(self, '_data'):
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
    

class DataContainerMixin(object):

    @property
    def data(self):
        if hasattr(self, '_data'):
            if 'data' not in self._data:
                self._data['data'] = None
            return self._data['data']
        else:
            return None

    @property
    def points(self):
        if hasattr(self, '_indexed_data'):
            return self._indexed_data.values()
        else:
            return None
    
    @property
    def indices(self):
        if hasattr(self, '_indexed_data'):
            return self._indexed_data.keys()
        else:
            return None

    @property
    def index_tag(self):
        if hasattr(self, '_index_tag'):
            return self._index_tag
        else:
            return None
    

    def __iter__(self):
        for index in self.indices:
            yield self[index]
            
    def __getitem__(self, index):
        if index in self.indices:
            return self._indexed_data[index]
        else:
            return None


    def __init__(self, *args, **kwargs):
        self._data = self.__class__.parser.fromfile(*args, **kwargs)
        self.__init_indexed_data__()
