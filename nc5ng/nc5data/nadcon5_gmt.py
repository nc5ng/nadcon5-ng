from .nadcon5_output import VectorData, PointData
from .services import region_bounds
from numpy import array

_pointstore = PointData.PointDataPoint.point_store
_vectorstore = VectorData.VectorDataPoint.point_store

DEFAULT_PROJECTION = 'M10.0i'
DEFAULT_REGION = [240,190,30,80]
DEFAULT_SHORELINES = 1
DEFAULT_RESOLUTION='c'
DEFAULT_THRESH=None
DEFAULT_FRAME=True
DEFAULT_INSERT=None
DEFAULT_BORDER=None
DEFAULT_SCALE=None
DEFAULT_OFFSET=None
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
DEFAULT_SYMBOL = None
DEFAULT_PEN = None

ARG_MAP = {
    'basemap':{
        'projection':'J',
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



def mk_arg_prop(FILTER_LIST):
    def prop_get(self):
        _r = {}
        for k,v in self.items():
            if k not in FILTER_LIST or v is None:
                continue
            if k in GMTOptions.ALIAS:
                k = GMTOptions.ALIAS[k]
            if k in _r:
                _r[k] = [_r[k],v]
            else:
                _r[k] = v
        
        return _r

    return prop_get

class GMTOptions(dict):

    ALIAS={
        'frame':'B',
        'projection':'J',
        'region':'R',
        'border':'F',
        'insert':'D',
        'scale':'L',
        'dir_rose':'Td',
        'mag_rose':'Tm',
        'logo':'U',
        'area_thresh':'A',
        'lakes':'C',
        'resolution':'D',
        'land':'G',
        'rivers':'I',
        'borders':'N',
        'water':'S',
        'shorelines':'W',
        'linear_lines':'A',
        'cpt':'C',
        'offset':'D',
        'error':'E',
        'color':'G',
        'symbol':'S',
        'pen':'W',
    }

    BASEMAP_FILTER = ['frame', 'projection', 'region', 'border', 'insert', 'scale', 'dir_rose', 'mag_rose', 'logo']
    COAST_FILTER = ['area_thresh', 'frame', 'lakes','insert', 'resolution', 'land', 'rivers', 'projection', 'borders', 'region', 'water', 'shorelines', 'logo']
    PLOT_FILTER = ['projection', 'region', 'linear_lines', 'cpt', 'offset', 'error', 'color', 'symbol', 'pen', 'logo']
    FILTERS = {
        'basemap': BASEMAP_FILTER,
        'coast':COAST_FILTER,
        'plot':PLOT_FILTER,
    }
    
    
    BASEMAP_FILTER_OUT = ['B', 'J', 'R', 'F', 'D', 'L', 'Td', 'Tm', 'U']
    COAST_FILTER_OUT = ['A','B','C','D','G','I','J','N','R','S','W', 'U']
    PLOT_FILTER_OUT = ['J','R','A','B','C','D','E','G','S','W','U']
    OUT_FILTERS = {
        'basemap':BASEMAP_FILTER_OUT,
        'coast' :COAST_FILTER_OUT,
        'plot' : PLOT_FILTER_OUT,
    }
    
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
                 symbol = DEFAULT_SYMBOL,
                 pen = DEFAULT_PEN,
                 basemap = None,
                 coast = None,
                 plot = None,
                 **kwargs):
        super().__init__(**locals())

    basemap = property(mk_arg_prop(BASEMAP_FILTER))
    coast = property(mk_arg_prop(COAST_FILTER))
    plot = property(mk_arg_prop(PLOT_FILTER))

    def __call__(self, *args, **kwargs):
        a = GMTOptions()
        a.update(**self)
        a.update(**kwargs)
        return a

PLOT_OPTS = {
    
    'default': GMTOptions(**{
        'projection':"M10.0i",
        'frame':True,
        'resolution':'fine',
        'water':"lightblue",
        'borders':["1", "2"],
        'area_thresh':1200,
    }),
    
    'vector':GMTOptions(**{
        'style':"V0.0001i/0.02i/0.02i"
    }),
    'point':GMTOptions(**{
        'style':"P0.01i"
    }),
    
    'red':GMTOptions(**{
        'color':'red'
    }),
    'black':GMTOptions(**{
        'color':'black'
    }),
    
    'blue':GMTOptions(**{
        'color':'blue'
    }),
    
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

    def __init__(self, base_plot_options=PLOT_OPTS['default']):
        import gmt
        self._figure = gmt.Figure()
        self.gmt_meta = base_plot_options

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
        elif vector[0] == 'v' and vector in conversion.output_data:
            vpoints = [conversion.output_data[vector],]
        else:
            vpoints = []
            for c in vector:
                vpoints.append(conversion.output_data[c])
        

        plotter.__base__(conversion, **kwargs)
        plotter.__coast__(conversion, **kwargs)
        plotter.__plot__(conversion, *cpoints, symbol="p4p",**kwargs)
        plotter.__plot__(conversion, *vpoints, symbol="v", **kwargs)
        plotter.show()
        return plotter


    def __base__(self, conversion, **kwargs):
        # Apply conversion options onto base options with any explicit keywords
        opts = self.gmt_meta(**conversion.gmt_meta)(**kwargs).basemap

        # passthrough shorthand we assume people know what they are doing
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in GMTOptions.BASEMAP_FILTER_OUT}
        opts.update(_filter_base_kwargs)
        
        print (_filter_base_kwargs, opts, conversion.gmt_meta)
                 
        #execute the command
        self.figure.basemap(**opts)

    def __coast__(self, conversion, **kwargs):
        # Apply conversion options onto base options with any explicit keywords
        opts = self.gmt_meta(**conversion.gmt_meta)(**kwargs).coast

        # passthrough shorthand we assume people know what they are doing
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in GMTOptions.COAST_FILTER_OUT}
        opts.update(_filter_base_kwargs)
        
        print (_filter_base_kwargs, opts, conversion.gmt_meta)
                 
        #execute the command
        self.figure.coast(**opts)
        

    def __plot__(self, conversion, *points,**kwargs):
                # Apply conversion options onto base options with any explicit keywords
        
        opts = self.gmt_meta(**conversion.gmt_meta)(**kwargs).plot

        # passthrough shorthand we assume people know what they are doing
        _filter_base_kwargs =  { x:y for x,y in kwargs.items() if x in GMTOptions.PLOT_FILTER_OUT}
        opts.update(_filter_base_kwargs)
        
        print (_filter_base_kwargs, opts, conversion.gmt_meta)
                 
        #execute the command
        for point_set in points:
            self.figure.plot(data = point_set.plot_data, **opts)

            
            
            
            
            
        

    
        
    

    
        
