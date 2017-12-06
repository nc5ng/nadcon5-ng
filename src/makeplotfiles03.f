c> \ingroup doers    
c> \if MANPAGE     
c> \page makeplotfiles03
c> \endif      
c> 
c> Part of the NADCON5 process, generates `gmtbat06`
c> 
c> Creates a batch file called 
c>       
c>       gmtbat06.(olddtm).(newdtm).(region).(igridsec).(mapflag)
c> 
c> That batch file will create JPGs of:
c>   1. Color Plots of the rddlat/rddlon/rddeht grids
c>   2. B/W plots of coverage of RMS'd differential vectors that went into the grid
c>   3. B/W plots of RMS'd differential vectors that went into the grid
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> They are enumerated here
c> \param oldtm Source Datum
c> \param newdtm Target Datum,region
c> \param region Conversion Region 
c> \param agridsec Grid Spacing in arcsec
c> \param mapflag Map Generation Level
c>     
c> Example:
c>     
c>     olddatum = 'ussd'
c>     newdatum = 'nad27'
c>     region = 'conus'
c>     agridsec = '900'    
c>     mapflag = '0'   
c>      
c> ### Program Inputs:
c> 
c> ## Changelog
c>       
c> ### 2016 10 19:
c> FIX for the HARN/FBN transformation.  As it stood, the "gridstats" was
c> returning  "0.0" as the median of the post-masked "ete" grid (which
c> is true, but unfortunate.)  I've changed the call to "gridstats"
c> to send it the "PREMASKED" version of the "ete" grid, so the median
c> won't be zero.   
c>       
c> ### 2016 08 26
c> Added new code to do reference vectors consistently
c> See DRU-12, p. 56-57
c>       
c> Fixed an error where "lorvogehtm" was declared real*8 but past 72 column,
c> so defaulting to integer*4 and coming out as "0.000" on plots
c>       
c> Also changing the call to "getmapbounds" to give it "olddatum" and "newdatum"
c> to aide in filtering out things like the Saint regions in Alaska
c> for unsupported transformations.
c>       
c> ### 2016 08 02:  
c> Changed the color palette for "09" grids from 2xMedian to 3xMedian      
c>       
c> ### 2016 07 29:  
c> Dropped code about personalized reference vectors and just      
c> let them be below/outside map
c>       
c> ### 2016 08 01:  
c> Moved "gridstats" to subroutines      
c> Also, completely removed the in-program computations of
c> the color palette, and instead relied on "cpt" and "cpt2"
c> as per "makeplotfiles02"
c>       
c> ### 2016 07 21:
c> Added code to allow for optional placement of reference vectors, coming from
c> `map.parameters` as read in subroutine getmapbounds
c>       
c> ### 2016 01 21: 
c> Updated to fix the CPT for the "09" (data noise)       
c> grids so that (cpthi - cptin) is exactly divisible by cptin
c>       
c> ### 2015 11 09:
c> Updated to adopt new naming scheme (yes, again)       
c> (See DRU-11, p. 150), as well as creating plots of the
c> total error grid.
c>       
c> ### 2015 10 07: 
c> Latest Version which had new naming scheme and      
c> dual-computations of arcseconds and meters for lat/lon
c> See DRU-11, pl. 139.
c>       
      program makeplotfiles03
      implicit real*8(a-h,o-z)
      parameter(maxplots=60)

      character*35 fname0
      character*34 dirnam 
      character*10 olddtm,newdtm,od,nd
      character*2 state,stdum
      character*3 ele,elelat,elelon,eleeht,ele0

      character*5 agridsec
      integer*4 igridsec
      character*200 suffix1,suffix2,suffix3
      character*200 suffix2t09,suffix2d3
      character*200 wfname,gmtfile

c - ".b" of RMS'd double difference data
      character*200 bfnvsrddlat,bfnvsrddlon,bfnvmrddeht
      character*200 bfnvmrddlat,bfnvmrddlon

c - "grd" of RMS'd double difference data
      character*200 rfnvsrddlat,rfnvsrddlon,rfnvmrddeht
      character*200 rfnvmrddlat,rfnvmrddlon

c - "coverage" of RMS'd data (needs to be created in "myrms.f")
      character*200 gfncvrddlat,gfncvrddlon,gfncvrddeht

c - RMS'd double difference vectors
      character*200 gfnvsrddlat,gfnvsrddlon,gfnvmrddeht
      character*200 gfnvmrddlat,gfnvmrddlon

c - "Method Noise" grids:
      character*200 sadbfnvmtcdlat1000,sadbfnvmtcdlon1000
      character*200 sadbfnvmtcdeht1000
      character*200 sadbfnvstcdlat1000,sadbfnvstcdlon1000

c -" Total Error" grids:
      character*200 bfnvsetelat,bfnvsetelon
      character*200 bfnvmetelat,bfnvmetelon
      character*200 bfnvmeteeht

c - 2016 10 19:
c - For the HARN/FBN situation *only*
c - "Total Error" grids, pre-mask:
      character*200 bfnvsetelat0,bfnvsetelon0
      character*200 bfnvmetelat0,bfnvmetelon0
      character*200 bfnvmeteeht0
    

c - 2015 10 09:
      character*200 gfnvsrddhor,gfnvmrddhor

c - Stats file
      character*200 sfn

c - GMT stuff
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
c - 2016 07 21:
      logical lrv(maxplots)
      real*8 rv0x(maxplots),rv0y(maxplots),rl0y(maxplots)


c - Stuff that is in the work file records:
      character*6 pid
      character*2 state
      character*1 rejlat,rejlon,rejeht
      real*8 xlath,xlonh,xehth
      real*8 dlatsec,dlonsec,dehtm
      real*8 dlatm,dlonm
      character*10 olddtm,newdtm,region
c - Units to put on scale on GMT color plots
      character*17 scunlat,scunlon,scuneht
      character*1 mapflag

      real*8 lorvopc,lorvoglats,lorvoglatm,lorvoglons,lorvoglonm
      real*8 lorvogehtm
c - 2015 10 09
      real*8 lorvoghors,lorvoghorm

c ------------------------------------------------------------------ 
c - BEGIN PROGRAM
c ------------------------------------------------------------------ 
      write(6,1001)
 1001 format('BEGIN program makeplotfiles03.f')

c ------------------------------------------------------------------ 
c - User-supplied input
c ------------------------------------------------------------------ 
      read(5,'(a)')olddtm
      read(5,'(a)')newdtm
      read(5,'(a)')region
      read(5,'(a)')agridsec
      read(5,'(a)')mapflag

c ------------------------------------------------------------------
c - Some necessary constants
c ------------------------------------------------------------------
      lorvopc = 1.d0
      csm = 3.d0
      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      MultiplierLorvog = 2

c ------------------------------------------------------------------
c - Generate the suffixes used in all our files
c ------------------------------------------------------------------
      read(agridsec,*)igridsec
      suffix1=trim(olddtm)//'.'//trim(newdtm)//'.'//trim(region)
      suffix2=trim(suffix1)//'.'//trim(agridsec)
      suffix3=trim(suffix2)//'.'//trim(mapflag)

      suffix2d3=trim(suffix2)//'.d3'
      suffix2t09=trim(suffix2)//'.09'

c ------------------------------------------------------------------ 
c - Got clever here...I stored # of double differences and the RMS of those
c - vectors into "dvstats...." back in the running of "checkgrid.f".
c - Now let's re-acquire this data and use it to scale double differenced vectors
c - in this program.  Granted, this won't be EXACTLY the same
c - as what is in the data (the RMS'd DD vectors are RMS'd in cells/bins,
c - but what is in "dvstats" is just an area-wide RMS value) but it's
c - good enough to scale things in the ballpark.

      sfn = 'dvstats.'//trim(suffix2)
      open(1,file=sfn,status='old',form='formatted')
      write(6,1004)
 1004 format(6x,'makeplotfiles03.f: Acquiring vectors ',
     *'stats from the dvstats file')

      read(1,*)nlat,rlats
      read(1,*)nlon,rlons
      read(1,*)neht,rehtm
      read(1,*)nlat0,rlatm
      read(1,*)nlon0,rlonm
c - 2015 10 09
      read(1,*)nhor ,rhors
      read(1,*)nhor0,rhorm
   
      if(nlat0.ne.nlat)stop 10001
      if(nlon0.ne.nlon)stop 10002
      if(nhor0.ne.nhor)stop 10003
      if(nhor.ne.nlat)stop 10004
      if(nhor.ne.nlon)stop 10005

      write(6,893)nlat,rlats,rlatm,
     *nlon,rlons,rlonm,
     *nhor,rhors,rhorm,
     *neht,rehtm

  893 format(6x,'makeplotfiles03.f: Vector Stats: ',/,
     *10x,'Number of Double Differenced Vectors in LAT: ',i10,/,
     *10x,'RMS length (arcseconds)                    : ',f10.3,/,
     *10x,'RMS length (meters)                        : ',f10.3,/,
     *10x,'Number of Double Differenced Vectors in LON: ',i10,/,
     *10x,'RMS length (arcseconds)                    : ',f10.3,/,
     *10x,'RMS length (meters)                        : ',f10.3,/,
     *10x,'Number of Double Differenced Vectors in HOR: ',i10,/,
     *10x,'RMS length (arcseconds)                    : ',f10.3,/,
     *10x,'RMS length (meters)                        : ',f10.3,/,
     *10x,'Number of Double Differenced Vectors in EHT: ',i10,/,
     *10x,'RMS length (arcseconds)                    : ',f10.3)
c ------------------------------------------------------------------ 


c --------------------------------------------------------------
c - GMT Batch file:  Open the file
c --------------------------------------------------------------
      gmtfile = 'gmtbat06.'//trim(suffix3)
      open(99,file=gmtfile,status='new',form='formatted')
      write(6,1011)trim(gmtfile)
 1011 format(6x,'makeplotfiles03.f: Creating GMT batch file ',a)
      write(99,1030)trim(gmtfile)
 1030 format('echo BEGIN batch file ',a)


c - The "method noise" grids
      sadbfnvmtcdlat1000 = 'vmtcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlat1000 = 'vstcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdlon1000 = 'vmtcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlon1000 = 'vstcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdeht1000 = 'vmtcdeht.'//trim(suffix2d3)//'.b'

c - The "data noise" grids
      bfnvsrddlat = 'vsrddlat.'//trim(suffix2t09)//'.b'
      bfnvsrddlon = 'vsrddlon.'//trim(suffix2t09)//'.b'
      bfnvmrddeht = 'vmrddeht.'//trim(suffix2t09)//'.b'
      bfnvmrddlat = 'vmrddlat.'//trim(suffix2t09)//'.b'
      bfnvmrddlon = 'vmrddlon.'//trim(suffix2t09)//'.b'

c - The "total noise" grids
      bfnvsetelat ='vsetelat.'//trim(suffix2)//'.b'
      bfnvsetelon ='vsetelon.'//trim(suffix2)//'.b'
      bfnvmetelat ='vmetelat.'//trim(suffix2)//'.b'
      bfnvmetelon ='vmetelon.'//trim(suffix2)//'.b'
      bfnvmeteeht ='vmeteeht.'//trim(suffix2)//'.b'

c --------------------------------------------------------------
c - GMT Batch file: Get color palatte for the "total error"
c - grids.  Keep this separate from the color palette for
c - the "data noise" grids.
c --------------------------------------------------------------

c - 2016 08 01:  All below changed to rely on "cpt2" for "ete" grids

      if(nlat.ne.0)then

c - 2016 10 19
c - Lazy coding here:  You can ONLY have "olddtm" = "nad83_harn" if 
c - you also have "nad83_fbn" as "newdtm" and "conus"
c - as "region", so I won't bother checking all 3:
        if(trim(olddtm).ne.'nad83_harn')then
          write(6,1012)trim(bfnvmetelat)
          call gridstats(bfnvmetelat,ave,std,xmd)
        else
          bfnvmetelat0 = trim(bfnvmetelat)//'.premask'
          write(6,1012)trim(bfnvmetelat0)
          call gridstats(bfnvmetelat0,ave,std,xmd)
        endif   

        avelatmE = ave
        stdlatmE = std
        xmdlatmE = xmd
        call cpt2(xmdlatmE,2.d0,
     *  cptlolatmE,cpthilatmE,cptinlatmE)
c       cptinlatmE=onzd2(std)
c       scaledave =onzd2(ave)
c       cptlolatmE = 0.d0
c       cpthilatmE = scaledave + csm*cptinlatmE


c - 2016 10 19 
c - Lazy coding here:  You can ONLY have "olddtm" = "nad83_harn" if 
c - you also have "nad83_fbn" as "newdtm" and "conus"
c - as "region", so I won't bother checking all 3:
        if(trim(olddtm).ne.'nad83_harn')then
          write(6,1012)trim(bfnvsetelat)
          call gridstats(bfnvsetelat,ave,std,xmd)
        else
          bfnvsetelat0 = trim(bfnvsetelat)//'.premask'
          write(6,1012)trim(bfnvsetelat0)
          call gridstats(bfnvsetelat0,ave,std,xmd)
        endif   

        avelatsE = ave
        stdlatsE = std
        xmdlatsE = xmd
        call cpt2(xmdlatsE,2.d0,
     *  cptlolatsE,cpthilatsE,cptinlatsE)
c       cptinlatsE=onzd2(std)
c       scaledave =onzd2(ave)
c       cptlolatsE = 0.d0
c       cpthilatsE = scaledave + csm*cptinlatsE
      endif

      if(nlon.ne.0)then

c - 2016 10 19 
c - Lazy coding here:  You can ONLY have "olddtm" = "nad83_harn" if 
c - you also have "nad83_fbn" as "newdtm" and "conus"
c - as "region", so I won't bother checking all 3:
        if(trim(olddtm).ne.'nad83_harn')then
          write(6,1012)trim(bfnvmetelon)
          call gridstats(bfnvmetelon,ave,std,xmd)
        else
          bfnvmetelon0 = trim(bfnvmetelon)//'.premask'
          write(6,1012)trim(bfnvmetelon0)
          call gridstats(bfnvmetelon0,ave,std,xmd)
        endif   

        avelonmE = ave
        stdlonmE = std
        xmdlonmE = xmd
        call cpt2(xmdlonmE,2.d0,
     *  cptlolonmE,cpthilonmE,cptinlonmE)
c       cptinlonmE=onzd2(std)
c       scaledave =onzd2(ave)
c       cptlolonmE = 0.d0
c       cpthilonmE = scaledave + csm*cptinlonmE

c - 2016 10 19 
c - Lazy coding here:  You can ONLY have "olddtm" = "nad83_harn" if 
c - you also have "nad83_fbn" as "newdtm" and "conus"
c - as "region", so I won't bother checking all 3:
        if(trim(olddtm).ne.'nad83_harn')then
          write(6,1012)trim(bfnvsetelon)
          call gridstats(bfnvsetelon,ave,std,xmd)
        else
          bfnvsetelon0 = trim(bfnvsetelon)//'.premask'
          write(6,1012)trim(bfnvsetelon0)
          call gridstats(bfnvsetelon0,ave,std,xmd)
        endif   

        avelonsE = ave
        stdlonsE = std
        xmdlonsE = xmd
        call cpt2(xmdlonsE,2.d0,
     *  cptlolonsE,cpthilonsE,cptinlonsE)
c       cptinlonsE=onzd2(std)
c       scaledave =onzd2(ave)
c       cptlolonsE = 0.d0
c       cpthilonsE = scaledave + csm*cptinlonsE
      endif

      if(neht.ne.0)then

c - 2016 10 19 
c - Lazy coding here:  You can ONLY have "olddtm" = "nad83_harn" if 
c - you also have "nad83_fbn" as "newdtm" and "conus"
c - as "region", so I won't bother checking all 3:
        if(trim(olddtm).ne.'nad83_harn')then
          write(6,1012)trim(bfnvmeteeht)
          call gridstats(bfnvmeteeht,ave,std,xmd)
        else
          bfnvmeteeht0 = trim(bfnvmeteeht)//'.premask'
          write(6,1012)trim(bfnvmeteeht0)
          call gridstats(bfnvmeteeht0,ave,std,xmd)
        endif   

        aveehtmE = ave
        stdehtmE = std
        xmdehtmE = xmd
        call cpt2(xmdehtmE,2.d0,
     *  cptloehtmE,cpthiehtmE,cptinehtmE)
c       cptinehtmE=onzd2(std)
c       scaledave =onzd2(ave)
c       cptloehtmE = 0.d0
c       cpthiehtmE = scaledave + csm*cptinehtmE
      endif


c --------------------------------------------------------------
c - GMT Batch file:  Determine Number of areas to plot (=nplots)
c -                  and Boundaries of plots and other stuff.
c -                  Report the information out.
c --------------------------------------------------------------
c - 2016 08 29:
      call getmapbounds(mapflag,maxplots,region,nplots,
     *olddtm,newdtm,
     *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y,rl0y)


c - 2016 08 26, DRU-12, p.56-57
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y,rl0y)
c - See DRU-11, p. 126 for choices on grid boundaries for NADCON v5.0
c - 2016 07 21
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y)
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn)
      write(6,1006)trim(region)
 1006 format(6x,'makeplotfiles03.f: Calling getmapbounds for region ',a)

c ---------------------------------------------------------------
c - Compute and report various things about our coverage
c - and vector plots.
c ---------------------------------------------------------------
c - How many centimeters long will our reference arrows be?
c - Base this on the actual data 
 
      if(nlat.ne.0)then
c       iqlats = floor(log10(rlats))
c       qqlats = 10.d0**(iqlats-1)
c       lorvoglats = MultiplierLorvog*qqlats*nint(rlats/qqlats)
        lorvoglats = onzd2(MultiplierLorvog*rlats)
        gs2pclat = lorvopc / lorvoglats

c       iqlatm = floor(log10(rlatm))
c       qqlatm = 10.d0**(iqlatm-1)
c       lorvoglatm = MultiplierLorvog*qqlatm*nint(rlatm/qqlatm)
        lorvoglatm = onzd2(MultiplierLorvog*rlatm)
        gm2pclat = lorvopc / lorvoglatm
      endif

      if(nlon.ne.0)then
c       iqlons = floor(log10(rlons))
c       qqlons = 10.d0**(iqlons-1)
c       lorvoglons = MultiplierLorvog*qqlons*nint(rlons/qqlons)
        lorvoglons = onzd2(MultiplierLorvog*rlons)
        gs2pclon = lorvopc / lorvoglons

c       iqlonm = floor(log10(rlonm))
c       qqlonm = 10.d0**(iqlonm-1)
c       lorvoglonm = MultiplierLorvog*qqlonm*nint(rlonm/qqlonm)
        lorvoglonm = onzd2(MultiplierLorvog*rlonm)
        gm2pclon = lorvopc / lorvoglonm
      endif

      if(neht.ne.0)then
c       iqehtm = floor(log10(rehtm))
c       qqehtm = 10.d0**(iqehtm-1)
c       lorvogehtm = MultiplierLorvog*qqehtm*nint(rehtm/qqehtm)
        lorvogehtm = onzd2(MultiplierLorvog*rehtm)
        gm2pceht = lorvopc / lorvogehtm
      endif

      if(nlon.ne.0 .and. nlat.ne.0)then
c       iqhors = floor(log10(rhors))
c       qqhors = 10.d0**(iqhors-1)
c       lorvoghors = MultiplierLorvog*qqhors*nint(rhors/qqhors)
        lorvoghors = onzd2(MultiplierLorvog*rhors)
        gs2pchor = lorvopc / lorvoghors

c       iqhorm = floor(log10(rhorm))
c       qqhorm = 10.d0**(iqhorm-1)
c       lorvoghorm = MultiplierLorvog*qqhorm*nint(rhorm/qqhorm)
        lorvoghorm = onzd2(MultiplierLorvog*rhorm)
        gm2pchor = lorvopc / lorvoghorm
      endif


c - Report:
      write(6,894)nplots
  894 format(6x,'makeplotfiles03.f: Info about plots:',/,
     *8x,'Number of sub-area plot sets to cover this region: ',i2)

      do 895 i=1,nplots
        dns = bn(i) - bs(i)
        dew = be(i) - bw(i)
        write(6,896)i,bs(i),bn(i),bw(i),be(i),dns,dew

        if(nlat.ne.0)then
          write(6,897)'lat',lorvoglatm,lorvoglats,gm2pclat,gs2pclat
        else
          write(6,898)'lat'
        endif

        if(nlon.ne.0)then
          write(6,897)'lon',lorvoglonm,lorvoglons,gm2pclon,gs2pclon
        else
          write(6,898)'lon'
        endif

        if(neht.ne.0)then
          write(6,899)'eht',lorvogehtm,gm2pceht
        else
          write(6,898)'eht'
        endif

        if(nlat.ne.0 .and. nlon.ne.0)then
          write(6,897)'hor',lorvoghorm,lorvoghors,gm2pchor,gs2pchor
        else
          write(6,898)'hor'
        endif

  895 continue

  896 format(
     *8x,'Plot # ',i2,/,
     *10x,'S/N/W/E/N-S/E-W = ',6f7.1)
  897 format(
     *10x,a3,' plots',13x,':',/,
     *12x,'Reference Vector ( m) = ',f10.2,/,
     *12x,'Reference Vector ( s) = ',f10.6,/,
     *12x,'Ground M to Paper cm  = ',f20.10,/,
     *12x,'Ground S to Paper cm  = ',f20.10)
  899 format(
     *10x,a3,' plots',13x,':',/,
     *12x,'Reference Vector ( m) = ',f10.2,/,
     *12x,'Ground M to Paper cm  = ',f20.10)
  898 format(
     *10x,a3,' plots: No data available for plotting')

c ------------------------------------------------------------------ 
c - pvlon and pvlat are the percentage of the total lon/lat
c - span of the plot, from which the reference vector
c - begins, starting with the Lower Left corner
c ------------------------------------------------------------------ 
      pvlon = 10.d0
      pvlat = 10.d0

      pvlat = (pvlat / 100.d0)
      pvlon = (pvlon / 100.d0)


c --------------------------------------------------------------
c - GMT Batch file: Get color palatte for the "data noise", aka "09" 
c - grids.
c --------------------------------------------------------------
c ------------------------------------------------------------------ 
c - Because our color palette will depend upon the statistics of
c - our grids, we need to access those grids, and store a few
c - statistics.
c ------------------------------------------------------------------ 
      rfnvsrddlat = 'vsrddlat.'//trim(suffix2t09)//'.grd'
      rfnvsrddlon = 'vsrddlon.'//trim(suffix2t09)//'.grd'
      rfnvmrddeht = 'vmrddeht.'//trim(suffix2t09)//'.grd'
      rfnvmrddlat = 'vmrddlat.'//trim(suffix2t09)//'.grd'
      rfnvmrddlon = 'vmrddlon.'//trim(suffix2t09)//'.grd'

      gfnvsrddlat = 'vsrddlat.'//trim(suffix2)
      gfnvsrddlon = 'vsrddlon.'//trim(suffix2)
      gfnvmrddeht = 'vmrddeht.'//trim(suffix2)
      gfnvmrddlat = 'vmrddlat.'//trim(suffix2)
      gfnvmrddlon = 'vmrddlon.'//trim(suffix2)
      gfnvsrddhor = 'vsrddhor.'//trim(suffix2)
      gfnvmrddhor = 'vmrddhor.'//trim(suffix2)

      gfncvrddlat = 'cvrddlat.'//trim(suffix2)
      gfncvrddlon = 'cvrddlon.'//trim(suffix2)
      gfncvrddeht = 'cvrddeht.'//trim(suffix2)

c - NOTE ON COLOR PALLETTES, BELOW:
c - Because all of the differential vectors are RMS'd values at
c - this point, they will have a minimum value of zero.  As such,
c - set the "cptlo" values to zero.

c - 2016 08 01: Changed to use "cpt2" for "09" (RMS) grids
c - 2016 08 02: Changed the multiplier in the 09 grids from 2 to 3

      if(nlat.ne.0)then
        write(6,1012)trim(bfnvsrddlat)
        call gridstats(bfnvsrddlat,ave,std,xmd)
        avelats = ave
        stdlats = std
        xmdlats = xmd
        call cpt2(xmdlats,3.d0,
     *  cptlolats,cpthilats,cptinlats)
 
        write(6,1012)trim(bfnvmrddlat)
        call gridstats(bfnvmrddlat,ave,std,xmd)
        avelatm = ave
        stdlatm = std
        xmdlatm = xmd
        call cpt2(xmdlatm,3.d0,
     *  cptlolatm,cpthilatm,cptinlatm)

      endif

      if(nlon.ne.0)then
        write(6,1012)trim(bfnvsrddlon)
        call gridstats(bfnvsrddlon,ave,std,xmd)
        avelons = ave
        stdlons = std
        xmdlons = xmd
        call cpt2(xmdlons,3.d0,
     *  cptlolons,cpthilons,cptinlons)

        write(6,1012)trim(bfnvmrddlon)
        call gridstats(bfnvmrddlon,ave,std,xmd)
        avelonm = ave
        stdlonm = std
        xmdlonm = xmd
        call cpt2(xmdlonm,3.d0,
     *  cptlolonm,cpthilonm,cptinlonm)

      endif

      if(neht.ne.0)then
        write(6,1012)trim(bfnvmrddeht)
        call gridstats(bfnvmrddeht,ave,std,xmd)
        aveehtm = ave
        stdehtm = std
        xmdehtm = xmd
        call cpt2(xmdehtm,3.d0,
     *  cptloehtm,cpthiehtm,cptinehtm)

      endif


 1012 format(6x,'makeplotfiles03.f: Grabbing stats of grid: ',a)

c ------------------------------------------------------------------ 
c ------------------------------------------------------------------ 
c ------------------------------------------------------------------ 
c - MAIN LOOP:  Loop over number of sub-areas (nplots) I've chosen
c - for this region (see "getmapbounds.f" subroutine). 
c ------------------------------------------------------------------ 
c ------------------------------------------------------------------ 
c ------------------------------------------------------------------ 
      do 2001 ij=1,nplots
        write(99,990)trim(region),trim(fn(ij)),
     *  trim(region),trim(fn(ij))

c --------------------
c - B/W COVERAGE PLOTS
c --------------------
c - Make B/W Coverage Plots of RMS'd data
c - Latitude
        if(nlat.ne.0)
     *  call bwplotcv('lat',gfncvrddlat,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LAT',ij,
     *  igridsec,fn)
c - Longitude
        if(nlon.ne.0)
     *  call bwplotcv('lon',gfncvrddlon,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LON',ij,
     *  igridsec,fn)
c - Ellipsoid Height
        if(neht.ne.0)
     *  call bwplotcv('eht',gfncvrddeht,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'EHT',ij,
     *  igridsec,fn)

c ------------------
c - B/W VECTOR PLOTS
c ------------------
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

c - Make B/W Vector Plots of RMS'd data

c - Latitude
        if(nlat.ne.0)then
          call bwplotvc('lat',gfnvsrddlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoglats,lorvopc,igridsec,fn)
          call bwplotvc('lat',gfnvmrddlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoglatm,lorvopc,igridsec,fn)
        endif
c - Longitude
        if(nlon.ne.0)then
          call bwplotvc('lon',gfnvsrddlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoglons,lorvopc,igridsec,fn)
          call bwplotvc('lon',gfnvmrddlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoglonm,lorvopc,igridsec,fn)
        endif
c - Ellipsoid height
        if(neht.ne.0)then
          call bwplotvc('eht',gfnvmrddeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'EHT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvogehtm,lorvopc,igridsec,fn)
        endif
c - Horizontal
        if(nlon.ne.0 .and. nlat.ne.0)then
          call bwplotvc('hor',gfnvsrddhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
          call bwplotvc('hor',gfnvmrddhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
        endif

c ------------------------------------------------
c - Color gridded data of RMS grids ("data noise")
c ------------------------------------------------
c - Make color plots of gridded, RMS'd data, with no
c - points.  

        write(99,3101)
 3101   format('echo Color Plots of RMS data...')
c - Latitude
        if(nlat.ne.0)then
          call coplot('lat',bfnvsrddlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,cptlolats,cpthilats,cptinlats,
     *    suffix2t09,igridsec,fn)
          call coplot('lat',bfnvmrddlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,cptlolatm,cpthilatm,cptinlatm,
     *    suffix2t09,igridsec,fn)
        endif
c - Longitude
        if(nlon.ne.0)then
          call coplot('lon',bfnvsrddlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,cptlolons,cpthilons,cptinlons,
     *    suffix2t09,igridsec,fn)
          call coplot('lon',bfnvmrddlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,cptlolonm,cpthilonm,cptinlonm,
     *    suffix2t09,igridsec,fn)
        endif
c - Ellipsoid Height
        if(neht.ne.0)then
          call coplot('eht',bfnvmrddeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'EHT',ij,cptloehtm,cpthiehtm,cptinehtm,
     *    suffix2t09,igridsec,fn)
        endif

c ------------------------------------------------
c - Color gridded data of "Total Error" grids
c ------------------------------------------------

        write(99,3102)
 3102   format('echo Color Plots of Total Error grids...')
c - Latitude
        if(nlat.ne.0)then
          call coplot('lat',bfnvsetelat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,cptlolatsE,cpthilatsE,
     *    cptinlatsE,
     *    suffix2,igridsec,fn)
          call coplot('lat',bfnvmetelat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,cptlolatmE,cpthilatmE,
     *    cptinlatmE,
     *    suffix2,igridsec,fn)
        endif
c - Longitude
        if(nlon.ne.0)then
          call coplot('lon',bfnvsetelon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,cptlolonsE,cpthilonsE,
     *    cptinlonsE,
     *    suffix2,igridsec,fn)
          call coplot('lon',bfnvmetelon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,cptlolonmE,cpthilonmE,
     *    cptinlonmE,
     *    suffix2,igridsec,fn)
        endif
c - Ellipsoid Height
        if(neht.ne.0)then
          call coplot('eht',bfnvmeteeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'EHT',ij,cptloehtmE,cpthiehtmE,
     *    cptinehtmE,
     *    suffix2,igridsec,fn)
        endif

 2001 continue
  990 format(
     *'# ------------------------------',/,
     *'# Plots for region: ',a,', sub-region: ',a,/,
     *'# ------------------------------',/,
     *'echo Creating plots for region: ',a,', sub-region: ',a)

      write(99,1031)trim(gmtfile)
 1031 format('echo END batch file ',a)
      close(99)

      write(6,9999)
 9999 format('END program makeplotfiles03.f')

      end
c
c ----------------------------------------------------
c
      include 'Subs/getmapbounds.f'
      include 'Subs/getmag.f'
      include 'Subs/coplot.f'
      include 'Subs/bwplotvc.f'
      include 'Subs/bwplotcv.f'
      include 'Subs/plotcoast.f'
      include 'Subs/onzd2.f'
      include 'Subs/gridstats.f'
      include 'Subs/cpt2.f'
      include 'Subs/select2_mod.for'
