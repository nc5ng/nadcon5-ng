c - Program makeharnfbnmask

c - 2016 06 30
c - Corrected to use REGIONAL boundary files since the
c - state polygons are NOT aligned at their boundaries

c - See DRU-12, p. 38

c - The 5 boundary files are HF*.txt (* = 1 through 5)


c - See DRU-12, p. 6

c - Program to take 5 (was 19) XX.txt files, each
c - containing a set of lat/lon pairs as a closed
c - polygon for one state which has both a HARN
c - and an FBN realization of NAD 83 i CONUS and
c - create a landmask at whatever grid spacing
c - the user requires, using the official NADCON5
c - boundaries of CONUS, so that grid points
c - INSIDE states with both a HARN and an FBN
c - will have a value of "1" and points outside
c - such states will have a value of "0"


      implicit real*8(a-h,o-z)
      character*11 dir
      character*7 fname0
      character*64 fname
      character*2 state(5)
      real*8 x(5,1000),y(5,1000)
      integer*4 nkt(5),inew(5)
      real*8 x0(1000),y0(1000)
      real*4 data(15000,15000)
      character*200 outname
      character*200 agrids
      real*8 xs,xw,xn,xe,dla,dlo
      integer*4 nla,nlo,ikind

      write(6,100)
  100 format('Program makeharnfbnmask')
      write(6,101)
  101 format('What grid spacing, in integer arcseconds? : ',$)
      read(5,*)agrids
      read(agrids,*)igrids
      
      outname = 'mask.harnfbn.'//trim(agrids)//'.b'

c - The following is hardcoded for simplicity, but
c - came from file "Data/grid.parameters"
      xn = 50.d0
      xs = 24.d0
      xw = 235.d0
      xe = 294.d0

c - Compute the grid spacing stats for the requested
c - mask.
      dla = (dble(igrids)/3600.d0)
      dlo = dla

      nla = nint((xn-xs) / dla) + 1
      nlo = nint((xe-xw) / dlo) + 1

      write(6,102)xn,xs,xw,xe,dla,dlo,nla,nlo
  102 format('Creating a HARN/FBN landmask grid with: ',/,
     *'North = ',f8.2,' South = ',f8.2,/,
     *'West  = ',f8.2,' East  = ',f8.2,/,
     *'DLA   = ',f8.5,' DLO   = ',f8.5,/,
     *'NLA   = ',i8  ,' NLO   = ',i8)

      dir = 'Boundaries/'
      open(1,file='filelist.harnfbn',status='old',form='formatted')


c - First step:  Get all 5 polygons into RAM
      ist = 0
    1 read(1,'(a7)',end=99)fname0
        ist = ist + 1
        fname = dir//fname0
        open(10,file=fname,status='old',form='formatted')
        state(ist)=fname0(1:2)

        ikt = 0
    2   read(10,*,end=98)xlat,xlon     
          ikt = ikt + 1
          if(xlon.lt.0)xlon = xlon + 360.d0

          x(ist,ikt) = xlon
          y(ist,ikt) = xlat

        goto 2
   98   continue

        nkt(ist) = ikt
        write(6,201)state(ist),nkt(ist)

      goto 1
   99 nst = ist

  201 format('Polygon now in RAM for: ',a2,' with ',i4,' points')

c - Second step, fill the grid with zeros
      write(6,104)
  104 format('Creating grid of all zeroes first...')
      do 5 i=1,nla
        do 6 j=1,nlo 
          data(i,j) = 0.d0
    6   continue
    5 continue
          


c - Second step, spin over every polygon, then every
c - grid node.  Put the polygon into special RAM spot,
c - and check the whole grid.  Then go back and do the
c - same for every polygon, skipping the check if a 
c - grid point ever is "1"

      do 7 ist=1,nst
        inew(ist) = 0
        write(6,105)state(ist)
  105   format('Checking polygon for ',a2,'...',$)
c - Move this polygon to special RAM spot
        do 8 kpt=1,nkt(ist)
          x0(kpt) = x(ist,kpt)
          y0(kpt) = y(ist,kpt)
    8   continue

c - Now go over the whole grid, and check the ONE polygon...
        do 9 i=1,nla
          yy = xs + (i-1)*dla
          do 10 j=1,nlo
c - Skip if this grid node has already been changed to 1 previously
            if(data(i,j).eq.1)goto 10
            xx = xw + (j-1)*dlo
            call inout(xx,yy,x0,y0,nkt(ist),iq)
            if(iq.eq.1)then
              inew(ist) = inew(ist) + 1
              data(i,j) = 1.d0
            endif
   10     continue
    9   continue
        write(6,106)inew(ist)
  106   format(i8,' grid points found inside.')
    7 continue

c - Finally, write out the grid
      ikind = 1
      write(6,107)trim(outname)
  107 format(/,'Writing out grid: ',a)
      open(99,file=outname,status='new',form='unformatted')
      write(99)xs,xw,dla,dlo,nla,nlo,ikind
      do 11 i=1,nla
        write(99)(data(i,j),j=1,nlo)
   11 continue

      end 

      include 'inout.f'
