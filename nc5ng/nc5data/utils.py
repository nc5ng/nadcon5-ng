

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


