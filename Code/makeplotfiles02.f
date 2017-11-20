c> \ingroup doers    
c> Part of the NADCON5 process, generates `gmtbat03`
c>     
c> Built upon the skeleton of "makeplotem.f" for GEOCON v2.0
c> But built specifically for NADCON v5.0.  So different
c> in file names and expanded plot creation that it was
c> given the new name "makeplotfiles02.f" to align with
c> another NADCON5 program "makeplotfiles01.f"
c>     
c> Creates a batch file called 
c>     
c>       gmtbat03.(olddtm).(newdtm).(region).(igridsec)
c>     
c> That batch file will create JPGs of:
c>   1. Color Plots of the dlat/dlon/deht grids at T=0.4
c>   2. Color Plots of the "method noise" grids (the "d3" grids, see DRU-11, p. 150) with thinned coverage overlaid
c>   3. B/W plots of thinned vectors that went into the T=0.4 transformation grid
c>   4. B/W plots of dropped vectors that did not go into the T=0.4 transformation grid
c>   5. B/W plots of thinned coverage of points that went into the T=0.4 transformation grid
c>   6. B/W plots of dropped coverage of points that did not go into the T=0.4 transformation grid
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
c> ### 2016 08 26
c> Added new code to do reference vectors consistently
c> See DRU-12, p. 56-57
c> Also fixed a typo in reference vector length for vmtcdeht plots
c> Also changing the call to getmapbounds to give it `olddatum` and `newdatum`
c> to aide in filtering out things like the Saint regions in Alaska
c> for unsupported transformations.
c>       
c> ### 2016 07 29:
c> Scrapped code about personalized reference vectors.  Just put all
c> reference vectors outside/below plot
c> Also moved gridstats and vecstats out into the `/Subs` directory
c> to be used by other programs (like makeplotfiles03.f)
c>       
c> ### 2016 07 28: 
c> Changed code to build the color palette of the `d3` grids 
c> around the median, and not ave or std.
c> See DRU-12, p. 48
c>       
c> ### 2016 07 21:
c> Added code to allow for optional placement of reference vectors, coming from
c> `map.parameters` as read in subroutine getmapbounds
c>       
c> ### 2016 01 21:
c> Updated to get the CPT values fixed in `d3` grids, so that
c> (cpthi - cptlo) is exactly divisible by `cptin` at (2 x csm)
c>       
c> ### 2015 10 27:
c> Updated to work with the new naming scheme (see DRU-11, p. 150)
c>       
c> ### 2015 10 05: 
c> Updated to work with the new naming scheme (see DRU-11, p. 139)
      program makeplotfiles02
      implicit real*8(a-h,o-z)
      parameter(maxplots=60)

      character*35 fname0
      character*34 dirnam 
      character*10 olddtm,newdtm,od,nd
      character*2 state,stdum
      character*3 ele,elelat,elelon,eleeht,elehor,ele0

      character*5 agridsec
      integer*4 igridsec
      character*200 suffix1,suffix2,suffix3,suffix2d3
      character*200 suffix2t04
      character*200 wfname,gmtfile
      character*200 gfncvtcdlat,gfncvtcdlon,gfncvtcdeht
      character*200 gfncvdcdlat,gfncvdcdlon,gfncvdcdeht

      character*200 bfnvmtcdlat,bfnvmtcdlon,bfnvmtcdeht
      character*200 bfnvstcdlat,bfnvstcdlon

c - 10/27/2015:  "sad" = "Scaled AbsoluteValue Differential", aka "d3" grids
c - See DRU-11, p. 150
      character*200 sadbfnvmtcdlat,sadbfnvmtcdlon,sadbfnvmtcdeht
      character*200 sadbfnvstcdlat,sadbfnvstcdlon

      character*200 gfnvmtcdlat,gfnvmtcdlon,gfnvmtcdeht,gfnvmtcdhor
      character*200 gfnvstcdlat,gfnvstcdlon,            gfnvstcdhor

      character*200 gfnvmdcdlat,gfnvmdcdlon,gfnvmdcdeht,gfnvmdcdhor
      character*200 gfnvsdcdlat,gfnvsdcdlon,            gfnvsdcdhor

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
      real*8 dlatsec,dlonsec,dehtm,dhorsec,azhor
      real*8 dlatm,dlonm,dhorm
      character*10 olddtm,newdtm,region
c - Units to put on scale on GMT color plots
      character*17 scunlat,scunlon,scuneht,scunhor
      character*1 mapflag

c - Plot/Scale stuff
      real*8 lorvopc
      real*8 lorvoghorm,lorvoghors
      real*8 lorvogehtm



c ------------------------------------------------------------------ 
c - BEGIN PROGRAM
c ------------------------------------------------------------------ 
      write(6,1001)
 1001 format('BEGIN program makeplotfiles02.f')

c--------------------------------------------
c - Some necessary constants
c
c - "lorvopc" = Length of Reference Vector on Paper in **CM**
c - *** CRITICAL:  The units of centimeters align with
c - the use, in .gmtdefaults4, of:
c -        MEASURE_UNIT            = cm
c - If you change that value, then the units of lorvopc
c - will be whatever you change it too, which may prove
c - displeasing.
c -
c - "csm" is the Color Sigma Multiplier...the
c - number of Standard Deviations away from
c - the average for the color palette to 
c - span on color plots.
c--------------------------------------------
      lorvopc = 1.d0
      csm = 3.d0
      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      re  = 6371000.d0
      MultiplierLorvog = 2

c ------------------------------------------------------------------ 
c - User-supplied input
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
      suffix2d3=trim(suffix2)//'.d3'

      suffix3=trim(suffix2)//'.'//trim(mapflag)

c ------------------------------------------------------------------ 
c - LAZY CODING:  Spin through work file, collecting stats
c - which we will use to scale the map and vectors, etc.
c ------------------------------------------------------------------ 
c ------------------------------------------------------------------
c - Open the work file
c ------------------------------------------------------------------
      wfname='work.'//trim(suffix1)
      open(1,file='Work/'//wfname,status='old',form='formatted')
      write(6,1004)trim(wfname)
 1004 format(6x,'makeplotfiles02.f: Opening work file ',a)

      ndhor  = 0
      ndeht  = 0
      avedhorm = 0.d0
      avedhors = 0.d0
      avedehtm = 0.d0
  891 read(1,104,end=892)pid,state,rejlat,rejlon,rejeht,
     *xlath,xlonh,xehth,
     *dlatsec,dlonsec,dehtm,dhorsec,azhor,dlatm,dlonm,dhorm,
     *olddtm,newdtm
        if(rejlat.eq.' ' .and. rejlon.eq.' ')then
          avedhorm = avedhorm + dhorm
          avedhors = avedhors + dhorsec
          ndhor  = ndhor  + 1
        endif
        if(rejeht.eq.' ')then
c - Because they can be +/-, we and this is JUST for scaling the map,
c - we want the average MAGNITUDE...use ABS.
          avedehtm = avedehtm + dabs(dehtm)
          ndeht  = ndeht  + 1
        endif
      goto 891
  892 continue
      if(ndhor .gt.0)then
        avedhorm = avedhorm / dble(ndhor )
        avedhors = avedhors / dble(ndhor )
      else
        avedhorm = 0.d0
        avedhors = 0.d0
      endif
      if(ndeht .gt.0)then
        avedehtm = avedehtm / dble(ndeht )
      else
        avedehtm = 0.d0
      endif
      write(6,893)ndhor ,avedhorm,avedhors,ndeht ,avedehtm
  893 format(6x,'makeplotfiles02.f: Vector Stats: ',/,
     *10x,'Number of Good Horizontal Vectors : ',i10,/,
     *10x,'Average length (meters)           : ',f10.3,/,
     *10x,'Average length (arcseconds)       : ',f10.6,/,
     *10x,'Number of Good Ell. Ht.   Vectors : ',i10,/,
     *10x,'Average length (meters)           : ',f10.3)
  104 format(a6,1x,a2,a1,a1,a1,1x,f14.10,1x,f14.10,1x,f8.3,1x,
     *f9.5,1x,f9.5,1x,f9.3,1x,f9.5,1x,f9.5,1x,f9.3,1x,f9.3,1x,f9.3,
     *1x,a10,1x,a10)
c ------------------------------------------------------------------ 
c - END OF LAZY CODING
c ------------------------------------------------------------------ 



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
c - 2016 07 21:
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y)
c     call getmapbounds(mapflag,maxplots,region,nplots,
c    *bw,be,bs,bn,jm,b1,b2,fn)
      write(6,1006)trim(region)
 1006 format(6x,'makeplotfiles02.f: Calling getmapbounds for region ',a)


c ---------------------------------------------------------------
c - Compute and report various things about our coverage
c - and vector plots.
c ---------------------------------------------------------------
c - Reference vector set to length of the average
c - absolute value of horizontal or ell ht shift.
c - Note "gm2pc" = "ground meters to paper centimeters"
c -      "gs2pc" = "ground arcseconds to paper centimeters"
c -      "lorvog*s" = "length of reference vector on ground (element) in arcseconds"
c -      "lorvog*m" = "length of reference vector on ground (element) in meters"

      if(ndhor.ne.0)then
c       iqhorm = floor(log10(avedhorm))
c       qqhorm = 10.d0**(iqhorm-1)
c       lorvoghorm = MultiplierLorvog*qqhorm*nint(avedhorm/qqhorm)
        lorvoghorm = onzd2(MultiplierLorvog*avedhorm)
        gm2pchor = lorvopc / lorvoghorm

c       iqhors = floor(log10(avedhors))
c       qqhors = 10.d0**(iqhors-1)
c       lorvoghors = MultiplierLorvog*qqhors*nint(avedhors/qqhors)
        lorvoghors = onzd2(MultiplierLorvog*avedhors)
        gs2pchor = lorvopc / lorvoghors
      endif

      if(ndeht.ne.0)then
c       iqehtm = floor(log10(avedehtm))
c       qqehtm = 10.d0**(iqehtm-1)
c       lorvogehtm = MultiplierLorvog*qqehtm*nint(avedehtm/qqehtm)
        lorvogehtm = onzd2(MultiplierLorvog*avedehtm)
        gm2pceht = lorvopc / lorvogehtm
      endif

c - Report:
      write(6,894)nplots
  894 format(6x,'makeplotfiles02.f: Info about plots:',/,
     *8x,'Number of sub-region plot sets to cover this region: ',i2)

      do 895 i=1,nplots
        dns = bn(i) - bs(i)
        dew = be(i) - bw(i)
        write(6,896)i,bs(i),bn(i),bw(i),be(i),dns,dew
        if(ndhor .ne.0)then
          write(6,897)lorvoghorm,lorvoghors,gm2pchor,gs2pchor
        else
          write(6,898)
        endif

        if(ndeht .ne.0)then
          write(6,899)lorvogehtm,gm2pceht
        else
          write(6,900)
        endif

  895 continue

  896 format(
     *8x,'Plot # ',i2,/,
     *10x,'S/N/W/E/N-S/E-W = ',6f7.1)
  897 format(
     *10x,'Lat/Lon/Hor plots: ',/,
     *12x,'Reference Vector ( m) = ',f10.2,/,
     *12x,'Reference Vector ( s) = ',f10.6,/,
     *12x,'Ground M to Paper cm  = ',f20.10,/,
     *12x,'Ground S to Paper cm  = ',f20.10)
  898 format(
     *10x,'Lat/Lon/Hor plots: ',/,
     *12x,'No horizontal data available for plotting')
  899 format(
     *10x,'Ell. Height plots: ',/,
     *12x,'Reference Vector ( m) = ',f10.2,/,
     *12x,'Ground M to Paper cm  = ',f20.10)
  900 format(
     *10x,'Ell. Height plots: ',/,
     *12x,'No ellipsoid height data available for plotting')

c ------------------------------------------------------------------ 
c - pvlon and pvlat are the percentage of the total lon/lat
c - span of the plot, from which the reference vector
c - begins, starting with the Lower Left corner
c ------------------------------------------------------------------ 
      pvlon = 10.d0
      pvlat = 10.d0

      pvlat = (pvlat / 100.d0)
      pvlon = (pvlon / 100.d0)


c ------------------------------------------------------------------ 
c - The output batch file full of all the GMT commands
c - needed to create the plots of interest
c ------------------------------------------------------------------ 
      gmtfile = 'gmtbat03.'//trim(suffix3)
      open(99,file=gmtfile,status='new',form='formatted')
      write(6,1011)trim(gmtfile)
 1011 format(6x,'makeplotfiles02.f: Creating GMT batch file ',a)
      write(99,1030)trim(gmtfile)
 1030 format('echo BEGIN batch file ',a)



c ------------------------------------------------------------------ 
c - Because our color palette will depend upon the statistics of
c - our grids, we need to access those grids, and store a few
c - statistics.
c ------------------------------------------------------------------ 
      bfnvmtcdlat = 'vmtcdlat.'//trim(suffix2t04)//'.b'
      bfnvmtcdlon = 'vmtcdlon.'//trim(suffix2t04)//'.b'
      bfnvmtcdeht = 'vmtcdeht.'//trim(suffix2t04)//'.b'
      bfnvstcdlat = 'vstcdlat.'//trim(suffix2t04)//'.b'
      bfnvstcdlon = 'vstcdlon.'//trim(suffix2t04)//'.b'

      sadbfnvmtcdlat = 'vmtcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdlon = 'vmtcdlon.'//trim(suffix2d3)//'.b'
      sadbfnvmtcdeht = 'vmtcdeht.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlat = 'vstcdlat.'//trim(suffix2d3)//'.b'
      sadbfnvstcdlon = 'vstcdlon.'//trim(suffix2d3)//'.b'

      gfnvmtcdlat = 'vmtcdlat.'//trim(suffix2)
      gfnvmtcdlon = 'vmtcdlon.'//trim(suffix2)
      gfnvmtcdeht = 'vmtcdeht.'//trim(suffix2)
      gfnvmtcdhor = 'vmtcdhor.'//trim(suffix2)
      gfnvstcdlat = 'vstcdlat.'//trim(suffix2)
      gfnvstcdlon = 'vstcdlon.'//trim(suffix2)
      gfnvstcdhor = 'vstcdhor.'//trim(suffix2)

      gfncvtcdlat = 'cvtcdlat.'//trim(suffix2)
      gfncvtcdlon = 'cvtcdlon.'//trim(suffix2)
      gfncvtcdeht = 'cvtcdeht.'//trim(suffix2)

      gfnvmdcdlat = 'vmdcdlat.'//trim(suffix2)
      gfnvmdcdlon = 'vmdcdlon.'//trim(suffix2)
      gfnvmdcdeht = 'vmdcdeht.'//trim(suffix2)
      gfnvmdcdhor = 'vmdcdhor.'//trim(suffix2)
      gfnvsdcdlat = 'vsdcdlat.'//trim(suffix2)
      gfnvsdcdlon = 'vsdcdlon.'//trim(suffix2)
      gfnvsdcdhor = 'vsdcdhor.'//trim(suffix2)

      gfncvdcdlat = 'cvdcdlat.'//trim(suffix2)
      gfncvdcdlon = 'cvdcdlon.'//trim(suffix2)
      gfncvdcdeht = 'cvdcdeht.'//trim(suffix2)

      call vecstats(gfnvmtcdhor,nthinhor)
      call vecstats(gfnvmtcdeht,nthineht)

c-------------------------------------
c - Stats of the TRANSFORMATION grids
c-------------------------------------

      if(nthinhor.ne.0)then
        write(6,1012)trim(bfnvmtcdlat)
        call gridstats(bfnvmtcdlat,ave,std,xmd)
        avelatm = ave
        stdlatm = std
        write(6,1012)trim(bfnvmtcdlon)
        call gridstats(bfnvmtcdlon,ave,std,xmd)
        avelonm = ave
        stdlonm = std

        write(6,1012)trim(bfnvstcdlat)
        call gridstats(bfnvstcdlat,ave,std,xmd)
        avelats = ave
        stdlats = std
        write(6,1012)trim(bfnvstcdlon)
        call gridstats(bfnvstcdlon,ave,std,xmd)
        avelons = ave
        stdlons = std

c - Get color palette, Lat, meters:
        call cpt(avelatm,stdlatm,csm,cptlolatm,cpthilatm,cptinlatm)

c - Get color palette, Lon, meters:
        call cpt(avelonm,stdlonm,csm,cptlolonm,cpthilonm,cptinlonm)

c - Get color palette, Lat, arcseconds:
        call cpt(avelats,stdlats,csm,cptlolats,cpthilats,cptinlats)

c - Get color palette, Lon, arcseconds:
        call cpt(avelons,stdlons,csm,cptlolons,cpthilons,cptinlons)

      endif

      if(nthineht.ne.0)then
        write(6,1012)trim(bfnvmtcdeht)
        call gridstats(bfnvmtcdeht,ave,std,xmd)
        aveehtm = ave
        stdehtm = std

c - Get color palette, Eht, meters:
        call cpt(aveehtm,stdehtm,csm,cptloehtm,cpthiehtm,cptinehtm)

      endif



c-------------------------------------
c - Stats of the METHOD NOISE ("d3") grids
c-------------------------------------
      if(nthinhor.ne.0)then
        write(6,1012)trim(sadbfnvmtcdlat)
        call gridstats(sadbfnvmtcdlat,ave,std,xmd)
        avelatmsad = ave
        stdlatmsad = std
        xmdlatmsad = xmd
        write(6,1012)trim(sadbfnvmtcdlon)
        call gridstats(sadbfnvmtcdlon,ave,std,xmd)
        avelonmsad = ave
        stdlonmsad = std
        xmdlonmsad = xmd

        write(6,1012)trim(sadbfnvstcdlat)
        call gridstats(sadbfnvstcdlat,ave,std,xmd)
        avelatssad = ave
        stdlatssad = std
        xmdlatssad = xmd
        write(6,1012)trim(sadbfnvstcdlon)
        call gridstats(sadbfnvstcdlon,ave,std,xmd)
        avelonssad = ave
        stdlonssad = std
        xmdlonssad = xmd

c - Get color palette, Lat, meters:
c       call cpt(avelatmsad,stdlatmsad,csm,
c    *  cptlolatmsad,cpthilatmsad,cptinlatmsad)
c       cptlolatmsad = 0.d0
c - 2016 01 21:
c       cpthilatmsad = 2 * csm * cptinlatmsad
c - 2016 07 28:
        call cpt2(xmdlatmsad,2.d0,
     *  cptlolatmsad,cpthilatmsad,cptinlatmsad)


c - Get color palette, Lon, meters:
c       call cpt(avelonmsad,stdlonmsad,csm,
c    *  cptlolonmsad,cpthilonmsad,cptinlonmsad)
c       cptlolonmsad = 0.d0
c - 2016 01 21:
c       cpthilonmsad = 2 * csm * cptinlonmsad
c - 2016 07 28:
        call cpt2(xmdlonmsad,2.d0,
     *  cptlolonmsad,cpthilonmsad,cptinlonmsad)


c - Get color palette, Lat, arcseconds:
c       call cpt(avelatssad,stdlatssad,csm,
c    *  cptlolatssad,cpthilatssad,cptinlatssad)
c       cptlolatssad = 0.d0
c - 2016 01 21:
c       cpthilatssad = 2 * csm * cptinlatssad
c - 2016 07 28:
        call cpt2(xmdlatssad,2.d0,
     *  cptlolatssad,cpthilatssad,cptinlatssad)


c - Get color palette, Lon, arcseconds:
c       call cpt(avelonssad,stdlonssad,csm,
c    *  cptlolonssad,cpthilonssad,cptinlonssad)
c       cptlolonssad = 0.d0
c - 2016 01 21:
c       cpthilonssad = 2 * csm * cptinlonssad
c - 2016 07 28:
        call cpt2(xmdlonssad,2.d0,
     *  cptlolonssad,cpthilonssad,cptinlonssad)

      endif

      if(nthineht.ne.0)then
        write(6,1012)trim(sadbfnvmtcdeht)
        call gridstats(sadbfnvmtcdeht,ave,std,xmd)
        aveehtmsad = ave
        stdehtmsad = std
        xmdehtmsad = xmd

c - Get color palette, Eht, meters:
c       call cpt(aveehtmsad,stdehtmsad,csm,
c    *  cptloehtmsad,cpthiehtmsad,cptinehtmsad)
c       cptloehtmsad = 0.d0
c - 2016 01 21:
c       cpthiehtmsad = 2 * csm * cptinehtmsad
        call cpt2(xmdehtmsad,2.d0,
     *  cptloehtmsad,cpthiehtmsad,cptinehtmsad)

      endif









 1012 format(6x,'makeplotfiles02.f: Grabbing stats of grid: ',a)

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
c - Make B/W Coverage Plots of Thinned data
c - Latitude
        if(nthinhor.ne.0)    
     *  call bwplotcv('lat',gfncvtcdlat,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LAT',ij,
     *  igridsec,fn)
c - Longitude
        if(nthinhor.ne.0)
     *  call bwplotcv('lon',gfncvtcdlon,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LON',ij,
     *  igridsec,fn)
c - Ellipsoid Height
        if(nthineht.ne.0)
     *  call bwplotcv('eht',gfncvtcdeht,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'EHT',ij,
     *  igridsec,fn)

c - Make B/W Coverage Plots of Dropped data
c - Latitude
        if(nthinhor.ne.0)
     *  call bwplotcv('lat',gfncvdcdlat,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LAT',ij,
     *  igridsec,fn)
c - Longitude
        if(nthinhor.ne.0)
     *  call bwplotcv('lon',gfncvdcdlon,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LON',ij,
     *  igridsec,fn)
c - Ellipsoid Height
        if(nthineht.ne.0)
     *  call bwplotcv('eht',gfncvdcdeht,bw,be,bs,bn,jm,
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

c - Make B/W Vector Plots of Thinned data

c - Latitude
        if(nthinhor.ne.0)then
          call bwplotvc('lat',gfnvmtcdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
          call bwplotvc('lat',gfnvstcdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
        endif
c - Longitude
        if(nthinhor.ne.0)then
          call bwplotvc('lon',gfnvmtcdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
          call bwplotvc('lon',gfnvstcdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
        endif
c - Ellipsoid height
        if(nthineht.ne.0)then
          call bwplotvc('eht',gfnvmtcdeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'EHT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvogehtm,lorvopc,igridsec,fn)
        endif
c - Horizontal
        if(nthinhor.ne.0)then
          call bwplotvc('hor',gfnvmtcdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
          call bwplotvc('hor',gfnvstcdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
        endif

c - Make B/W Vector Plots of Dropped data

c - Latitude
        if(nthinhor.ne.0)then
          call bwplotvc('lat',gfnvmdcdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
          call bwplotvc('lat',gfnvsdcdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
        endif
c - Longitude
        if(nthinhor.ne.0)then
          call bwplotvc('lon',gfnvmdcdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
          call bwplotvc('lon',gfnvsdcdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
        endif
c - Ellipsoid Height
        if(nthineht.ne.0)then
          call bwplotvc('eht',gfnvmdcdeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'EHT',ij,xvlon,xvlat,xllon,xllat,
     *    lorvogehtm,lorvopc,igridsec,fn)
        endif
c - Horizontal
        if(nthinhor.ne.0)then
          call bwplotvc('hor',gfnvmdcdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghorm,lorvopc,igridsec,fn)
          call bwplotvc('hor',gfnvsdcdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *    lorvoghors,lorvopc,igridsec,fn)
        endif

c --------------------
c - Color gridded data (Transformation grid)
c --------------------
c - Make color plots of gridded (T=0.4), thinned data, with no
c - points.  

c - Latitude
        if(nthinhor.ne.0)then
          call coplot('lat',bfnvmtcdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,cptlolatm,cpthilatm,cptinlatm,
     *    suffix2t04,igridsec,fn)
          call coplot('lat',bfnvstcdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LAT',ij,cptlolats,cpthilats,cptinlats,
     *    suffix2t04,igridsec,fn)
        endif
c - Longitude
        if(nthinhor.ne.0)then
          call coplot('lon',bfnvmtcdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,cptlolonm,cpthilonm,cptinlonm,
     *    suffix2t04,igridsec,fn)
          call coplot('lon',bfnvstcdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'LON',ij,cptlolons,cpthilons,cptinlons,
     *    suffix2t04,igridsec,fn)
        endif
c - Ellipsoid Height
        if(nthineht.ne.0)then
          call coplot('eht',bfnvmtcdeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *    olddtm,newdtm,region,'EHT',ij,cptloehtm,cpthiehtm,cptinehtm,
     *    suffix2t04,igridsec,fn)
        endif

c --------------------
c - Color gridded data ("method noise", AKA "d3" grid)
c --------------------
c - Make color plots of "method noise" *with* data overlain.  See
c - DRU-11, p.150

c - Latitude
        if(nthinhor.ne.0)then
          call coplotwcv('lat',sadbfnvmtcdlat,bw,be,bs,bn,jm,b1,b2,
     *    maxplots,olddtm,newdtm,region,'LAT',ij,cptlolatmsad,
     *    cpthilatmsad,cptinlatmsad,suffix2d3,igridsec,fn,
     *    gfncvtcdlat)

          call coplotwcv('lat',sadbfnvstcdlat,bw,be,bs,bn,jm,b1,b2,
     *    maxplots,olddtm,newdtm,region,'LAT',ij,cptlolatssad,
     *    cpthilatssad,cptinlatssad,suffix2d3,igridsec,fn,
     *    gfncvtcdlat)
        endif
c - Longitude
        if(nthinhor.ne.0)then
          call coplotwcv('lon',sadbfnvmtcdlon,bw,be,bs,bn,jm,b1,b2,
     *    maxplots,olddtm,newdtm,region,'LON',ij,cptlolonmsad,
     *    cpthilonmsad,cptinlonmsad,suffix2d3,igridsec,fn,
     *    gfncvtcdlon)

          call coplotwcv('lon',sadbfnvstcdlon,bw,be,bs,bn,jm,b1,b2,
     *    maxplots,olddtm,newdtm,region,'LON',ij,cptlolonssad,
     *    cpthilonssad,cptinlonssad,suffix2d3,igridsec,fn,
     *    gfncvtcdlon)
        endif
c - Ellipsoid Height
        if(nthineht.ne.0)then
          call coplotwcv('eht',sadbfnvmtcdeht,bw,be,bs,bn,jm,b1,b2,
     *    maxplots,olddtm,newdtm,region,'EHT',ij,cptloehtmsad,
     *    cpthiehtmsad,cptinehtmsad,suffix2d3,igridsec,fn,
     *    gfncvtcdeht)
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
 9999 format('END program makeplotfiles02.f')


      end
c
c ------------------------------------------------------
c
      include 'Subs/bwplotvc.f'
      include 'Subs/bwplotcv.f'
      include 'Subs/coplot.f'
      include 'Subs/coplotwcv.f'
      include 'Subs/plotcoast.f'
      include 'Subs/getmapbounds.f'
      include 'Subs/getmag.f'
      include 'Subs/cpt.f'
      include 'Subs/select2_mod.for'
      include 'Subs/cpt2.f'
      include 'Subs/gridstats.f'
      include 'Subs/vecstats.f'
