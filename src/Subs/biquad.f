c> \ingroup core
c> \if MANPAGE     
c> \page biquad
c> \endif      
c> 
c> Subroutine to perform a 2-D quadratic ("biquadratic") interpolation
c> 
c> Performs a biquadratic interpolation at location 
c> `xla,xlo` off of grid `z`, whose
c> header information is the standard ".b" header
c> information
c> 
c> \param[in] z      Input Grid
c> \param[in] glamn  minimum latitude   (real*8 decimal degrees)
c> \param[in] glomn  minimum longitude  (real*8 decimal degrees)
c> \param[in] dla    latitude spacing   (real*8 decimal degrees)
c> \param[in] dlo    longitude spacing  (real*8 decimal degrees)
c> \param[in] nla    number of lat rows (integer*4)
c> \param[in] nlo    number of lon cols (integer*4)
c> \param[in] maxla  actual dimensioned size of "z" in rows
c> \param[in] maxlo  actual dimensioned size of "z" in cols
c> \param[in] xla    lat of pt for interpolation (real*8 dec. deg)
c> \param[in] xlo    lon of pt for interpolation (real*8 dec. deg)
c> \param[out] val    interpolated value (real*8)
c> 
c> ### Method:
c>   Fit a 3x3 window over the random point.  The closest
c>   2x2 points will surround the point.  But based on which
c>   quadrant of that 2x2 cell in which the point falls, the
c>   3x3 window could extend NW, NE, SW or SE from the 2x2 cell.
      subroutine biquad(z,glamn,glomn,dla,dlo,
     *nla,nlo,maxla,maxlo,xla,xlo,val)

c - Subroutine to perform a 2-D quadratic ("biquadratic")
c - interpolation at location "xla,xlo" off of grid "z", whose
c - header information is the standard ".b" header
c - information of
c -    glamn = minimum latitude   (real*8 decimal degrees)
c -    glomn = minimum longitude  (real*8 decimal degrees)
c -    dla   = latitude spacing   (real*8 decimal degrees)
c -    dlo   = longitude spacing  (real*8 decimal degrees)
c -    nla   = number of lat rows (integer*4)
c -    nlo   = number of lon cols (integer*4)
c -    maxla = actual dimensioned size of "z" in rows
c -    maxlo = actual dimensioned size of "z" in cols
c - Further input: 
c -    xla   = lat of pt for interpolation (real*8 dec. deg)
c -    xlo   = lon of pt for interpolation (real*8 dec. deg)
c - Output:
c -    val   = interpolated value (real*8)
c - 
c - Method:
c -   Fit a 3x3 window over the random point.  The closest
c -   2x2 points will surround the point.  But based on which
c -   quadrant of that 2x2 cell in which the point falls, the
c -   3x3 window could extend NW, NE, SW or SE from the 2x2 cell.

c - Data is assumed real*4
      implicit real*8 (a-h,o-z)
      real*4 z(maxla,maxlo)

c - Internal use
      real*4 x,y,fx0,fx1,fx2,qterp

c - Find which row should be LEAST when fitting
c - a 3x3 window around xla.
      difla = (xla - glamn)
      ratla = difla / (dla/2.d0)
      ila = int(ratla)+1
      if(mod(ila,2).ne.0)then
        jla = (ila+1)/2 - 1
      else
        jla = (ila  )/2
      endif
c - Fix any edge overlaps
      if(jla.lt.1)jla = 1
      if(jla.gt.nla-2)jla = nla-2

c - Find which column should be LEAST when fitting
c - a 3x3 window around xlo.
      diflo = (xlo - glomn)
      ratlo = diflo / (dlo/2.d0)
      ilo = int(ratlo)+1
      if(mod(ilo,2).ne.0)then
        jlo = (ilo+1)/2 - 1
      else
        jlo = (ilo  )/2
      endif
c - Fix any edge overlaps
      if(jlo.lt.1)jlo = 1
      if(jlo.gt.nlo-2)jlo = nlo-2

c - In the range of 0(westernmost) to
c - 2(easternmost) col, where is our
c - random lon value?  That is, x must
c - be real and fall between 0 and 2.

      x=(xlo-dlo*(jlo-1)-glomn)/dlo

      if(x.lt.0.0)then
        val = 1.d30
        write(6,100)x,val
c       stop
        return
      endif
  100 format(
     *'FATAL in biquad:  x<0 : ',f20.10,/,
     *' --> Returning with val = ',f40.1)

      if(x.gt.2.0)then
        val = 1.d30
        write(6,101)x,val
c       stop
        return
      endif
  101 format(
     *'FATAL in biquad:  x>2 : ',f20.10,/,
     *' --> Returning with val = ',f40.1)

c - In the range of 0(southernmost) to
c - 2(northernmost) row, where is our
c - random lat value?  That is, x must
c - be real and fall between 0 and 2.

      y=(xla-dla*(jla-1)-glamn)/dla

      if(y.lt.0.0)then
        val = 1.d30
        write(6,102)y,val
c       stop
        return
      endif
  102 format(
     *'FATAL in biquad:  y<0 : ',f20.10,/,
     *' --> Returning with val = ',f40.1)

      if(y.gt.2.0)then
        val = 1.d30
        write(6,103)y,val
c       stop
        return
      endif
  103 format(
     *'FATAL in biquad:  y>2 : ',f20.10,/,
     *' --> Returning with val = ',f40.1)

c - Now do the interpolation.  First, build a paraboloa
c - east-west the southermost row and interpolate to longitude
c - "xlo" (at "x" for 0<x<2).  Then do it in the middle
c - row, then finally the northern row.  The last step
c - is to fit a parabola north-south at the three previous
c - interpolations, but this time to interpolate to 
c - latitude "xla" (at "y" for 0<y<2).  Obviously we 
c - could reverse the order, doing 3 north-south parabolas
c - followed by one east-east and we'd get the same answer.

      fx0=qterp(x,z(jla  ,jlo),z(jla  ,jlo+1),z(jla  ,jlo+2))
      fx1=qterp(x,z(jla+1,jlo),z(jla+1,jlo+1),z(jla+1,jlo+2))
      fx2=qterp(x,z(jla+2,jlo),z(jla+2,jlo+1),z(jla+2,jlo+2))
      val=dble(qterp(y,fx0,fx1,fx2))

c     goto 888

c     write(6,*) ' '
c     write(6,*) ' ---------------------------------'
c     write(6,*) ' Inside biquad.f'
c     write(6,*) ' '

c     write(6,*) ' Southern Row of 3x3 window: '
c     write(6,*) ' jla  ,jlo  ,z(jla  ,jlo  ) = ',
c    *jla  ,jlo  ,z(jla  ,jlo  )
c     write(6,*) ' jla  ,jlo+1,z(jla  ,jlo+1) = ',
c    *jla  ,jlo+1,z(jla  ,jlo+1)
c     write(6,*) ' jla  ,jlo+2,z(jla  ,jlo+2) = ',
c    *jla  ,jlo+2,z(jla  ,jlo+2)
c     write(6,*) ' fx0 = ',fx0

c     write(6,*) ' Middle   Row of 3x3 window: '
c     write(6,*) ' jla+1,jlo  ,z(jla+1,jlo  ) = ',
c    *jla+1,jlo  ,z(jla+1,jlo  )
c     write(6,*) ' jla+1,jlo+1,z(jla+1,jlo+1) = ',
c    *jla+1,jlo+1,z(jla+1,jlo+1)
c     write(6,*) ' jla+1,jlo+2,z(jla+1,jlo+2) = ',
c    *jla+1,jlo+2,z(jla+1,jlo+2)
c     write(6,*) ' fx1 = ',fx1

c     write(6,*) ' Northern Row of 3x3 window: '
c     write(6,*) ' jla+2,jlo  ,z(jla+2,jlo  ) = ',
c    *jla+2,jlo  ,z(jla+2,jlo  )
c     write(6,*) ' jla+2,jlo+1,z(jla+2,jlo+1) = ',
c    *jla+2,jlo+1,z(jla+2,jlo+1)
c     write(6,*) ' jla+2,jlo+2,z(jla+2,jlo+2) = ',
c    *jla+2,jlo+2,z(jla+2,jlo+2)
c     write(6,*) ' fx2 = ',fx2

c     write(6,*) ' Final interpolated value = ',val

c 888 continue


      return
      end
      include 'qterp.f'
