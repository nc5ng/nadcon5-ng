from .nadcon5_output import VectorData, PointData
from .services import region_bounds

_pointstore = PointData.PointDataPoint.point_store
_vectorstore = VectorData.VectorDataPoint.point_store



PLOT_OPTS = {
    'default': {
        'projection':"M10.0i",
        'frame':True,
        'resolution':'fine',
        'water':"lightblue",
        'borders':["1", "2"],
        'area_thresh':1200,
    },

    'vector':{
        'style':"V0.0001i/0.02i/0.02i"
    },
    'point':{
        'style':"P0.01i"
    },

    'red':{
        'color':'red'
    },
    'black':{
        'color':'black'
    },

    'blue':{
        'color':'blue'
    },

}
    
    




        
        


class GMTPlotter(object):

    @property
    def figure(self):
        return getattr(self, '_figure', None)

    def __init__(self, conversion, base_plot_optons=PLOT_OPTS['default']):
        import gmt
        self._conversion = conversion
        self._figure = gmt.Figure()

    def plot(self, *args, **kwargs):
        self.figure.plot(*args, **kwargs)

    def show(self, *args, **kwargs):
        self.figure.show(*args, **kwargs)

    @staticmethod
    def plot_conversion(conversion, coverage='all', vector='all', plotter=None, **kwargs):
        if plotter is None:
            plotter = GMTPlotter()
            
        if (coverage == 'all'):
            cpoints = [_pointstore,]
        elif not(coverage):
            cpoints = []
        elif coverage[0] == 'c' and coverage in conversion.output_data:
            cpoints = [conversion.output_data[coverage],]
        else:
            cpoints = []
            for c in coverage:
                cpoints.append(conversion.output_data[c])


        if (vector == 'all'):
            vpoints = [_vectorstore,]
        elif not(vector):
            vpoints = []
        elif vector[0] == 'c' and vector in conversion.output_data:
            vpoints = [conversion.output_data[vector],]
        else:
            vpoints = []
            for c in vector:
                vpoints.append(conversion.output_data[c])

        plotter.__plot_base__(conversion, **kwargs)
        plotter.__plot_coast__(conversion, **kwargs)
        plotter.__plot_coverage__(*cpoints, **kwargs)
        plotter.__plot_vector__(*vpoints, **kwargs)


    def __plot_base__(self, conversion, frame=True, projection=None, region=None, **kwargs):
        
        _BASEMAP_ARGS = ['D','F','L','Td', 'Tm', 'U']
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in _BASEMAP_ARGS}
        for _arg in conversion.gmt_meta:
            if _arg in _BASEMAP_ARGS and _arg not in _filter_base_kwargs:
                _filter_base_kwargs[_arg] = conversion.gmt_meta[_arg]

        
        if region is None and conversion.gmt_region is None:
            region = region_bounds(conversion.region)
        elif region is None and conversion.gmt_region is not None:
            region = conversion.gmt_region
        elif region is None:
            region = DEFAULT_REGION


        if projection is None and conversion.gmt_projection is None:
            projection = DEFAULT_PROJECTION
        elif projection is None:
            projection = conversion.gmt_projection

        frame = frame and conversion.gmt_frame is False # differentiate from None
                   
        self.figure.basemap( region=region, projection=projection, frame=frame, **_filter_base_kwargs)
    def __plot_coast__(self ):

        _COAST_ARGS = ['A','C', 'D', 'G','I', 'N', 'S', 'W']
        _COAST_ARG_ALT = ['area_thresh', 'lakes','resolution', 'land', 'rivers', 'borders',  'water', 'shorelines']
        _COAST_DICT = dict(zip(_COAST_ARGS_ALT, _COAST_ARGS))
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in _COAST_ARGS}
        for _arg in conversion.gmt_meta:
            if _arg in _COAST_DICT and _COAST_DICT[_arg] not in _filter_base_kwargs:
                _filter_base_kwargs[ _COAST_DICT[_arg] ] = conversion.gmt_meta[_arg]


        self.figure.coast(**_filter_base_kwargs)
        
                
    def __plot_coverage__(self, *args, **kwargs):
        pass

    def __plot_vector__(self):
        pass


            
            
            
            
            
        

    
        
    

    
        
