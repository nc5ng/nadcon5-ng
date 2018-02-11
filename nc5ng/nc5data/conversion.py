from .nadcon5_input import RegionData, ControlData, InData, ExclusionData





class Conversion(object):

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

        
        def __init__(self, region, old_datum, new_datum):
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

            


    @property
    def input_data(self):
        return self._input_data
            
    def __init__(self, region, old_datum, new_datum):
        self._input_data = self.ConversionInput(region, old_datum, new_datum)
        
