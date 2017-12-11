## \ingroup nc5data
## \brief a single data point from \ref sinfiles 
class DataPoint(object):
        
    
    def __init__(self, pid=None, data=((None, None, None),(None, None, None)), **meta):
        self._pid = pid
        self._meta = meta
        (self._oldlat,self._oldlon,self._oldht),(self._newlat,self._newlon,self._newht) = data
    
    @property
    def pid(self):
        return self._pid
    
    @property
    def oldlat(self):
        return self._oldlat
    
    @property
    def oldlon(self):
        return self._oldlon
    
    @property
    def oldht(self):
        return self._oldht
    
    @property
    def newlat(self):
        return self._newlat
    
    @property
    def newlon(self):
        return self._newlon
    
    @property
    def newht(self):
        return self._newht
    
    @property
    def dlat(self):
        if (self._oldlat and self._newlat):
            return self._newlat - self._oldlat
        else:
            return None
        
    @property
    def dlon(self):
        if (self._oldlon and self._newlon):
            return self._newlon - self._oldlon
        else:
            return  None

    @property
    def dht(self):
        if (self._oldht and self._newht):
            return self._newht - self._oldht
        else:
            return  None
        
    def __getattr__(self, attr):
        return self._meta.get(attr)


    

class DataSet(object):
    def __init__(self, *points, **meta):
        self._points = {}
        self._meta = meta

        print(len(points))
        for point in  points:
            if point.pid in self._points:
                print ("dup @ ",point.pid)
            self._points[point.pid]=point
            

    
    @property
    def points(self):
        return self._points

    @property
    def pids(self):
        return self.points.keys()

    def __len__(self):
        return len(self.points)

    def __contains__(self, pid):
        return pid in self.pids

    
    def __getitem__(self, pid):
        return self.points[pid]


    def __getattr__(self, attr):
        if attr in self._meta:
            return self._meta[attr]
        else:
            return None

    def __add__(self, dataset):
        _meta = self._meta.copy()
        _meta.update(dataset._meta)

        return DataSet(*self.points.values(), *dataset.points.values(), **_meta)

    def __iadd__(self, other):
        self._meta.update(other._meta)
        self._points.update(other.points)
        return self
        






from .nadcon5_files import InFile, WorkEditsFile
import pkg_resources

IN_PATH = pkg_resources.resource_filename('nc5ng.nc5data', 'data/InFiles')
EDITS_FILE = pkg_resources.resource_filename('nc5ng.nc5data', 'data/Work/workedits')
        

class FileDataSet(DataSet, metaclass=InFile, fpath=IN_PATH):    
    def __init__(self, subregion, old_datum, new_datum, *extra_pts):
        key = (subregion, old_datum, new_datum)
        super().__init__(*FileDataSet._open_inputs[key], *extra_pts, subregion=subregion, old_datum=old_datum, new_datum=new_datum)

        


class ExclusionSet(DataSet, metaclass=WorkEditsFile, fpath=EDITS_FILE):
    def __init__(self, region=None, old_datum=None, new_datum=None, *extra_pts):    
        super().__init__(*(pt for pt in self._in_data
                           if not( (region and pt.region != region)
                           or (old_datum and pt.old_datum != old_datum)
                           or (new_datum and pt.new_datum != new_datum))),
                         *extra_pts,
                         region = region,
                         old_datum = old_datum,
                         new_datum = new_datum)
        
