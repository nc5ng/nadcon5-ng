""" \file nadcon5_files_ng.py
"""
from os.path import basename, exists, join, isdir, isfile, isabs
from os import listdir
import pkg_resources

from .utils import dmstodec, output_filename

import fortranformat as ff
import logging


NADCON5_FILE_RESOURCES = {
    'in_dir': pkg_resources.resource_filename('nc5ng.nc5data', 'data/InFiles'),
    'grid_file': pkg_resources.resource_filename('nc5ng.nc5data', 'data/Data/grid.parameters'),
    'control_dir': pkg_resources.resource_filename('nc5ng.nc5data', 'data/Control'),
    'workedits_file': pkg_resources.resource_filename('nc5ng.nc5data', 'data/Work/workedits'),
}


class BaseFileParser(object):
    def __init__(self, parser=None, fdir=None, ffile=None):
        self.parser = parser
        self.fdir = fdir
        self.ffile = ffile
        
        

    @property
    def parser(self):
        return self._parser
    @parser.setter
    def parser(self, value):
        self._parser = value

    @property
    def fdir(self):
        return getattr(self, '_fdir', None)

    @fdir.setter
    def fdir(self, value):
        self._fdir = value
        if (value is not None) and not(isabs(value)):
            logging.warning("%s is not an absolute path"%str(value))

    @property
    def ffile(self):
        return self._ffile

    @ffile.setter
    def ffile(self, value):
        self._ffile = value
        

    def __call__(self, it):
        if self.parser and hasattr(self.parser, '__call__'):
            return [self.parser(_line) for _line in it]
        elif self.parser and hasattr(self.parser, 'read'):
            return [self.parser.read(_line) for _line in it]
        else:
            return None

    def __fromfile__(self, f):
        return {'meta': {}, 'data':[ _ for _ in self(f) if _ is not None] }

    def fromfile(self, ffile=None, process=None, fdir=None):
        if ffile is None and self.ffile is not None:
            ffile = self.ffile

        if fdir is None and self.fdir is not None:
            fdir = self.fdir
        
        if (fdir is not None) and (ffile is not None) and  not(isabs(ffile)):
            ffile = join(fdir, ffile)

        with open(ffile,'r') as f:
            res = self.__fromfile__(f)
            res['meta']['source'] = ffile
            return res
        
        return None

class FortranFormatFileParser(BaseFileParser):
    def __init__(self, fformat = None, ffilter = None):
        self._parser = None
        self.fformat = fformat
        self.ffilter = ffilter
        
    @property
    def fformat(self):
        return self._fformat
    
    @fformat.setter
    def fformat(self, value):
        self._fformat = value
        if self._fformat:
            self._parser = ff.FortranRecordReader(self._fformat)

    @property
    def ffilter(self):
        return self._ffilter

    @ffilter.setter
    def ffilter(self, value):
        if value is None:
            self._ffilter = lambda x: x
        else:
            self._ffilter = value            
    
    def __call__(self, it):
        if self._parser:
            return [ self._ffilter( self._parser.read(_line) ) for _line in it ]
    
        

class IndexedFortranFormatFileParser(FortranFormatFileParser):
    def __init__(self, *args, **kwargs):
        super().__init__()
        self._running_index=0
        self._index=0
        self.indexed_format = {}
        
        for entry in args:
            try:
                fformat,ffilter = entry
            except TypeException:
                fformat = args.pop(0)
                if args: ffilter = args.pop(0)
                else: ffilter=None
            self._register_format(fformat, ffilter)
        for index, entry in kwargs.items():
            try:
                fformat, ffilter = entry
            except TypeException:
                fformat = entry
                ffilter = None
            self._register_format(fformat, ffilter, index)
        self.index=0

    def _register_format(self, fformat, ffilter=None, index = None, overwrite=False):
        if index is None:
            index = self._running_index
            self.fformat = fformat
            self._running_index = self._running_index + 1

        if (index not in self.indexed_format or overwrite):
            self.indexed_format[index]=(fformat,ffilter)
            if (index == self.index):
                self.index = index # reload filters
            return index
        else:
            return None

    @property
    def index(self):
        return self._index

    @index.setter
    def index(self, index=None):
        if index in self.indexed_format:
            fformat, ffilter = self.indexed_format[index]
            self.fformat = fformat
            self.ffilter = ffilter
            self._index = index
        else:
            pass
        
    def __getitem__(self,index):
        if index in self.indexed_format:
            return FortranFormatFileParser(*self.indexed_format[index])
        else:
            return None

    def __contains__(self, value):
        return index in self.indexed_format

    def __call__(self, it, index=None):        
        if index is None or index == self.index:
            return super().__call__(it)
        elif index in self:
            return p(it)
        else:
            return None
                        
    



class InFileParser(IndexedFortranFormatFileParser):
    IN_FILE_HEADER_FORMAT = '27x,a15,26x,a15'
    IN_FILE_DATA_FORMAT = 'a6,1x,a2,5x,a13,1x,a14,1x,a9,3x,a13,1x,a14,1x,a9'

    @staticmethod
    def _line_filter(line):
        pid, subr, oldlat, oldlon, oldht, newlat, newlon, newht = line
        oldlat = None if oldlat.strip() == "N/A" else dmstodec(oldlat)
        oldlon = None if oldlon.strip() == "N/A" else dmstodec(oldlon)
        oldht = None if oldht.strip() == "N/A" else float(oldht)
        newlat = None if newlat.strip() == "N/A" else dmstodec(newlat)
        newlon = None if newlon.strip() == "N/A" else dmstodec(newlon)
        newht = None if newht.strip()  == "N/A" else float(newht)

        return [pid,subr,oldlat,oldlon,oldht,newlat,newlon,newht]

    @staticmethod
    def _header_filter(line):
        return [ _.strip() for _ in line]
    
    def __init__(self, fdir=NADCON5_FILE_RESOURCES['in_dir'], ffile = None):
        self.fdir = fdir
        self.ffile = ffile
        super().__init__(data=(self.IN_FILE_DATA_FORMAT, InFileParser._line_filter), header=(self.IN_FILE_HEADER_FORMAT, InFileParser._header_filter))
        
    def __fromfile__(self, f):        
        header = self['header']([next(f)])[0]
        meta={'DATUM1':header[0], 'DATUM2':header[1], 'header':header}
        return {'meta':meta, 'data':self['data'](f)}
    
    def fromfile(self, ffile=None, old_datum=None, new_datum=None, subregion=None):
        if ffile is not None:
            res = super().fromfile(ffile)
        elif old_datum and new_datum:
            old_datum = old_datum.lower()
            new_datum = new_datum.lower()
            subregion = subregion.lower() if subregion is not None else None
            if subregion:
                res = super().fromfile( "NADCON5.%s.%s.%s.in"%(old_datum, new_datum, subregion))
            else:
                res = super().fromfile( "NADCON5.%s.%s.in"%(old_datum, new_datum ))            
        else:
            raise TypeError("fromfile Incorrect number of arguments")

        res['meta'].update({'subregion':subregion, 'old_datum':old_datum, 'new_datum':new_datum})
        return res


    

        
class ControlFileParser(BaseFileParser):
    @staticmethod
    def _parse_line(line):
        if '.in' in line:
            return line.strip()
        else:
            return None

    def __init__(self, control_dir = NADCON5_FILE_RESOURCES['control_dir']):
        super().__init__(ControlFileParser._parse_line, fdir = control_dir)

    def __fromfile__(self, f):
        header_lines = ['HEADER','REGION', 'DATUM1', 'DATUM2', 'REJMET', 'NFILES']
        
        data = []
        meta = {}

        for l in f:
            if '.in' not in l:
                
                h,v = (l[:6], l[7:].strip(),)
                if h in header_lines:
                    meta[h.lower()] = v.lower()
                else:
                    logging.warning('Encountered Control File Header Line that is not Known')
                
            else:
                data.append(ControlFileParser._parse_line(l))

        return {'meta':meta, 'data':data}
                
    def fromfile(self, *args):

        argc = len(args)
        if argc == 1:
            res = super().fromfile(args.pop())
        elif argc == 3:
            region, old_datum, new_datum = args
            res = super().fromfile("control.%s.%s.%s"%(old_datum.lower(), new_datum.lower(),region.lower() ))
        else:
            raise TypeError("fromfile Incorrect number of arguments")

        res['meta'].update({'region':region, 'old_datum':old_datum, 'new_datum':new_datum})
        return res



class GridParamFileParser(BaseFileParser):
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

    def gen_parse_line(self):
        _regions = self._VALID_REGIONS
        def parse_line(line):
            region, *data = line.split()
            
            if region.lower() in _regions:
                return [region,]+ [ _ for _ in map (lambda x: float(x.strip()), data)]
            else:
                return None

        return parse_line
        
    
    
    def __init__(self, grid_file = NADCON5_FILE_RESOURCES['grid_file'], *regions):
        if regions:
            self._VALID_REGIONS = self._VALID_REGIONS + regions
        super().__init__(self.gen_parse_line(), ffile=grid_file)
    
    def valid_region(self, region):
        return region in self._VALID_REGIONS

class WorkEditsFileParser(BaseFileParser):
    @staticmethod
    def _parse_line(line):
        """
        01- 10  : olddtm : lower case, left justified 
        11  : "|"    : vertcal spacer just for ease of reading
        12- 21  : newdtm : lower case, left justified 
        22  : "|"    : vertcal spacer just for ease of reading
        23- 32  : region : lower case, left justified (conus, alaska, hawaii, prvi, guamcnmi, as)
        33  : "|"    : vertcal spacer just for ease of reading
        34- 39  : PID    : upper case, left justified 
        40  : "|"    : vertcal spacer just for ease of reading
        41- 43  : rejects: Three digits (0's or 1's only) to reject lat, lon, eht, in that order.  '1' = reject, '0' = keep
        44  : "|"    : vertcal spacer just for ease of reading
        45-200  : reason : Upper/lower case, giving first your name then reason for the line to exist
        """
        
        if (len(line) < 44) or not(line[10] == line[21] == line[32] == line[39] == line[43] == '|'):
            return None

        
        
        olddtm = line[:10].strip()
        newdtm = line[11:21].strip()
        region = line[22:32].strip()
        pid = line [33:39].strip()
        rejlat = line[40] == '1'
        rejlon = line[41] == '1'
        rejeht = line[42] == '1'
        reason = line[44:]

        return [olddtm, newdtm, region, pid, rejlat, rejlon, rejeht, reason]

    def __init__(self, ffile = NADCON5_FILE_RESOURCES['workedits_file']):
        super().__init__(self.__class__._parse_line, ffile=ffile)


class CoverageFileParser(FortranFormatFileParser):
    COVERAGE_FILE_FORMAT = "f16.10,1x,f15.10,1x,f6.2,1x,a6"
    def __init__(self, **kwargs):
        super().__init__(fformat=self.COVERAGE_FILE_FORMAT, **kwargs)


    def fromfile(self,
                 region='conus',
                 old_datum='ussd',
                 new_datum='nad27',
                 grid_spacing='900',
                 vdir='lon',
                 vclass='a',
                 vout='cd',
                 **kwargs):


        if 'ffile' in kwargs:
            return super().fromfile(**kwargs)


        meta_dict = {'old_datum':old_datum,
                     'new_datum':new_datum,
                     'region':region,
                     'grid_spacing':grid_spacing,
                     'vclass':vclass,
                     'vout':vout,
                     'vdir':vdir}

        ffile = output_filename(output_type = 'c', **meta_dict)

        meta_dict['basename'] = ffile.split('.')[0]
        
        res = super().fromfile(ffile=ffile, **kwargs)
        
        res['meta'].update(meta_dict)

        return res

        

class VectorFileParser(FortranFormatFileParser):
    VECTOR_FILE_FORMAT = "f16.10,1x,f15.10,1x,f6.2,1x,f12.2,1x,f9.5,1x,f9.3,1x,a6"
    
    def __init__(self, **kwargs):
        super().__init__(fformat=self.VECTOR_FILE_FORMAT, **kwargs)

    def fromfile(self,
                 region='conus',
                 old_datum='ussd',
                 new_datum='nad27',
                 grid_spacing='900',
                 vdir='lon',
                 vclass='a',
                 vout='cd',
                 vunit='m',
                 surface=False,
                 **kwargs):

        if 'ffile' in kwargs:
            return super().fromfile(**kwargs)
            
    
        meta_dict = {'old_datum':old_datum,
                     'new_datum':new_datum,
                     'region':region,
                     'grid_spacing':grid_spacing,
                     'vunit':vunit,
                     'vclass':vclass,
                     'vout':vout,
                     'vdir':vdir}


        ffile = output_filename(output_type = 'v', surface=surface, **meta_dict)

        meta_dict['basename'] = ffile.split('.')[0]

        res = super().fromfile(ffile=ffile, **kwargs)

        res['meta'].update(meta_dict)
        return res

        

class FileBackedMetaBase(type):
    @classmethod
    def __prepare__(metacls, name, bases, **kargs):
        """ Prepare the new class, here for completeness
        """
        logging.debug("Preparing Class %s"%name)
        return super().__prepare__(name, bases, **kargs)

    def __new__(metacls, name, bases, namespace, **kargs):
        logging.debug("Creating Class %s"%name)
        return super().__new__(metacls, name, bases, namespace)

    @property
    def parser(self):
        return self._parser
    

    @parser.setter
    def parser(self, parser):
        logging.debug("Setting parser instance %s"%parser)
        if not(issubclass(parser.__class__,BaseFileParser)):
            raise TypeError("parser %s is not a valid BaseFileParser"%str(parser))

        self._parser = parser

    @property
    def instances(self):
        return self._instances

    
    def __init__(cls, name, bases, namespace, Parser=BaseFileParser, **kwargs):
        """ Initialize a new FileBacked Class

        This is a slot method for class creation, __init__ is called when class is defined (load time)

        \param cls - reference to new type, similiar to @classmethod
        \param name - new class name
        \param bases - base classes
        \param namespace - new class attributes
        \param Parser - BaseFileParser underlying this type
        \param **kwargs - keywords passed to Parser initialization
        
        """        
        logging.debug("Creating File Backed Class %s"%name)

        if Parser:
            logging.debug("Creating Parser Instance of %s"%Parser)
            cls.parser = Parser(**kwargs)
            
        cls._Parser = Parser
        cls._instances = dict()
        super().__init__(name, bases, namespace)
            

class SingletonFileBackedMeta(FileBackedMetaBase):
    
    def __init__(cls, name, bases, namespace, Parser=BaseFileParser, **kwargs):
        """
        """        
        cls._instance = None
        super().__init__(name, bases, namespace, Parser, **kwargs)

    def __call__(cls, *args, overwrite=False, **kwargs):
        if cls._instance is None or overwrite:
            logging.debug("Creating new Singleton File Backed Meta Instance %s"%cls.__name__ )
            inst = super().__call__(*args, **kwargs)
            cls._instance = inst
            return inst
        else:
            return cls._instance
        

