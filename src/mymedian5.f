c> \ingroup doers
c> \if MANPAGE     
c> \page mymedian5
c> \endif      
c> 
c> Program to filter Map Data for GMT Plotting
c>   
c> 1. Run a customized block-median thinning 
c>    algorithm on coordinate differences (horizontal
c>    and ellipsoid height)
c> 2. Save the thinned data to GMT-ready plottable files
c> 3. Save the removed data to GMT-ready plottable files
c> 4. Create a GMT batch file (gmtbat02) to grid the thinned data at T=0.4 (which
c>    becomes the final transformation grid) and also at T=1.0 and
c>    T=0.0, (whose difference becomes the bases for the 
c>    "method noise" grid)
c> 5. If, and only if, we are doing the combination of 
c>    HARN/FBN/CONUS, insert commands into gmtbat02
c>    to apply a mask to the "04.b" grids (See DRU-12, p. 36-37)
c> See DRU-11, p. 127
c>       
c> unlike `mymedian.f`, this program is
c> set up to filter/process all data
c> at once in one run. Also, significant
c> philosophical changes occurred, including:
c>       
c> 1. Median filter on absolute horizontal length, and
c>    then, when we have our "kept" points, we use
c>    the lat and lon of those kept points to grid
c>    lat and lon separately.  (mymedian.f actually
c>    sorted lat medians and lon medians separately,
c>    raising the very real possibility that separate
c>    points would go into each grid.)
c> 2. Nothing RANDOM!  No coin flipping, etc.  It was
c>    viewed, for NADCON 5.0, as scientifically
c>    improper for the final grids to be reliant upon
c>    a filtering mechanism that could be different
c>    each time it was run. 
c>       
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> They are enumerated here
c> \param oldtm Source Datum
c> \param newdtm Target Datum,region
c> \param region Conversion Region 
c> \param agridsec Grid Spacing in Arc Seconds
c>      
c> ### Program Inputs:
c> 
c> ## Changelog
c>       
c> ### 2016 09 14
c> Bug found when running Hawaii with points outside grid -- some mixup
c> between "ikt" and "ipid".  Changed this program as follows:  It now
c> REQUIRES that the incoming data has NO points outside the grid
c> boundary.  This has been forced by giving such points a "444" reject
c> code in "makework" when creating the work file.  By going through
c> "makeplotfiles01" with a "444" reject, those points won't even make
c> it into the "all" file, which is our input for median filtering here...
c>       
c> ### 2016 06 29
c> Updated to insert masking commands for the "...04.b" (transformation
c> grid) into gmtbat02 when working ONLY in the HARN/FBN/CONUS combination.
c>       
c> ### 2015 10 27
c> For use in creating NADCON5
c> Built by Dru Smith
c> Built from scratch, scrapping all previous
c> "mymedian" programs used in making GEOCON
      program mymedian5

      implicit real*8(a-h,o-z)

c - Updated to allow up to 280,000 points to come in 
c - which also translates to letting 280,000 grid cells
c -  to be non-empty.
      parameter(max=280000)
c - And using a little hit or miss logic, the number
c - of possible points in one cell can't be more than
c - about 100, right?
      parameter(maxppcell=5000)

c - Holding place for the values themselves, in read-order
      dimension zs(max)

c - Pass/nopass flag for all data, in read-order
      logical lpass(max)

c - Holding place for each record, in read-order
      character*80 cards(max)         ! 2016 09 14

c - Index of what latititude row and longitude column
c - is associated with each non-empty cell, in
c - cell-found order.  
c -   1 <= ilapcell() <= nla
c -   1 <= ilopcell() <= nlo
      integer*4 ilapcell(max),ilopcell(max)
      integer*4 poscode(max)
      integer*4 indx(max)
c - Distance of a point from its cell's center
      real*8 dist(max)

c - Index telling me which cell a given point is
c - associated with, in read-order
c - 1 <= whichcell() <= ncells
      integer*4 whichcell(max)

c - ppcell(i) contains the count of how many values fall
c - in cell "i", where "i" ratchets up from 1 to max
c - every time I find a new non-empty cell.
      integer*4 ppcell(max)

      character*10 olddtm,newdtm,region
      character*200 suffix1,suffix2
      character*200 suffix2t00,suffix2t04,suffix2t10
      character*200 suffix2d1,suffix2d2,suffix2d3
c - Input GMT-ready files:
      character*200 gfncvacdlat
      character*200 gfncvacdlon
      character*200 gfncvacdeht
      character*200 gfnvmacdlat
      character*200 gfnvmacdlon
      character*200 gfnvmacdeht
      character*200 gfnvmacdhor
      character*200 gfnvsacdlat
      character*200 gfnvsacdlon
      character*200 gfnvsacdhor
c - Output thinned GMT-ready files:
      character*200 gfncvtcdlat
      character*200 gfncvtcdlon
      character*200 gfncvtcdeht
      character*200 gfnvmtcdlat
      character*200 gfnvmtcdlon
      character*200 gfnvmtcdeht
      character*200 gfnvmtcdhor
      character*200 gfnvstcdlat
      character*200 gfnvstcdlon
      character*200 gfnvstcdhor
c - Output dropped GMT-ready files:
      character*200 gfncvdcdlat
      character*200 gfncvdcdlon
      character*200 gfncvdcdeht
      character*200 gfnvmdcdlat
      character*200 gfnvmdcdlon
      character*200 gfnvmdcdeht
      character*200 gfnvmdcdhor
      character*200 gfnvsdcdlat
      character*200 gfnvsdcdlon
      character*200 gfnvsdcdhor
c - Output thinned GMT(surface)-ready files:
      character*200 gfnsmtcdlat
      character*200 gfnsmtcdlon
      character*200 gfnsmtcdeht
      character*200 gfnsstcdlat
      character*200 gfnsstcdlon
c - To be created ".grd" files by surface
      character*200 rfnvmtcdlat04
      character*200 rfnvmtcdlon04
      character*200 rfnvmtcdeht04
      character*200 rfnvstcdlat04
      character*200 rfnvstcdlon04

      character*200 rfnvmtcdlat00
      character*200 rfnvmtcdlon00
      character*200 rfnvmtcdeht00
      character*200 rfnvstcdlat00
      character*200 rfnvstcdlon00

      character*200 rfnvmtcdlat10
      character*200 rfnvmtcdlon10
      character*200 rfnvmtcdeht10
      character*200 rfnvstcdlat10
      character*200 rfnvstcdlon10

c     character*200 rfnvmtcdlat
c     character*200 rfnvmtcdlon
c     character*200 rfnvmtcdeht
c     character*200 rfnvstcdlat
c     character*200 rfnvstcdlon

c - To be created ".xyz" files by GMT's grd2xyz program
      character*200 zfnvmtcdlat04
      character*200 zfnvmtcdlon04
      character*200 zfnvmtcdeht04
      character*200 zfnvstcdlat04
      character*200 zfnvstcdlon04

      character*200 zfnvmtcdlat00
      character*200 zfnvmtcdlon00
      character*200 zfnvmtcdeht00
      character*200 zfnvstcdlat00
      character*200 zfnvstcdlon00

      character*200 zfnvmtcdlat10
      character*200 zfnvmtcdlon10
      character*200 zfnvmtcdeht10
      character*200 zfnvstcdlat10
      character*200 zfnvstcdlon10

c     character*200 zfnvmtcdlat
c     character*200 zfnvmtcdlon
c     character*200 zfnvmtcdeht
c     character*200 zfnvstcdlat
c     character*200 zfnvstcdlon

c - To be created ".b" files by grd2b
      character*200 bfnvmtcdlat04
      character*200 bfnvmtcdlon04
      character*200 bfnvmtcdeht04
      character*200 bfnvstcdlat04
      character*200 bfnvstcdlon04

      character*200 bfnvmtcdlat00
      character*200 bfnvmtcdlon00
      character*200 bfnvmtcdeht00
      character*200 bfnvstcdlat00
      character*200 bfnvstcdlon00

      character*200 bfnvmtcdlat10
      character*200 bfnvmtcdlon10
      character*200 bfnvmtcdeht10
      character*200 bfnvstcdlat10
      character*200 bfnvstcdlon10

c - Difference grids to be used in creation of the "method noise" grid
      character*200 dbfnvmtcdlat1000
      character*200 dbfnvstcdlat1000
      character*200 dbfnvmtcdlon1000
      character*200 dbfnvstcdlon1000
      character*200 dbfnvmtcdeht1000

      character*200 adbfnvmtcdlat1000
      character*200 adbfnvstcdlat1000
      character*200 adbfnvmtcdlon1000
      character*200 adbfnvstcdlon1000
      character*200 adbfnvmtcdeht1000

      character*200 sadbfnvmtcdlat1000
      character*200 sadbfnvstcdlat1000
      character*200 sadbfnvmtcdlon1000
      character*200 sadbfnvstcdlon1000
      character*200 sadbfnvmtcdeht1000

      character*200 sadrfnvmtcdlat1000
      character*200 sadrfnvstcdlat1000
      character*200 sadrfnvmtcdlon1000
      character*200 sadrfnvstcdlon1000
      character*200 sadrfnvmtcdeht1000

c     character*200 bfnvmtcdlat
c     character*200 bfnvmtcdlon
c     character*200 bfnvmtcdeht
c     character*200 bfnvstcdlat
c     character*200 bfnvstcdlon
c - Dummy
      character*200 fused
c - Output GMT-batch file:
      character*200 gmtfile
c - Grid spacing, converted to characters for file names
c - Presumes:
c -   1) igridsec is an integer
c -   2) 1 <= igridsec <= 99999
      integer*4 igridsec
      character*5 agridsec

      character*6  pid
      character*80 card
      character*80 cardcvlat,cardcvlon,cardcveht
      character*80 cardvmlat,cardvmlon,cardvmeht,cardvmhor
      character*80 cardvslat,cardvslon,          cardvshor


c --------------------------------------
c --------------------------------------
c --------------------------------------
c -------BEGIN GUTS OF PROGRAM----------
c --------------------------------------
c --------------------------------------
c --------------------------------------
      write(6,1001)
 1001 format('BEGIN program mymedian5.f')

c ------------------------------------------------------------------
c - Some required constants.
c ------------------------------------------------------------------
      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      rng2std = 1.d0/1.6929d0

c ------------------------------------------------------------------
c - Read in arguments from batch file
c ------------------------------------------------------------------
      read(5,'(a)')olddtm
      read(5,'(a)')newdtm
      read(5,'(a)')region
      read(5,'(a)')agridsec

c ------------------------------------------------------------------
c - Generate the suffixes used in all our files
c ------------------------------------------------------------------
      read(agridsec,*)igridsec
      suffix1=trim(olddtm)//'.'//trim(newdtm)//'.'//trim(region)
      suffix2=trim(suffix1)//'.'//trim(agridsec)

      suffix2t00=trim(suffix2)//'.00'
      suffix2t04=trim(suffix2)//'.04'
      suffix2t10=trim(suffix2)//'.10'

      suffix2d1=trim(suffix2)//'.d1'
      suffix2d2=trim(suffix2)//'.d2'
      suffix2d3=trim(suffix2)//'.d3'


c ------------------------------------------------------------------
c - Open the GMT batch file for gridding the thinned data
c ------------------------------------------------------------------
      gmtfile = 'gmtbat02.'//trim(suffix2)
      open(99,file=gmtfile,status='new',form='formatted')
      write(6,1011)trim(gmtfile)
 1011 format(6x,'mymedian5.f: Creating GMT batch file ',a)
      write(99,1030)trim(gmtfile)
 1030 format('echo BEGIN batch file ',a)


c ------------------------------------------------------------------
c - Open the input, pre-thinned, GMT-ready files
c ------------------------------------------------------------------

c - Coverage (11-13):
      gfncvacdlat = 'cvacdlat.'//trim(suffix1)
      open(11,file=gfncvacdlat,status='old',form='formatted')
      write(6,1010)trim(gfncvacdlat)

      gfncvacdlon = 'cvacdlon.'//trim(suffix1)
      open(12,file=gfncvacdlon,status='old',form='formatted')
      write(6,1010)trim(gfncvacdlon)

      gfncvacdeht = 'cvacdeht.'//trim(suffix1)
      open(13,file=gfncvacdeht,status='old',form='formatted')
      write(6,1010)trim(gfncvacdeht)


c - Vectors, Meters (21-24):
      gfnvmacdlat = 'vmacdlat.'//trim(suffix1)
      open(21,file=gfnvmacdlat,status='old',form='formatted')
      write(6,1010)trim(gfnvmacdlat)

      gfnvmacdlon = 'vmacdlon.'//trim(suffix1)
      open(22,file=gfnvmacdlon,status='old',form='formatted')
      write(6,1010)trim(gfnvmacdlon)

      gfnvmacdeht = 'vmacdeht.'//trim(suffix1)
      open(23,file=gfnvmacdeht,status='old',form='formatted')
      write(6,1010)trim(gfnvmacdeht)

      gfnvmacdhor = 'vmacdhor.'//trim(suffix1)
      open(24,file=gfnvmacdhor,status='old',form='formatted')
      write(6,1010)trim(gfnvmacdhor)

c - Vectors, Seconds (26-29, skipping 28):
      gfnvsacdlat = 'vsacdlat.'//trim(suffix1)
      open(26,file=gfnvsacdlat,status='old',form='formatted')
      write(6,1010)trim(gfnvsacdlat)

      gfnvsacdlon = 'vsacdlon.'//trim(suffix1)
      open(27,file=gfnvsacdlon,status='old',form='formatted')
      write(6,1010)trim(gfnvsacdlon)

      gfnvsacdhor = 'vsacdhor.'//trim(suffix1)
      open(29,file=gfnvsacdhor,status='old',form='formatted')
      write(6,1010)trim(gfnvsacdhor)


 1010 format(6x,'mymedian5.f: ',
     *'Opening existing unthinned file ',a)

c ------------------------------------------------------------------
c - Open the output, thinned, GMT-ready files
c - "t" meaning "thinned"
c ------------------------------------------------------------------

c - Coverage (31-33):
      gfncvtcdlat = 'cvtcdlat.'//trim(suffix2)
      open(31,file=gfncvtcdlat,status='new',form='formatted')
      write(6,1022)trim(gfncvtcdlat)

      gfncvtcdlon = 'cvtcdlon.'//trim(suffix2)
      open(32,file=gfncvtcdlon,status='new',form='formatted')
      write(6,1022)trim(gfncvtcdlon)

      gfncvtcdeht = 'cvtcdeht.'//trim(suffix2)
      open(33,file=gfncvtcdeht,status='new',form='formatted')
      write(6,1022)trim(gfncvtcdeht)

c - Vectors, Meters (41-44):
      gfnvmtcdlat = 'vmtcdlat.'//trim(suffix2)
      open(41,file=gfnvmtcdlat,status='new',form='formatted')
      write(6,1012)trim(gfnvmtcdlat)

      gfnvmtcdlon = 'vmtcdlon.'//trim(suffix2)
      open(42,file=gfnvmtcdlon,status='new',form='formatted')
      write(6,1012)trim(gfnvmtcdlon)

      gfnvmtcdeht = 'vmtcdeht.'//trim(suffix2)
      open(43,file=gfnvmtcdeht,status='new',form='formatted')
      write(6,1012)trim(gfnvmtcdeht)

      gfnvmtcdhor = 'vmtcdhor.'//trim(suffix2)
      open(44,file=gfnvmtcdhor,status='new',form='formatted')
      write(6,1012)trim(gfnvmtcdhor)

c - Vectors, Seconds (46-49, skipping 48):
      gfnvstcdlat = 'vstcdlat.'//trim(suffix2)
      open(46,file=gfnvstcdlat,status='new',form='formatted')
      write(6,1012)trim(gfnvstcdlat)

      gfnvstcdlon = 'vstcdlon.'//trim(suffix2)
      open(47,file=gfnvstcdlon,status='new',form='formatted')
      write(6,1012)trim(gfnvstcdlon)

      gfnvstcdhor = 'vstcdhor.'//trim(suffix2)
      open(49,file=gfnvstcdhor,status='new',form='formatted')
      write(6,1012)trim(gfnvstcdhor)


 1012 format(6x,'mymedian5.f: ',
     *'Opening output thinned vector file ',a)
 1022 format(6x,'mymedian5.f: ',
     *'Opening output thinned coverage file ',a)

c ------------------------------------------------------------------
c - Open the output, dropped, GMT-ready files
c - "d" meaning "dropped"
c ------------------------------------------------------------------

c - Coverage (51-53):
      gfncvdcdlat = 'cvdcdlat.'//trim(suffix2)
      open(51,file=gfncvdcdlat,status='new',form='formatted')
      write(6,1023)trim(gfncvdcdlat)

      gfncvdcdlon = 'cvdcdlon.'//trim(suffix2)
      open(52,file=gfncvdcdlon,status='new',form='formatted')
      write(6,1023)trim(gfncvdcdlon)

      gfncvdcdeht = 'cvdcdeht.'//trim(suffix2)
      open(53,file=gfncvdcdeht,status='new',form='formatted')
      write(6,1023)trim(gfncvdcdeht)

c - Vectors, Meters (61-64):
      gfnvmdcdlat = 'vmdcdlat.'//trim(suffix2)
      open(61,file=gfnvmdcdlat,status='new',form='formatted')
      write(6,1013)trim(gfnvmdcdlat)

      gfnvmdcdlon = 'vmdcdlon.'//trim(suffix2)
      open(62,file=gfnvmdcdlon,status='new',form='formatted')
      write(6,1013)trim(gfnvmdcdlon)

      gfnvmdcdeht = 'vmdcdeht.'//trim(suffix2)
      open(63,file=gfnvmdcdeht,status='new',form='formatted')
      write(6,1013)trim(gfnvmdcdeht)

      gfnvmdcdhor = 'vmdcdhor.'//trim(suffix2)
      open(64,file=gfnvmdcdhor,status='new',form='formatted')
      write(6,1013)trim(gfnvmdcdhor)

c - Vectors, Seconds (66-69, skippin 68):
      gfnvsdcdlat = 'vsdcdlat.'//trim(suffix2)
      open(66,file=gfnvsdcdlat,status='new',form='formatted')
      write(6,1013)trim(gfnvsdcdlat)

      gfnvsdcdlon = 'vsdcdlon.'//trim(suffix2)
      open(67,file=gfnvsdcdlon,status='new',form='formatted')
      write(6,1013)trim(gfnvsdcdlon)

      gfnvsdcdhor = 'vsdcdhor.'//trim(suffix2)
      open(69,file=gfnvsdcdhor,status='new',form='formatted')
      write(6,1013)trim(gfnvsdcdhor)

 
 1013 format(6x,'mymedian5.f: ',
     *'Opening output dropped vector file ',a) 
 1023 format(6x,'mymedian5.f: ',
     *'Opening output dropped coverage file ',a) 

c ------------------------------------------------------------------
c - Open the output, thinned, GMT-ready files for pushing
c - through "surface" to get a grid.
c - "t" meaning "thinned"
c ------------------------------------------------------------------

c -  Surface ready vectors, meters (71-73):
      gfnsmtcdlat = 'smtcdlat.'//trim(suffix2)
      open(71,file=gfnsmtcdlat,status='new',form='formatted')
      write(6,1014)trim(gfnsmtcdlat)

      gfnsmtcdlon = 'smtcdlon.'//trim(suffix2)
      open(72,file=gfnsmtcdlon,status='new',form='formatted')
      write(6,1014)trim(gfnsmtcdlon)

      gfnsmtcdeht = 'smtcdeht.'//trim(suffix2)
      open(73,file=gfnsmtcdeht,status='new',form='formatted')
      write(6,1014)trim(gfnsmtcdeht)

c -  Surface ready vectors, seconds (76-77):
      gfnsstcdlat = 'sstcdlat.'//trim(suffix2)
      open(76,file=gfnsstcdlat,status='new',form='formatted')
      write(6,1014)trim(gfnsstcdlat)

      gfnsstcdlon = 'sstcdlon.'//trim(suffix2)
      open(77,file=gfnsstcdlon,status='new',form='formatted')
      write(6,1014)trim(gfnsstcdlon)


 1014 format(6x,'mymedian5.f: ',
     *'Opening output thinned vector file (for surface):',a) 

c ------------------------------------------------------------------
c - Each region has officially chosen boundaries (which may
c - or may not agree with the MAP boundaries).  Get the
c - official grid boundaries here.  See DRU-11, p. 126
c ------------------------------------------------------------------
      call getgridbounds(region,glamx,glamn,glomn,glomx)

      write(6,1004)trim(region),glamn,glamx,glomn,glomx
 1004 format(6x,'mymedian5.f: Region= ',a,/,
     *       6x,'mymedian5.f: North = ',f12.6,/,
     *       6x,'mymedian5.f: South = ',f12.6,/,
     *       6x,'mymedian5.f: West  = ',f12.6,/,
     *       6x,'mymedian5.f: East  = ',f12.6)

c -------------------------------------------------------
c - Get the header information necessary for a ".b" file
c - 1) Convert "igridsec" to decimal degrees      
c - 2) Count rows and columns
c -------------------------------------------------------
      dgla = dble(igridsec)/3600.d0
      dglo = dble(igridsec)/3600.d0

      nla=idnint((glamx-glamn)/dgla)+1
      nlo=idnint((glomx-glomn)/dglo)+1

      write(6,3001)glamn,glamx,glomn,glomx,dgla,dglo,nla,nlo
 3001 format(6x,'mymedian5.f : Cell Structure:',/,
     *8x,'North = ',f16.10,/,
     *8x,'South = ',f16.10,/,
     *8x,'West  = ',f16.10,/,
     *8x,'East  = ',f16.10,/,
     *8x,'DLat  = ',f16.10,/,
     *8x,'DLon  = ',f16.10,/,
     *8x,'NLat  = ',i16   ,/,
     *8x,'NLon  = ',i16   )

c     glamx=glamn+dgla*(nla-1)         !*** register the far boundary
c     glomx=glomn+dglo*(nlo-1)

c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c - Median filter in a loop.  First loop is to process on absolute horizontal
c - distance in METERS.  Second loop on ellipsoid height, again on
c - absolute horizontal value in METERS.   (All "arcsecond" stuff
c - is passively carried along to match the meter stuff.  All the
c - WORK is done in meters for median thinning).
c - 
c - In the first loop, when done processing on horizontal distance,
c - use the kept PIDs to generate the thinned LAT and thinned LON
c - files (in this way, the PID list for both LAT and LON files will
c - always be identical).  Do NOT process medians on LAT and LON
c - separately!!!
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------

      nthinhor = 0
      ndrophor = 0
      nthineht = 0
      ndropeht = 0

      do 2001 iloop = 1,2 
        if    (iloop.eq.1)then
          lin = 24       ! vchor file
c         fused = gfnvchor
          fused = gfnvmacdhor
        elseif(iloop.eq.2)then
          lin = 23       ! vceht file
c         fused = gfnvceht
          fused = gfnvmacdeht
        endif
        write(6,2002)trim(fused)
 2002   format(6x,'mymedian5.f: Median filtering file     :  ',a)
  101   format(f16.10,1x,f15.10,1x,6x  ,1x,12x  ,1x,9x  ,1x,f9.3,1x,a6)

c - 2016 09 14:
c2003   format(6x,'mymedian5.f: Point outside boundaries: ',
c    *  f16.10,1x,f15.10,1x,f9.5,1x,a6)
 2003   format(6x,'mymedian5.f: FATAL ERROR:  ',
     *  'Point outside boundaries: ',
     *  f16.10,1x,f15.10,1x,f9.5,1x,a6)

c - Set the count of how many values are in each non-empty
c - grid cell to zero.
        do 201 i=1,max
          ppcell(i)=0      
  201   continue
        ncells = 0

c ------------------------------------------------------------
c - Top of READ loop
c - "ikt" is the count of all records in the vector file
c ------------------------------------------------------------
        ikt  = 0
c       write(6,*) ' before read loop'
  100   read(lin,'(a)',end=777)card

c - Note that we will work in (aka "the z value") METERS on both horizontal
c - *AND* ellipsoid heights.
          read(card,101)glo,gla,z,pid
          ikt = ikt + 1

c - 2016 09 14:  Changed this code...if there is ANY point that comes
c - in from outside the grid, that will be a FATAL error
c - in this program.
          if(gla.lt.glamn.or.gla.gt.glamx .or.
     *       glo.lt.glomn.or.glo.gt.glomx) then
            write(6,2003)gla,glo,z,pid
            stop
          endif

c - Store the read data
          cards(ikt)=card   

c - Store the values too
          zs(ikt)   =z

c - Set a default for ALL points that it will "not pass"
c - (e.g. "be dropped")
          lpass(ikt)=.false.        

c - Determine which row and column our point falls in.  Then
c - convert that combination of row/col into a single
c - value (encoded as ila*100000+ilo)
          ila=idnint((gla-glamn)/dgla)+1
          ilo=idnint((glo-glomn)/dglo)+1
          ipos=ila*100000+ilo 

c - Determine the distance our point is from the cell's center.
c - This is used to break a tie when there are an even number
c - of points in a cell.
          xla = glamn + (ila-1)*dgla
          xlo = glomn + (ilo-1)*dglo
          dist(ikt) = dsqrt((gla-xla)**2+(glo-xlo)**2)   

c - Is this point a new cell?
          do 202 j=1,ncells

c - OLD cell
c - Ratchet up the count of points in this cell
c - Store the unique input number as being in this cell
c - Jump out
            if(ipos.eq.poscode(j))then
              ppcell(j) = ppcell(j) + 1
              whichcell(ikt) = j
              goto 203
            endif
  202     continue

c - NEW cell (jump over this code from previous loop if
c -           an old cell were found)

          ncells = ncells + 1
          poscode(ncells)  = ipos
          ilapcell(ncells) = ila
          ilopcell(ncells) = ilo
          ppcell(ncells) = 1
c 2016 09 14:
          whichcell(ikt) = ncells

c         write(6,*) ' new cell : ',ncells,ipos
 
  203     continue

        goto 100

  777   continue

c ------------------------------------------------------------
c - Bottom of READ loop
c ------------------------------------------------------------

        nkt = ikt

        write(6,2004) trim(fused),nkt,igridsec,ncells
 2004   format(
     *6x,'mymedian5.f: Done Reading from         : ',a,/,
     *6x,'mymedian5.f: Points in File            : ',i10,/,
     *6x,'mymedian5.f: Cell Size (Arcseconds)    : ',i10,/,
     *6x,'mymedian5.f: Number of Cells with Data : ',i10)
        write(6,2005)
 2005   format(6x,'mymedian5.f: Begin median filtering')


c ------------------------------------------------------------
c - TOP of SORTING section
c ------------------------------------------------------------

c- Sort all of our data (nkt values) by their poscode
        write(6,2020)
 2020   format(6x,'mymedian5.f: Sorting data...')
c - 2016 09 14
        call indexxi(nkt,max,whichcell,indx)

c - 2016 09 14: Fixed, but kept commented out
c - Spit out our data in WHICHCELL order
c       goto 400
c       do 400 i=1,nkt
c         j = indx(i)
c         icell = whichcell(j)
c         if(mod(i,1000).eq.0)then
c         write(6,2010)cards(j),icell,ilapcell(icell),
c    *    ilopcell(icell),poscode(icell)
c         endif
c 400   continue
 2010   format(i8,1x,a80,1x,4(i10))

c - Now go through each cell and sort it
        inumlo = 0
        inumhi = 0
        ikt = 0
        do 401 icell=1,ncells
          inumlo = inumhi + 1 
          inumhi = inumlo + ppcell(icell) - 1
c         write(6,*) ' inumlo/inumhi = ',inumlo,inumhi
          do 402 jpt=1,ppcell(icell)
            ikt = ikt + 1
            j = indx(ikt)
c           write(6,2010)ikt,cards(j),icell,ilapcell(icell),
c    *      ilopcell(icell),poscode(icell)
  402     continue 
          call getmedian(zs,max,inumlo,inumhi,indx,
     *    maxppcell,dist,iiival)

c - Set the median for this cell to "pass" (e.g. to be
c - put in the "thinned" data file.
          if(iiival.lt.0)stop 10001
          if(iiival.gt.nkt)stop 10002
          lpass(iiival) = .true.
  401   continue
        write(6,408)
  408   format(6x,'mymedian5.f: Done finding medians',/,
     *  6x,'mymedian5.f: Populating thinned and dropped files')

        rewind(lin)

        ithin = 0
        idrop = 0

c - 2016 09 14
        do 451 i=1,nkt

          if(iloop.eq.1)then
            read(11,'(a)')cardcvlat
            read(12,'(a)')cardcvlon

            read(21,'(a)')cardvmlat
            read(22,'(a)')cardvmlon
            read(24,'(a)')cardvmhor

            read(26,'(a)')cardvslat
            read(27,'(a)')cardvslon
            read(29,'(a)')cardvshor

            if(lpass(i))then
              ithin = ithin + 1
              write(31,'(a)')cardcvlat
              write(32,'(a)')cardcvlon

              write(41,'(a)')cardvmlat
              write(42,'(a)')cardvmlon
              write(44,'(a)')cardvmhor

              write(46,'(a)')cardvslat
              write(47,'(a)')cardvslon
              write(49,'(a)')cardvshor

c - write the thinned vectors to the surface files
c - NOTE:  We need to extract LON/LAT/Value_in_correct_units
c -        from the overall "card", and the correct value
c -        depends on whether we're pulling out arcseconds or
c -        meters.

              write(71,'(a,a,a)')cardvmlat(1:33),cardvmlat(64:72),
     *        cardvmlat(73:79)
              write(72,'(a,a,a)')cardvmlon(1:33),cardvmlon(64:72),
     *        cardvmlat(73:79)

              write(76,'(a,a,a)')cardvslat(1:33),cardvslat(54:62),
     *        cardvmlat(73:79)
              write(77,'(a,a,a)')cardvslon(1:33),cardvslon(54:62),
     *        cardvmlat(73:79)

            else
              idrop = idrop + 1
              write(51,'(a)')cardcvlat
              write(52,'(a)')cardcvlon

              write(61,'(a)')cardvmlat
              write(62,'(a)')cardvmlon
              write(64,'(a)')cardvmhor

              write(66,'(a)')cardvslat
              write(67,'(a)')cardvslon
              write(69,'(a)')cardvshor
            endif

          else
            read(13,'(a)')cardcveht

            read(23,'(a)')cardvmeht

            if(lpass(i))then
              ithin = ithin + 1
              write(33,'(a)')cardcveht
              write(43,'(a)')cardvmeht
c - write the thinned vectors to the surface file
              write(73,'(a,a,a)')cardvmeht(1:33),cardvmeht(64:72),
     *        cardvmeht(73:79)
            else
              idrop = idrop + 1
              write(53,'(a)')cardcveht
              write(63,'(a)')cardvmeht
            endif
          endif
  451   continue

        write(6,*) ' Number kept    : ',ithin
        write(6,*) ' Number dropped : ',idrop

        if(iloop.eq.1)then
          nthinhor = ithin
          ndrophor = idrop
        else
          nthineht = ithin
          ndropeht = idrop
        endif

c       do 300 i=1,ncells
c         write(6,2006)i,poscode(i)
c         do 301 j=1,ppcell(i)
c           write(6,2007)j
c 301     continue
c 300   continue


c ------------------------------------------------------------
c - BOTTOM of SORTING section
c ------------------------------------------------------------


 2001 continue

c -------------------------------------------------------
c - Based on everything we have so far, put a bunch
c - of "surface" calls into the GMT batch file.
c - These will be to turn the median-thinned data
c - into grids.  DO NOT GENERATE A CALL TO SURFACE
c - IF THE NUMBER OF THINNED DATA IS ZERO.

c - Because "surface", as part of GMT, returns its
c - own binary grid format (called ".grd" herein), it must be
c - converted to ".b" format.  The easiest way to 
c - do so is to use the GMT built-in routine "grd2xyz"
c - with the "-bos" extension to create a binary XYZ
c - list file.  Then run Dennis's homemade "xyz2b.for" 
c - routine to finally arrive at the ".b" binary grid format.
c -------------------------------------------------------
      cmidlat=dcos(((glamn+glamx)/2.d0)*d2r)
      rfnvmtcdlat00 = 'vmtcdlat.'//trim(suffix2t00)//'.grd'
      rfnvmtcdlon00 = 'vmtcdlon.'//trim(suffix2t00)//'.grd'
      rfnvmtcdeht00 = 'vmtcdeht.'//trim(suffix2t00)//'.grd'
      rfnvstcdlat00 = 'vstcdlat.'//trim(suffix2t00)//'.grd'
      rfnvstcdlon00 = 'vstcdlon.'//trim(suffix2t00)//'.grd'
      rfnvmtcdlat04 = 'vmtcdlat.'//trim(suffix2t04)//'.grd'
      rfnvmtcdlon04 = 'vmtcdlon.'//trim(suffix2t04)//'.grd'
      rfnvmtcdeht04 = 'vmtcdeht.'//trim(suffix2t04)//'.grd'
      rfnvstcdlat04 = 'vstcdlat.'//trim(suffix2t04)//'.grd'
      rfnvstcdlon04 = 'vstcdlon.'//trim(suffix2t04)//'.grd'
      rfnvmtcdlat10 = 'vmtcdlat.'//trim(suffix2t10)//'.grd'
      rfnvmtcdlon10 = 'vmtcdlon.'//trim(suffix2t10)//'.grd'
      rfnvmtcdeht10 = 'vmtcdeht.'//trim(suffix2t10)//'.grd'
      rfnvstcdlat10 = 'vstcdlat.'//trim(suffix2t10)//'.grd'
      rfnvstcdlon10 = 'vstcdlon.'//trim(suffix2t10)//'.grd'

      sadrfnvmtcdlat1000 = 'vmtcdlat.'//trim(suffix2d3)//'.grd'
      sadrfnvstcdlat1000 = 'vstcdlat.'//trim(suffix2d3)//'.grd'
      sadrfnvmtcdlon1000 = 'vmtcdlon.'//trim(suffix2d3)//'.grd'
      sadrfnvstcdlon1000 = 'vstcdlon.'//trim(suffix2d3)//'.grd'
      sadrfnvmtcdeht1000 = 'vmtcdeht.'//trim(suffix2d3)//'.grd'

      zfnvmtcdlat00 = 'vmtcdlat.'//trim(suffix2t00)//'.xyz'
      zfnvmtcdlon00 = 'vmtcdlon.'//trim(suffix2t00)//'.xyz'
      zfnvmtcdeht00 = 'vmtcdeht.'//trim(suffix2t00)//'.xyz'
      zfnvstcdlat00 = 'vstcdlat.'//trim(suffix2t00)//'.xyz'
      zfnvstcdlon00 = 'vstcdlon.'//trim(suffix2t00)//'.xyz'
      zfnvmtcdlat04 = 'vmtcdlat.'//trim(suffix2t04)//'.xyz'
      zfnvmtcdlon04 = 'vmtcdlon.'//trim(suffix2t04)//'.xyz'
      zfnvmtcdeht04 = 'vmtcdeht.'//trim(suffix2t04)//'.xyz'
      zfnvstcdlat04 = 'vstcdlat.'//trim(suffix2t04)//'.xyz'
      zfnvstcdlon04 = 'vstcdlon.'//trim(suffix2t04)//'.xyz'
      zfnvmtcdlat10 = 'vmtcdlat.'//trim(suffix2t10)//'.xyz'
      zfnvmtcdlon10 = 'vmtcdlon.'//trim(suffix2t10)//'.xyz'
      zfnvmtcdeht10 = 'vmtcdeht.'//trim(suffix2t10)//'.xyz'
      zfnvstcdlat10 = 'vstcdlat.'//trim(suffix2t10)//'.xyz'
      zfnvstcdlon10 = 'vstcdlon.'//trim(suffix2t10)//'.xyz'

      bfnvmtcdlat00 = 'vmtcdlat.'//trim(suffix2t00)//'.b'
      bfnvmtcdlon00 = 'vmtcdlon.'//trim(suffix2t00)//'.b'
      bfnvmtcdeht00 = 'vmtcdeht.'//trim(suffix2t00)//'.b'
      bfnvstcdlat00 = 'vstcdlat.'//trim(suffix2t00)//'.b'
      bfnvstcdlon00 = 'vstcdlon.'//trim(suffix2t00)//'.b'
      bfnvmtcdlat04 = 'vmtcdlat.'//trim(suffix2t04)//'.b'
      bfnvmtcdlon04 = 'vmtcdlon.'//trim(suffix2t04)//'.b'
      bfnvmtcdeht04 = 'vmtcdeht.'//trim(suffix2t04)//'.b'
      bfnvstcdlat04 = 'vstcdlat.'//trim(suffix2t04)//'.b'
      bfnvstcdlon04 = 'vstcdlon.'//trim(suffix2t04)//'.b'
      bfnvmtcdlat10 = 'vmtcdlat.'//trim(suffix2t10)//'.b'
      bfnvmtcdlon10 = 'vmtcdlon.'//trim(suffix2t10)//'.b'
      bfnvmtcdeht10 = 'vmtcdeht.'//trim(suffix2t10)//'.b'
      bfnvstcdlat10 = 'vstcdlat.'//trim(suffix2t10)//'.b'
      bfnvstcdlon10 = 'vstcdlon.'//trim(suffix2t10)//'.b'

c - Difference grid names
      dbfnvmtcdlat1000 = 'vmtcdlat.'//trim(suffix2d1)//'.b'
      dbfnvstcdlat1000 = 'vstcdlat.'//trim(suffix2d1)//'.b'
      dbfnvmtcdlon1000 = 'vmtcdlon.'//trim(suffix2d1)//'.b'
      dbfnvstcdlon1000 = 'vstcdlon.'//trim(suffix2d1)//'.b'
      dbfnvmtcdeht1000 = 'vmtcdeht.'//trim(suffix2d1)//'.b'

      adbfnvmtcdlat1000 = 'vmtcdlat.'//trim(suffix2d2)//'.b'
      adbfnvstcdlat1000 = 'vstcdlat.'//trim(suffix2d2)//'.b'
      adbfnvmtcdlon1000 = 'vmtcdlon.'//trim(suffix2d2)//'.b'
      adbfnvstcdlon1000 = 'vstcdlon.'//trim(suffix2d2)//'.b'
      adbfnvmtcdeht1000 = 'vmtcdeht.'//trim(suffix2d2)//'.b'

      sadbfnvmtcdlat1000 = 'vmtcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlat1000 = 'vstcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdlon1000 = 'vmtcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlon1000 = 'vstcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdeht1000 = 'vmtcdeht.'//trim(suffix2d3)//'.b'

c - Due to a bug in GMT, the call will use "-I*m" rather
c - than "-I*s".  As such, convert igridsec to xgridmin.
      xgridmin = dble(igridsec)/60.d0

c - Do NOT generate a call to surface if there is no data
c - to grid.

c - Call to grid the thinned latitudes
      if(nthinhor.ne.0)then
        write(99,501)trim(gfnsmtcdlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdlat00),0.0,cmidlat
        write(99,501)trim(gfnsstcdlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvstcdlat00),0.0,cmidlat

        write(99,501)trim(gfnsmtcdlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdlat04),0.4,cmidlat
        write(99,501)trim(gfnsstcdlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvstcdlat04),0.4,cmidlat

        write(99,501)trim(gfnsmtcdlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdlat10),1.0,cmidlat
        write(99,501)trim(gfnsstcdlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvstcdlat10),1.0,cmidlat
      endif
      
c - Call to grid the thinned longitudes
      if(nthinhor.ne.0)then
        write(99,501)trim(gfnsmtcdlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdlon00),0.0,cmidlat
        write(99,501)trim(gfnsstcdlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvstcdlon00),0.0,cmidlat

        write(99,501)trim(gfnsmtcdlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdlon04),0.4,cmidlat
        write(99,501)trim(gfnsstcdlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvstcdlon04),0.4,cmidlat

        write(99,501)trim(gfnsmtcdlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdlon10),1.0,cmidlat
        write(99,501)trim(gfnsstcdlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvstcdlon10),1.0,cmidlat
      endif

c - Call to grid the thinned ellipsoid heights
      if(nthineht.ne.0)then
        write(99,501)trim(gfnsmtcdeht),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdeht00),0.0,cmidlat

        write(99,501)trim(gfnsmtcdeht),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdeht04),0.4,cmidlat

        write(99,501)trim(gfnsmtcdeht),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmtcdeht10),1.0,cmidlat
      endif

c - Calls to convert ".grd" to ".xyz"
      if(nthinhor.ne.0)then
        write(99,502)trim(rfnvmtcdlat00),trim(zfnvmtcdlat00)
        write(99,502)trim(rfnvstcdlat00),trim(zfnvstcdlat00)

        write(99,502)trim(rfnvmtcdlat04),trim(zfnvmtcdlat04)
        write(99,502)trim(rfnvstcdlat04),trim(zfnvstcdlat04)

        write(99,502)trim(rfnvmtcdlat10),trim(zfnvmtcdlat10)
        write(99,502)trim(rfnvstcdlat10),trim(zfnvstcdlat10)
      endif

      if(nthinhor.ne.0)then
        write(99,502)trim(rfnvmtcdlon00),trim(zfnvmtcdlon00)
        write(99,502)trim(rfnvstcdlon00),trim(zfnvstcdlon00)

        write(99,502)trim(rfnvmtcdlon04),trim(zfnvmtcdlon04)
        write(99,502)trim(rfnvstcdlon04),trim(zfnvstcdlon04)

        write(99,502)trim(rfnvmtcdlon10),trim(zfnvmtcdlon10)
        write(99,502)trim(rfnvstcdlon10),trim(zfnvstcdlon10)
      endif

      if(nthineht.ne.0)then
        write(99,502)trim(rfnvmtcdeht00),trim(zfnvmtcdeht00)

        write(99,502)trim(rfnvmtcdeht04),trim(zfnvmtcdeht04)

        write(99,502)trim(rfnvmtcdeht10),trim(zfnvmtcdeht10)
      endif

c - Calls to convert ".xyz" to ".b"
      if(nthinhor.ne.0)then
        write(99,503)trim(zfnvmtcdlat00),trim(bfnvmtcdlat00)
        write(99,503)trim(zfnvstcdlat00),trim(bfnvstcdlat00)

        write(99,503)trim(zfnvmtcdlat04),trim(bfnvmtcdlat04)
        write(99,503)trim(zfnvstcdlat04),trim(bfnvstcdlat04)

        write(99,503)trim(zfnvmtcdlat10),trim(bfnvmtcdlat10)
        write(99,503)trim(zfnvstcdlat10),trim(bfnvstcdlat10)
      endif

      if(nthinhor.ne.0)then
        write(99,503)trim(zfnvmtcdlon00),trim(bfnvmtcdlon00)
        write(99,503)trim(zfnvstcdlon00),trim(bfnvstcdlon00)

        write(99,503)trim(zfnvmtcdlon04),trim(bfnvmtcdlon04)
        write(99,503)trim(zfnvstcdlon04),trim(bfnvstcdlon04)

        write(99,503)trim(zfnvmtcdlon10),trim(bfnvmtcdlon10)
        write(99,503)trim(zfnvstcdlon10),trim(bfnvstcdlon10)
      endif

      if(nthineht.ne.0)then
        write(99,503)trim(zfnvmtcdeht00),trim(bfnvmtcdeht00)

        write(99,503)trim(zfnvmtcdeht04),trim(bfnvmtcdeht04)

        write(99,503)trim(zfnvmtcdeht10),trim(bfnvmtcdeht10)
      endif


  501 format(
     *'surface ',a,' -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
     *' -I',f0.2,'m -G',a,' -T',f3.1,' -A',s,f6.4,' -C0.01 -V')

c 501 format(
c    *'surface ',a,' -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
c    *' -I',f0.2,'m -G',a,' -T0.4 -A',s,f6.4,' -C0.01 -V')

  502 format(
     *'grd2xyz ',a,' -bo3f > ',a)
  503 format(
     *'xyz2b << !',/,
     *a,/,a,/,'!')
  504 format(
     *'subtrc << !',/,
     *a,/,a,/,a,/,'!')
  505 format(
     *'gabs << !',/,
     *a,/,a,/,'!')
  506 format(
     *'gscale << !',/,
     *a,/,f10.5,/,a,/,'!')
  507 format(
     *'b2xyz << !',/,a,/,'!',/,
     *'xyz2grd temp.xyz -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
     *' -I',f0.2,'m -bi3f -G',a,/,
     *'rm -f temp.xyz')

c - New, as of 10/27/2015:
c - Subtract the T=0.0 transformation grid
c - from the T=1.0 transformation grid.
c - Then take the absolute value of that
c - difference, and finally scale that
c - grid by 1/1.6929.  Do this for
c - all 5 possible transformation grids
c - All of these calls should be in the
c - "gmtbat02" file.


c - Differences first:
      if(nthinhor.ne.0)then
        write(99,504)trim(bfnvmtcdlat10),trim(bfnvmtcdlat00),
     *  trim(dbfnvmtcdlat1000)
        write(99,504)trim(bfnvstcdlat10),trim(bfnvstcdlat00),
     *  trim(dbfnvstcdlat1000)

        write(99,504)trim(bfnvmtcdlon10),trim(bfnvmtcdlon00),
     *  trim(dbfnvmtcdlon1000)
        write(99,504)trim(bfnvstcdlon10),trim(bfnvstcdlon00),
     *  trim(dbfnvstcdlon1000)
      endif

      if(nthineht.ne.0)then
        write(99,504)trim(bfnvmtcdeht10),trim(bfnvmtcdeht00),
     *  trim(dbfnvmtcdeht1000)
      endif

c - Make them absolute values:
      if(nthinhor.ne.0)then
        write(99,505)trim(dbfnvmtcdlat1000),trim(adbfnvmtcdlat1000)
        write(99,505)trim(dbfnvstcdlat1000),trim(adbfnvstcdlat1000)
        write(99,505)trim(dbfnvmtcdlon1000),trim(adbfnvmtcdlon1000)
        write(99,505)trim(dbfnvstcdlon1000),trim(adbfnvstcdlon1000)
      endif

      if(nthineht.ne.0)then
        write(99,505)trim(dbfnvmtcdeht1000),trim(adbfnvmtcdeht1000)
      endif

c - Finally, scale by 1/1.6929
      if(nthinhor.ne.0)then
        write(99,506)trim(adbfnvmtcdlat1000),rng2std,
     *  trim(sadbfnvmtcdlat1000)
        write(99,506)trim(adbfnvstcdlat1000),rng2std,
     *  trim(sadbfnvstcdlat1000)
        write(99,506)trim(adbfnvmtcdlon1000),rng2std,
     *  trim(sadbfnvmtcdlon1000)
        write(99,506)trim(adbfnvstcdlon1000),rng2std,
     *  trim(sadbfnvstcdlon1000)
      endif

      if(nthineht.ne.0)then
        write(99,506)trim(adbfnvmtcdeht1000),rng2std,
     *  trim(sadbfnvmtcdeht1000)
      endif

c - After all this, I now have the "d3" files as ".b" grids,
c - but in order to plot them, I'll have to convert them
c - to ".grd" files.  So here we go...
      if(nthinhor.ne.0)then
        write(99,507)trim(sadbfnvmtcdlat1000)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(sadrfnvmtcdlat1000)
        write(99,507)trim(sadbfnvstcdlat1000)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(sadrfnvstcdlat1000)
        write(99,507)trim(sadbfnvmtcdlon1000)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(sadrfnvmtcdlon1000)
        write(99,507)trim(sadbfnvstcdlon1000)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(sadrfnvstcdlon1000)
      endif

      if(nthineht.ne.0)then
        write(99,507)trim(sadbfnvmtcdeht1000)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(sadrfnvmtcdeht1000)
      endif

ccccccccccccccccccccccccccccccccccccc
c - 2016 06 29
c - MASK, Mask, mask code for HARN/FBN/CONUS combination
      if(trim(olddtm).eq.'nad83_harn' .and.
     *   trim(newdtm).eq.'nad83_fbn'  .and.
     *   trim(region).eq.'conus'      )then

        write(99,601) 


c - See DRU-12, p. 39
c - First, create the masked ".b" files...

        if(nthinhor.ne.0)then
          write(99,602)trim(bfnvmtcdlat04),
     *    trim(bfnvmtcdlat04)//'.premask',
     *    trim(bfnvmtcdlat04)//'.premask',
     *    trim(bfnvmtcdlat04),
     *    igridsec/30,igridsec/30

          write(99,602)trim(bfnvstcdlat04),
     *    trim(bfnvstcdlat04)//'.premask',
     *    trim(bfnvstcdlat04)//'.premask',
     *    trim(bfnvstcdlat04),
     *    igridsec/30,igridsec/30

          write(99,602)trim(bfnvmtcdlon04),
     *    trim(bfnvmtcdlon04)//'.premask',
     *    trim(bfnvmtcdlon04)//'.premask',
     *    trim(bfnvmtcdlon04),
     *    igridsec/30,igridsec/30

          write(99,602)trim(bfnvstcdlon04),
     *    trim(bfnvstcdlon04)//'.premask',
     *    trim(bfnvstcdlon04)//'.premask',
     *    trim(bfnvstcdlon04),
     *    igridsec/30,igridsec/30
        endif

        if(nthineht.ne.0)then
          write(99,602)trim(bfnvmtcdeht04),
     *    trim(bfnvmtcdeht04)//'.premask',
     *    trim(bfnvmtcdeht04)//'.premask',
     *    trim(bfnvmtcdeht04),
     *    igridsec/30,igridsec/30
        endif


c - Second, create the masked ".xyz" and masked ".grd" files
        if(nthinhor.ne.0)then
          write(99,603)
     *    trim(zfnvmtcdlat04),trim(zfnvmtcdlat04)//'.premask',
     *    trim(bfnvmtcdlat04),
     *    trim(zfnvmtcdlat04),
     *    trim(rfnvmtcdlat04),
     *    trim(rfnvmtcdlat04)//'.premask',
     *    trim(zfnvmtcdlat04),
     *    glomn,glomx,glamn,glamx,xgridmin,trim(rfnvmtcdlat04)

          write(99,603)
     *    trim(zfnvstcdlat04),trim(zfnvstcdlat04)//'.premask',
     *    trim(bfnvstcdlat04),
     *    trim(zfnvstcdlat04),
     *    trim(rfnvstcdlat04),
     *    trim(rfnvstcdlat04)//'.premask',
     *    trim(zfnvstcdlat04),
     *    glomn,glomx,glamn,glamx,xgridmin,trim(rfnvstcdlat04)

          write(99,603)
     *    trim(zfnvmtcdlon04),trim(zfnvmtcdlon04)//'.premask',
     *    trim(bfnvmtcdlon04),
     *    trim(zfnvmtcdlon04),
     *    trim(rfnvmtcdlon04),
     *    trim(rfnvmtcdlon04)//'.premask',
     *    trim(zfnvmtcdlon04),
     *    glomn,glomx,glamn,glamx,xgridmin,trim(rfnvmtcdlon04)

          write(99,603)
     *    trim(zfnvstcdlon04),trim(zfnvstcdlon04)//'.premask',
     *    trim(bfnvstcdlon04),
     *    trim(zfnvstcdlon04),
     *    trim(rfnvstcdlon04),
     *    trim(rfnvstcdlon04)//'.premask',
     *    trim(zfnvstcdlon04),
     *    glomn,glomx,glamn,glamx,xgridmin,trim(rfnvstcdlon04)
        endif

        if(nthineht.ne.0)then
          write(99,603)
     *    trim(zfnvmtcdeht04),trim(zfnvmtcdeht04)//'.premask',
     *    trim(bfnvmtcdeht04),
     *    trim(zfnvmtcdeht04),
     *    trim(rfnvmtcdeht04),
     *    trim(rfnvmtcdeht04)//'.premask',
     *    trim(zfnvmtcdeht04),
     *    glomn,glomx,glamn,glamx,xgridmin,trim(rfnvmtcdeht04)
        endif

  603 format(
     *'mv ',a,' ',a,/,
     *'b2xyz << !',/,a,/,'!',/,  
     *'mv temp.xyz ',a,/,
     *'mv ',a,' ',a,/,
     *'xyz2grd ',a,' -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
     *' -I',f0.2,'m -bis -G',a)

      endif
  601 format('echo Applying MASK for HARN FBN CONUS 04 grids')

  602 format(
     *'mv ',a,' ',a,/,
     *'regrd2 << !',/,
     *a,/,
     *'dummy1.b',/,
     *'3121',/,
     *'7081',/,
     *'!',/,
     *'convlv << !',/
     *'dummy1.b',/,
     *'Masks/mask.harnfbn.30.b',/,
     *'dummy2.b',/,
     *'!',/,
     *'decimate << !',/
     *'dummy2.b',/,
     *a,/,
     *i3,/,
     *i3,/,
     *'!',/,
     *'rm -f dummy1.b',/,
     *'rm -f dummy2.b')



  




ccccccccccccccccccccccccccccccccccccc



      write(99,1031)trim(gmtfile)
 1031 format('echo END batch file ',a)
      close(99)

      write(6,9999)
 9999 format('END mymedian5.f')


 2006 format('Cell ',i8,' Poscode: ',i12)
 2007 format(6x,'Pt : ',i5)
      end    
c
c -----------------------------------------------
c
      subroutine getmedian(zs,max,inumlo,inumhi,indx,
     *maxppcell,dist,iiival)
      real*8 zs(max),dist(max)
      integer*4 indx(max),indx2(maxppcell)
      integer*4 inumlo,inumhi

      real*8 zz(maxppcell)
  

c     write(6,1)inumlo,inumhi
c   1 format('Inside getmedian',/,
c    *'inumlo,inumhi = ',i8,1x,i8)

c - When the whole set of "zs" data is sorted by
c - "whichcell", then the "indx" values are our
c - key to that sort.  The "zs" data remains
c - in "read order" (1-nkt), but the indx values   
c - (also in "read order" point to the sorted
c - order.

c     write(6,*) ' UNSORTED data: '

      nval = inumhi-inumlo+1
      iq = 0
      do 2 i=inumlo,inumhi
        iq = iq + 1
        zz(iq) = zs(indx(i))
c       write(6,3)i,iq,zz(iq)
    2 continue
    3 format(i10,1x,i10,1x,f20.10)

c - Sort this mini vector
c     call hpsort(nval,maxppcell,zz)

      call indexxd(nval,maxppcell,zz,indx2)

c     write(6,*) ' SORTED data: '

c     do 4 i=1,nval
c       write(6,3)i,indx2(i),zz(indx2(i))
c   4 continue
    5 format(i10,1x,f20.10)

c - True median comes from an odd number of values.  If
c - it is even, take the one which sits closest to the
c - center of the cell.
      if(mod(nval,2).eq.1)then
        ival = (nval+1)/2
      else
        ival1 = nval/2
        ival2 = ival1 + 1
c       write(6,*) ' MedianLo = ',zz(indx2(ival1))
c       write(6,*) ' MedianHi = ',zz(indx2(ival2))
c       write(6,*) ' Dist  Lo = ',dist(indx2(ival1))
c       write(6,*) ' Dist  Hi = ',dist(indx2(ival2))
        if(dist(indx2(ival1)).lt.dist(indx2(ival2)))then
c         write(6,*) ' Median Set to LO = ',zz(indx2(ival1))
          ival = ival1 
        else 
c         write(6,*) ' Median Set to HI = ',zz(indx2(ival2))
          ival = ival2
        endif
      endif

c - Note that "iiival" is the read-order number of the
c - point chosen as median for the cell we're analyzing 
c - in this subroutine.
c       write(6,*) ' Median = ',zz(indx2(ival))
        igood1 = indx2(ival)
c       write(6,*) ' ival = ',ival
c       write(6,*) ' indx2(ival) = ',indx2(ival)
        iival = inumlo + indx2(ival) - 1
c       write(6,*) ' iival = ',iival
        iiival = indx(iival)
c       write(6,*) ' indx(iival) = ',indx(iival)


      return
      end

      include 'Subs/getgridbounds.f'
      include 'Subs/indexxi.for'
      include 'Subs/indexxd.for'
