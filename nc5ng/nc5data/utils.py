

def dmstodec(x):
    """ Utility Function to convert CDDMMSS.sssss
    to floating point decimal degrees
    
    where C is the Cardinal Direction (N/W/S/E) indicator for sign
    """

    c = 1.0 if x[0] in "NW" else -1.0
    d = float(x[1:3])
    m = float(x[3:5])
    s = float(x[5:])

    return c*(d+m/60.0 + s/3600.0)








def output_filename(output_type='v',
                    region='conus',
                    old_datum='ussd',
                    new_datum='nad27',
                    grid_spacing='900',
                    vdir='lon',
                    vclass='a',
                    vout='cd',
                    vunit='m',
                    surface=False, no_errors=True,*args, **kwargs):


    output_type = output_type.lower()
    if output_type not in ['v', 'c']:
        if output_type in 'vector':
            output_type = 'v'
        elif output_type in 'coverage':
            output_type = 'c'
        elif output_type in 'surface':
            output_type = 'v'
            surface = True
        else:
            raise ValueError("Output_type must be (v)ector, (c)overage, or (s)urface")

    prefix = ""
    if (output_type == 'v' and surface):
        prefix = "s"
    elif output_type == 'v':
        prefix = 'v'
    elif output_type == 'c':
        prefix = 'cv'
    
    if output_type == 'c' and surface:
        raise ValueError("No surface ready output type for coverage")

    
    vunit = vunit.lower()
    if vunit not in ['m','s']:
        if vunit in 'meters':
            vunit = 'm'
        elif vunit in 'arcseconds':
            vunit ='s'
        else:
            raise ValueError("Cannot Determine Intent of vunit = %s as (m)eters or arcsecond(s)"%vunit)
        
    vclass = vclass.lower()
    if vclass not in ['a','t','r','d']:
        if vclass in 'all':
            vclass = 'a'
        elif vclass in 'thinned':
            vclass = 't'
        elif vclass in 'dropped':
            vclass = 'd'
        elif vclass in 'rms':
            vclass = 'r'
        else:
            raise ValueError("Cannot Determine Intent of vclass = %s as (a)ll, (t)hinned, (d)ropped, or (r)ms"%vclass)
        
    vout = vout.lower()
    if vout not in ['gi','cd','dd']:
        if vout in 'gridinterp':
            vout = 'gi'
        elif vout in 'doubledifference':
            vout = 'dd'
        else:
            raise ValueError("Cannot determine intent of vout = %s as (g)rid(i)nterp or (d)ouble(d)ifference"%vout)
            
            
    vdir = vdir.lower()
    if vdir not in ['lon', 'lat', 'eht', 'hor']:
        if vdir in 'longitude':
            vdir = 'lon'
        if vdir in 'latitude':
            vdir = 'lat'
        if vdir in 'horizontal':
            if output_type == 'c':
                raise ValueError("No (hor)izontal coverage for output_type = (c)overage")
            vdir = 'hor'
        if vdir in 'height':
            vdir = 'eht'
        else:
            raise ValueError("Cannot determine intent of vdir = %s as (lon)gitude, (lat)itutde, (hor)izontal, or height (eht)"%vdir)

    if vunit == 's'  and vdir == 'eht':
        raise ValueError("No Height Difference for vdir of arcseconds")

    if not(no_errors):
        if output_type == 'c' and vdir == 'hor':
            raise ValueError("No Horizontal Coverage File")
        
        if output_type == 'c' and  vclass == 'r' and vdir == 'eht':
            raise ValueError("No Horizontal Difference for vout of rms")
        
        if ( (vout == 'dd') ^ (vclass == 'r') ) and output_type =='c':
            raise ValueError("vout=dd requires vclass=rms for coverage")
        
        if  vclass == 'r' and not vout == 'dd' and output_type == 'v':
            raise ValueError("vclass=rms requires vout=dd for vector")
        
        if output_type == 'c' and vout == 'gi':
            raise ValueError("No (g)rid(i)nterp vout for output_type = (c)overage")                
    

    if output_type == 'c':
        if  vclass in ['r','d','t']:
            ffile = "{prefix}{vclass}{vout}{vdir}.{old_datum}.{new_datum}.{region}.{grid_spacing}"
        else:
            ffile = "{prefix}{vclass}{vout}{vdir}.{old_datum}.{new_datum}.{region}"
    else:
        if surface or  vout in ['gi', 'dd'] or vclass in ['r','d','t']:
            ffile = "{prefix}{vunit}{vclass}{vout}{vdir}.{old_datum}.{new_datum}.{region}.{grid_spacing}"
        else:
            ffile = "{prefix}{vunit}{vclass}{vout}{vdir}.{old_datum}.{new_datum}.{region}"


    return ffile.format(prefix=prefix, **{'old_datum':old_datum,
                  'new_datum':new_datum,
                  'region':region,
                  'grid_spacing':grid_spacing,
                  'vunit':vunit,
                  'vclass':vclass,
                  'vout':vout,
                  'vdir':vdir})
    


