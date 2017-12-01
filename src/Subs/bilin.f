c> \ingroup core
c> \if MANPAGE     
c> \page bilin
c> \endif      
c> 
c> Subroutine to perform bilinear interpolation
c> 
c> Performs a bilinear interpolation
c> at location `xla,xlo` off of grid `data`, whose
c> header information is the standard `.b` header
c> information
c> 
c> \param[in] data Input Data assumed to be real*4
c> \param[in] glamn  minimum latitude   (real*8 decimal degrees) `*.b`
c> \param[in] glomn  minimum longitude  (real*8 decimal degrees) `*.b`
c> \param[in] dla   latitude spacing   (real*8 decimal degrees) `*.b`
c> \param[in] dlo   longitude spacing  (real*8 decimal degrees) `*.b`
c> \param[in] nla   number of lat rows (integer*4) `*.b`
c> \param[in] nlo   number of lon cols (integer*4) `*.b`
c> \param[in] maxla actual dimensioned size of "data" in rows `*.b`
c> \param[in] maxlo actual dimensioned size of "data" in cols `*.b`
c> \param[in] xla   lat of pt for interpolation (real*8 dec. def)
c> \param[in] xlo   lon of pt for interpolation (real*8 dec. def)
c> \param[out] val  interpolated value (real*8)
      subroutine bilin(data,glamn,glomn,dla,dlo,
     *nla,nlo,maxla,maxlo,xla,xlo,val)
c - Subroutine to perform a bilinear interpolation
c - at location "xla,xlo" off of grid "data", whose
c - header information is the standard ".b" header
c - information of
c -    glamn = minimum latitude   (real*8 decimal degrees)
c -    glomn = minimum longitude  (real*8 decimal degrees)
c -    dla   = latitude spacing   (real*8 decimal degrees)
c -    dlo   = longitude spacing  (real*8 decimal degrees)
c -    nla   = number of lat rows (integer*4)
c -    nlo   = number of lon cols (integer*4)
c -    maxla = actual dimensioned size of "data" in rows
c -    maxlo = actual dimensioned size of "data" in cols

c - data is assumed real*4
      implicit real*8 (a-h,o-z)
      real*4 data(maxla,maxlo)
      logical onedlat,onedlon

c - HACK 
c     do 8787 i=1,nla
c       do 8788 j=1,nlo
c         write(6,8789)i,j,data(i,j)
c8788   continue
c8787 continue
c8789 format(i5,1x,i5,1x,f20.10)

c - Find the row of xla
      difla = (xla - glamn) 
      ratla = difla / dla
      ila = int(ratla)+1
      gla0 = glamn + (ila-1)*dla

c - Find the col of xlo
      diflo = (xlo - glomn) 
      ratlo = diflo / dlo
      ilo = int(ratlo)+1
      glo0 = glomn + (ilo-1)*dlo


c - Do the interpolation.  
      t=(xlo-glo0)/dlo
      u=(xla-gla0)/dla
     
      val = (1.d0-t)*(1.d0-u)*data(ila  ,ilo  )  
     *    + (     t)*(1.d0-u)*data(ila  ,ilo+1)
     *    + (     t)*(     u)*data(ila+1,ilo+1)
     *    + (1.d0-t)*(     u)*data(ila+1,ilo  )

c - HACK
      return  
      write(6,198)xla,xlo
      write(6,200)ila,ilo,gla0,glo0
      write(6,199)xla-gla0,xlo-glo0
      write(6,201)ila,ilo,gla0,glo0,
     *data(ila,ilo)
      write(6,201)ila,ilo+1,gla0,glo0+dlo,
     *data(ila,ilo+1)
      write(6,201)ila+1,ilo,gla0+dla,glo0,
     *data(ila+1,ilo)
      write(6,201)ila+1,ilo+1,gla0+dla,glo0+dlo,
     *data(ila+1,ilo+1)
      write(6,202)'SW',(1.d0-t)*(1.d0-u)
      write(6,202)'SE',(     t)*(1.d0-u)
      write(6,202)'NW',(     t)*(     u)
      write(6,202)'NE',(1.d0-t)*(     u)
  202 format(
     *'Weight to ',a,' corner = ',f20.15)

  198 format(
     *6x,'bilin.f: lat/lon = ',f10.6,1x,f10.6)
  199 format(
     *6x,'bilin.f: diff from SW corner of cell = ',f10.6,1x,f10.6)
  200 format(
     *6x,'bilin.f: SW corner: ',i6,1x,i6,1x,f10.6,1x,f10.6)
  201 format(
     *6x,2(i6,1x),2(f10.6,1x),f20.15)
      

c     write(6,801)xla,xlo,ila,ilo,gla0,glo0,t,u,val
  801 format(f15.8,1x,f15.8,1x,i6,1x,i6,1x,
     *f15.8,1x,f15.8,1x,f8.6,1x,f8.6,1x,f20.10)

c     write(6,802)data(ila  ,ilo  ),
c    *data(ila  ,ilo+1),data(ila+1,ilo+1),
c    *data(ila+1,ilo  )
  802 format(4(f15.8,1x))
      
      return
      end
      
      
        
      
