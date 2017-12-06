c> \ingroup core
c> \if MANPAGE     
c> \page bicubic
c> \endif      
c> 
c> Subroutine to perform a 2-D cubic ("bicubic") interpolation
c> 
c> Performs interpolation at location "xla,xlo" off of grid "z", whose
c> header information is the standard ".b" header
c> information with additional inputs
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
c>   Fit a 4x4 window over the random point. Unless the point
c>   is less than one grid spacing from the edge of the grid,
c>   it will fall in the inner 2x2 cell, and the 4x4 cell will
c>   be centered upon that.
c> 
c>   Thus, if our point of interest is the asterisk, the window 
c>   will look like this:
c> 
c>              .  .  .  .
c>              .  .  .  .
c>              .  .* .  . 
c>              .  .  .  .
c> 
      subroutine bicubic(z,glamn,glomn,dla,dlo,
     *nla,nlo,maxla,maxlo,xla,xlo,val)

c - Data is assumed real*4
      implicit real*8 (a-h,o-z)
      real*4 z(maxla,maxlo)

c - Internal use
      real*4 x,y,fx0,fx1,fx2,fx3,cubterp

c - Find which row should be LEAST when fitting
c - a 4x4 window around xla.  
      difla = (xla - glamn)
      ratla = difla / dla
      jla = int(ratla)
c - Fix any edge overlaps
      if(jla.lt.1)jla = 1
      if(jla.gt.nla-3)jla = nla-3

c - Find which column should be LEAST when fitting
c - a 4x4 window around xlo.
      diflo = (xlo - glomn)
      ratlo = diflo / dlo
      jlo = int(ratlo)
c - Fix any edge overlaps
      if(jlo.lt.1)jlo = 1
      if(jlo.gt.nlo-3)jlo = nlo-3

c - In the range of 0(westernmost) to
c - 3(easternmost) col, where is our
c - random lon value?  That is, x must
c - be real and fall between 0 and 3.
c - (Note, unless it is near an edge,
c - it will always be between 1 and 2)

      x=(xlo-dlo*(jlo-1)-glomn)/dlo

      if(x.lt.0.0)then
        write(6,100)x
        stop
      endif
  100 format(
     *'FATAL in bicubic:  x<0 : ',f20.10)

      if(x.gt.3.0)then
        write(6,101)x
        stop
      endif
  101 format(
     *'FATAL in bicubic:  x>3 : ',f20.10)

c - In the range of 0(southernmost) to
c - 3(northernmost) row, where is our
c - random lat value?  That is, x must
c - be real and fall between 0 and 3.
c - (Note, unless it is near an edge,
c - it will always be between 1 and 2)

      y=(xla-dla*(jla-1)-glamn)/dla

      if(y.lt.0.0)then
        write(6,102)y
        stop
      endif
  102 format(
     *'FATAL in bicubic:  y<0 : ',f20.10)

      if(y.gt.3.0)then
        write(6,103)y
        stop
      endif
  103 format(
     *'FATAL in bicubic:  y>3 : ',f20.10)

c - Now do the interpolation.  First, build a 1-D cubic function
c - east-west in the southermost row and interpolate to longitude
c - "xlo" (at "x" for 0<x<3).  Then do it in the 2nd row,
c - then again in the 3rd, and finally the 4th and most northern row.  
c - The last step is to fit a 1-D cubic function north-south at the
c - four previous interpolations, but this time to interpolate to 
c - latitude "xla" (at "y" for 0<y<3).  Obviously we 
c - could reverse the order, doing 4 north-south cubics
c - followed by one east-east and we'd get the same answer.


      fx0=cubterp(x,z(jla  ,jlo  ),z(jla  ,jlo+1),
     *              z(jla  ,jlo+2),z(jla  ,jlo+3))

      fx1=cubterp(x,z(jla+1,jlo  ),z(jla+1,jlo+1),
     *              z(jla+1,jlo+2),z(jla+1,jlo+3))

      fx2=cubterp(x,z(jla+2,jlo  ),z(jla+2,jlo+1),
     *              z(jla+2,jlo+2),z(jla+2,jlo+3))

      fx3=cubterp(x,z(jla+3,jlo  ),z(jla+3,jlo+1),
     *              z(jla+3,jlo+2),z(jla+3,jlo+3))

      val=dble(cubterp(y,fx0,fx1,fx2,fx3))

      
c     write(6,1001)glamn,xla,jla,y
c     write(6,1002)glomn,xlo,jlo,x
c     write(6,1003)z(jla+3,jlo  ),z(jla+3,jlo+1),
c    *             z(jla+3,jlo+2),z(jla+3,jlo+3)
c     write(6,1003)z(jla+2,jlo  ),z(jla+2,jlo+1),
c    *             z(jla+2,jlo+2),z(jla+2,jlo+3)
c     write(6,1003)z(jla+1,jlo  ),z(jla+1,jlo+1),
c    *             z(jla+1,jlo+2),z(jla+1,jlo+3)
c     write(6,1003)z(jla  ,jlo  ),z(jla  ,jlo+1),
c    *             z(jla  ,jlo+2),z(jla  ,jlo+3)
c     write(6,1004)fx0,fx1,fx2,fx3,val
c     pause

 1001 format(f14.10,1x,f14.10,1x,i8,1x,f8.5)
 1002 format(f14.10,1x,f14.10,1x,i8,1x,f8.5)
 1003 format(4(f15.8,1x))
 1004 format(
     *'fx0 = ',f15.8,/,
     *'fx1 = ',f15.8,/,
     *'fx2 = ',f15.8,/,
     *'fx3 = ',f15.8,/,
     *'val = ',f15.8)


      
      return
      end
      include 'cubterp.f'
