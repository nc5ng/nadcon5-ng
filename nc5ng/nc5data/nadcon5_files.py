from os.path import basename, exists, join, isdir, isfile
from os import listdir

from .utils import dmstodec
from .dataset import DataPoint

class FileMetaBase(type):
    """ This class is the base for our metaclass hierarchy

    These classes create a system for a file backed database
    hiding much of the underlying file parsing from the user
    
    Shared low level functionality for parsing files
    
    
    """
    
    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        """ Prepare the new class, here for completeness
        """
        return super().__prepare__(name, bases, **kargs)

    def __new__(metacls, name, bases, namespace, **kargs):
        return super().__new__(metacls, name, bases, namespace)
    
    def __init__(cls, name, bases, namespace, fpath=None, **kwargs):
        """
        """        
        cls._fpath = fpath
        if fpath is None:
            print ("Registering new data class ", name, " with no underlying filepath")
        elif isfile(fpath):
            print ("Registering new data class ", name , " backed by file ", fpath)
        elif isdir(fpath):
            print ("Registering new data class ", name , " backed by directory ", fpath)
        else:
            print ("Registering new data class ", name, " but path ", fname, " not found")
            
        
    def __init_read__(cls, key, f):
        pass


    def __init_dir__(cls):
        """ Initialize the class variables for a directory backed class
        """
        cls._fmatrix = []
        cls._openf = {}
        

        
    ## These properties are automatically created in every class that uses
    ## This as meta class
    
    @property
    def fpath(self):
        return self._fpath

    
            
        

    

## \ingroup nc5data
## \brief \ref sgridparams reader
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
    """ Hardcoded Valid Regions """
    

    def __call__(cls, region, *a, **kw):
        if region not in cls._VALID_REGIONS:
            return None

        return super().__call__(region, *a, **kw)
    
    
    def __init__(cls, name, bases, namespace, fpath=None, **kwargs):
        """ GridParamFile  constructor
        gets called when GridParam is defined 

        because GridParam (the class) *is* a GridParamFile
        """
        
        cls._source_name=basename(fpath)
        
        with open(fpath) as f:
            print ("opened ", fpath)
            cls.__init_read__(f)


        super().__init__(name, bases, namespace)

    def __init_read__(cls, f=None):
        """ 
        We pre-read the file into an array of strings

        cls.raw_data

        Then construct an index dictionary by region (first word in the string)

        cls.indexed_data
       
        region1: (n,s,w,e)
        """

        cls._raw_data = tuple(f) #Split into tuples
        cls._indexed_data = { region: tuple(map(lambda x: float(x.strip()), data)) # region:(float,float,float...)
                              for region, *data    #grab first element as region rest in data
                              in tuple(map(lambda x: x.split(),cls._raw_data)) #split each line into a tuples by whitespace
                              if region in cls._VALID_REGIONS # only select lines with valid index
        } #_indexed_data



## \ingroup nc5data        
## \brief \ref scontrolfile reader
class ControlFile(type):
    """Reader of NADCON5.0 Control Files

    This is effectively a factory for Conversion

    The control file defines all the allowed conversions (Region, Old Datum, New Datum)

    This is a metaclass.

    Which is just a normal(-ish) class, but we get to fiddle
    with every Conversion that gets created. 
    """

    
    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        return super().__prepare__(name, bases, **kargs)

    def __new__(metacls, name, bases, namespace, **kargs):
        return super().__new__(metacls, name, bases, namespace)

    def __call__(cls, region, old_datum, new_datum, *a, **kw):

        key = (region,old_datum,new_datum,)
        
        if not(cls.valid_conversions(*key)):
            return None

        if key not in cls._open_conversions.keys():
            with open(join(cls._control_path, "control.%s.%s.%s"%(old_datum, new_datum,region))) as f:
                cls.__init_read__(*key,f)
                

        
        return super().__call__(*key, *a, **kw)

    def __init_read__(cls, region, old_datum, new_datum, f):
        """
        Metaclass constructor function which reads the underlying \ref scontrolfile
        Fixed Format
        """
        conversion_record = {'in_files':[]}

        is_hdr = lambda x: ": " in x
        split_hdr  = lambda x: x.split(': ')


        
        for line in f:
            if is_hdr(line):
                k,v = split_hdr(line)
                conversion_record[k]=v
            else:
                conversion_record['in_files'].append(line.split()[0])
                
        cls._open_conversions[(region, old_datum, new_datum,)] = conversion_record
        

        
    
    def __init__(cls, name, bases, namespace, fpath=None, **kwargs):
        """ ControlFile  construct
        gets called when  is defined 

        because GridParam (the class) *is* a GridParamFile
        """

        if fpath is not None:
            cls._control_path = fpath
            cls._control_files = (f_ for f_ in listdir(fpath) if "control." in f_)
            cls.__init_conversions__()
            

        super().__init__(name, bases, namespace)

    def __init_conversions__(cls):
        cls._conversion_matrix = []
        for fname in cls._control_files:
            if exists(join(cls._control_path, fname)):
                cls._conversion_matrix.append(tuple(fname.split('.')[1:4]))

        _zipped_matrix = [_ for _ in zip(*cls._conversion_matrix)]
        cls._regions = list(set(_zipped_matrix[2]))
        cls._source_datums = list(set(_zipped_matrix[0]))
        cls._target_datums = list(set(_zipped_matrix[1]))
        cls._open_conversions = {}

    @property
    def regions(self):
        return self._regions

    @property
    def source_datums(self):
        return self._source_datums

    @property
    def target_datums(self):
        return self._target_datums


    def valid_conversions(self, region=None, source=None, target=None):
        """ Returns a tuple of valid conversions all arguments optional to partial filtering """

        return tuple([(region_, source_, target_,) for source_, target_, region_ in self._conversion_matrix if ( region == None or region_ == region) and (source==None or  source_ == source) and (target==None or target_ == target) ])

        



## \ingroup nc5data
## \brief \ref sinfiles reader
class InFile(type):
    """Reader of NADCON5.0 In Files

    This is effectively a factory for DataSet

    This is a metaclass.

    Which is just a normal(-ish) class, but we get to fiddle
    with every ConverersionData that gets created. 
    """

    
    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        return super().__prepare__(name, bases, **kargs)

    def __new__(metacls, name, bases, namespace, **kargs):
        return super().__new__(metacls, name, bases, namespace)

    def fromfile(cls, fname, **kw):
        if fname not in cls._in_files:
            print (fname, " not in infile")
            return None

        print(fname)
        old_datum, new_datum, subregion = InFile._parse_fname(fname)

        return cls.__call__(subregion, old_datum, new_datum, **kw)
    
    def __call__(cls, subregion, old_datum, new_datum, *a, **kw):
        key = (subregion,old_datum,new_datum,)
        
        if not(cls.valid_dataset(*key)):
            return None

        if key not in cls._open_inputs.keys():
            with open(cls._key_tofname(*key)) as f:
                cls.__init_read__(*key,f)
                

        
        return super().__call__(*key, *a, **kw)
    
    def __init_read__(cls, subregion, old_datum, new_datum, f):
        """
        Metaclass constructor function which reads the underlying \ref scontrolfile
        Fixed Format
        """
        in_data = []

        split_line = lambda x: x.split()
        is_data = lambda x: len(split_line(x))==10
        
        for line in f:
            if is_data(line):
                pid, subr, subrcode, oldlat, oldlon, oldht, _, newlat, newlon, newht = entry =  split_line(line)
                oldlat = None if oldlat == "N/A" else dmstodec(oldlat)
                oldlon = None if oldlon == "N/A" else dmstodec(oldlon)
                oldht = None if oldht == "N/A" else float(oldht)
                newlat = None if newlat == "N/A" else dmstodec(newlat)
                newlon = None if newlon == "N/A" else dmstodec(newlon)
                newht = None if newht == "N/A" else float(newht)
                in_data.append(DataPoint( pid, ((oldlat, oldlon, oldht) , (newlat, newlon, newht)), region=None, subregion=subr, old_datum = old_datum, new_datum = new_datum))
            else:
                print("Invalid Line ", line)
                               
        cls._open_inputs[(subregion, old_datum, new_datum,)] = tuple(in_data)


        
    

        
        
    def __init__(cls, name, bases, namespace, fpath=None, **kwargs):

        if fpath is not None:
            cls._in_path = fpath
            cls._in_files = tuple(f_ for f_ in listdir(fpath) if ".in" in f_[-3:])
            cls.__init_inputs__()
        
        super().__init__(name, bases, namespace)


    @classmethod
    def _parse_fname(cls,fname):
        _ , source, target, *subr = fname.split('.')
        subr = 'all' if subr[0] == "in" else subr[0]

        return source,target,subr

    
    def _key_tofname(cls, *key):
        subr, old_datum, new_datum = key
        key = (old_datum, new_datum, subr)
        if subr == "all":
            return join(cls._in_path, "NADCON5.%s.%s.in"%tuple(map(str.upper, key))[:2])
        else:
            return join(cls._in_path, "NADCON5.%s.%s.%s.in"%tuple(map(str.upper,key)))
    
    def __init_inputs__(cls):
        cls._input_matrix = []
        for fname in cls._in_files:
            if exists(join(cls._in_path, fname)):
                source,target,subr = InFile._parse_fname(fname)
                cls._input_matrix.append((source, target, subr))

        _zipped_matrix = [_ for _ in zip(*cls._input_matrix)]
        cls._sub_regions = list(set(_zipped_matrix[2]))
        cls._source_datums = list(set(_zipped_matrix[0]))
        cls._target_datums = list(set(_zipped_matrix[1]))
        cls._open_inputs = {}

    @property
    def subregions(self):
        return self._sub_regions

    @property
    def source_datums(self):
        return self._source_datums

    @property
    def target_datums(self):
        return self._target_datums


    def valid_dataset(self, sub_region=None, source=None, target=None):
        """ Returns a tuple of valid conversions all arguments optional to partial filtering """

        return tuple([(sub_region_, source_, target_,) for source_, target_, sub_region_ in self._input_matrix if ( sub_region == None or sub_region_ == sub_region) and (source==None or  source_ == source) and (target==None or target_ == target) ])

        





## \ingroup nc5data
## \brief \ref sworkedits importer
class WorkEditsFile(type):
    """
    """

    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        return super().__prepare__(name, bases, **kargs)

    
    def __new__(metacls, name, bases, namespace, **kargs):
        return super().__new__(metacls, name, bases, namespace)
    

    def __call__(cls, *a, **kw):
        return super().__call__(*a, **kw)
    
    
    def __init__(cls,name, bases, namespace, fpath, **kwargs):
        cls._source_name=basename(fpath)
        
        with open(fpath) as f:
            print ("opened ", fpath)
            cls.__init_read__(f)

        super().__init__(name, bases, namespace)

    def __init_read__(cls, f):
        """ 
        """
        
        in_data = []

        split_line = lambda x: tuple(map(str.strip, x.split("|")))
        is_data = lambda x: not(x[0] == "#") and len(split_line(x))==6

        
        for line in f:
            if is_data(line):
                old_datum, new_datum, region, pid, rej, comment = split_line(line)
                pt = DataPoint(pid, old_datum=old_datum, new_datum=new_datum, region=region, rej=rej, comment=comment)
                in_data.append(pt)


        cls._in_data = in_data
