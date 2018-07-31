from .nadcon5_input import RegionData, ControlData, InData, ExclusionData
from .nadcon5_output import VectorData, PointData
from .nadcon5_types import MetaMixin, GMTMetaMixin
from .services import region_bounds
import logging
import itertools


class Conversion(MetaMixin, GMTMetaMixin):
    """ A Conversion agregates all parts of a NADCON5 Datum Conversion and serves
    as the primary user interface into the dataset

    A Conversion is created based on region, source,  target datum, and gridspacing
    the same parameters that go into the data build pipeline

    Conversions maintain a large set of data in memory (when loaded) and have accessors for data

    Creating a conversion is simple

        c = Conversion('conus', 'ussd', 'nad27')

    The output data of a conversion can be accessed directly by output prefix

       v1 = c.output_data['vmacdlat']
       v2 = c.output_data['vmacdlon']

    Output data is indexed by PID, to extract all PID's with lat and lon conversions in this data set

       shared_pids = [ i for i in v1 if i in v2 ] 

    
    All point data for a single point can be examined directly, including its source data

       point = v[shared_pids[0]]
       point.source 


    """

    class ConversionInput(object):

        @property
        def region_data(self):
            return self._region_data
        
        @property
        def grid_bound(self):
            return self._grid_bound

        @property
        def control_data(self):
            return self._control_data

        @property
        def input_data_set(self):
            return self._input_data_set

        @property
        def input_pid_set(self):
            return self._input_pid_set

        @property
        def input_point_set(self):
            return self._input_point_set

        @property
        def exclusion_data(self):
            return self._exclusion_data

        @property
        def exclusion_pid_set(self):
            return self._exclusion_pid_set

        @property
        def exclusion_point_set(self):
            return self._exclusion_point_set

        @property
        def pruned_point_set(self):
            return self._pruned_points

        
        def __init__(self, region, old_datum, new_datum, **kwargs):
            self._region_data = RegionData()
            self._grid_bound = self._region_data[region]

            self._control_data = ControlData(region, old_datum, new_datum)

            self._input_pid_set = set()
            self._input_data_set = set()
            self._input_point_set = set()
            for in_point in self._control_data:
                i = InData(in_point.in_file)
                [self._input_pid_set.add(_) for _ in i.indices]
                [self._input_point_set.add(_) for _ in i.points]
                self._input_data_set.add(i)

            self._exclusion_data = ExclusionData()
            self._exclusion_pid_set = set()
            self._exclusion_point_set = set()
            for exclusion_point in self._exclusion_data:
                if (exclusion_point.olddtm == old_datum) and (exclusion_point.newdtm == new_datum) and (exclusion_point.region == region):
                    self._exclusion_pid_set.add(exclusion_point.pid)
                    self._exclusion_point_set.add(exclusion_point)

            self._pruned_points = {_p for _p in self._input_point_set if not _p.pid in self._exclusion_pid_set}

    class ConversionOutput(object):
        def __init__(self, region, old_datum, new_datum, grid_spacing, load_all = False, **kwargs):
            self._output_data = {}
            vdir = ['lat', 'lon', 'eht','hor']
            vclass = ['a','t','d','r']
            vout = ['cd','dd','gi']
            vunit = ['m', 's']
            surface = [True, False]
            

            c_pars = itertools.product(vdir, vclass,vout)
            v_pars = itertools.product(vdir, vclass, vout,vunit,surface)

            local_kwargs = {}
            if 'out_fdir' in kwargs:
                local_kwargs['fdir'] = kwargs['out_fdir']

            print ("Loading Coverage Files")
            for c in c_pars:
                print ("Trying to Load Coverage File args - %s"%str(c))
                try:
                    cov = PointData(region,old_datum, new_datum, grid_spacing, *c, **local_kwargs)
                    print ("Finished Loading Coverage File - %s"%cov.shorthand)
                except (ValueError, FileNotFoundError) as e:
                    print ("Could not find Coverage File")
                    print (e)
                    continue
                self._output_data[cov.shorthand] = cov

            print ("Loading Vector Files")
            for v in v_pars:
                print ("Trying to Load Vector File args - %s"%str(v))
                try:
                    vec = VectorData(region, old_datum, new_datum, grid_spacing, *v, **local_kwargs)
                    print ("Finished Loading Vector File - %s"%vec.shorthand)
                except (ValueError, FileNotFoundError) as e:
                    print ("Could not find Vector File")
                    print (e)
                    continue
                self._output_data[vec.shorthand] = vec

        
        def __contains__(self, item):
            return ( item in self.raw_data ) or ( item in self.pid_set )


        def __getitem__(self, key):
            if key in self.raw_data:
                return self.raw_data[key]
            elif key in self.pid_set:
                return { d_k:d_v[key] for d_k, d_v in self.raw_data.items() if key in d_v.indices }
            else:
                return None

        @property
        def raw_data(self):
            return self._output_data

        @property
        def pid_set(self):
            return self._pid_set

        
            
            

            


    @property
    def input_data(self):
        return self._input_data

    @property
    def output_data(self):
        return self._output_data
            
    def __init__(self, region, old_datum, new_datum, grid_spacing = '900',  **kwargs):
        self._input_data = self.ConversionInput(region, old_datum, new_datum, **kwargs)
        self._output_data = self.ConversionOutput(region, old_datum, new_datum, grid_spacing, **kwargs)
        self._meta={'region':region,
                    'old_datum':old_datum,
                    'new_datum':new_datum,
                    'grid_spacing':grid_spacing,
                    **kwargs}


        self._gmt_meta={
            'region':region_bounds(region)
        }

        
            
        if 'gmt' in kwargs:
            self._gmt_meta.update(kwargs['gmt'])
