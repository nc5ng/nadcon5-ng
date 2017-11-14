      program checkgrid

c - 2016 08 26:  Changed "getmapbounds" to bring in a better way 
c      of computing the reference vector location and added a new
c      variable for its label
c - Also changing the call to "getmapbounds" to give it "olddatum" and "newdatum"
c - to aide in filtering out things like the Saint regions in Alaska
c - for unsupported transformations.

c - 2016 07 29:  Scrapped personal placement of vectors and just let them
c - sit outside/below the map

c - 2016 07 21:
c    - Added code to allow for optional placement of reference vectors, coming from
c      "map.parameters" as read in subroutine "getmapbounds"


c - 2015 10 08 - Added HOR output in M and S for Lat/Lon to both "gi" and "dd" vector output.
c - Combined: v(m/s)(a/t/d)(gi/dd)lat...
c -           v(m/s)(a/t/d)(gi/dd)lon...
c -    into : v(m/s)(a/t/d)(gi/dd)hor...
c
c
c
c - Program begun 9/10/2015
c - For use in creating NADCON5
c - Built by Dru Smith

c - 1) Compare grids of dlat, dlon and deht
c -    to vectors of dlat, dlon and deht.
c - 2) Spit out interpolated (from grid) vectors
c - 3) Spit out differential (interpolated minus original) vectors.
c - 4) Create a GMT batch file to plot said vectors.

c - The input vectors:
c -   Represent *all* (outlier removed)
c -   vectors of dlat/dlon/deht for the
c -   olddatum/newdatum/region combination

c - However, for the sake of understanding, the
c - vectors will be read in from their "thinned"
c - and "dropped" files, so that we can generate
c - statistics of:
c -   thinned-versus-gridded
c -   dropped-versus-gridded
c -   all-versus-gridded
c - This is important, since ONLY the thinned
c - vectors went into the grid and it seems
c - that their statistics should be better against
c - the grid than the dropped vectors.  Additionally,
c - one might argue that the only independent check
c - on the grid is the dropped agreement.  We'll see.

c - The input grids:
c -    dlat/dlon/deht grids based on thinning
c -    all of the vectors (see above) using
c -    a median thinning at some block spacing
c -    in arcseconds, and gridding to that same
c -    block spacing.

c - Input to this program:
c -   olddtm    
c -   newdtm
c -   region
c -   agridsec

      implicit real*8(a-h,o-z)
      parameter(maxlat=5000,maxlon=5000,maxpts=300000)
      parameter(maxplots=60)

      character*10 olddtm,newdtm,region
c - Grid spacing, converted to characters for file names
c - Presumes:
c -   1) igridsec is an integer
c -   2) 1 <= igridsec <= 99999
      integer*4 igridsec
      character*5 agridsec
      character*1 mapflag
      character*200 suffix1,suffix2,suffix3
      character*200 suffix2t04
      character*200 gmtfile
      character*3 ele(7),el0(7)

c - GMT stuff
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
      character*200 gfn
      real*8 lorvopc
      real*8 lorvog(7),lorvoggi(7)
      real*8 scaledd(7),scalegi(7)
      real*8 basedd(7),basegi(7)
      real*8 lorvogprime,lorvogmeters
      real*8 lorvogprimegi,lorvogmetersgi
      real*8 lorvoghorgis,lorvoghorgim
      real*8 lorvoghordds,lorvoghorddm

c - 2016 07 21:
      logical lrv(maxplots)
      real*8 rv0x(maxplots),rv0y(maxplots),rl0y(maxplots)

c - Input original THINNED vectors (outliers must be
c - removed)
      character*200 gfnvmtcdlat,gfnvstcdlat
      character*200 gfnvmtcdlon,gfnvstcdlon
      character*200 gfnvmtcdeht
      character*200 gfnvmtcdhor,gfnvstcdhor
c - Input original DROPPED vectors (outliers must be
c - removed)
      character*200 gfnvmdcdlat,gfnvsdcdlat
      character*200 gfnvmdcdlon,gfnvsdcdlon
      character*200 gfnvmdcdeht
      character*200 gfnvmdcdhor,gfnvsdcdhor
c - Input ".b" files created from the thinned vectors
      character*200 bfnvmtcdlat,bfnvstcdlat
      character*200 bfnvmtcdlon,bfnvstcdlon
      character*200 bfnvmtcdeht

c - Logical arguments to tell me if there are no values in files
      logical*1 nothinlat,nothinlon,nothineht

c - Output grid-interpolated coordinate difference vector files:
c - For the sake of completeness, we'll create grid-interpolated vectors
c - for all of these combinations in meters (thus 15 files):
c -        thin, drop, all 
c -      by 
c -        lat(m),lat(s),lon(m),lon(s),eht(m) 
      character*200 gfnvmagilat,gfnvmtgilat,gfnvmdgilat
      character*200 gfnvsagilat,gfnvstgilat,gfnvsdgilat
      character*200 gfnvmagilon,gfnvmtgilon,gfnvmdgilon
      character*200 gfnvsagilon,gfnvstgilon,gfnvsdgilon
      character*200 gfnvmagieht,gfnvmtgieht,gfnvmdgieht
c - Added 2015 10 08
      character*200 gfnvmagihor,gfnvmtgihor,gfnvmdgihor
      character*200 gfnvsagihor,gfnvstgihor,gfnvsdgihor

c - Output double differenced (differences of coordinate differences,
c - aka DDlat, DDlon or DDeht) GMT-ready files:
c
c - For the sake of completeness, we'll create differential vectors
c - for all of these combinations in meters (thus 15 files):
c -        thin, drop, all 
c -      by 
c -        lat(m),lat(s),lon(m),lon(s),eht(m) 
c - 

c - Stats will be generated for thin, drop or all.  
c - We will create a batch file to plot thin, drop or all.  

c - Naming scheme is:

c - 1-2: "vm" or "vs" for "vectors in meters" or "vectos in arcseconds"
c -   3: "a","t","d" or "r" for All, Thinned, Dropped or RMS'd
c - 4-5: "cd" or "gi" or "dd" for Coordinate Differences, Grid-Interpolated coordinate differences, or Double Differences
c - 6-8: "lat", "lon" or "eht" 

c - Thus, by way of example:
c -    vmacdlat = Vectors in meters, All Coordinate Differences, Latitude
c -    vmagilat = Vectors in meters, All Grid-Interpolated coordinate differences, Latitude
c - and their difference would be:
c -    vmaddlat = Vectors in meters, Double Differences (Grid minus original), Latitude
c
c - Other examples, in general:
c -    vstcdlon = Vectors in arcseconds, Thinned Coordinate Differences, Longitude
c -    vmrddeht = Vectors in meters, RMS'd Double Differences, Ellipsoid Height (not used in this program)
c -
c - On the use of RMS: The RMS'd values only are applied to Double Differences
c - (that is, Differences of Coordinate Differences).  As such, we should
c - not see an "r" in the 3rd position of the file name without "dd" in 
c - positions 4-5.  These Double Differenes represent the difference
c - between a Coordinate Difference interpolated off the GRID and a Coordinate
c - Difference directly computed from input data (aka "vectors").
c - The RMS'd data is compiled from ALL vectors compared against the
c - GRID, not just thinned vectors (which were used to MAKE the grid).
c - Doing it only on "thinned" causes overly optimistic statistics, while
c - doing it only on "dropped" ignores the fact that the thinned
c - and dropped vectors are both in the public domain and used by
c - the public.)

c - Note, the "dropped" and "thinned" refer to those categories established
c - way back in "mymedian5.f", under doit3.bat.


c - Output double differenced vector files (all/thinned/dropped):
      character*200 gfnvmaddlat,gfnvmtddlat,gfnvmdddlat
      character*200 gfnvsaddlat,gfnvstddlat,gfnvsdddlat
      character*200 gfnvmaddlon,gfnvmtddlon,gfnvmdddlon
      character*200 gfnvsaddlon,gfnvstddlon,gfnvsdddlon
      character*200 gfnvmaddeht,gfnvmtddeht,gfnvmdddeht
c - Added 2015 10 08
      character*200 gfnvmaddhor,gfnvmtddhor,gfnvmdddhor
      character*200 gfnvsaddhor,gfnvstddhor,gfnvsdddhor

c - Stats file name
      character*200 sfn

c - The gridded data
      real*8 glamn,glomn,dla,dlo
      integer*4 nla,nlo,ikind
      real*4 datlats(maxlat,maxlon)
      real*4 datlons(maxlat,maxlon)
      real*4 datehtm(maxlat,maxlon)
      
c - The vector data
      character*80 card

c - All statistical data
c     i,j,k,l:
      real*8 stat(5,5,3,3)
c     j,k:
      integer*4 kstat(5,3)
c     j:
      character*20 units(5)

c - stat(i,j,k,l) :
c - kstat(j,k) :
c
c     i = 1 => Average
c     i = 2 => RMS
c     i = 3 => Min
c     i = 4 => Max
c     i = 5 => Standard Deviation
c
c     j = 1 => LAT, arcseconds
c     j = 2 => LON, arcseconds 
c     j = 3 => EHT, meters
c     j = 4 => LAT, meters
c     j = 4 => LON, meters
c 
c     k = 1 => Thinned vectors
c     k = 2 => Dropped vectors
c     k = 3 => All vectors
c
c     l = 1 => Bilinear Interpolation
c     l = 2 => Biquadratic Interpolation
c     l = 3 => Not currently used

c     l:
      real*8 vgrd(3),vgrdm(3),dd(3),ddm(3)

      character*4 type(3)
c - Note that "dd" means arcsec/arcsec/meters for lat/lon/eht
c - while "ddm" means meters/meters/meters for lat/lon/eht

      character*20 coord(3)

      real*8 fac(3,3)

c - The output data
      real*8 xla0(maxpts),xlo0(maxpts)
      real*8 dd0(maxpts),ddm0(maxpts),gi0(maxpts),gim0(maxpts)
      character*6 pid0(maxpts)

c --------------------------------------
c --------------------------------------
c --------------------------------------
c -------BEGIN GUTS OF PROGRAM----------
c --------------------------------------
c --------------------------------------
c --------------------------------------
      write(6,1001)
 1001 format('BEGIN program checkgrid.f')

c ------------------------------------------------------------------
c - Some required constants.
c ------------------------------------------------------------------
c - Length of Reference Vector on Paper, in CM (lorvopc).  Depends
c - on having the "MEASURE_UNITS" in .gmtdefaults set to "cm"
      lorvopc = 1.d0 
      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      re = 6371000.d0
      s2m = (1.d0/3600.d0)*d2r*re
      MultiplierLorvog = 2

      coord(1) = 'LATITUDE'
      coord(2) = 'LONGITUDE'
      coord(3) = 'ELLIPSOID HEIGHT'

      units(1) = 'arcseconds'
      units(2) = 'arcseconds'
      units(3) = 'meters'
      units(4) = 'meters'
      units(5) = 'meters'

c ------------------------------------------------------------------
c - Read in arguments from batch file
c ------------------------------------------------------------------
      read(5,'(a)')olddtm
      read(5,'(a)')newdtm
      read(5,'(a)')region
      read(5,'(a)')agridsec
      read(5,'(a)')mapflag

c ------------------------------------------------------------------
c - Generate the suffixes used in all our files
c ------------------------------------------------------------------
      read(agridsec,*)igridsec
      suffix1=trim(olddtm)//'.'//trim(newdtm)//'.'//trim(region)
      suffix2=trim(suffix1)//'.'//trim(agridsec)

      suffix2t04=trim(suffix2)//'.04'

      suffix3=trim(suffix2)//'.'//trim(mapflag)

c ------------------------------------------------------------------
c - Open the input, thinned, GMT-ready files
c - "t" meaning "thinned".  Briefly snoop the
c - first line of each file.  If it is empty,
c - then skip using that particular component.
c ------------------------------------------------------------------

c - Always maintain THIS order:
c - Lat/Seconds  1
c - Lon/Seconds  2
c - Eht/Meters   3
c - (Hor/Seconds  4)
c - (Hor/Meters   5)
c - Lat/Meters   6
c - Lon/Meters   7

      gfnvstcdlat = 'vstcdlat.'//trim(suffix2)
      open(21,file=gfnvstcdlat,status='old',form='formatted')
      write(6,1012)trim(gfnvstcdlat)

      gfnvstcdlon = 'vstcdlon.'//trim(suffix2)
      open(22,file=gfnvstcdlon,status='old',form='formatted')
      write(6,1012)trim(gfnvstcdlon)

      gfnvmtcdeht = 'vmtcdeht.'//trim(suffix2)
      open(23,file=gfnvmtcdeht,status='old',form='formatted')
      write(6,1012)trim(gfnvmtcdeht)

      gfnvmtcdlat = 'vmtcdlat.'//trim(suffix2)
      open(26,file=gfnvmtcdlat,status='old',form='formatted')
      write(6,1012)trim(gfnvmtcdlat)

      gfnvmtcdlon = 'vmtcdlon.'//trim(suffix2)
      open(27,file=gfnvmtcdlon,status='old',form='formatted')
      write(6,1012)trim(gfnvmtcdlon)


c - Note:  "nothinlat" means there were no thinned lat vectors,
c - and thus no ".b" grid made from thinned vectors.  As such,
c - anything having to do with latitude grids is skipped.  
c - Same for lon or eht.
      call nlines(21,nthinlat,nothinlat)
      call nlines(22,nthinlon,nothinlon)
      call nlines(23,nthineht,nothineht)
c - No need to do this for files 26/27 as the parallel 21 and 22

 1012 format(6x,'checkgrid.f: ',
     *'Opening input thinned vector file ',a)

c ------------------------------------------------------------------
c - Open the input, dropped, GMT-ready files
c - "d" meaning "dropped"
c ------------------------------------------------------------------
      gfnvsdcdlat = 'vsdcdlat.'//trim(suffix2)
      open(31,file=gfnvsdcdlat,status='old',form='formatted')
      write(6,1013)trim(gfnvsdcdlat)

      gfnvsdcdlon = 'vsdcdlon.'//trim(suffix2)
      open(32,file=gfnvsdcdlon,status='old',form='formatted')
      write(6,1013)trim(gfnvsdcdlon)

      gfnvmdcdeht = 'vmdcdeht.'//trim(suffix2)
      open(33,file=gfnvmdcdeht,status='old',form='formatted')
      write(6,1013)trim(gfnvmdcdeht)

      gfnvmdcdlat = 'vmdcdlat.'//trim(suffix2)
      open(36,file=gfnvmdcdlat,status='old',form='formatted')
      write(6,1013)trim(gfnvmdcdlat)

      gfnvmdcdlon = 'vmdcdlon.'//trim(suffix2)
      open(37,file=gfnvmdcdlon,status='old',form='formatted')
      write(6,1013)trim(gfnvmdcdlon)

 1013 format(6x,'checkgrid.f: ',
     *'Opening input dropped vector file ',a) 

c ------------------------------------------------------------------
c - Open the input, gridded-from-thinned .b files.  If the
c - thinned vector file is empty, skip trying to open the
c - related ".b" file.
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        bfnvstcdlat = 'vstcdlat.'//trim(suffix2t04)//'.b'
        open(11,file=bfnvstcdlat,status='old',form='unformatted')
        write(6,1015)trim(bfnvstcdlat)

        bfnvmtcdlat = 'vmtcdlat.'//trim(suffix2t04)//'.b'
        open(16,file=bfnvmtcdlat,status='old',form='unformatted')
        write(6,1015)trim(bfnvmtcdlat)
      endif

      if(.not.nothinlon)then
        bfnvstcdlon = 'vstcdlon.'//trim(suffix2t04)//'.b'
        open(12,file=bfnvstcdlon,status='old',form='unformatted')
        write(6,1015)trim(bfnvstcdlon)

        bfnvmtcdlon = 'vmtcdlon.'//trim(suffix2t04)//'.b'
        open(17,file=bfnvmtcdlon,status='old',form='unformatted')
        write(6,1015)trim(bfnvmtcdlon)
      endif

      if(.not.nothineht)then
        bfnvmtcdeht = 'vmtcdeht.'//trim(suffix2t04)//'.b'
        open(13,file=bfnvmtcdeht,status='old',form='unformatted')
        write(6,1015)trim(bfnvmtcdeht)
      endif

 1015 format(6x,'checkgrid.f: ',
     *'Opening input grid file ',a)

c ------------------------------------------------------------------
c - Open the output, interpolated-from-grid coordinate difference
c - vector files, GMT-ready for plotting.
c - If the input thinned vector file is empty (aka there is
c - no grid), skip 
c  ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnvsagilat = 'vsagilat.'//trim(suffix2)
        open(91,file=gfnvsagilat,status='new',form='formatted')
        write(6,1017)'lat',trim(gfnvsagilat)

        gfnvmagilat = 'vmagilat.'//trim(suffix2)
        open(96,file=gfnvmagilat,status='new',form='formatted')
        write(6,1017)'lat',trim(gfnvmagilat)

        gfnvstgilat = 'vstgilat.'//trim(suffix2)
        open(71,file=gfnvstgilat,status='new',form='formatted')
        write(6,1017)'lat',trim(gfnvstgilat)

        gfnvmtgilat = 'vmtgilat.'//trim(suffix2)
        open(76,file=gfnvmtgilat,status='new',form='formatted')
        write(6,1017)'lat',trim(gfnvmtgilat)

        gfnvsdgilat = 'vsdgilat.'//trim(suffix2)
        open(81,file=gfnvsdgilat,status='new',form='formatted')
        write(6,1017)'lat',trim(gfnvsdgilat)

        gfnvmdgilat = 'vmdgilat.'//trim(suffix2)
        open(86,file=gfnvmdgilat,status='new',form='formatted')
        write(6,1017)'lat',trim(gfnvmdgilat)
      endif



      if(.not.nothinlon)then
        gfnvsagilon = 'vsagilon.'//trim(suffix2)
        open(92,file=gfnvsagilon,status='new',form='formatted')
        write(6,1017)'lon',trim(gfnvsagilon)

        gfnvmagilon = 'vmagilon.'//trim(suffix2)
        open(97,file=gfnvmagilon,status='new',form='formatted')
        write(6,1017)'lon',trim(gfnvmagilon)

        gfnvstgilon = 'vstgilon.'//trim(suffix2)
        open(72,file=gfnvstgilon,status='new',form='formatted')
        write(6,1017)'lon',trim(gfnvstgilon)

        gfnvmtgilon = 'vmtgilon.'//trim(suffix2)
        open(77,file=gfnvmtgilon,status='new',form='formatted')
        write(6,1017)'lon',trim(gfnvmtgilon)

        gfnvsdgilon = 'vsdgilon.'//trim(suffix2)
        open(82,file=gfnvsdgilon,status='new',form='formatted')
        write(6,1017)'lon',trim(gfnvsdgilon)

        gfnvmdgilon = 'vmdgilon.'//trim(suffix2)
        open(87,file=gfnvmdgilon,status='new',form='formatted')
        write(6,1017)'lon',trim(gfnvmdgilon)
      endif



      if(.not.nothineht)then
        gfnvmagieht = 'vmagieht.'//trim(suffix2)
        open(93,file=gfnvmagieht,status='new',form='formatted')
        write(6,1017)'eht',trim(gfnvmagieht)

        gfnvmtgieht = 'vmtgieht.'//trim(suffix2)
        open(73,file=gfnvmtgieht,status='new',form='formatted')
        write(6,1017)'eht',trim(gfnvmtgieht)

        gfnvmdgieht = 'vmdgieht.'//trim(suffix2)
        open(83,file=gfnvmdgieht,status='new',form='formatted')
        write(6,1017)'eht',trim(gfnvmdgieht)
      endif

c - Added 2015 10 08

      if(.not.nothinlat .and. .not.nothinlon)then
        gfnvsagihor = 'vsagihor.'//trim(suffix2)
        open(94,file=gfnvsagihor,status='new',form='formatted')
        write(6,1017)'hor',trim(gfnvsagihor)

        gfnvmagihor = 'vmagihor.'//trim(suffix2)
        open(95,file=gfnvmagihor,status='new',form='formatted')
        write(6,1017)'hor',trim(gfnvmagihor)

        gfnvstgihor = 'vstgihor.'//trim(suffix2)
        open(74,file=gfnvstgihor,status='new',form='formatted')
        write(6,1017)'hor',trim(gfnvstgihor)

        gfnvmtgihor = 'vmtgihor.'//trim(suffix2)
        open(75,file=gfnvmtgihor,status='new',form='formatted')
        write(6,1017)'hor',trim(gfnvmtgihor)

        gfnvsdgihor = 'vsdgihor.'//trim(suffix2)
        open(84,file=gfnvsdgihor,status='new',form='formatted')
        write(6,1017)'hor',trim(gfnvsdgihor)

        gfnvmdgihor = 'vmdgihor.'//trim(suffix2)
        open(85,file=gfnvmdgihor,status='new',form='formatted')
        write(6,1017)'hor',trim(gfnvmdgihor)
      endif

 1017 format(6x,'checkgrid.f: ',
     *'Opening output grid-interpolated ',a,' vector file :',a) 

c ------------------------------------------------------------------
c - Open the output, differential, GMT-ready files for
c - plotting. THINNED.  If the input thinned vector file
c - is empty, skip 
c  ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnvstddlat = 'vstddlat.'//trim(suffix2)
        open(41,file=gfnvstddlat,status='new',form='formatted')
        write(6,1014)'lat',trim(gfnvstddlat)

        gfnvmtddlat = 'vmtddlat.'//trim(suffix2)
        open(46,file=gfnvmtddlat,status='new',form='formatted')
        write(6,1014)'lat',trim(gfnvmtddlat)
      endif

      if(.not.nothinlon)then
        gfnvstddlon = 'vstddlon.'//trim(suffix2)
        open(42,file=gfnvstddlon,status='new',form='formatted')
        write(6,1014)'lon',trim(gfnvstddlon)

        gfnvmtddlon = 'vmtddlon.'//trim(suffix2)
        open(47,file=gfnvmtddlon,status='new',form='formatted')
        write(6,1014)'lon',trim(gfnvmtddlon)
      endif

      if(.not.nothineht)then
        gfnvmtddeht = 'vmtddeht.'//trim(suffix2)
        open(43,file=gfnvmtddeht,status='new',form='formatted')
        write(6,1014)'eht',trim(gfnvmtddeht)
      endif

      if(.not.nothinlon .and. .not.nothinlat)then
        gfnvstddhor = 'vstddhor.'//trim(suffix2)
        open(44,file=gfnvstddhor,status='new',form='formatted')
        write(6,1014)'hor',trim(gfnvstddhor)

        gfnvmtddhor = 'vmtddhor.'//trim(suffix2)
        open(45,file=gfnvmtddhor,status='new',form='formatted')
        write(6,1014)'hor',trim(gfnvmtddhor)
      endif

c ------------------------------------------------------------------
c - Open the output, differential, GMT-ready files for
c - plotting. DROPPED. 
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnvsdddlat = 'vsdddlat.'//trim(suffix2)
        open(51,file=gfnvsdddlat,status='new',form='formatted')
        write(6,1014)'lat',trim(gfnvsdddlat)

        gfnvmdddlat = 'vmdddlat.'//trim(suffix2)
        open(56,file=gfnvmdddlat,status='new',form='formatted')
        write(6,1014)'lat',trim(gfnvmdddlat)
      endif

      if(.not.nothinlon)then
        gfnvsdddlon = 'vsdddlon.'//trim(suffix2)
        open(52,file=gfnvsdddlon,status='new',form='formatted')
        write(6,1014)'lon',trim(gfnvsdddlon)

        gfnvmdddlon = 'vmdddlon.'//trim(suffix2)
        open(57,file=gfnvmdddlon,status='new',form='formatted')
        write(6,1014)'lon',trim(gfnvmdddlon)
      endif

      if(.not.nothineht)then
        gfnvmdddeht = 'vmdddeht.'//trim(suffix2)
        open(53,file=gfnvmdddeht,status='new',form='formatted')
        write(6,1014)'eht',trim(gfnvmdddeht)
      endif

      if(.not.nothinlat .and. .not.nothinlon)then
        gfnvsdddhor = 'vsdddhor.'//trim(suffix2)
        open(54,file=gfnvsdddhor,status='new',form='formatted')
        write(6,1014)'hor',trim(gfnvsdddhor)

        gfnvmdddhor = 'vmdddhor.'//trim(suffix2)
        open(55,file=gfnvmdddhor,status='new',form='formatted')
        write(6,1014)'hor',trim(gfnvmdddhor)
      endif

c ------------------------------------------------------------------
c - Open the output, differential, GMT-ready files for
c - plotting. ALL.
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnvsaddlat = 'vsaddlat.'//trim(suffix2)
        open(61,file=gfnvsaddlat,status='new',form='formatted')
        write(6,1014)'lat',trim(gfnvsaddlat)

        gfnvmaddlat = 'vmaddlat.'//trim(suffix2)
        open(66,file=gfnvmaddlat,status='new',form='formatted')
        write(6,1014)'lat',trim(gfnvmaddlat)
      endif

      if(.not.nothinlon)then
        gfnvsaddlon = 'vsaddlon.'//trim(suffix2)
        open(62,file=gfnvsaddlon,status='new',form='formatted')
        write(6,1014)'lon',trim(gfnvsaddlon)

        gfnvmaddlon = 'vmaddlon.'//trim(suffix2)
        open(67,file=gfnvmaddlon,status='new',form='formatted')
        write(6,1014)'lon',trim(gfnvmaddlon)
      endif

      if(.not.nothineht)then
        gfnvmaddeht = 'vmaddeht.'//trim(suffix2)
        open(63,file=gfnvmaddeht,status='new',form='formatted')
        write(6,1014)'eht',trim(gfnvmaddeht)
      endif

      if(.not.nothinlat .and. .not.nothinlon)then
        gfnvsaddhor = 'vsaddhor.'//trim(suffix2)
        open(64,file=gfnvsaddhor,status='new',form='formatted')
        write(6,1014)'hor',trim(gfnvsaddhor)

        gfnvmaddhor = 'vmaddhor.'//trim(suffix2)
        open(65,file=gfnvmaddhor,status='new',form='formatted')
        write(6,1014)'hor',trim(gfnvmaddhor)
      endif

 1014 format(6x,'checkgrid.f: ',
     *'Opening output differential ',a,' vector file :',a) 

c ------------------------------------------------------------------
c - Each region has officially chosen boundaries (which may
c - or may not agree with the MAP boundaries).  Get the
c - official grid boundaries here.  See DRU-11, p. 126
c ------------------------------------------------------------------
      call getgridbounds(region,glamx,glamn,glomn,glomx)

      write(6,1004)trim(region),glamn,glamx,glomn,glomx
 1004 format(6x,'checkgrid.f: Region= ',a,/,
     *       6x,'checkgrid.f: North = ',f12.6,/,
     *       6x,'checkgrid.f: South = ',f12.6,/,
     *       6x,'checkgrid.f: West  = ',f12.6,/,
     *       6x,'checkgrid.f: East  = ',f12.6)

      write(6,8002)
 8002 format(50('*'),/,
     *6x,'checkgrid.f: BEGIN STATISTICAL REPORT ',
     *'(grid minus true vector diffs)')

c -------------------------------------------------------
c - Read the ".b" grids into RAM
c - 
c - See DRU-11, p. 140 for the following philosophy:
c   
c   Because the final grids in lat/lon will ONLY be
c   in arcseconds, all statistics should be about
c   arcseconds, with CONVERSION to meters on the fly,
c   and NOT about meter vectors compared to meter grids.
c -------------------------------------------------------
      do 1 i=1,3

        if(i.eq.1 .and. nothinlat)goto 1
        if(i.eq.2 .and. nothinlon)goto 1
        if(i.eq.3 .and. nothineht)goto 1

        ifil = 10+i
        read(ifil)glamn,glomn,dla,dlo,nla,nlo,ikind
        do 2 j=1,nla
          if(i.eq.1)read(ifil)(datlats(j,k),k=1,nlo)
          if(i.eq.2)read(ifil)(datlons(j,k),k=1,nlo)
          if(i.eq.3)read(ifil)(datehtm(j,k),k=1,nlo)

    2   continue
    1 continue
      glamx = glamn + (nla-1)*dla
      glomx = glomn + (nlo-1)*dlo

c -------------------------------------------------------
c - Go through the vectors.  Do lat first, then lon,
c - then eht.  Compute DDlat, DDlon and DDeht.
c - Compute region-wide statistics for:
c -    thinned-versus-gridded
c -    dropped-versus-gridded
c -    all-versus-gridded
c - Spit out the grid interpolated lat/lon/eht values,
c - as well as the double differences:
c - Spit out the DDlat, DDlon and DDeht values to
c - output files, for either thinned, dropped or all.
c -------------------------------------------------------

c - stat(i,j,k,l) :
c - kstat(j,k) :
c
c     i = 1 => Average
c     i = 2 => RMS
c     i = 3 => Min
c     i = 4 => Max
c     i = 5 => Standard Deviation
c
c     j = 1 => LAT, arcseconds
c     j = 2 => LON, arcseconds 
c     j = 3 => EHT, meters
c     j = 4 => LAT, meters <- Computed by converting from arcseconds
c     j = 4 => LON, meters <- Computed by converting from arcseconds
c 
c     k = 1 => Thinned vectors
c     k = 2 => Dropped vectors
c     k = 3 => All vectors
c
c     l = 1 => Bilinear Interpolation
c     l = 2 => Biquadratic Interpolation
c     l = 3 => Bicubic Spline Interpolation

c - Zero stats
      do 3002 i=1,5
c       do 3003 j=1,3 
        do 3003 j=1,5 
          do 3004 k=1,3
            kstat(j,k) = 0
            do 3005 l=1,3
              stat(i,j,k,l) = 0.d0
              if(i.eq.3)stat(i,j,k,l) = 99999.d0
              if(i.eq.4)stat(i,j,k,l) =-99999.d0
 3005       continue
 3004     continue
 3003   continue
 3002 continue

      type(1) = 'THIN'
      type(2) = 'DROP'
      type(3) = 'ALL '
   

c -------------------------------------------------------------
c -------------------------------------------------------------
c -------------------------------------------------------------
c - MAIN LOOP
c -------------------------------------------------------------
c -------------------------------------------------------------
c -------------------------------------------------------------

c In the loops below, for j,k=
c 1,1 = Lat(s)/Thinned
c 1,2 = Lat(s)/Dropped
c 2,1 = Lon(s)/Thinned
c 2,2 = Lon(s)/Dropped
c 3,1 = Eht(s)/Thinned
c 1,2 = Eht(s)/Dropped

c - j=4 and 5, being Lat(m) and Lon(m) will be converted ON THE FLY
c - from j=1 and 2 values.
c 4,1 = Lat(s)/Thinned
c 4,2 = Lat(s)/Dropped
c 5,1 = Lon(s)/Thinned
c 5,2 = Lon(s)/Dropped

      do 2001 j=1,3

        avegiprime = 0.d0
        avegimeter = 0.d0

        if(j.eq.1 .and. nothinlat)goto 2001
        if(j.eq.2 .and. nothinlon)goto 2001
        if(j.eq.3 .and. nothineht)goto 2001

c - Now spin over thinned, then dropped vectors
        itot = 0

        do 2002 k=1,2
          if(k.eq.1)ifile = 20+j   ! Thinned Vectors
          if(k.eq.2)ifile = 30+j   ! Dropped Vectors

          iread = 0
          igood = 0
  101     read(ifile,'(a)',end=103)card
            iread = iread + 1

c - CRITICAL, pull true values of ARCSECONDS for lat/lon
c - but METERS for eht
            if(j.eq.1 .or. j.eq.2)read(card, 102)xlo,xla,vvec
            if(j.eq.3            )read(card,1102)xlo,xla,vvec

c - This shouldn't happen, but in case a vector 
c - is not inside the grid, skip it
            if(xla.gt.glamx .or. xla.lt.glamn .or.
     *         xlo.gt.glomx .or. xlo.lt.glomn)then
              goto 101
            endif
            igood = igood + 1
            itot = itot + 1

c - Hold the lat, lon and PID in RAM until its time to 
c - spit them out.
            xla0(itot) = xla
            xlo0(itot) = xlo
            pid0(itot) = card(74:79)

c - Do the interpolations
c - "vgrd()" stores sec/sec/met for lat/lon/eht
c - "vgrdm()" stores meters for everything

c - Bilinear to get vgrd(1)
            if(j.eq.1)call bilin(datlats,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(1))
            if(j.eq.2)call bilin(datlons,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(1))
            if(j.eq.3)call bilin(datehtm,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(1))

c - Biquadratic to get vgrd(2)
            if(j.eq.1)call biquad(datlats,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(2))
            if(j.eq.2)call biquad(datlons,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(2))
            if(j.eq.3)call biquad(datehtm,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(2))

c - Biquadratic to get vgrd(2)
            if(j.eq.1)call bicubic(datlats,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(3))
            if(j.eq.2)call bicubic(datlons,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(3))
            if(j.eq.3)call bicubic(datehtm,glamn,glomn,dla,dlo,
     *      nla,nlo,maxlat,maxlon,xla,xlo,vgrd(3))

c - Differences grd minus true (lat, lon in arcseconds; eht in meters)
            do 808 l = 1,3
              dd(l)  = vgrd(l) - vvec

c - Convert seconds to meters but don't lose the seconds either
              if(j.eq.1)then
                vgrdm(l) = vgrd(l) * s2m
                ddm(l)   =   dd(l) * s2m
              elseif(j.eq.2)then
                coslat = dcos(xla*d2r)
                vgrdm(l) = vgrd(l) * s2m * coslat
                ddm(l)   =   dd(l) * s2m * coslat
              else
                vgrdm(l) = vgrd(l)
                ddm(l)   = dd(l)
              endif

c*********************************************************
c - ALL *STATISTICS* in their primary units
c - (arcsec for lat/lon, meters for eht), but then
c - converted to meters/meters for lat/lon after the
c - fact.
c - will be in arcseconds or meters appropriately.
c - These stats are all for DOUBLE DIFFERENCES
c 
c - However, I do need to tally the average absolute
c - values of lat(sec), lat(m), lon(sec), lon(m) and eht(m) of
c - grid-interpolated vectors so I can scale their vector 
c - plots correctly.  We'll hack that into here...
c*********************************************************

c - k=1,2 = thin/drop; k=3 = all
c - j=1,2,3 for lat-sec,lon-sec,eht-met
c - j=4,5 for lat-met, lon-met

c - Tally average 
              stat(1,j,k,l) = stat(1,j,k,l) + dd(l)
              stat(1,j,3,l) = stat(1,j,3,l) + dd(l)
              if(j.lt.3)then
                stat(1,j+3,k,l) = stat(1,j+3,k,l) + ddm(l)
                stat(1,j+3,3,l) = stat(1,j+3,3,l) + ddm(l)
              endif

c - Tally RMS:    
              stat(2,j,k,l) = stat(2,j,k,l) + dd(l)**2
              stat(2,j,3,l) = stat(2,j,3,l) + dd(l)**2
              if(j.lt.3)then
                stat(2,j+3,k,l) = stat(2,j+3,k,l) + ddm(l)**2
                stat(2,j+3,3,l) = stat(2,j+3,3,l) + ddm(l)**2
              endif
c - Tally Min:    
              if(dd(l).lt.stat(3,j,k,l))stat(3,j,k,l)=dd(l)
              if(dd(l).lt.stat(3,j,3,l))stat(3,j,3,l)=dd(l)
              if(j.lt.3)then
                if(ddm(l).lt.stat(3,j+3,k,l))stat(3,j+3,k,l)=ddm(l)
                if(ddm(l).lt.stat(3,j+3,3,l))stat(3,j+3,3,l)=ddm(l)
              endif
               
c - Tally Max:    
              if(dd(l).gt.stat(4,j,k,l))stat(4,j,k,l)=dd(l)
              if(dd(l).gt.stat(4,j,3,l))stat(4,j,3,l)=dd(l)
              if(j.lt.3)then
                if(ddm(l).gt.stat(4,j+3,k,l))stat(4,j+3,k,l)=ddm(l)
                if(ddm(l).gt.stat(4,j+3,3,l))stat(4,j+3,3,l)=ddm(l)
              endif

  808       continue

c - HACK / CHOICE:  For now, use biquadratically interpolated
c - data as the official output.  Note that
c - "dd0" stores ARCSECONDS for lat or lon and METERS for eht
c - but "ddm0" stores METERS for everything
c             dd0(igood)  = dd(2)
c             ddm0(igood) = ddm(2)

c - Double Differences:
              dd0(itot)  = dd(2)
              ddm0(itot) = ddm(2)
c - Grid Interpolated:
              gi0(itot)  = vgrd(2)
              gim0(itot) = vgrdm(2) 

              avegiprime = avegiprime + dabs(gi0(itot))
              avegimeter = avegimeter + dabs(gim0(itot))

c - Tally counts
c -   Either Thinned or Dropped:
            kstat(j,k)=kstat(j,k) + 1
            if(j.lt.3)then
              kstat(j+3,k)=kstat(j+3,k) + 1
            endif
c -   All:
            kstat(j,3)=kstat(j,3) + 1
            if(j.lt.3)then
              kstat(j+3,3)=kstat(j+3,3) + 1
            endif

          goto 101
  103     continue

 2002   continue

c - Double check that the counts of thinned and dropped
c - add up to the count for all.  
        kthin = kstat(j,1)
        kdrop = kstat(j,2)
        kall  = kstat(j,3)
c - Won't do this for j=4/5 as they should parallel j=1/2

        avegiprime = avegiprime / dble(kall)
        avegimeter = avegimeter / dble(kall)

c       write(6,*) j,kthin 
c       write(6,*) j,kdrop 
c       write(6,*) j,kall  
        if(kall.ne.kthin+kdrop)then
          write(6,*) ' Thin+Drop .DNE. All => STOP'
          stop
        endif
        if(itot.ne.kall)then
          write(6,*) ' itot .DNE. All => STOP'
          stop
        endif

c - Finalize stats for k=1,3 (thin/drop/all)
        do 809 k=1,3
          fac(j,k) = dble(kstat(j,k))/dble(kstat(j,k)-1)
          if(j.lt.3)then
            fac(j+3,k) = dble(kstat(j+3,k))/dble(kstat(j+3,k)-1)
          endif
          do 810 l=1,3
            stat(1,j,k,l)=stat(1,j,k,l)/kstat(j,k)
            stat(2,j,k,l)=dsqrt(stat(2,j,k,l)/kstat(j,k))
            stat(5,j,k,l)=dsqrt(fac(j,k)*
     *      (stat(2,j,k,l)**2 - stat(1,j,k,l)**2))

            if(j.lt.3)then
              stat(1,j+3,k,l)=stat(1,j+3,k,l)/kstat(j+3,k)
              stat(2,j+3,k,l)=dsqrt(stat(2,j+3,k,l)/kstat(j+3,k))
              stat(5,j+3,k,l)=dsqrt(fac(j+3,k)*
     *        (stat(2,j+3,k,l)**2 - stat(1,j+3,k,l)**2))
            endif

  810     continue
  809   continue


c -----------------------
c - At this point we've finished collecting statistics for
c - one type of coordinate (lat, lon or eht), and can spit
c - out the data to files.
c - 
c - OUTPUT the "vgrd"      values to the appropriate VECTOR FILE
c - OUTPUT the "vgrd-vvec" values to the appropriate VECTOR FILE
c -
c - Use the RMS value to compute scales needed for our output vector file.
c - Why not AVE?  Because the AVE is expected to be VERY close to zero
c - but RMS better represents overall magnitude of disagreement.  
c -----------------------
c
c - 2,j,3,2 = rms , lat-sec/lon-sec/eht-met/lat-met/lon-met , all , biquad, double differenced
c Convert the RMS to cm to go along with all over vector plots heretofore
        rms0prime = stat(2,j,3,2)
        lorvogprime = onzd2(MultiplierLorvog*rms0prime)
c       iqprime = floor(log10(rms0prime))
c       qqprime = 10.d0**(iqprime  )
c       lorvogprime = MultiplierLorvog*qqprime*nint(rms0prime/qqprime)

        gprime2pc = lorvopc / lorvogprime
        scaledd(j) = gprime2pc
        basedd(j) = rms0prime
        if(j.lt.3)then
          rms0meters = stat(2,j+3,3,2)
          lorvogmeters = onzd2(MultiplierLorvog*rms0meters)
c         iqmeters = floor(log10(rms0meters))
c         qqmeters = 10.d0**(iqmeters  )
c         lorvogmeters = MultiplierLorvog*
c    *                   qqmeters*nint(rms0meters/qqmeters)
          gmeters2pc = lorvopc / lorvogmeters
          scaledd(j+3) = gmeters2pc
          basedd(j+3) = rms0meters
        endif
        lorvog(j) = lorvogprime
        if(j.lt.3)lorvog(j+3) = lorvogmeters

c - for the grid interpolated guys...
c       iqprimegi = floor(log10(avegiprime))
c       qqprimegi = 10.d0**(iqprimegi  )
c       lorvogprimegi = MultiplierLorvog*
c    *                  qqprimegi*nint(avegiprime/qqprimegi)
        lorvogprimegi = onzd2(MultiplierLorvog*avegiprime)
c       write(6,*)'MultiplierLorvog = ',MultiplierLorvog
c       write(6,*)'avegiprime       = ',avegiprime
c       write(6,*)'lorvogprimegi    = ',lorvogprimegi
        gprime2pcgi = lorvopc / lorvogprimegi
        scalegi(j) = gprime2pcgi
        basegi(j) = avegiprime
        if(j.lt.3)then
          lorvogmetersgi = onzd2(MultiplierLorvog*avegimeter)
c         iqmetersgi = floor(log10(avegimeter))
c         qqmetersgi = 10.d0**(iqmetersgi  )
c         lorvogmetersgi = MultiplierLorvog*
c    *                     qqmetersgi*nint(avegimeter/qqmetersgi)
          gmeters2pcgi = lorvopc / lorvogmetersgi
          scalegi(j+3) = gmeters2pcgi
          basegi(j+3) = avegimeter
        endif
        lorvoggi(j) = lorvogprimegi
        if(j.lt.3)lorvoggi(j+3) = lorvogmetersgi

c ------------------------------------------------------------------
c - pvlon and pvlat are the percentage of the total lon/lat
c - span of the plot, from which the reference vector
c - begins, starting with the Lower Left corner
c ------------------------------------------------------------------
      pvlon = 10.d0
      pvlat = 10.d0

      pvlat = (pvlat / 100.d0)
      pvlon = (pvlon / 100.d0)

c - Set the output file number
        ifthin = 40+j
        ifdrop = 50+j
        ifall  = 60+j

c - Spin over all "grid minus vector" values, and spit the differences
c - into fresh vector files.  Note that THIN data is first, then DROPPED
        do 813 ipt=1,kall
          if(ipt.le.kthin)then
            ifout1 = ifthin
          else
            ifout1 = ifdrop
          endif
          ifout2 = ifall

c - Get the Azimuth for this point, double differenced version:
          if(j.eq.1 .or. j.eq.3)then
            if(dd0(ipt).lt.0)then
              az=180.d0
             else
               az=0.d0
             endif
           else
             if(dd0(ipt).lt.0)then
               az=270.d0
             else
               az=90.d0
             endif
           endif

c - Get the Azimuth for this point, grid interpolated version:
          if(j.eq.1 .or. j.eq.3)then
            if(gi0(ipt).lt.0)then
              azgi=180.d0
             else
               azgi=0.d0
             endif
           else
             if(gi0(ipt).lt.0)then
               azgi=270.d0
             else
               azgi=90.d0
             endif
           endif

c - Get the scaled value for this point
c - Because we aren't looping over j through 4/5, we catch
c - the j=4/5 values while hitting j=1/2:
           vcprime = dabs(dd0(ipt)*gprime2pc)
           if(j.lt.3)then
             vcmeters = dabs(ddm0(ipt) * gmeters2pc)
           endif

           giprime = dabs(gi0(ipt)*gprime2pcgi)
           if(j.lt.3)then
             gimeters = dabs(gim0(ipt) * gmeters2pcgi)
           endif

c ------------------------
c - Spit out fresh "grid interpolated" as well as "double difference" vectors
c ------------------------

          if(j.eq.1 .or. j.eq.2)then
c - Write out for j=1,2 to thinned/dropped in primary units, double differenced:            
            write(ifout1   ,140)xlo0(ipt),xla0(ipt),az,vcprime,
     *      dd0(ipt),ddm0(ipt),pid0(ipt)
c - Write out for j=1,2 to thinned/dropped in primary units, grid-interpolated:
            write(ifout1+30,140)xlo0(ipt),xla0(ipt),azgi,giprime,
     *      gi0(ipt),gim0(ipt),pid0(ipt)


c - Write out for j=1,2 to all in primary units, double differenced:            
            write(ifout2   ,140)xlo0(ipt),xla0(ipt),az,vcprime,
     *      dd0(ipt),ddm0(ipt),pid0(ipt)
c - Write out for j=1,2 to all in primary units, grid-interpolated:
            write(ifout2+30,140)xlo0(ipt),xla0(ipt),azgi,giprime,
     *      gi0(ipt),gim0(ipt),pid0(ipt)
   

c - Write out for j=4,5 to thinned/dropped in meters, double differenced:
            write(ifout1+5 ,140)xlo0(ipt),xla0(ipt),az,vcmeters,
     *      dd0(ipt),ddm0(ipt),pid0(ipt)
c - Write out for j=4,5 to thinned/dropped in meters, grid interpolated:
            write(ifout1+35,140)xlo0(ipt),xla0(ipt),azgi,gimeters,
     *      gi0(ipt),gim0(ipt),pid0(ipt)


c - Write out for j=4,5 to all in meters, double differenced:
            write(ifout2+5 ,140)xlo0(ipt),xla0(ipt),az,vcmeters,
     *      dd0(ipt),ddm0(ipt),pid0(ipt)
c - Write out for j=4,5 to all in meters, grid interpolated:
            write(ifout2+35,140)xlo0(ipt),xla0(ipt),azgi,gimeters,
     *      gi0(ipt),gim0(ipt),pid0(ipt)



          endif

          if(j.eq.3)then
c - Write out for j=3 to thinned/dropped in primary units, double differenced:
            write(ifout1   ,140)xlo0(ipt),xla0(ipt),az,vcprime,
     *      0.d0    ,ddm0(ipt),pid0(ipt)
c - Write out for j=3 to thinned/dropped in primary units, grid interpolated:
            write(ifout1+30,140)xlo0(ipt),xla0(ipt),azgi,giprime,
     *      0.d0    ,gim0(ipt),pid0(ipt)


c - Write out for j=3 to all in primary units, double differenced:
            write(ifout2   ,140)xlo0(ipt),xla0(ipt),az,vcprime,
     *      0.d0    ,ddm0(ipt),pid0(ipt)
c - Write out for j=3 to all in primary units, grid interpolated:
            write(ifout2+30,140)xlo0(ipt),xla0(ipt),azgi,giprime,
     *      0.d0    ,gim0(ipt),pid0(ipt)

          endif

  813   continue

c 140 format(f16.10,1x,f15.10,1x,f6.2,1x,f12.2,1x,f5.1,1x,f9.5,1x,a6)
  140 format(f16.10,1x,f15.10,1x,f6.2,1x,f12.2,1x,f9.5,1x,f9.3,1x,a6)


c ------------------------------------------------------------------
c - Write out a clear report.
c ------------------------------------------------------------------
        write(6,8000)trim(coord(j)),units(j)
        do 2003 k=1,3
          write(6,8001)type(k),
     *    (kstat(j,k),l=1,3),
     *    (stat(1,j,k,l),l=1,3),
     *    (stat(2,j,k,l),l=1,3),
     *    (stat(5,j,k,l),l=1,3),
     *    (stat(3,j,k,l),l=1,3),
     *    (stat(4,j,k,l),l=1,3)
 2003   continue

        if(j.lt.3)then
          write(6,8000)trim(coord(j)),units(j+3)
          do 2004 k=1,3
            write(6,8001)type(k),
     *      (kstat(j+3,k),l=1,3),
     *      (stat(1,j+3,k,l),l=1,3),
     *      (stat(2,j+3,k,l),l=1,3),
     *      (stat(5,j+3,k,l),l=1,3),
     *      (stat(3,j+3,k,l),l=1,3),
     *      (stat(4,j+3,k,l),l=1,3)
 2004     continue
        endif

 2001 continue

c 102 format(f16.10,1x,f15.10,1x,  6x,1x,  12x,1x,  5x,1x,f9.5,1x,6x)

c - To pull arcseconds:
  102 format(f16.10,1x,f15.10,1x,  6x,1x,  12x,1x,f9.5,1x,  9x,1x,a6)
c - To pull meters:
 1102 format(f16.10,1x,f15.10,1x,  6x,1x,  12x,1x,  9x,1x,f9.3,1x,a6)


 8000 format(
     *//,25x,a,' in ',a,/,
     *'Type',1x,'Stat',
     *7x,'Bilinear',5x,'Biquadratic',
     *9x,'Bicubic       ')
 8001 format(a4,1x,
     *'Num:',3(i15   ,1x),/,
     *5x,'Ave:',3(f15.6,1x),/,
     *5x,'RMS:',3(f15.6,1x),/,
     *5x,'STD:',3(f15.6,1x),/,
     *5x,'MIN:',3(f15.6,1x),/,
     *5x,'MAX:',3(f15.6,1x),/,
     *50('-'))

      write(6,8003)
 8003 format(
     *6x,'checkgrid.f: END STATISTICAL REPORT ',
     *'(grid minus true vector diffs)',/,
     *50('*'))


c -----------------------------------------------
c - CREATE THE HORIZONTAL VECTOR FILES
c - 2015 10 08
c -----------------------------------------------
      write(6,8004)
 8004 format(
     *6x,'checkgrid.f: Generating HORIZONTAL vector files',
     *' from lat/lon vector files')
 5072 format('FATAL in checkgrid: Mismatched PID for hor')
 5073 format('FATAL in checkgrid: Mismatched LON for hor')
 5074 format('FATAL in checkgrid: Mismatched LAT for hor')

      do 5080 i=1,5
        if(i.eq.3)goto 5080
c       write(6,*)i,'basedd() = ',basedd(i)
 5080 continue
      do 5081 i=1,5
        if(i.eq.3)goto 5081
c       write(6,*)i,'basegi() = ',basegi(i)
 5081 continue

      baseddhors = sqrt(basedd(1)**2+basedd(2)**2)
      baseddhorm = sqrt(basedd(4)**2+basedd(5)**2)
      basegihors = sqrt(basegi(1)**2+basegi(2)**2)
      basegihorm = sqrt(basegi(4)**2+basegi(5)**2)

c     lorvog(6) = baseddhors
c     lorvog(7) = baseddhorm

c     lorvoggi(6) = basegihors
c     lorvoggi(7) = basegihorm

c     write(6,*) ' baseddhors = ',baseddhors
c     write(6,*) ' baseddhorm = ',baseddhorm
c     write(6,*) ' basegihors = ',basegihors
c     write(6,*) ' basegihorm = ',basegihorm

      lorvoghorddm = onzd2(MultiplierLorvog*baseddhorm)
c     iqhorddm = floor(log10(baseddhorm))
c     qqhorddm = 10.d0**(iqhorddm  )
c     lorvoghorddm = MultiplierLorvog*qqhorddm*nint(baseddhorm/qqhorddm)
      gm2pchordd = lorvopc / lorvoghorddm

      lorvoghordds = onzd2(MultiplierLorvog*baseddhors)
c     iqhordds = floor(log10(baseddhors))
c     qqhordds = 10.d0**(iqhordds  )
c     lorvoghordds = MultiplierLorvog*qqhordds*nint(baseddhors/qqhordds)
      gs2pchordd = lorvopc / lorvoghordds

      lorvoghorgim = onzd2(MultiplierLorvog*basegihorm)
c     iqhorgim = floor(log10(basegihorm))
c     qqhorgim = 10.d0**(iqhorgim  )
c     lorvoghorgim = MultiplierLorvog*qqhorgim*nint(basegihorm/qqhorgim)
      gm2pchorgi = lorvopc / lorvoghorgim

      lorvoghorgis = onzd2(MultiplierLorvog*basegihors)
c     iqhorgis = floor(log10(basegihors))
c     qqhorgis = 10.d0**(iqhorgis  )
c     lorvoghorgis = MultiplierLorvog*qqhorgis*nint(basegihors/qqhorgis)
      gs2pchorgi = lorvopc / lorvoghorgis

      lorvog(6) = lorvoghordds
      lorvog(7) = lorvoghorddm

      lorvoggi(6) = lorvoghorgis
      lorvoggi(7) = lorvoghorgim

      convgs2pcddlat = lorvopc / lorvog(1) 
      convgs2pcddlon = lorvopc / lorvog(2) 

      convgm2pcddlat = lorvopc / lorvog(4) 
      convgm2pcddlon = lorvopc / lorvog(5) 

      convgs2pcgilat = lorvopc / lorvoggi(1) 
      convgs2pcgilon = lorvopc / lorvoggi(2) 

      convgm2pcgilat = lorvopc / lorvoggi(4) 
      convgm2pcgilon = lorvopc / lorvoggi(5) 

c     goto 8070
c     write(6,*) ' Way #1 : '
c     write(6,*) ' convgs2pcddlat = ',convgs2pcddlat 
c     write(6,*) ' convgs2pcddlon = ',convgs2pcddlon 
c     write(6,*) ' convgm2pcddlat = ',convgm2pcddlat 
c     write(6,*) ' convgm2pcddlon = ',convgm2pcddlon 
c     write(6,*) ' convgs2pcgilat = ',convgs2pcgilat 
c     write(6,*) ' convgs2pcgilon = ',convgs2pcgilon 
c     write(6,*) ' convgm2pcgilat = ',convgm2pcgilat 
c     write(6,*) ' convgm2pcgilon = ',convgm2pcgilon 
c8070 continue

      convgs2pcddlat = scaledd(1)
      convgs2pcddlon = scaledd(2)
      convgm2pcddlat = scaledd(4)
      convgm2pcddlon = scaledd(5)
      convgs2pcgilat = scalegi(1)
      convgs2pcgilon = scalegi(2)
      convgm2pcgilat = scalegi(4)
      convgm2pcgilon = scalegi(5)

c     goto 8071
c     write(6,*) ' Way #2 : '
c     write(6,*) ' convgs2pcddlat = ',convgs2pcddlat 
c     write(6,*) ' convgs2pcddlon = ',convgs2pcddlon 
c     write(6,*) ' convgm2pcddlat = ',convgm2pcddlat 
c     write(6,*) ' convgm2pcddlon = ',convgm2pcddlon 
c     write(6,*) ' convgs2pcgilat = ',convgs2pcgilat 
c     write(6,*) ' convgs2pcgilon = ',convgs2pcgilon 
c     write(6,*) ' convgm2pcgilat = ',convgm2pcgilat 
c     write(6,*) ' convgm2pcgilon = ',convgm2pcgilon 
c8071 continue

      convgs2pcddhor = dsqrt(convgs2pcddlat**2 + convgs2pcddlon**2)
      convgm2pcddhor = dsqrt(convgm2pcddlat**2 + convgm2pcddlon**2)
      convgs2pcgihor = dsqrt(convgs2pcgilat**2 + convgs2pcgilon**2)
      convgm2pcgihor = dsqrt(convgm2pcgilat**2 + convgm2pcgilon**2)

c     goto 8072
c     write(6,*) ' Ways #1 or 2 : '
c     write(6,*) ' convgs2pcddhor = ',convgs2pcddhor
c     write(6,*) ' convgm2pcddhor = ',convgm2pcddhor
c     write(6,*) ' convgs2pcgihor = ',convgs2pcgihor
c     write(6,*) ' convgm2pcgihor = ',convgm2pcgihor
c8072 continue

      convgs2pcddhor = gs2pchordd
      convgm2pcddhor = gm2pchordd
      convgs2pcgihor = gs2pchorgi
      convgm2pcgihor = gm2pchorgi

c     goto 8073
c     write(6,*) ' Way #3:'
c     write(6,*) ' convgs2pcddhor = ',convgs2pcddhor
c     write(6,*) ' convgm2pcddhor = ',convgm2pcddhor
c     write(6,*) ' convgs2pcgihor = ',convgs2pcgihor
c     write(6,*) ' convgm2pcgihor = ',convgm2pcgihor
c8073 continue

      do 5070 i=40,90,10
        do 5071 j=1,2
          if(i.le.60 .and. j.eq.1)conv = convgs2pcddhor
          if(i.le.60 .and. j.eq.2)conv = convgm2pcddhor
          if(i.ge.70 .and. j.eq.1)conv = convgs2pcgihor
          if(i.ge.70 .and. j.eq.2)conv = convgm2pcgihor

          ilat = i+1 + (j-1)*5
          ilon = i+2 + (j-1)*5
          ihor = i+4 + (j-1)*1
c         write(6,*) ilat,ilon,ihor
          rewind(ilat)
          rewind(ilon)

 5078     read(ilat,140,end=5071)ylo1,yla1,az1,vc1,sec1,xmet1,pid1
            read(ilon,140)ylo2,yla2,az2,vc2,sec2,xmet2,pid2
            if(pid1.ne.pid2)then
              write(6,5072)
              stop
            endif
            if(ylo1.ne.ylo2)then
              write(6,5073)
              stop
            endif
            if(yla1.ne.yla2)then
              write(6,5074)
              stop
            endif
            azhor = datan2(xmet2,xmet1)/d2r 
            if(azhor.lt.0.d0)azhor=azhor+360.d0
            dhors = dsqrt(sec1**2 + sec2**2)
            dhorm = dsqrt(xmet1**2 + xmet2**2)

            if(j.eq.1)vchor = conv * dhors
            if(j.eq.2)vchor = conv * dhorm
          
            write(ihor,140)ylo1,yla1,azhor,vchor,dhors,dhorm,pid1
          goto 5078

 5071   continue
 5070 continue


c ------------------------------------------------------------------
c - Write out statistics that I'll pick up later when
c - I run "makeplotfiles03.f" -- just the "rmslatm", "rmslonm"
c - and "rmsehtm" values, used to scale vector plots.
c ------------------------------------------------------------------
      sfn = 'dvstats.'//trim(suffix2)
      open(2,file=sfn,status='new',form='formatted')

c 2,j,3,2 = RMS/j/All/Biquad, 
c -         where j=1/2/3 => lat-sec/lon-sec/eht-met
c -               j=4/5   => lat-met/lon-met
      write(2,777)kstat(1,3),stat(2,1,3,2)
      write(2,777)kstat(2,3),stat(2,2,3,2)
      write(2,777)kstat(3,3),stat(2,3,3,2)
      write(2,777)kstat(1,3),stat(2,4,3,2)
      write(2,777)kstat(2,3),stat(2,5,3,2)
c - 2015 10 09:
      rhors = sqrt(stat(2,1,3,2)**2 + stat(2,2,3,2)**2)
      rhorm = sqrt(stat(2,4,3,2)**2 + stat(2,5,3,2)**2)
      write(2,777)kstat(1,3),rhors
      write(2,777)kstat(2,3),rhorm

      close(2)
  777 format(i10,1x,f20.10)

c ----------------------------------------------------------
c ----------------------------------------------------------
c ----------------------------------------------------------
c - Create GMT file "gmtbat04..." and fill it full of
c - calls to make vector plots of thinned/dropped/all
c - "grid interpolated" vectors as well as 
c - "double differenced" vectors.
c ----------------------------------------------------------
c ----------------------------------------------------------
c ----------------------------------------------------------

c ------------------------------------------------------------------
c - GMT Batch file:  Open the file.  The output batch file full 
c -                  of all the GMT commands needed to create 
c -                  the plots of interest
c ------------------------------------------------------------------
      gmtfile = 'gmtbat04.'//trim(suffix3)
      open(99,file=gmtfile,status='new',form='formatted')
      write(6,1011)trim(gmtfile)
 1011 format(6x,'checkgrid.f: Creating GMT batch file ',a)
      write(99,1030)trim(gmtfile)
 1030 format('echo BEGIN batch file ',a)

c --------------------------------------------------------------
c - GMT Batch file:  Determine Number of areas to plot (=nplots)
c -                  and Boundaries of plots and other stuff.
c -                  Report the information out.
c --------------------------------------------------------------
c - 2016 08 29 
      call getmapbounds(mapflag,maxplots,region,nplots,
     *olddtm,newdtm,
     *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y,rl0y)

c - 2016 08 26, See DRU-12, p. 56-57:
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y,rl0y)

c - See DRU-11, p. 126 for choices on grid boundaries for NADCON v5.0
c - 2016 07 21:
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y)
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn)
      write(6,1006)trim(region)
 1006 format(6x,'checkgrid.f: Calling getmapbounds for region ',a)

c --------------------------------------------------------------
c - GMT Batch file:  Like "makeplotfiles02.f", I will 
c - spin over "nplots" as my main loop, inside of that though,
c - I will spin over j,k (as above, but letting k go from 1 to 3) 
c - Remember:  j=1,2,3 => lat,lon,eht
c -            k=1,2,3 => Thinned, Dropped, All
c --------------------------------------------------------------
      ele(1) = 'lat'
      ele(2) = 'lon'
      ele(3) = 'eht'
      ele(4) = 'lat'
      ele(5) = 'lon'
      ele(6) = 'hor'
      ele(7) = 'hor'
      
      el0(1) = 'LAT'
      el0(2) = 'LON'
      el0(3) = 'EHT'
      el0(4) = 'LAT'
      el0(5) = 'LON'
      el0(6) = 'HOR'
      el0(7) = 'HOR'

  991 format(
     *'# ------------------------------',/,
     *'# Double Difference Vector Plots',/,
     *'# ------------------------------',/,
     *'echo Double Difference Vector Plots')

  992 format(
     *'# ------------------------------',/,
     *'# Grid Interpolated Vector Plots',/,
     *'# ------------------------------',/,
     *'echo Grid Interpolated Vector Plots')

  990 format(
     *'# ------------------------------',/,
     *'# Plots for region: ',a,', sub-region: ',a,/,
     *'# ------------------------------',/,
     *'echo Creating plots for region: ',a,', sub-region: ',a)


c----------------------------------
c - Grid-Interpolated Vector Plots
c----------------------------------

      write(99,992)
      do 4011 ij=1,nplots
        write(99,990)trim(region),trim(fn(ij)),
     *  trim(region),trim(fn(ij))

c - 2016 08 26:
        xvlon = rv0x(ij)
        xvlat = rv0y(ij)

        xllat = rl0y(ij)
        xllon = xvlon

c - Where is the start of the reference vector:
c - 2016 07 29:  Decided to scrap personalized locations
c - and just put all reference vectors outside/below
c - the plots
c - 2016 07 21:
c       if(lrv(ij))then
c         xvlon = rv0x(ij)
c         xvlat = rv0y(ij)
c       else
c - 2016 08 26
cccc      xvlon = bw(ij) + (pvlon*(be(ij)-bw(ij)))
c         xvlat = bs(ij) + (pvlat*(bn(ij)-bs(ij)))
cccc      xvlat = bs(ij) - (pvlat*(bn(ij)-bs(ij)))
c       endif
c - Where is the start of the label for the ref vector:
c       xllon = xvlon
c - To prevent the label from going off the page on
c - plots that have very little N/S span, put in a
c - failsafe
c - 2016 07 21:  This may take some tweaking...
c       if(lrv(ij))then
ccccc     xllat = xvlat - 0.1d0
c       else
cccc      if(bn(ij)-bs(ij).lt.2.0)then
c           xllat = bs(ij) + ((pvlat*0.75d0)*(bn(ij)-bs(ij)))
cccc        xllat = bs(ij) - ((pvlat*1.25d0)*(bn(ij)-bs(ij)))
cccc      else
c           xllat = bs(ij) + (pvlat*(bn(ij)-bs(ij))) - 0.1d0
cccc        xllat = bs(ij) - (pvlat*(bn(ij)-bs(ij))) - 0.1d0
cccc      endif
c       endif


c       do 4012 j = 1,5
        do 4012 j = 1,7
          do 4013 k = 1,3
            if(j.eq.1.and.k.eq.1)gfn = gfnvstgilat
            if(j.eq.1.and.k.eq.2)gfn = gfnvsdgilat
            if(j.eq.1.and.k.eq.3)gfn = gfnvsagilat

            if(j.eq.2.and.k.eq.1)gfn = gfnvstgilon
            if(j.eq.2.and.k.eq.2)gfn = gfnvsdgilon
            if(j.eq.2.and.k.eq.3)gfn = gfnvsagilon

            if(j.eq.3.and.k.eq.1)gfn = gfnvmtgieht
            if(j.eq.3.and.k.eq.2)gfn = gfnvmdgieht
            if(j.eq.3.and.k.eq.3)gfn = gfnvmagieht

            if(j.eq.4.and.k.eq.1)gfn = gfnvmtgilat
            if(j.eq.4.and.k.eq.2)gfn = gfnvmdgilat
            if(j.eq.4.and.k.eq.3)gfn = gfnvmagilat

            if(j.eq.5.and.k.eq.1)gfn = gfnvmtgilon
            if(j.eq.5.and.k.eq.2)gfn = gfnvmdgilon
            if(j.eq.5.and.k.eq.3)gfn = gfnvmagilon

            if(j.eq.6.and.k.eq.1)gfn = gfnvstgihor
            if(j.eq.6.and.k.eq.2)gfn = gfnvsdgihor
            if(j.eq.6.and.k.eq.3)gfn = gfnvsagihor

            if(j.eq.7.and.k.eq.1)gfn = gfnvmtgihor
            if(j.eq.7.and.k.eq.2)gfn = gfnvmdgihor
            if(j.eq.7.and.k.eq.3)gfn = gfnvmagihor

            if(j.le.5)then
              if(kstat(j,k).ne.0)
     *        call bwplotvc(ele(j),gfn,bw,be,bs,bn,jm,b1,b2,
     *        maxplots,olddtm,newdtm,region,el0(j),ij,xvlon,
     *        xvlat,xllon,xllat,lorvoggi(j),lorvopc,igridsec,fn)
            else
              if(kstat(1,k).ne.0 .and. kstat(2,k).ne.0)
     *        call bwplotvc(ele(j),gfn,bw,be,bs,bn,jm,b1,b2,
     *        maxplots,olddtm,newdtm,region,el0(j),ij,xvlon,
     *        xvlat,xllon,xllat,lorvoggi(j),lorvopc,igridsec,fn)
            endif
       
             
 4013     continue
 4012   continue
 4011 continue

c----------------------------------
c - Double-Difference Vector Plots
c----------------------------------


      write(99,991)
      do 3011 ij=1,nplots
        write(99,990)trim(region),trim(fn(ij)),
     *  trim(region),trim(fn(ij))

c - Where is the start of the reference vector:
c - 2016 07 29:  Decided to scrap personalized locations
c - and just put all reference vectors outside/below
c - the plots

c - 2016 08 26
        xvlon = rv0x(ij)
        xvlat = rv0y(ij)

        xllon = xvlon
        xllat = rl0y(ij)

c - 2016 07 21:
c       if(lrv(ij))then
c         xvlon = rv0x(ij)
c         xvlat = rv0y(ij)
c       else
cccc      xvlon = bw(ij) + (pvlon*(be(ij)-bw(ij)))
c         xvlat = bs(ij) + (pvlat*(bn(ij)-bs(ij)))
cccc      xvlat = bs(ij) - (pvlat*(bn(ij)-bs(ij)))
c       endif
c - Where is the start of the label for the ref vector:
cccc    xllon = xvlon
c - To prevent the label from going off the page on
c - plots that have very little N/S span, put in a
c - failsafe
c - 2016 07 21:
c       if(lrv(ij))then
c         xllat = xvlat - 0.1d0
c       else
cccc      if(bn(ij)-bs(ij).lt.2.0)then
c           xllat = bs(ij) + ((pvlat*0.75d0)*(bn(ij)-bs(ij)))
cccc        xllat = bs(ij) - ((pvlat*1.25d0)*(bn(ij)-bs(ij)))
cccc      else
c           xllat = bs(ij) + (pvlat*(bn(ij)-bs(ij))) - 0.1d0
cccc        xllat = bs(ij) - (pvlat*(bn(ij)-bs(ij))) - 0.1d0
cccc      endif
c       endif


c       do 3012 j = 1,3
c       do 3012 j = 1,5
        do 3012 j = 1,7
          do 3013 k = 1,3
            if(j.eq.1.and.k.eq.1)gfn = gfnvstddlat
            if(j.eq.1.and.k.eq.2)gfn = gfnvsdddlat
            if(j.eq.1.and.k.eq.3)gfn = gfnvsaddlat

            if(j.eq.2.and.k.eq.1)gfn = gfnvstddlon
            if(j.eq.2.and.k.eq.2)gfn = gfnvsdddlon
            if(j.eq.2.and.k.eq.3)gfn = gfnvsaddlon

            if(j.eq.3.and.k.eq.1)gfn = gfnvmtddeht
            if(j.eq.3.and.k.eq.2)gfn = gfnvmdddeht
            if(j.eq.3.and.k.eq.3)gfn = gfnvmaddeht

            if(j.eq.4.and.k.eq.1)gfn = gfnvmtddlat
            if(j.eq.4.and.k.eq.2)gfn = gfnvmdddlat
            if(j.eq.4.and.k.eq.3)gfn = gfnvmaddlat

            if(j.eq.5.and.k.eq.1)gfn = gfnvmtddlon
            if(j.eq.5.and.k.eq.2)gfn = gfnvmdddlon
            if(j.eq.5.and.k.eq.3)gfn = gfnvmaddlon

            if(j.eq.6.and.k.eq.1)gfn = gfnvstddhor
            if(j.eq.6.and.k.eq.2)gfn = gfnvsdddhor
            if(j.eq.6.and.k.eq.3)gfn = gfnvsaddhor

            if(j.eq.7.and.k.eq.1)gfn = gfnvmtddhor
            if(j.eq.7.and.k.eq.2)gfn = gfnvmdddhor
            if(j.eq.7.and.k.eq.3)gfn = gfnvmaddhor

            if(j.le.5)then
              if(kstat(j,k).ne.0)
     *        call bwplotvc(ele(j),gfn,bw,be,bs,bn,jm,b1,b2,
     *        maxplots,olddtm,newdtm,region,el0(j),ij,xvlon,
     *        xvlat,xllon,xllat,lorvog(j),lorvopc,igridsec,fn)
            else
              if(kstat(1,k).ne.0 .and. kstat(2,k).ne.0)
     *        call bwplotvc(ele(j),gfn,bw,be,bs,bn,jm,b1,b2,
     *        maxplots,olddtm,newdtm,region,el0(j),ij,xvlon,
     *        xvlat,xllon,xllat,lorvog(j),lorvopc,igridsec,fn)
            endif
             
 3013     continue
 3012   continue
 3011 continue






      write(99,1031)trim(gmtfile)
 1031 format('echo END batch file ',a)
      close(99)

      write(6,9999)
 9999 format('END program checkgrid.f')
  
      end    
c
c --------------------------------------------------------------
c
      subroutine nlines(ifile,num,ilogic)
      integer*4 ifile,num
      logical*1 ilogic
      character*1 dummy
    
      ilogic = .false.
      num = 0
    1 read(ifile,'(a)',end=2)dummy
        num = num + 1
      goto 1
    2 if(num.eq.0)ilogic = .true.
      rewind(ifile)
      return
      end
c
c --------------------------------------------------------------
c
      include 'Subs/getmapbounds.f'
      include 'Subs/getgridbounds.f'
      include 'Subs/bwplotvc.f'
      include 'Subs/plotcoast.f'
c
      include 'Subs/bilin.f'
      include 'Subs/biquad.f'
      include 'Subs/bicubic.f'
      include 'Subs/onzd2.f'

