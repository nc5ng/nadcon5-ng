c> \ingroup core 
c> \if MANPAGE     
c> \page xyz2b
c> \endif      
c> 
c> Part of the NADCON5 \ref core , Converts GMT `*.grd` to a `*.b` NADCON style grid file
c>     
c> Turn gmt/netcdf grd dump into my grid file  (real number version)
c> assumes grd dump is longitude/latitude/real (binary s.p.)
c>     
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> When run from the command line, the program prints a prompt for each argument    
c>     
c> They are enumerated here
c> \param infile  Input File Name 
c> \param outfile Output File Name 
c>      
c> ### Program Inputs:
c> 
c> - `lin` Input File  (`*.grd`)
c> 
c> ### Program Outputs:
c> 
c> - `lout` Output File (`*.b`)
c>
      program xyz2b

*** turn gmt/netcdf grd dump into my grid file  (real number version)
*** assumes grd dump is longitude/latitude/real (binary s.p.)

      implicit double precision(a-h,o-z)
      parameter(len=5401*5401)
      parameter(gran=3600.d0)
      character*88 fname
      logical makpos
      integer h(len)
      real*4  z(len),glo,gla,val
      equivalence(h(1),z(1))

      lin=1
      lout=2

****  write(*,1)
****1 format(' program xyz2b     --> Enter input file name: ',$)
****  read(*,'(a)') fname

      read(5,'(a)') fname

*** next line is non-standard (binary input)
c     open(lin,file='temp',status='old',form='binary')
      open(lin,file=fname,status='old',form='binary')

****  write(*,2)
****2 format('      grid output --> Enter file name: ',$)
****  read(*,'(a)') fname

      read(5,'(a)') fname

c     open(lout,file='xyz2b.b',status='new',form='unformatted')
      open(lout,file=fname,status='new',form='unformatted')

****  write(*,'(a,$)') 'Integer data?  '
****  read (*,'(a)')   yesno

*** real number version

      yesno='n'
      if(yesno.eq.'y'.or.yesno.eq.'Y') then
        ikind=0
      else
        ikind=1
      endif

      glamx=-9999.d0
      glamn= 9999.d0
      glomx=-9999.d0
      glomn= 9999.d0
      dgla =-9999.d0
      dglo =-9999.d0

*** loop over data -- get grid parameters

      n=0
      read(lin) glo,gla,val
      n=1
      if(makpos(glo)) continue

      if(gla.gt.glamx) glamx=gla
      if(gla.lt.glamn) glamn=gla
      if(glo.gt.glomx) glomx=glo
      if(glo.lt.glomn) glomn=glo

      glax=gla
      glox=glo

  100 read(lin,end=777) glo,gla,val
      n=n+1
      if(makpos(glo)) continue

      if(gla.gt.glamx) glamx=gla
      if(gla.lt.glamn) glamn=gla
      if(glo.gt.glomx) glomx=glo
      if(glo.lt.glomn) glomn=glo

      dla=dabs(gla-glax)
      dlo=dabs(glo-glox)
      if(dla.gt.dgla.and.dla.lt.(glamx-glamn)/2.d0 ) dgla=dla
      if(dlo.gt.dglo.and.dlo.lt.(glomx-glomn)/2.d0 ) dglo=dlo

      glax=gla
      glox=glo
      go to 100
  777 rewind lin

*** adjust granularity of input and report header

      glamn=idnint(gran*glamn)/gran
      glamx=idnint(gran*glamx)/gran
      glomn=idnint(gran*glomn)/gran
      glomx=idnint(gran*glomx)/gran
      dgla =idnint(gran*dgla )/gran
      dglo =idnint(gran*dglo )/gran
      nla=idnint((glamx-glamn)/dgla)+1
      nlo=idnint((glomx-glomn)/dglo)+1
      dgla=(glamx-glamn)/dble(nla-1)
      dglo=(glomx-glomn)/dble(nlo-1)

      write(*,*)
      write(*,*) ' kind=',ikind
      write(*,*) ' LAT  min=',glamn
      write(*,*) '      del=',dgla,'    # lat=',nla
      write(*,*) '      max=',glamn+(nla-1)*dgla
      write(*,*) ' LON  min=',glomn
      write(*,*) '      del=',dglo,'    # lon=',nlo
      write(*,*) '      max=',glomn+(nlo-1)*dglo

*** initialize the grid

      if(nla*nlo.gt.len) stop 12345
      if(ikind.eq.0) then
        do 3 i=1,nla*nlo
    3   h(i)=0
      else
        do 4 i=1,nla*nlo
    4   z(i)=9999999999.0
      endif

*** read the text       (3rd column is alway real*4 float)

      icount=0
      iclip=0
   10 read(lin,end=7777) glo,gla,val
      icount=icount+1
      if(makpos(glo)) continue
      if(ikind.eq.0) then
        ival=nint(val)
        call put1(ival,gla,glo,h,nla,nlo,glamn,dgla,glomn,dglo,iclip)
      else
        call put2( val,gla,glo,z,nla,nlo,glamn,dgla,glomn,dglo,iclip)
      endif
      go to 10
 7777 continue

*** write the grid

      write(lout) glamn,glomn,dgla,dglo,nla,nlo,ikind
      if(ikind.eq.0) then
        call w1(lout,h,nla,nlo,glamn,dgla,glomn,dglo)
      else
        call w2(lout,z,nla,nlo,glamn,dgla,glomn,dglo)
      endif

      write(*,*) ' all, icount, iclip = ',nla*nlo,icount,iclip

      stop
      end
      subroutine put1(ival,gla,glo,h,nla,nlo,glamn,dgla,glomn,dglo,iclp)

*** load value into grid

      implicit double precision(a-h,o-z)
      real*4  val,gla,glo
      integer h(nla,nlo)

      i=idnint((gla-glamn)/dgla)+1
      if(i.lt.1.or.i.gt.nla) then
        iclp=iclp+1
        return
      endif
      j=idnint((glo-glomn)/dglo)+1
      if(j.lt.1.or.j.gt.nlo) then
        iclp=iclp+1
        return
      endif
      h(i,j)=ival

      return
      end
      subroutine put2(val,gla,glo,z,nla,nlo,glamn,dgla,glomn,dglo,iclip)

*** load value into grid

      implicit double precision(a-h,o-z)
      real*4 z(nla,nlo),val,gla,glo

      i=idnint((gla-glamn)/dgla)+1
      if(i.lt.1.or.i.gt.nla) then
        iclip=iclip+1
        return
      endif
      j=idnint((glo-glomn)/dglo)+1
      if(j.lt.1.or.j.gt.nlo) then
        iclip=iclip+1
        return
      endif
      z(i,j)=val

      return
      end
      subroutine w1(lout,h,nla,nlo,glamn,dgla,glomn,dglo)

*** write records south to north (elements are west to east)

      implicit double precision(a-h,o-z)
      integer h(nla,nlo)

      do 1 i=1,nla
    1 write(lout) (h(i,j),j=1,nlo)

      return
      end
      subroutine w2(lout,z,nla,nlo,glamn,dgla,glomn,dglo)

*** write records south to north (elements are west to east)

      implicit double precision(a-h,o-z)
      real*4 z(nla,nlo)

      do 1 i=1,nla
    1 write(lout) (z(i,j),j=1,nlo)

      return
      end
      logical function makpos(glon)

*** insure longitude is positive  (single precision)

      makpos=.false.

    1 if(glon.lt.0.d0) then
        glon=glon+360.d0
        makpos=.true.
        go to 1
      endif

    2 if(glon.ge.360.d0) then
        glon=glon-360.d0
        go to 2
      endif

      return
      end
