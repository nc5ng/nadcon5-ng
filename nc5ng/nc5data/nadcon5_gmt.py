from .nadcon5_output import VectorData, PointData
from .services import region_bounds

_pointstore = PointData.PointDataPoint.point_store
_vectorstore = VectorData.VectorDataPoint.point_store

DEFAULT_PROJECTION = 'M10.0i'
DEFAULT_REGION = [240,190,30,80]
DEFAULT_RESOLUTION='f'
DEFAULT_THRESH=None
DEFAULT_FRAME=True
DEFAULT_INSERT=None
DEFAULT_BORDER=None
DEFAULT_SCALE=None
DEFAULT_DIR_ROSE=None
DEFAULT_MAG_ROSE=None
DEFAULT_LOGO=False
DEFAULT_LAKES=None
DEFAULT_LAND=None
DEFAULT_RIVERS = None
DEFAULT_BORDERS = None
DEFAULT_WATER = None
DEFAULT_LINEAR = False
DEFAULT_CPT = None
DEFAULT_ERRORS = None
DEFAULT_COLOR = None
DEFAULT_STYLE = None

ARG_MAP = {
    'basemap':{
        'projection':'J'.
        'region':'R',
        'frame':'B',
        'insert':'D',
        'border':'F',
        'scale':'L',
        'dir_rose':'Td',
        'mag_rose':'Tm',
        'logo':'U',
    },
    'coast':{
        'area_thresh':'A',
        'lakes':'C',
        'resolution':'D',
        'land':'G',
        'rivers':'I',
        'borders':'N',
        'water':'S',
        'shorelines':'W',
    },
    'plot':{
        'cpt':'C',
        'offset':'D',
        'errors':'B',
        'color':'G',
        'style':'S',
        'pen':'W',
    },
}


class GMTOptions(dict):

    def __init__(self,
                 projection = DEFAULT_PROJECTION,
                 region = DEFAULT_REGION,
                 frame=DEFAULT_FRAME,
                 insert=DEFAULT_INSERT,
                 border=DEFAULT_BORDER,
                 scale = DEFAULT_SCALE,
                 dir_rose = DEFAULT_DIR_ROSE,
                 mag_rose = DEFAULT_MAG_ROSE,
                 logo = DEFAULT_LOGO,
                 area_thresh = DEFAULT_THRESH,
                 lakes = DEFAULT_LAKES,
                 resolution=DEFAULT_RESOLUTION,
                 land = DEFAULT_LAND,
                 rivers = DEFAULT_RIVERS,
                 borders = DEFAULT_BORDERS,
                 water = DEFAULT_WATER,
                 shorelines = DEFAULT_SHORELINES,
                 linear_lines = DEFAULT_LINEAR,
                 cpt = DEFAULT_CPT,
                 offset = DEFAULT_OFFSET,
                 errors = DEFAULT_ERRORS,
                 color = DEFAULT_COLOR,
                 style = DEFAULT_STYLE,
                 pen = DEFAULT_PEN,
                 basemap = None,
                 coast = None
                 plot = None,
                 **kwargs):
        super().__init__(**locals())
    
        self.__init_basemap__()
        self.__init_coast__()
        self.__init_plot__()


    def __init_basemap__(self):
        pass

    def __init_coast__(self):
        pass

    def __init_plot__(self):
        pass
        
                 
            

    @property
    def basemap(self):
        

    @property
    def coast(self):
        return self.get('coast',None)

    @property
    def plot(self):
        return self.get('plot',None)


    

    
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
    
    

def _mk_filter_plot_pars(conversion, names, *aliases):
    def _filter(args):
        _COAST_ARGS = ['A','C', 'D', 'G','I', 'N', 'S', 'W']
        _COAST_ARGS_ALT = ['area_thresh', 'lakes','resolution', 'land', 'rivers', 'borders',  'water', 'shorelines']
        _COAST_DICT = dict(zip(_COAST_ARGS_ALT, _COAST_ARGS))
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in _COAST_ARGS}
        for _arg in conversion.gmt_meta:
            if _arg in _COAST_DICT and _COAST_DICT[_arg] not in _filter_base_kwargs:
                _filter_base_kwargs[ _COAST_DICT[_arg] ] = conversion.gmt_meta[_arg]




        
        


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
        plotter.__plot_coverage__(conversion, *cpoints, **kwargs)
        plotter.__plot_vector__(conversion, *vpoints, **kwargs)


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

        frame = frame or conversion.gmt_frame # differentiate from None
                   
        self.figure.basemap( region=region, projection=projection, frame=frame, **_filter_base_kwargs)
    def __plot_coast__(self, conversion,  **kwargs):

        _COAST_ARGS = ['A','C', 'D', 'G','I', 'N', 'S', 'W']
        _COAST_ARGS_ALT = ['area_thresh', 'lakes','resolution', 'land', 'rivers', 'borders',  'water', 'shorelines']
        _COAST_DICT = dict(zip(_COAST_ARGS_ALT, _COAST_ARGS))
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in _COAST_ARGS}
        for _arg in conversion.gmt_meta:
            if _arg in _COAST_DICT and _COAST_DICT[_arg] not in _filter_base_kwargs:
                _filter_base_kwargs[ _COAST_DICT[_arg] ] = conversion.gmt_meta[_arg]


        print (_filter_base_kwargs)
        self.figure.coast(**_filter_base_kwargs)
        
                
    def __plot_coverage__(self, conversion, *cpoints, **kwargs):
        def _filter_plot_pars(**pars):
            

        
        for cpoint in cpoints:
            if hasattr(cpoints,'gmt_meta')
        
        pass

    def __plot_vector__(self, conversion, *args, **kwargs):
        pass


            
            
            
            
            
        

    
        
    

    
        
