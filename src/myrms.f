c> \ingroup doers    
c> Part of the NADCON5 build process, generates `gmtbat05`
c> 
c> Creates a batch file called 
c>       
c>       gmtbat05.(olddtm).(newdtm).(region).(igridsec)
c> 
c> 
c> Program to 
c> 1. Run a customized RMS-computing
c>    algorithm on vector differences (gridded minus true)
c> 2. Save the RMS data to GMT-ready plottable files
c> 3. Create a GMT batch file to plot both the 
c>    thinned data and removed data in both coverage and vectors
c> 
c> Unlike "mymedian5.f", this program is
c> set up to compute the RMS of vector differences
c> in a cell-by-cell basis (aka NOT a median filter
c> at all, but a true RMS representation of of disagreements)
c> 
c> A "value" is the differential vector of:
c> 
c>     interpolated-from-grid minus true
c>
c> For any cell with at least ONE point with a value, the following is done:
c> 1. Compute the average latitude of all points in the cell
c> 2. Compute the average longitude of all points in the cell
c> 3. Compute the RMS of all values in the cell
c> 
c> The output vector will then reflect these three values.
c> 
c> For latitude and ellipsoid height, the azimuth of the vector 
c> will ALWAYS be 0.0 (pointing up) while for longitude it will
c> always be 90.0 (pointing right).  However, these are mere conventions
c> as they are not directional vectors anyway, but rather quanta which
c> will be gridded and it is the grid which is of utmost importance.
c> 
c> No PIDS will be in the output files, as the output RMS vectors are
c> not reflective of any one point, but rather a cell-wide conglomeration
c> of information.
c> 
c> See DRU-11, p. 130
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> They are enumerated here
c> \param oldtm Source Datum
c> \param newdtm Target Datum,region
c> \param region Conversion Region 
c> \param agridsec Grid Spacing in arcsec
c>     
c> Example:
c>     
c>     olddatum = 'ussd'
c>     newdatum = 'nad27'
c>     region = 'conus'
c>     agridsec = '900'    
c>      
c> ### Program Inputs:
c> 
c> ## Changelog
c> 
c> ### 2016 01 21:
c> Updated to RETURN to an old way of registering RMS vectors
c> at AVE lat/lon rather than center of cell.
c> 
c> ### 2015 10 28 
c> Updated to work with new naming scheme (see DRU-11, p. 150) and
c> to adopt the central lat/lon for the RMS vectors, rather than 
c> ave lat/ave lon (see DRU-11, p.145), and to also set up the gridding
c> of RMS vectors at the T=0.9 level (see DRU-11, p. 148)
c> 
c> Also added "donzd" functionality to help control the magnitude
c> of the Length of Reference Vector on Ground variables.
c> 
c> Also, added a section at the end to create the TOTAL error grids.
c> by RMS-combining the "method noise grid" (the "d3" grid)
c> with the "data noise grid" (the "rdd...09" grid) into
c> one single "transformation error grid"
c> 
c> ### 2016 08 25: 
c> For reasons that are difficult to describe, "donzd" is 
c> now "onzd2.f" in /home/dru/Subs.  Change and recompile...
c> 
c> ### 2015 10 09: 
c> Updated to add HOR vectors
c> 
c> ### 2015 10 06:
c> Updated
c> 
c> ### 2015 09 16:
c> Initial Release, For use in creating NADCON5
c> Built by Dru Smith
c> 
c>       
      program myrms
      
      implicit real*8(a-h,o-z)

c - Allow up to 280,000 points to come in 
c - which also translates to letting 280,000 grid cells
c -  to be non-empty.
      parameter(max=280000)

c - And using a little hit or miss logic, the number
c - of possible points in one cell can't be more than
c - about 5000, right?
      parameter(maxppcell=5000)

c - Holding place for each record, in read-order
      character*80 cards(max)
      real*8 xlat(max),xlon(max),z0(max),zm(max)

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
      character*200 suffix2t04,suffix2t09,suffix2d3

c - Input GMT-ready differentical vector files containing all points:
      character*200 gfnvmaddlat,gfnvmaddlon,gfnvmaddeht
      character*200 gfnvsaddlat,gfnvsaddlon
      character*200 gfnvsaddhor,gfnvmaddhor   ! 2015 10 09
c - Output GMT-ready RMS differential vector files:
      character*200 gfnvmrddlat,gfnvmrddlon,gfnvmrddeht
      character*200 gfnvsrddlat,gfnvsrddlon
      character*200 gfnvsrddhor,gfnvmrddhor   ! 2015 10 09
c - Output RMS GMT(surface)-ready RMS differential vector files:
      character*200 gfnsmrddlat,gfnsmrddlon,gfnsmrddeht
      character*200 gfnssrddlat,gfnssrddlon
c - Output RMS GMT-read RMS differential vector COVERAGE files:
      character*200 gfncvrddlat,gfncvrddlon,gfncvrddeht
c - To be created ".grd" files by surface 
      character*200 rfnvmrddlat,rfnvmrddlon,rfnvmrddeht
      character*200 rfnvsrddlat,rfnvsrddlon
c - To be created ".xyz" files by GMT's grd2xyz program
      character*200 zfnvmrddlat,zfnvmrddlon,zfnvmrddeht
      character*200 zfnvsrddlat,zfnvsrddlon
c - To be created ".b" files by grd2b
      character*200 bfnvmrddlat,bfnvmrddlon,bfnvmrddeht
      character*200 bfnvsrddlat,bfnvsrddlon
c - Stats file name
      character*200 sfn
      logical*1 nothinlat,nothinlon,nothineht

c - "Method Noise" grids:
      character*200 sadbfnvmtcdlat1000,sadbfnvmtcdlon1000
      character*200 sadbfnvmtcdeht1000
      character*200 sadbfnvstcdlat1000,sadbfnvstcdlon1000
c -" Total Error" grids in ".b" format:
      character*200 bfnvsetelat,bfnvsetelon
      character*200 bfnvmetelat,bfnvmetelon
      character*200 bfnvmeteeht
c -" Total Error" grids in "grd" format:
      character*200 rfnvsetelat,rfnvsetelon
      character*200 rfnvmetelat,rfnvmetelon
      character*200 rfnvmeteeht


c - Dummy
      character*200 fused,gfndv,gfnsu
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

      real*8 lorvopc,lorvog0,lorvogm
      real*8 lorvoghorddm,lorvoghordds

      real*8 basedd(5)

c --------------------------------------
c --------------------------------------
c --------------------------------------
c -------BEGIN GUTS OF PROGRAM----------
c --------------------------------------
c --------------------------------------
c --------------------------------------
      write(6,1001)
 1001 format('BEGIN program myrms.f')

c ------------------------------------------------------------------
c - Some required constants.
c ------------------------------------------------------------------
      lorvopc = 1.d0
      pi  = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      re  = 6371000.d0
      s2m = (1/3600.d0)*d2r*re
      MultiplierLorvog = 2

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
      suffix2t04=trim(suffix2)//'.04'
      suffix2t09=trim(suffix2)//'.09'
      suffix2d3=trim(suffix2)//'.d3'

c ------------------------------------------------------------------
c - Open the GMT batch file for gridding the RMS data
c ------------------------------------------------------------------
      gmtfile = 'gmtbat05.'//trim(suffix2)
      open(99,file=gmtfile,status='new',form='formatted')
      write(6,1011)trim(gmtfile)
 1011 format(6x,'myrms.f: Creating GMT batch file ',a)
      write(99,1030)trim(gmtfile)
 1030 format('echo BEGIN batch file ',a)


c ------------------------------------------------------------------
c - Open the "dvstats" file generated by "checkgrid", and use it
c - to determine which, if any, elements (lat, lon, eht) to skip
c ------------------------------------------------------------------
      sfn = 'dvstats.'//trim(suffix2)
      open(2,file=sfn,status='old',form='formatted')
      write(6,1003)trim(sfn)
 1003 format(6x,'myrms.f: Opening exisiting stats file ',a)
      read(2,*)nlat,rmslat
      read(2,*)nlon,rmslon
      read(2,*)neht,rmseht
      nothinlat = .false.
      nothinlon = .false.
      nothineht = .false.
      if(nlat.eq.0)nothinlat=.true.
      if(nlon.eq.0)nothinlon=.true.
      if(neht.eq.0)nothineht=.true.

c ------------------------------------------------------------------
c - Open the input, raw, differential vector GMT-ready files
c - Note, unlike "mymedian5", these file names already
c - contain the grid spacing, since they refer to differences
c - relative to a grid that is grid-spacing dependent.
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnvsaddlat = 'vsaddlat.'//trim(suffix2)
        open(21,file=gfnvsaddlat,status='old',form='formatted')
        write(6,1010)trim(gfnvsaddlat)

        gfnvmaddlat = 'vmaddlat.'//trim(suffix2)
        open(26,file=gfnvmaddlat,status='old',form='formatted')
        write(6,1010)trim(gfnvmaddlat)
      endif

      if(.not.nothinlon)then
        gfnvsaddlon = 'vsaddlon.'//trim(suffix2)
        open(22,file=gfnvsaddlon,status='old',form='formatted')
        write(6,1010)trim(gfnvsaddlon)

        gfnvmaddlon = 'vmaddlon.'//trim(suffix2)
        open(27,file=gfnvmaddlon,status='old',form='formatted')
        write(6,1010)trim(gfnvmaddlon)
      endif

      if(.not.nothineht)then
        gfnvmaddeht = 'vmaddeht.'//trim(suffix2)
        open(23,file=gfnvmaddeht,status='old',form='formatted')
        write(6,1010)trim(gfnvmaddeht)
      endif

      if(.not.nothinlat .and. .not.nothinlon)then
        gfnvsaddhor = 'vsaddhor.'//trim(suffix2)
        open(24,file=gfnvsaddhor,status='old',form='formatted')
        write(6,1010)trim(gfnvsaddhor)

        gfnvmaddhor = 'vmaddhor.'//trim(suffix2)
        open(25,file=gfnvmaddhor,status='old',form='formatted')
        write(6,1010)trim(gfnvmaddhor)
      endif

 1010 format(6x,'myrms.f: ',
     *'Opening existing raw differential vector file ',a)

c ------------------------------------------------------------------
c - Open the output, RMS'd, GMT-ready DIFFERENTIAL VECTOR files
c - "r" means "rms of differential"
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnvsrddlat = 'vsrddlat.'//trim(suffix2)
        open(41,file=gfnvsrddlat,status='new',form='formatted')
        write(6,1012)trim(gfnvsrddlat)

        gfnvmrddlat = 'vmrddlat.'//trim(suffix2)
        open(46,file=gfnvmrddlat,status='new',form='formatted')
        write(6,1012)trim(gfnvmrddlat)
      endif

      if(.not.nothinlon)then
        gfnvsrddlon = 'vsrddlon.'//trim(suffix2)
        open(42,file=gfnvsrddlon,status='new',form='formatted')
        write(6,1012)trim(gfnvsrddlon)

        gfnvmrddlon = 'vmrddlon.'//trim(suffix2)
        open(47,file=gfnvmrddlon,status='new',form='formatted')
        write(6,1012)trim(gfnvmrddlon)
      endif

      if(.not.nothineht)then
        gfnvmrddeht = 'vmrddeht.'//trim(suffix2)
        open(43,file=gfnvmrddeht,status='new',form='formatted')
        write(6,1012)trim(gfnvmrddeht)
      endif

      if(.not.nothinlat .and. .not.nothinlon)then
        gfnvsrddhor = 'vsrddhor.'//trim(suffix2)
        open(44,file=gfnvsrddhor,status='new',form='formatted')
        write(6,1010)trim(gfnvsrddhor)

        gfnvmrddhor = 'vmrddhor.'//trim(suffix2)
        open(45,file=gfnvmrddhor,status='new',form='formatted')
        write(6,1010)trim(gfnvmrddhor)
      endif

 1012 format(6x,'myrms.f: ',
     *'Opening output RMS differential vector file ',a)

c ------------------------------------------------------------------
c - Open the output, RMS'd, GMT-ready differential COVERAGE files
c - "r" means "rms of differential"
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfncvrddlat = 'cvrddlat.'//trim(suffix2)
        open(51,file=gfncvrddlat,status='new',form='formatted')
        write(6,1013)trim(gfncvrddlat)
      endif

      if(.not.nothinlon)then
        gfncvrddlon = 'cvrddlon.'//trim(suffix2)
        open(52,file=gfncvrddlon,status='new',form='formatted')
        write(6,1013)trim(gfncvrddlon)
      endif

      if(.not.nothineht)then
        gfncvrddeht = 'cvrddeht.'//trim(suffix2)
        open(53,file=gfncvrddeht,status='new',form='formatted')
        write(6,1013)trim(gfncvrddeht)
      endif

 1013 format(6x,'myrms.f: ',
     *'Opening output RMS differential coverage file ',a)

c ------------------------------------------------------------------
c - Open the output, RMS'd GMT-ready files for pushing
c - through "surface" to get a grid.
c - "r" meaning "RMS'd"
c ------------------------------------------------------------------
      if(.not.nothinlat)then
        gfnssrddlat = 'ssrddlat.'//trim(suffix2)
        open(71,file=gfnssrddlat,status='new',form='formatted')
        write(6,1014)trim(gfnssrddlat)

        gfnsmrddlat = 'smrddlat.'//trim(suffix2)
        open(76,file=gfnsmrddlat,status='new',form='formatted')
        write(6,1014)trim(gfnsmrddlat)
      endif

      if(.not.nothinlon)then
        gfnssrddlon = 'ssrddlon.'//trim(suffix2)
        open(72,file=gfnssrddlon,status='new',form='formatted')
        write(6,1014)trim(gfnssrddlon)

        gfnsmrddlon = 'smrddlon.'//trim(suffix2)
        open(77,file=gfnsmrddlon,status='new',form='formatted')
        write(6,1014)trim(gfnsmrddlon)
      endif

      if(.not.nothineht)then
        gfnsmrddeht = 'smrddeht.'//trim(suffix2)
        open(73,file=gfnsmrddeht,status='new',form='formatted')
        write(6,1014)trim(gfnsmrddeht)
      endif

 1014 format(6x,'myrms.f: ',
     *'Opening output RMS differential vector ',
     *'file (for surface):',a) 

c ------------------------------------------------------------------
c - Each region has officially chosen boundaries (which may
c - or may not agree with the MAP boundaries).  Get the
c - official grid boundaries here.  See DRU-11, p. 126
c ------------------------------------------------------------------
      call getgridbounds(region,glamx,glamn,glomn,glomx)

      write(6,1004)trim(region),glamn,glamx,glomn,glomx
 1004 format(6x,'myrms.f: Region= ',a,/,
     *       6x,'myrms.f: North = ',f12.6,/,
     *       6x,'myrms.f: South = ',f12.6,/,
     *       6x,'myrms.f: West  = ',f12.6,/,
     *       6x,'myrms.f: East  = ',f12.6)

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
 3001 format(6x,'myrms.f Cell Structure:',/,
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
c - MAIN LOOP
c -     First trip is to process on differential
c -     latitude vectors (both units).  Second trip 
c -     on differential longitude vectors (both units).
c -     Third trip on differential ellipsoid height vectors (meters only).
c -     What's done in each trip:
c -     1) Data are sorted into respective cells
c -     2) An overall RMS value for the whole dataset is tallied
c -     3) After all data are in RAM, each cell's average latitude,
c -        average longitude and RMS value are computed 
c -     4) The data in #3 is put (including proper scaling, based on
c -        the overall RMS value) into a vector plot file
c -     5) The data in #3 is put (no scaling necessary) into a
c -        file ready to go into surface for gridding.
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------
c -----------------------------------------------------------------------

      nrmslat = 0
      nrmslon = 0
      nrmseht = 0

      do 2001 iloop = 1,3

        if(iloop.eq.1)then
          write(6,2002)trim(gfnvsrddlat)
          write(6,2002)trim(gfnvmrddlat)
        endif
        if(iloop.eq.2)then
          write(6,2002)trim(gfnvsrddlon)
          write(6,2002)trim(gfnvmrddlon)
        endif
        if(iloop.eq.3)then
          write(6,2002)trim(gfnvmrddeht)
        endif

        if(iloop.eq.1 .and. nothinlat)goto 2001
        if(iloop.eq.2 .and. nothinlon)goto 2001
        if(iloop.eq.3 .and. nothineht)goto 2001

        lin = 20 + iloop

        if(iloop.eq.1 .or. iloop.eq.3)az=0.d0
        if(iloop.eq.2                )az=90.d0

 2002   format(6x,'myrms.f : RMS computing on file     :',a)


c 101   format(f16.10,1x,f15.10,1x,6x  ,1x,12x  ,1x,5x  ,1x,f9.5,1x,a6)
c - To pull arcseconds:
  101 format(f16.10,1x,f15.10,1x,  6x,1x,  12x,1x,f9.5,1x,  9x,1x,a6)
c - To pull meters:
 1101 format(f16.10,1x,f15.10,1x,  6x,1x,  12x,1x,  9x,1x,f9.3,1x,a6)



 2003   format(6x,'myrms.f : Point outside boundaries: ',
     *  f16.10,1x,f15.10,1x,f9.5,1x,a6)

c - Set the count of how many values are in each non-empty
c - grid cell to zero, as well as the count of how many cells
c - have data to zero
        do 201 i=1,max
          ppcell(i)=0      
  201   continue
        ncells = 0

c - Top of READ loop
c - "ikt" is the count of all records in the vector file
c - whether we keep them or not.  "ipid" is the count
c - points found that are inside our grid boundaries.
        ikt  = 0
        ipid = 0

c - rmsoverallm is the RMS of all vectors in one file,
c - converted into meters.
        rmsoverallm = 0.d0

  100   read(lin,'(a)',end=777)card
          if(iloop.le.2)read(card, 101)glo,gla,z,pid
          if(iloop.eq.3)read(card,1101)glo,gla,z,pid
          ikt = ikt + 1

c - Store the read data and values both
          cards(ikt) = card
c - z0 = primary coordinates
          z0(ikt)    = z
          xlat(ikt)  = gla
          xlon(ikt)  = glo
          if    (iloop.eq.1)then
            zm(ikt) = z * s2m
          elseif(iloop.eq.2)then
            coslat = dcos(gla*d2r)
            zm(ikt) = z * s2m * coslat
          else
            zm(ikt)= z
          endif
          rms0 = rms0 + z0(ikt)**2
          rmsm = rmsm + zm(ikt)**2

c - Double check that the data we're using is inside our
c - pre-arranged grid boundaries for this region
          if(gla.lt.glamn.or.gla.gt.glamx .or.
     *       glo.lt.glomn.or.glo.gt.glomx) then
            write(6,2003)gla,glo,z,pid
            goto 100
          endif

          ipid = ipid + 1

c - Determine which row and column our point falls in.  Then
c - convert that combination of row/col into a single
c - value (encoded as ila*100000+ilo)
          ila=idnint((gla-glamn)/dgla)+1
          ilo=idnint((glo-glomn)/dglo)+1
          ipos=ila*100000+ilo 

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
          whichcell(ikt) = ncells

  203     continue

        goto 100

  777   continue

c - At this point, I've read ONE differential vector
c - file into RAM and identified the cell of each
c - entry.

        nkt = ikt
        npid = ipid

        rms0 = dsqrt(rms0/nkt)
        rmsm = dsqrt(rmsm/nkt)

        if(iloop.eq.1)nrmslat = nkt
        if(iloop.eq.2)nrmslon = nkt
        if(iloop.eq.3)nrmseht = nkt

c - Use the RMS value to compute scales needed for our output vector file.
c - Why not AVE?  Because the AVE is expected to be VERY close to zero
c - but RMS represents a better overall level of disagreement.  

c       iq0 = floor(log10(rms0))
c       qq0 = 10.d0**(iq0-1)
c       lorvog0 = MultiplierLorvog*qq0*nint(rms0/qq0)
        lorvog0 = onzd2(MultiplierLorvog*rms0)
        g02pc = lorvopc / lorvog0

c       iqm = floor(log10(rmsm))
c       qqm = 10.d0**(iqm-1)
c       lorvogm = MultiplierLorvog*qqm*nint(rmsm/qqm)
        lorvogm = onzd2(MultiplierLorvog*rmsm)
        gm2pc = lorvopc / lorvogm

c - 2015 10 09
        if(iloop.eq.1)then
          basedd(1) = rms0
          basedd(4) = rmsm
        endif
        if(iloop.eq.2)then
          basedd(2) = rms0
          basedd(5) = rmsm
        endif


        write(6,2004) nkt,npid,igridsec,ncells
 2004   format(
     *6x,'myrms.f: Done with file  ',/,
     *6x,'myrms.f: Points in File            : ',i10,/,
     *6x,'myrms.f: Points within Grid Bounds : ',i10,/,
     *6x,'myrms.f: Cell Size (Arcseconds)    : ',i10,/,
     *6x,'myrms.f: Number of Cells with Data : ',i10)
        write(6,2005)
 2005   format(6x,'myrms.f: Begin RMS computations')

c - Sort all of our data (nkt values) by their poscode
        write(6,2020)
 2020   format(6x,'myrms.f : Sorting data...')
        call indexxi(nkt,max,whichcell,indx)

c - Spit out our data in WHICHCELL order
c       do 400 i=1,nkt
c         j = indx(i)
c         icell = whichcell(j)
c         if(mod(i,1000).eq.0)then
c         write(6,2010)cards(j),icell,ilapcell(icell),
c    *    ilopcell(icell),poscode(icell)
c         endif
c 400   continue
 2010   format(i8,1x,a80,1x,4(i10))

c - 2015/11/06:  Change from average lat/lon to
c - center of cell for registration of RMS vector,
c - as per discussions with Andria

c - Now go through each cell and compute
c - the average latitude, average longitude
c - and RMS value.  As each alat/alon/rval is found,
c - put it in the appropriate output vector file.
c - Change as of 10/28/2015:  No longer using
c - average lat/lon, but rather center of cell.
 
        inumlo = 0
        inumhi = 0
        ikt = 0

        if(iloop.eq.1)then
          write(6,2021)trim(gfnvsrddlat),trim(gfnssrddlat)
          write(6,2021)trim(gfnvmrddlat),trim(gfnsmrddlat)
        endif
        if(iloop.eq.2)then
          write(6,2021)trim(gfnvsrddlon),trim(gfnssrddlon)
          write(6,2021)trim(gfnvmrddlon),trim(gfnsmrddlon)
        endif
        if(iloop.eq.3)then
          write(6,2021)trim(gfnvmrddeht),trim(gfnsmrddeht)
        endif

 2021   format(6x,'myrms.f : ',
     *  'Populating RMS diff vec               file: ',a,/,
     *  6x,'myrms.f : ',
     *  'Populating RMS diff vec surface-ready file: ',a)

        ifileout1 = 40+iloop   ! DD vectors, primary units
        ifileout3 = 50+iloop   ! DD coverage
        ifileout2 = 70+iloop   ! DD vectors for surface, primary units

        do 401 icell=1,ncells
          inumlo = inumhi + 1 
          inumhi = inumlo + ppcell(icell) - 1

c - 10/28/2015:  removed...useless, right?
c         do 402 jpt=1,ppcell(icell)
c           ikt = ikt + 1
c           j = indx(ikt)
c 402     continue 

          call getrms(z0,max,inumlo,inumhi,indx,
     *    maxppcell,xlat,xlon,alat,alon,rval0)

c - 01/21/2016: Returned to use of AVE lat/lon for registering RMS vectors
c - 10/28/2015:  Use center of cell
c         ila = ilapcell(icell) 
c         ilo = ilopcell(icell)
c         glacc = glamn + (ila-1)*dgla + (dgla/2.d0)
c         glocc = glomn + (ilo-1)*dglo + (dglo/2.d0)
c         alat = glacc
c         alon = glocc

          if    (iloop.eq.1)then
            rvalm = rval0 * s2m
          elseif(iloop.eq.2)then
            coslat = dcos(alat*d2r)
            rvalm = rval0 * s2m * coslat 
          else
            rvalm = rval0
          endif
          vc0 = dabs(rval0 * g02pc)
          vcm = dabs(rvalm * gm2pc)

c - For vector plotting:
          write(ifileout1  ,2101)alon,alat,az,vc0,rval0,rvalm
          if(iloop.lt.3)
     *    write(ifileout1+5,2101)alon,alat,az,vcm,rval0,rvalm
 2101     format(f16.10,1x,f15.10,1x,f6.2,1x,
     *    f12.2,1x,f9.5,1x,f9.3)

c - For coverage plotting:
          write(ifileout3,2103)alon,alat,1.0
 2103     format(f16.10,1x,f15.10,1x,f6.2)

c - For use in surface for gridding:
          write(ifileout2  ,2102)alon,alat,rval0
          if(iloop.lt.3)
     *    write(ifileout2+5,2102)alon,alat,rvalm
 2102     format(f16.10,1x,f15.10,1x,f10.5) 

  401   continue

 2001 continue

c -------------------------------------------------
c - 2015 10 09
c - Spin through the newly created RMS DD vectors in
c - lat/lon (in sec and meters) and create an RMS DD
c - vector file in HOR (in sec and meters)  
c 
c - Do NOT create this from the "add" horizontal
c - files, but rather from the newly created "rdd"
c - lat and lon files.
c -------------------------------------------------

      baseddhors = sqrt(basedd(1)**2+basedd(2)**2)
      baseddhorm = sqrt(basedd(4)**2+basedd(5)**2)

c     iqhorddm = floor(log10(baseddhorm))
c     qqhorddm = 10.d0**(iqhorddm-1)
c     lorvoghorddm = MultiplierLorvog*qqhorddm*nint(baseddhorm/qqhorddm)
      lorvoghorddm = onzd2(MultiplierLorvog*baseddhorm)
      gm2pchordd = lorvopc / lorvoghorddm

c     iqhordds = floor(log10(baseddhors))
c     qqhordds = 10.d0**(iqhordds-1)
c     lorvoghordds = MultiplierLorvog*qqhordds*nint(baseddhors/qqhordds)
      lorvoghordds = onzd2(MultiplierLorvog*baseddhors)
      gs2pchordd = lorvopc / lorvoghordds

      write(6,2504)
 2504 format
     *(6x,'myrms.f: Populating RMS dd horizontal vector files')
      iflats = 41
      iflons = 42
      iflatm = 46
      iflonm = 47
      ifhors = 44
      ifhorm = 45
      rewind(iflats)
      rewind(iflons)
      rewind(iflatm)
      rewind(iflonm)
 2503 read(iflats,2101,end=2502)xlo1,xla1,az1,vc1,xs1,xm1
        read(iflons,2101)xlo2,xla2,az2,vc2,xs2,xm2
        if(xlo1.ne.xlo2)stop 10501
        if(xla1.ne.xla2)stop 10502
c       if(az1.ne.90.00)stop 10503
c       if(az2.ne. 0.00)stop 10504
        azhor = datan2(xm2,xm1)/d2r
        if(azhor.lt.0)azhor = azhor + 360.d0
        xshor = dsqrt(xs1**2 + xs2**2)
        xmhor = dsqrt(xm1**2 + xm2**2) 
        vchors = xshor * gs2pchordd
        vchorm = xmhor * gm2pchordd
        write(ifhors,2101)xlo1,xla1,azhor,vchors,xshor,xmhor
        write(ifhorm,2101)xlo1,xla1,azhor,vchorm,xshor,xmhor
      goto 2503
 2502 continue

c -------------------------------------------------------
c - Based on everything we have so far, put a bunch
c - of "surface" calls into the GMT batch file.
c - These will be to turn the RMS'd differential vector data
c - into grids.  DO NOT GENERATE A CALL TO SURFACE
c - IF THE NUMBER OF RMS'd DATA IS ZERO.

c - Because "surface", as part of GMT, returns its
c - own binary grid format (called ".grd" herein), it must be
c - converted to ".b" format.  The easiest way to 
c - do so is to use the GMT built-in routine "grd2xyz"
c - with the "-bos" extension to create a binary XYZ
c - list file.  Then run Dennis's homemade "xyz2b.for" 
c - routine to finally arrive at the ".b" binary grid format.
c
c - 2015/11/06:  Updated to put the ".09." in the names
c -------------------------------------------------------
      cmidlat=dcos(((glamn+glamx)/2.d0)*d2r)
      rfnvsrddlat = 'vsrddlat.'//trim(suffix2t09)//'.grd'
      rfnvsrddlon = 'vsrddlon.'//trim(suffix2t09)//'.grd'
      rfnvmrddeht = 'vmrddeht.'//trim(suffix2t09)//'.grd'
      rfnvmrddlat = 'vmrddlat.'//trim(suffix2t09)//'.grd'
      rfnvmrddlon = 'vmrddlon.'//trim(suffix2t09)//'.grd'

      zfnvsrddlat = 'vsrddlat.'//trim(suffix2t09)//'.xyz'
      zfnvsrddlon = 'vsrddlon.'//trim(suffix2t09)//'.xyz'
      zfnvmrddeht = 'vmrddeht.'//trim(suffix2t09)//'.xyz'
      zfnvmrddlat = 'vmrddlat.'//trim(suffix2t09)//'.xyz'
      zfnvmrddlon = 'vmrddlon.'//trim(suffix2t09)//'.xyz'

      bfnvsrddlat = 'vsrddlat.'//trim(suffix2t09)//'.b'
      bfnvsrddlon = 'vsrddlon.'//trim(suffix2t09)//'.b'
      bfnvmrddeht = 'vmrddeht.'//trim(suffix2t09)//'.b'
      bfnvmrddlat = 'vmrddlat.'//trim(suffix2t09)//'.b'
      bfnvmrddlon = 'vmrddlon.'//trim(suffix2t09)//'.b'

c - Due to a bug in GMT, the call will use "-I*m" rather
c - than "-I*s".  As such, convert igridsec to xgridmin.
      xgridmin = dble(igridsec)/60.d0

c - Do NOT generate a call to surface if there is no data
c - to grid.

c - Call to grid the RMS'd latitudes
      if(nrmslat.ne.0)then
        write(99,501)trim(gfnssrddlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvsrddlat),cmidlat
        write(99,501)trim(gfnsmrddlat),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmrddlat),cmidlat
      endif
      
c - Call to grid the RMS'd longitudes
      if(nrmslon.ne.0)then
        write(99,501)trim(gfnssrddlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvsrddlon),cmidlat
        write(99,501)trim(gfnsmrddlon),glomn,glomx,glamn,glamx,
     *  xgridmin,trim(rfnvmrddlon),cmidlat
      endif

c - Call to grid the RMS'd ellipsoid heights
      if(nrmseht.ne.0)
     *write(99,501)trim(gfnsmrddeht),glomn,glomx,glamn,glamx,
     *xgridmin,trim(rfnvmrddeht),cmidlat

c - Calls to convert ".grd" to ".xyz"
      if(nrmslat.ne.0)then
        write(99,502)trim(rfnvsrddlat),trim(zfnvsrddlat)
        write(99,502)trim(rfnvmrddlat),trim(zfnvmrddlat)
      endif

      if(nrmslon.ne.0)then
        write(99,502)trim(rfnvsrddlon),trim(zfnvsrddlon)
        write(99,502)trim(rfnvmrddlon),trim(zfnvmrddlon)
      endif
      if(nrmseht.ne.0)
     *write(99,502)trim(rfnvmrddeht),trim(zfnvmrddeht)

c - Calls to convert ".xyz" to ".b"
      if(nrmslat.ne.0)then
        write(99,503)trim(zfnvsrddlat),trim(bfnvsrddlat)
        write(99,503)trim(zfnvmrddlat),trim(bfnvmrddlat)
      endif
      if(nrmslon.ne.0)then
        write(99,503)trim(zfnvsrddlon),trim(bfnvsrddlon)
        write(99,503)trim(zfnvmrddlon),trim(bfnvmrddlon)
      endif
      if(nrmseht.ne.0)
     *write(99,503)trim(zfnvmrddeht),trim(bfnvmrddeht)

c - Changed to T=0.9 on 10/28/2015
  501 format(
     *'surface ',a,' -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
     *' -I',f0.2,'m -G',a,' -T0.9 -A',s,f6.4,' -C0.01 -V -Lld')

c 501 format(
c    *'surface ',a,' -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
c    *' -I',f0.2,'m -G',a,' -T0.4 -A',s,f6.4,' -C0.01 -V -Lld')
c 501 format(
c    *'surface ',a,' -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
c    *' -I',f0.2,'m -G',a,' -T0.4 -A',s,f6.4,' -C0.01 -V')
  502 format(
     *'grd2xyz ',a,' -bo3f > ',a)
  503 format(
     *'xyz2b << !',/,
     *a,/,a,/,'!')

c --------------------------------------------------------------
c - GMT Batch file: CREATE TRANSFORMATION ERROR GRID
c - Added 11/9/2015
c
c -   See DRU-11, p. 145-148:  The total transformation error
c -   grid (representing a "standard deviation of the transformation
c -   at any grid location") will be a combination of two grids
c -   that have been called (in shorthand):
c      1) The "method noise" grid
c      2) The "data noise" grid
c   * The "method noise" grid represents the noise that comes
c     from not knowing the perfect tension at which to pull a
c     transformation grid sheet.  It was created in batch
c     file "gmtbat02...", as created by mymedian5.f
c   * The "data noise" grid represents the RMS mismatch between
c     all non-outlier vectors (both kept and dropped) and the
c     transformation grid (as pulled at T=0.4). It was created
c     in batch file "gmtbat05..." as created by myrms.f.
c     The final "transformation error grid" will be a
c     sort of convolution of the two above grids, as follows:
c     Let "TE(i,j)" be the transformation error at some
c     grid node "i,j", and "MN(i,j)" be the method noise
c     at grid node i,j and "DN(i,j)" be the data noise at
c     grid node i,j.  All three should be in the same units
c     (either meters or arcseconds).  The final "TE" grid
c     will have these values at every grid node:
c      TE(i,j) = SQRT[ MN(i,j)**2 + DN(i,j)**2 ]
c --------------------------------------------------------------
c - The "method noise" grids
      sadbfnvmtcdlat1000 = 'vmtcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlat1000 = 'vstcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdlon1000 = 'vmtcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlon1000 = 'vstcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdeht1000 = 'vmtcdeht.'//trim(suffix2d3)//'.b'

c - The "total error" grids in ".b" format
      bfnvsetelat ='vsetelat.'//trim(suffix2)//'.b'
      bfnvsetelon ='vsetelon.'//trim(suffix2)//'.b'
      bfnvmetelat ='vmetelat.'//trim(suffix2)//'.b'
      bfnvmetelon ='vmetelon.'//trim(suffix2)//'.b'
      bfnvmeteeht ='vmeteeht.'//trim(suffix2)//'.b'

c - The "total error" grids in ".grd" format
      rfnvsetelat ='vsetelat.'//trim(suffix2)//'.grd'
      rfnvsetelon ='vsetelon.'//trim(suffix2)//'.grd'
      rfnvmetelat ='vmetelat.'//trim(suffix2)//'.grd'
      rfnvmetelon ='vmetelon.'//trim(suffix2)//'.grd'
      rfnvmeteeht ='vmeteeht.'//trim(suffix2)//'.grd'


      if(nlat.ne.0)then
c------------------
c - LATITUDE/METERS
c------------------
c - Square Method Noise:
        write(99,801)trim(sadbfnvmtcdlat1000),
     *  trim(sadbfnvmtcdlat1000),
     *  trim(sadbfnvmtcdlat1000)
c - Square Data Noise:
        write(99,802)trim(bfnvmrddlat),trim(bfnvmrddlat),
     *  trim(bfnvmrddlat)
c - Add the two squares together:
        write(99,803)
c - Square root of the sum to give the final total transformation error grid
        write(99,804)trim(bfnvmetelat),trim(bfnvmetelat),
     *  trim(bfnvmetelat)
c - Remove all dummy files
        write(99,805)
c------------------
c - LATITUDE/ARCSECONDS
c------------------
c - Square Method Noise:
        write(99,801)trim(sadbfnvstcdlat1000),
     *  trim(sadbfnvstcdlat1000),
     *  trim(sadbfnvstcdlat1000)
c - Square Data Noise:
        write(99,802)trim(bfnvsrddlat),trim(bfnvsrddlat),
     *  trim(bfnvsrddlat)
c - Add the two squares together:
        write(99,803)
c - Square root of the sum to give the final total transformation error grid
        write(99,804)trim(bfnvsetelat),trim(bfnvsetelat),
     *  trim(bfnvsetelat)
c - Remove all dummy files
        write(99,805)
      endif

      if(nlon.ne.0)then
c------------------
c - LONGITUDE/METERS
c------------------
c - Square Method Noise:
        write(99,801)trim(sadbfnvmtcdlon1000),
     *  trim(sadbfnvmtcdlon1000),
     *  trim(sadbfnvmtcdlon1000)
c - Square Data Noise:
        write(99,802)trim(bfnvmrddlon),trim(bfnvmrddlon),
     *  trim(bfnvmrddlon)
c - Add the two squares together:
        write(99,803)
c - Square root of the sum to give the final total transformation error grid
        write(99,804)trim(bfnvmetelon),trim(bfnvmetelon),
     *  trim(bfnvmetelon)
c - Remove all dummy files
        write(99,805)
c------------------
c - LONGITUDE/ARCSECONDS
c------------------
c - Square Method Noise:
        write(99,801)trim(sadbfnvstcdlon1000),
     *  trim(sadbfnvstcdlon1000),
     *  trim(sadbfnvstcdlon1000)
c - Square Data Noise:
        write(99,802)trim(bfnvsrddlon),trim(bfnvsrddlon),
     *  trim(bfnvsrddlon)
c - Add the two squares together:
        write(99,803)
c - Square root of the sum to give the final total transformation error grid
        write(99,804)trim(bfnvsetelon),trim(bfnvsetelon),
     *  trim(bfnvsetelon)
c - Remove all dummy files
        write(99,805)
      endif

      if(neht.ne.0)then
c------------------
c - ELLIPSOID HEIGHT/METERS
c------------------
c - Square Method Noise:
        write(99,801)trim(sadbfnvmtcdeht1000),
     *  trim(sadbfnvmtcdeht1000),
     *  trim(sadbfnvmtcdeht1000)
c - Square Data Noise:
        write(99,802)trim(bfnvmrddeht),trim(bfnvmrddeht),
     *  trim(bfnvmrddeht)
c - Add the two squares together:
        write(99,803)
c - Square root of the sum to give the final total transformation error grid
        write(99,804)trim(bfnvmeteeht),trim(bfnvmeteeht),
     *  trim(bfnvmeteeht)
c - Remove all dummy files
        write(99,805)
      endif


  801 format(
     *'# ------------------------------',/,
     *'# Squaring the Method Noise Grid: ',a,' = dummy1',/,
     *'# ------------------------------',/,
     *'echo Squaring the Method Noise Grid: ',a,' = dummy1',/,
     *'gsqr << !',/,
     *a,/,'dummy1',/,'!')

  802 format(
     *'# ------------------------------',/,
     *'# Squaring the Data Noise Grid: ',a,' = dummy2',/,
     *'# ------------------------------',/,
     *'echo Squaring the Data Noise Grid: ',a,' = dummy2',/,
     *'gsqr << !',/,
     *a,/,'dummy2',/,'!')
  803 format(
     *'# ------------------------------',/,
     *'# Adding dummy1 and dummy2 = dummy3',/,
     *'# ------------------------------',/,
     *'echo Adding dummy1 and dummy2 = dummy3',/,
     *'addem << !',/,
     *'dummy1',/,'dummy2',/,'dummy3',/,'!')
  804 format(
     *'# ------------------------------',/,
     *'# SquareRoot dummy3 to get Trans. Error Grid: ',a,/,
     *'# ------------------------------',/,
     *'echo SquareRoot dummy3 to get Trans. Error Grid: ',a,/,
     *'gsqrt << !',/,
     *'dummy3',/,a,/,'!')
  805 format(
     *'# ------------------------------',/,
     *'# Removing dummy1, dummy2, dummy3',/,
     *'# ------------------------------',/,
     *'echo Removing dummy1, dummy2, dummy3',/,
     *'rm -f dummy1',/,
     *'rm -f dummy2',/,
     *'rm -f dummy3')

cccccccccccccccccccccccccccccccccccccccccccccccccccccc
c - 2016 07 01 : Mask/MASK/mask for the HARN/FBN/CONUS situation
c - See DRU-12, p. 41
c - Basically:  Once the "...ete...b" files are created,
c - move them to be "...ete...b.premask".  Then apply
c - the mask to this "premask" grid (densify to 30", 
c - convolve with 30" mask, then decimate back to original 
c - grid spacing) and give it the standard "...ete...b" file name.
c - In this way, when we convert the ".b" to ".grd" in the
c - next section of code, it'll be for the MASKED version
c - of the ".b" grid (but again, ONLY for the HARN/FBN/CONUS
c - situation)
      if(trim(olddtm).eq.'nad83_harn' .and.
     *   trim(newdtm).eq.'nad83_fbn'  .and.
     *   trim(region).eq.'conus'      )then

        write(99,601)

        if(nlat.ne.0)then
          write(99,602)trim(bfnvmetelat),
     *    trim(bfnvmetelat)//'.premask',
     *    trim(bfnvmetelat)//'.premask',
     *    trim(bfnvmetelat),
     *    igridsec/30,igridsec/30

          write(99,602)trim(bfnvsetelat),
     *    trim(bfnvsetelat)//'.premask',
     *    trim(bfnvsetelat)//'.premask',
     *    trim(bfnvsetelat),
     *    igridsec/30,igridsec/30
        endif

        if(nlon.ne.0)then
          write(99,602)trim(bfnvmetelon),
     *    trim(bfnvmetelon)//'.premask',
     *    trim(bfnvmetelon)//'.premask',
     *    trim(bfnvmetelon),
     *    igridsec/30,igridsec/30

          write(99,602)trim(bfnvsetelon),
     *    trim(bfnvsetelon)//'.premask',
     *    trim(bfnvsetelon)//'.premask',
     *    trim(bfnvsetelon),
     *    igridsec/30,igridsec/30
        endif

        if(neht.ne.0)then
          write(99,602)trim(bfnvmeteeht),
     *    trim(bfnvmeteeht)//'.premask',
     *    trim(bfnvmeteeht)//'.premask',
     *    trim(bfnvmeteeht),
     *    igridsec/30,igridsec/30
        endif

      endif


  601 format('echo Applying MASK for HARN FBN CONUS ete grids')
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

c --------------------------------------------------------------
c - GMT Batch file: Convert transformation error grid to "grd"
c -                 format so I can color plot it later.  
c --------------------------------------------------------------

      if(nlat.ne.0)then
        write(99,507)trim(bfnvmetelat)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(rfnvmetelat)
        write(99,507)trim(bfnvsetelat)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(rfnvsetelat)
      endif

      if(nlon.ne.0)then
        write(99,507)trim(bfnvmetelon)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(rfnvmetelon)
        write(99,507)trim(bfnvsetelon)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(rfnvsetelon)
      endif

      if(neht.ne.0)then
        write(99,507)trim(bfnvmeteeht)
     *  ,glomn,glomx,glamn,glamx,xgridmin,trim(rfnvmeteeht)

      endif
  507 format(
     *'b2xyz << !',/,a,/,'!',/,
     *'xyz2grd temp.xyz -R',f9.5,'/',f9.5,'/',sp,f9.5,'/',f9.5,s,
     *' -I',f0.2,'m -bi3f -G',a,/,
     *'rm -f temp.xyz')















      write(99,1031)trim(gmtfile)
 1031 format('echo END batch file ',a)
      close(99)

      write(6,9999)
 9999 format('END program myrms.f')



 2006 format('Cell ',i8,' Poscode: ',i12)
 2007 format(6x,'Pt : ',i5)
      end    
c
c -----------------------------------------------
c
      subroutine getrms(zs,max,inumlo,inumhi,indx,
     *maxppcell,xlat,xlon,alat,alon,rval)

c - As of 10/28/2015, no longer using average
c - lat/lon, but rather center of cell, to
c - register the RMS vector

      real*8 xlat(max),xlon(max),zs(max)
      integer*4 indx(max),indx2(maxppcell)
      integer*4 inumlo,inumhi

      real*8 alat,alon,rval
  
c     write(6,1)inumlo,inumhi
    1 format('Inside getrms',/,
     *'inumlo,inumhi = ',i8,1x,i8)

c - When the whole set of "zs" data is sorted by
c - "whichcell", then the "indx" values are our
c - key to that sort.  The "zs" data remains
c - in "read order" (1-nkt), but the indx values
c - (also in "read order" point to the sorted
c - order.

c - Because we are NOT attempting any kind of
c - median filter, there is no need to sort
c - the "mini vector" of data in this cell.
c - Just compute the average lat, average lon
c - and RMS value and return.
c - Change as of 10/28/2015:  Do not
c - use the avelat/avelon.  Instead, 
c - register the RMS vector to the center of 
c - the cell.  (See DRU-11, p. 145)

      rval = 0.d0
      alat = 0.d0
      alon = 0.d0

      
      nval = inumhi-inumlo+1
      iq = 0
      do 4 i=inumlo,inumhi
        iq = iq + 1
        rval = rval + zs(indx(i))**2
        alat = alat + xlat(indx(i))
        alon = alon + xlon(indx(i))
    4 continue
      rval = dsqrt(rval/nval) 
      alat = alat/nval
      alon = alon/nval

      return
      end

      include 'Subs/getgridbounds.f'
      include 'Subs/indexxi.for'
      include 'Subs/onzd2.f'

