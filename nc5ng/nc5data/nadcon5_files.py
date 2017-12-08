from os.path import basename

class GridParamFile(type):
    """Reader of NADCON5.0 Grid Param Files

    This is effectively a factory for GridBound

    Based on native nadcon5.0 data, which comes packaged. 

    As such, this is a metaclass.

    Which is just a normal(-ish) class, but we get to fiddle
    with every GridBound that gets created. 
    """

    _VALID_REGIONS = (
        'conus',
        'alaska',
        'hawaii',
        'prvi',
        'as',
        'guamcnmi',
        'stpaul',
        'stgeorge',
        'stlawrence',
        'stmatthew',
    )

    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        return super().__prepare__(name, bases, **kargs)

    def __new__(metacls, name, bases, namespace, **kargs):
        return super().__new__(metacls, name, bases, namespace)

    def __call__(cls, region, *a, **kw):
        if region not in cls._VALID_REGIONS:
            return None

        return super().__call__(region, *a, **kw)
    
    
    def __init__(cls, name, bases, namespace, fpath=None, **kwargs):
        """ GridParamFile  constructor
        gets called when GridParam is defined
        """
        
        
        cls._source_name=basename(fpath)
        
        with open(fpath) as f:
            print ("opened ", fpath)
            cls.__init_read__(f)

        super().__init__(name, bases, namespace)

    def __init_read__(self, f=None):
        """ 
        We pre-read the file into an array of strings

        self.raw_data

        Then construct an index dictionary by region (first word in the string)

        self.indexed_data
       
        region1: (n,s,w,e)
        """

        self._raw_data = tuple(f)
        self._indexed_data = { region: tuple(map(lambda x: float(x.strip()), data))
                              for region, *data
                              in tuple(map(lambda x: x.split(),
                                      self._raw_data))
                              if region in self._VALID_REGIONS }

        #print (self.raw_data)
        #print (self.indexed_data)
        
    



