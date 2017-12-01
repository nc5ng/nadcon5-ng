c> \ingroup core 
c> \if MANPAGE     
c> \page regrd2
c> \endif      
c> 
c> Part of the NADCON5 \ref core , regrid data 
c>     
c> Regrid gridded data using biquadratic interpolation     
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> When run from the command line, the program prints a prompt for each argument    
c>     
c> They are enumerated here
c> \param infile  Input Master Grid File Name 
c> \param outfile Output Regrid File Name 
c> \param nrow    Number of rows in new Grid (Lat)
c> \param ncol    Number of cols in new Grid (Lon)
c>      
c> ### Program Inputs:
c> 
c> - `lin` Input File 
c> 
c> ### Program Outputs:
c> 
c> - `lout` Output File
c>
      program regrd2

*** regrid gridded data using biquadratic interpolation 

      implicit double precision(a-h,o-z)
      parameter(len=6000*40000)
      real*4  z(len),zrec(40000)
      integer h(len),hrec(40000)
      character*68 fname
      equivalence(h(1),z(1)),(hrec(1),zrec(1))
      common/gstuff/glamn,dgla,glamx,glomn,dglo,glomx,nla,nlo,nclip

      common/static/z,zrec

      lin =1
      lout=2

      write(*,*) 'program regrd2'
      write(*,*)

      write(*,2)
    2 format('Enter master grid file:     ',$)
      read(*,1) fname
    1 format(a)
      open(lin,file=fname,status='old',form='unformatted')
      read(lin) glamn,glomn,dgla,dglo,nla,nlo,ikind
      glamx=glamn+dgla*(nla-1)
      glomx=glomn+dglo*(nlo-1)
      if(nla*nlo.gt.len) stop 12345
      if(nla.lt.4.or.nlo.lt.4) stop 54321

*** display header contents

      write(*,*) 'kind=',ikind
      write(*,*) 'LAT  min=',glamn
      write(*,*) '     del=',dgla,'    # lat=',nla
      write(*,*) '     max=',glamx
      write(*,*) 'LON  min=',glomn
      write(*,*) '     del=',dglo,'    # lon=',nlo
      write(*,*) '     max=',glomx
      write(*,*)

      write(*,3)
    3 format('Enter regridded output file:',$)
      read(*,1) fname
      open(lout,file=fname,status='new',form='unformatted')

*** following disabled

*  15 write(*,5)
*   5 format('Enter minimum latitude  of new grid: ',$)
*     read(*,*) glamn2
*     if(glamn2.lt.glamn.or.glamn2.gt.glamx) go to 15

*  16 write(*,6)
*   6 format('Enter maximum latitude  of new grid: ',$)
*     read(*,*) glamx2
*     if(glamx2.lt.glamn2.or.glamx2.gt.glamx) go to 16

*  17 write(*,7)
*   7 format('Enter minimum longitude of new grid: ',$)
*     read(*,*) glomn2
*     if(glomn2.lt.glomn.or.glomn2.gt.glomx) go to 17

*  18 write(*,8)
*   8 format('Enter maximum longitude of new grid: ',$)
*     read(*,*) glomx2
*     if(glomx2.lt.glomn2.or.glomx2.gt.glomx) go to 18

*     write(*,4)
*   4 format('Enter delta latitude (in minutes) : ',$)
*     read(*,*) dglam

*     write(*,9)
*   9 format('Enter delta longitude (in minutes): ',$)
*     read(*,*) dglom

*     dgla2=dglam/60.d0
*     dglo2=dglom/60.d0
*     nla2=idnint((glamx2-glamn2)/dgla2)+1
*     nlo2=idnint((glomx2-glomn2)/dglo2)+1

*** foregoing disabled
*** following clause added

   93 write(*,94)
   94 format('Enter new number of rows (latitude) : ',$)
      read(*,*) nla2
      if(nla2.lt.0) go to 93

   98 write(*,99)
   99 format('Enter new number of columns (longitude): ',$)
      read(*,*) nlo2
      if(nlo2.lt.0) go to 98

      glamn2=glamn
      glamx2=glamx
      glomn2=glomn
      glomx2=glomx
      dgla2=(glamx2-glamn2)/(nla2-1)
      dglo2=(glomx2-glomn2)/(nlo2-1)

*** back to standard code

*** input the grid

      if(ikind.eq.0) then
        call r1(lin,h,nla,nlo)
      else
        call r2(lin,z,nla,nlo)
      endif
      close(lin)

*** do the interpolation

      write(lout) glamn2,glomn2,dgla2,dglo2,nla2,nlo2,ikind

      if(ikind.eq.0) then
        do 10 ir=1,nla2
          gla=glamn2+(ir-1)*dgla2
          do 20 ic=1,nlo2
            glo=glomn2+(ic-1)*dglo2
            call bquad1(h,gla,glo,ival)
            if(ival.ge.2147483647) stop 11111
            hrec(ic)=ival
   20     continue
          write(lout) (hrec(i),i=1,nlo2)
   10   continue
      else
        do 30 ir=1,nla2
          gla=glamn2+(ir-1)*dgla2
          do 40 ic=1,nlo2
            glo=glomn2+(ic-1)*dglo2
            call bquad2(z,gla,glo,val)
            if(val.ge.1.d30) stop 22222
            zrec(ic)=val
   40     continue
          write(lout) (zrec(i),i=1,nlo2)
   30   continue
      endif

      stop
      end
      subroutine bquad1(h,gla,glo,ival)

*** compute biquadratic interpolation, integer version
*** logic not tested for '0/360 meridian wraparound'

      implicit double precision(a-h,o-z)
      integer h(nla,nlo)
      real*4 x,y,fx0,fx1,fx2,val,qterp1,qterp2
      external qterp1,qterp2
      common/gstuff/glamn,dgla,glamx,glomn,dglo,glomx,nla,nlo,nclip

      if(gla.lt.glamn.or.gla.gt.glamx.or.
     *   glo.lt.glomn.or.glo.gt.glomx) then
        nclip=nclip+1
        ival=2147483647
      else

*** within grid boundaries, get indicies in the grid

        ix=(glo-glomn)/dglo+1.d0
        ix1=ix+1
        ix2=ix+2

*** check if edge collision

    1   if(ix2.gt.nlo)then
          ix =ix -1
          ix1=ix1-1
          ix2=ix2-1
          go to 1
        endif

        x=(glo-dglo*(ix-1)-glomn)/dglo

*** move grid to get nearer center of 3 x 3

        if(x.lt.0.5.and.ix.gt.1)then
          ix =ix -1
          ix1=ix1-1
          ix2=ix2-1
          x=x+1.
        endif
        if(x.lt.0..or.x.gt.2.) stop 55555

*** now do it for y

        jy=(gla-glamn)/dgla+1.d0
        jy1=jy+1
        jy2=jy+2
    2   if(jy2.gt.nla)then
          jy =jy -1
          jy1=jy1-1
          jy2=jy2-1
          go to 2
        endif
        y=(gla-dgla*(jy-1)-glamn)/dgla
        if(y.lt.0.5.and.jy.gt.1)then
          jy =jy -1
          jy1=jy1-1
          jy2=jy2-1
          y=y+1.
        endif
        if(y.lt.0..or.y.gt.2.) stop 33333

        fx0=qterp1(x, h(jy ,ix ), h(jy ,ix1), h(jy ,ix2))
        fx1=qterp1(x, h(jy1,ix ), h(jy1,ix1), h(jy1,ix2))
        fx2=qterp1(x, h(jy2,ix ), h(jy2,ix1), h(jy2,ix2))
        val=qterp2(y, fx0       , fx1       , fx2       )
        ival=nint(val)
      endif

      return
      end
      subroutine bquad2(z,gla,glo,val)

*** compute biquadratic interpolation, floating point version
*** logic not tested for '0/360 meridian wraparound'

      implicit double precision(a-h,o-z)
      real*4 z(nla,nlo)
      real*4 x,y,fx0,fx1,fx2,qterp2
      external qterp2
      common/gstuff/glamn,dgla,glamx,glomn,dglo,glomx,nla,nlo,nclip

      if(gla.lt.glamn.or.gla.gt.glamx.or.
     *   glo.lt.glomn.or.glo.gt.glomx) then
        nclip=nclip+1
        val=1.d30
      else

*** within grid boundaries, get indicies in the grid

        ix=(glo-glomn)/dglo+1.d0
        ix1=ix+1
        ix2=ix+2

*** check if edge collision

    1   if(ix2.gt.nlo)then
          ix =ix -1
          ix1=ix1-1
          ix2=ix2-1
          go to 1
        endif

        x=(glo-dglo*(ix-1)-glomn)/dglo

*** move grid to get nearer center of 3 x 3

        if(x.lt.0.5.and.ix.gt.1)then
          ix =ix -1
          ix1=ix1-1
          ix2=ix2-1
          x=x+1.
        endif
        if(x.lt.0..or.x.gt.2.) stop 66666

*** now do it for y

        jy=(gla-glamn)/dgla+1.d0
        jy1=jy+1
        jy2=jy+2
    2   if(jy2.gt.nla)then
          jy =jy -1
          jy1=jy1-1
          jy2=jy2-1
          go to 2
        endif
        y=(gla-dgla*(jy-1)-glamn)/dgla
        if(y.lt.0.5.and.jy.gt.1)then
          jy =jy -1
          jy1=jy1-1
          jy2=jy2-1
          y=y+1.
        endif
        if(y.lt.0..or.y.gt.2.) stop 44444

        fx0=     qterp2(x, z(jy ,ix ), z(jy ,ix1), z(jy ,ix2))
        fx1=     qterp2(x, z(jy1,ix ), z(jy1,ix1), z(jy1,ix2))
        fx2=     qterp2(x, z(jy2,ix ), z(jy2,ix1), z(jy2,ix2))
        val=dble(qterp2(y, fx0       , fx1       , fx2       ))
      endif

      return
      end
      real function qterp1(x,if0,if1,if2)

*** linear quadratic interpolation from equally spaced values
*** uses newton-gregory forward polynomial
*** x ranges from 0 thru 2.  (thus s = x)

*** forward differences

      idf0 =if1 -if0
      idf1 =if2 -if1
      id2f0=idf1-idf0

      qterp1=if0 + x*idf0 + 0.5*x*(x-1.)*id2f0

      return
      end
      real function qterp2(x,f0,f1,f2)

*** linear quadratic interpolation from equally spaced values
*** uses newton-gregory forward polynomial
*** x ranges from 0 thru 2.  (thus s = x)

*** forward differences

      df0 =f1 -f0
      df1 =f2 -f1
      d2f0=df1-df0

      qterp2=f0 + x*df0 + 0.5*x*(x-1.)*d2f0

      return
      end
      subroutine r1(lin,h,nla,nlo)

***  read records south to north (elements are west to east)

      implicit double precision(a-h,o-z)
      integer h(nla,nlo)

      do 1 i=1,nla
    1 read(lin) (h(i,j),j=1,nlo)

      return
      end
      subroutine r2(lin,z,nla,nlo)

***  read records south to north (elements are west to east)

      implicit double precision(a-h,o-z)
      real*4 z(nla,nlo)

      do 1 i=1,nla
    1 read(lin) (z(i,j),j=1,nlo)

      return
      end
