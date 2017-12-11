from .dataset import FileDataSet, DataSet

from .nadcon5_files import ControlFile as MyMeta


import pkg_resources

CONTROL_DIR = pkg_resources.resource_filename('nc5ng.nc5data', 'data/Control')

class Conversion(metaclass=MyMeta, fpath=CONTROL_DIR):
    

    def __init__(self, region, old_datum, new_datum):
        key = (region, old_datum, new_datum,)
        self.conversion_record = Conversion._open_conversions[key]

        self.__init_datasets__()

    def __init_datasets__(self):

        self._dataset = DataSet()
        for _infile in self._infiles:
            self._dataset += FileDataSet.fromfile(_infile)
        
    @property
    def header(self):
        return self.conversion_record['HEADER']

    @property
    def region(self):
        return self.conversion_record['REGION'].lower()

    @property
    def source(self):
        return self.conversion_record['DATUM1'].lower()

    @property
    def target(self):
        return self.conversion_record['DATUM2'].lower()

    @property
    def rejmet(self):
        return int(self.conversion_record['REJMET'])

    @property
    def n_infiles(self):
        return int(self.conversion_record['NFILES'])
    
    
    @property
    def _infiles(self):
        return self.conversion_record['in_files']


    @property
    def dataset(self):
        return self._dataset

    
