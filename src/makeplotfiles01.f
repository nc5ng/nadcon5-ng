c> \ingroup doers
c> \if MANPAGE     
c> \page makeplotfiles01
c> \endif      
c> 
c> Part of the NADCON5 process, generates gmtbat01
c>
c> Program to take a "work" file and create
c> a variety of GMT-ready data files of the following
c> 1. Coverage in latitude
c> 2. Coverage in longitude
c> 3. Coverage in ellipsoid height
c> 4. Vectors  in latitude
c> 5. Vectors  in longitude
c> 6. Vectors  in ellipdoid height
c> 7. Vectors  in horizontal (properly azimuthed)
c>
c> It furthermore will create batch file to run the
c> GMT scripts:
c>     
c>      gmtbat01.(olddtm).(newdtm).(region).(mapflag)
c>
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> They are enumerated here
c> \param oldtm Source Datum
c> \param newdtm Target Datum,region
c> \param region Conversion Region 
c> \param mapflag Map Detail Level
c>     
c> Example:
c>     
c>     olddatum = 'ussd'
c>     newdatum = 'nad27'
c>     region = 'conus'
c>     mapflag = 0      
c>      
c> ### Program Inputs:
c> 
c> ## Changelog
c>       
c> ### 2016 08 26
c> Added new code to do reference vectors consistently
c> See DRU-12, p. 56-57
c> Also changing the call to "getmapbounds" to give it "olddatum" and "newdatum"
c> to aide in filtering out things like the Saint regions in Alaska
c> for unsupported transformations.
c>       
c> ### 2016 07 29:
c> Scrapped the code for personalized reference vector location.  Just put
c> all ref vectors outside/below plot.
c>       
c> ### 2016 07 21:
c> Added code to allow for optional placement of reference vectors, coming from
c> "map.parameters" as read in subroutine "getmapbounds"
c>       
      program makeplotfiles01
      implicit double precision(a-h,o-z)
      parameter(maxplots=60)

c - Stuff that is in the work file records:
      character*6 pid
      character*2 state
      character*1 rejlat,rejlon,rejeht
      real*8 xlath,xlonh,xehth
      real*8 dlatsec,dlonsec,dehtm,dhorsec,azhor
      real*8 dlatm,dlonm,dhorm
      character*10 olddtm,newdtm,region

c - Input work file:
      character*200 wfname

c - Plot/Scale stuff
      real*8 lorvopc
      real*8 lorvoghorm,lorvoghors
      real*8 lorvogehtm

c - Output GMT-ready files:
c - Coverage, All, Coordinate Differences
      character*200 gfncvacdlat
      character*200 gfncvacdlon
      character*200 gfncvacdeht

c - Vectors, All, Coordinate Differences, Meters
      character*200 gfnvmacdlat
      character*200 gfnvmacdlon
      character*200 gfnvmacdeht
      character*200 gfnvmacdhor

c - Vectors, All, Coordinate Differences, ArcSeconds
      character*200 gfnvsacdlat
      character*200 gfnvsacdlon
      character*200 gfnvsacdhor

c - GMT stuff
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
c - 2016 07 21:
      logical lrv(maxplots)
      real*8 rv0x(maxplots),rv0y(maxplots),rl0y(maxplots)

c - Output GMT-batch file: 
      character*200 gmtfile
   
      character*1 mapflag
      character*200 suffix1,suffix4

c ------------------------------------------------------------------
c - BEGIN PROGRAM
c ------------------------------------------------------------------
      write(6,1001)
 1001 format('BEGIN makeplotfiles01.f')

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
c--------------------------------------------
      lorvopc = 1.d0
      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      re  = 6371000.d0

      MultiplierLorvog = 2 

c--------------------------------------------
c - User-supplied input
c--------------------------------------------
      read(5,'(a)')olddtm
      read(5,'(a)')newdtm
      read(5,'(a)')region
      read(5,'(a)')mapflag

c ------------------------------------------------------------------
c - Generate the suffixes used in all our files
c ------------------------------------------------------------------
      suffix1=trim(olddtm)//'.'//trim(newdtm)//'.'//trim(region)
      suffix4=trim(suffix1)//'.'//trim(mapflag)

c ------------------------------------------------------------------
c - Create and open the work file 
c ------------------------------------------------------------------
      wfname='work.'//trim(suffix1)
      open(1,file='Work/'//wfname,status='old',form='formatted')
      write(6,1004)trim(wfname)
 1004 format(6x,'makeplotfiles01.f: Opening work file ',a)

c ------------------------------------------------------------------
c - Open the GMT batch file for plotting
c ------------------------------------------------------------------
      gmtfile = 'gmtbat01.'//trim(suffix4)
      open(99,file=gmtfile,status='new',form='formatted')
      write(6,1011)trim(gmtfile)
 1011 format(6x,'makeplotfiles01.f: Creating GMT batch file ',a)
      write(99,1030)trim(gmtfile)
 1030 format('echo BEGIN batch file ',a)


c ------------------------------------------------------------------
c - Open the output GMT-ready files
c ------------------------------------------------------------------
      gfncvacdlat = 'cvacdlat.'//trim(suffix1)
      open(11,file=gfncvacdlat,status='new',form='formatted')
      write(6,1010)trim(gfncvacdlat)

      gfncvacdlon = 'cvacdlon.'//trim(suffix1)
      open(12,file=gfncvacdlon,status='new',form='formatted')
      write(6,1010)trim(gfncvacdlon)

      gfncvacdeht = 'cvacdeht.'//trim(suffix1)
      open(13,file=gfncvacdeht,status='new',form='formatted')
      write(6,1010)trim(gfncvacdeht)

c - Vectors, Meters, All, Coordinate Differences
      gfnvmacdlat = 'vmacdlat.'//trim(suffix1)
      open(21,file=gfnvmacdlat,status='new',form='formatted')
      write(6,1010)trim(gfnvmacdlat)

      gfnvmacdlon = 'vmacdlon.'//trim(suffix1)
      open(22,file=gfnvmacdlon,status='new',form='formatted')
      write(6,1010)trim(gfnvmacdlon)

      gfnvmacdeht = 'vmacdeht.'//trim(suffix1)
      open(23,file=gfnvmacdeht,status='new',form='formatted')
      write(6,1010)trim(gfnvmacdeht)

      gfnvmacdhor = 'vmacdhor.'//trim(suffix1)
      open(24,file=gfnvmacdhor,status='new',form='formatted')
      write(6,1010)trim(gfnvmacdhor)

c - Vectors, ArcSeconds, All, Coordinate Differences
      gfnvsacdlat = 'vsacdlat.'//trim(suffix1)
      open(31,file=gfnvsacdlat,status='new',form='formatted')
      write(6,1010)trim(gfnvsacdlat)

      gfnvsacdlon = 'vsacdlon.'//trim(suffix1)
      open(32,file=gfnvsacdlon,status='new',form='formatted')
      write(6,1010)trim(gfnvsacdlon)

      gfnvsacdhor = 'vsacdhor.'//trim(suffix1)
      open(34,file=gfnvsacdhor,status='new',form='formatted')
      write(6,1010)trim(gfnvsacdhor)

 1010 format(6x,'makeplotfiles01.f: Creating file ',a)

c - LAZY CODING:  Spin through work file, collecting stats
c - which we will use to scale the map and vectors, etc.
c - Then rewind the work file.
c - If I wasn't lazy, this would be a RAM-read, etc etc
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
          ndhor = ndhor + 1
        endif
        if(rejeht.eq.' ')then
c - Because they can be +/-, we and this is JUST for scaling the map,
c - we want the average MAGNITUDE...use ABS.  This means that
c - I don't need to accept my own latter advice of returning
c - here and using RMS.
          avedehtm = avedehtm + dabs(dehtm)
          ndeht = ndeht + 1
        endif
      goto 891
  892 continue
      if(ndhor.gt.0)then
        avedhorm = avedhorm / dble(ndhor)
        avedhors = avedhors / dble(ndhor)
      else
        avedhorm = 0.d0
        avedhors = 0.d0
      endif
      if(ndeht.gt.0)then
        avedehtm = avedehtm / dble(ndeht)
      else
        avedehtm = 0.d0
      endif
      write(6,893)ndhor,avedhorm,avedhors,ndeht,avedehtm
  893 format(6x,'makeplotfiles01.f: Vector Stats: ',/,
     *10x,'Number of Good Horizontal Vectors : ',i10,/,
     *10x,'Average length (meters)           : ',f10.3,/,
     *10x,'Average length (arcseconds)       : ',f10.6,/,
     *10x,'Number of Good Ell. Ht.   Vectors : ',i10,/,
     *10x,'Average length (meters)           : ',f10.3)

c - END OF LAZY CODING
        

c --------------------------------------------------------------
c - GMT Batch file:  Determine Number of areas to plot (=nplots)
c -                  and Boundaries of plots and other stuff
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
 1006 format(6x,'makeplotfiles01.f: Calling getmapbounds for region ',a)

c ---------------------------------------------------------------
c - Compute and report various things about our coverage 
c - and vector plots.
c ---------------------------------------------------------------
c - Reference vector set to length of the average 
c - absolute value of horizontal or ell ht shift.

c - I keep flip-flopping about whether it's more visually 
c - pleasing to use the average or twice the average.

c - As of 2015 10 22, I go with "twice the average"
c - Thus:      MultiplierLorvog = 2 

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

      write(6,894)nplots
  894 format(6x,'makeplotfiles01.f: Info about plots:',/,
     *8x,'Number of sub-region plot sets ',
     *'being made for this region: ',i2)

      do 895 i=1,nplots
        dns = bn(i) - bs(i)
        dew = be(i) - bw(i)
        write(6,896)i,region,fn(i),
     *  bs(i),bn(i),bw(i),be(i),dns,dew
        if(ndhor.ne.0)then
          write(6,897)lorvoghorm,lorvoghors,gm2pchor,gs2pchor
        else
          write(6,898)
        endif

        if(ndeht.ne.0)then
          write(6,899)lorvogehtm,gm2pceht
        else
          write(6,900)
        endif

  895 continue 

  896 format(50('-'),/,
     *8x,'Plot # ',i2,
     *'(',a,1x,a,')',/,
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

c - pvlon and pvlat are the percentage of the total lon/lat
c - span of the plot, from which the reference vector
c - begins, starting with the Lower Left corner
      pvlon = 10.d0
      pvlat = 10.d0

      pvlat = (pvlat / 100.d0)
      pvlon = (pvlon / 100.d0)

c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - MAIN LOOP: TOP
c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - Read in each record and produce GMT-ready data for
c - all appropriate non-rejected records.

      rewind(1)

      n=0
      ncvlat = 0
      ncvlon = 0
      ncveht = 0
      nvclat = 0
      nvclon = 0
      nvceht = 0
      nvchor = 0

    1 read(1,104,end=2)pid,state,rejlat,rejlon,rejeht,xlath,xlonh,xehth,
     *dlatsec,dlonsec,dehtm,dhorsec,azhor,dlatm,dlonm,dhorm,
     *olddtm,newdtm

  104 format(a6,1x,a2,a1,a1,a1,1x,f14.10,1x,f14.10,1x,f8.3,1x,
     *f9.5,1x,f9.5,1x,f9.3,1x,f9.5,1x,f9.5,1x,f9.3,1x,f9.3,1x,f9.3,
     *1x,a10,1x,a10)


c - Experiment
  105 format(f16.10,1x,f15.10,1x,f6.2,1x,f12.2,1x,f5.1)
 1105 format(f16.10,1x,f15.10,1x,f6.2,1x,a6)

c1106 format(f16.10,1x,f15.10,1x,f6.2,1x,f12.2,1x,f5.1,1x,f9.5,1x,a6)
 1106 format(f16.10,1x,f15.10,1x,f6.2,1x,f12.2,1x,f9.5,1x,f9.3,1x,a6)
 
c---------------------------------------------------------------------
c - If it's a good latitude point, write to:
c    11) Latitude Coverage File
c    21) Latitude Vector (meters) File
c    31) Latitude Vector (seconds) File
        if(rejlat.eq.' ')then
          if(dlatm.le.0)then
            az = 180.d0
          else
            az =   0.d0
          endif
          vclatm = dabs(dlatm  *gm2pchor)
          vclats = dabs(dlatsec*gs2pchor)
          write(11,1105)xlonh,xlath,sngl(1.0),pid
          write(21,1106)xlonh,xlath,az,vclatm,dlatsec,dlatm,pid
          write(31,1106)xlonh,xlath,az,vclats,dlatsec,dlatm,pid
          ncvlat = ncvlat + 1
          nvclat = nvclat + 1
        endif
c---------------------------------------------------------------------
c - If it's a good longitude point, write to:
c    12) Longitude Coverage File
c    22) Longitude Vector (meters) File
c    32) Longitude Vector (seconds) File
        if(rejlon.eq.' ')then
          if(dlonm.le.0)then
            az = 270.d0
          else
            az =  90.d0
          endif
          vclonm = dabs(dlonm  *gm2pchor)
          vclons = dabs(dlonsec*gs2pchor)
          write(12,1105)xlonh,xlath,sngl(1.0),pid
          write(22,1106)xlonh,xlath,az,vclonm,dlonsec,dlonm,pid
          write(32,1106)xlonh,xlath,az,vclons,dlonsec,dlonm,pid

          ncvlon = ncvlon + 1
          nvclon = nvclon + 1
        endif
c---------------------------------------------------------------------
c - If it's a good ell ht    point, write to:
c    13) Ell Ht Coverage File
c    23) Ell Ht Vector (meters) File
        if(rejeht.eq.' ')then
          if(dehtm.le.0)then
            az = 180.d0
          else
            az =   0.d0
          endif
          vcehtm = dabs(dehtm*gm2pceht)
          write(13,1105)xlonh,xlath,sngl(1.0),pid
          write(23,1106)xlonh,xlath,az,vcehtm,0.d0,dehtm,pid

          ncveht = ncveht + 1
          nvceht = nvceht + 1
        endif
c---------------------------------------------------------------------
c - If it's a good latitude *and* good longitude point, write to:
c    24) Horizontal Vector (meters) File
c    34) Horizontal Vector (seconds) File
        if(rejlat.eq.' ' .and. rejlon.eq.' ')then
c - No need for "dabs", since its already applied
          vchorm =     dhorm  *gm2pchor
          vchors =     dhorsec*gs2pchor
          write(24,1106)xlonh,xlath,azhor,vchorm,dhorsec,dhorm,pid
          write(34,1106)xlonh,xlath,azhor,vchors,dhorsec,dhorm,pid

          nvchor = nvchor + 1
        endif

c - Count total number of points read in the work file
        n=n+1


      goto 1

c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - MAIN LOOP: BOTTOM
c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------

    2 continue

      write(6,778)n,ncvlat,ncvlon,ncveht,nvclat,nvclon,nvceht,nvchor

  778 format(6x,'makeplotfiles01.f: Statistics: ',/,
     *10x,'Number of total records read           : ',i10,/,
     *10x,'Number of lat coverage records prepared: ',i10,/,
     *10x,'Number of lon coverage records prepared: ',i10,/,
     *10x,'Number of eht coverage records prepared: ',i10,/,
     *10x,'Number of lat vector   records prepared: ',i10,/,
     *10x,'Number of lon vector   records prepared: ',i10,/,
     *10x,'Number of eht vector   records prepared: ',i10,/,
     *10x,'Number of hor vector   records prepared: ',i10)

c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - CREATE GMT BATCH FILE
c - There are multiple steps here:
c - 1) Determine how many maps to make (for example, for
c      CONUS its a little easier to look at things when
c      broken down into a 3x3 tile over CONUS, rather than
c      one large plot)
c - 2) Determine the boundaries of each map to be created
c - 3) Determine which shoreline (GMT-provided, or Dru's
c      personally created detailed shorelines of certain
c      areas)
c - 4) The title of each plot
c - 5) The size of each plot
c - 6) The file name to use for each plot
c -
c - As each decision is made, make the right calls to the batch
c - file.
c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
      write(6,800)
  800 format(6x,'makeplotfiles01.f: Preparing GMT batch file')

c --------------------------------------------------------------
c - GMT Batch file:  Make header
c --------------------------------------------------------------
      write(6,801)
  801 format(6x,'makeplotfiles01.f: GMT: Write header')

      write(99,901)
  901 format('gmtset GRID_PEN_PRIMARY 0.25p,-')
      write(99,902)
c 902 format('gmtset BASEMAP_TYPE fancy')
  902 format('gmtset BASEMAP_TYPE fancy',/,
     *'gmtset HEADER_FONT Helvetica',/,
     *'gmtset HEADER_FONT_SIZE 12p',/,
     *'gmtset HEADER_OFFSET 0.5c')


      write(6,802)
  802 format(6x,'makeplotfiles01.f: GMT: Num Plots Analysis')
      write(6,1005)trim(region)
 1005 format(6x,'makeplotfiles01.f: REGION = ',a)


c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - GMT Batch creation loop TOP
c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - For each "ij" value, we will put GMT calls into batch
c - file "gmtbat01***" (unit 99) which will plot the following:
c -     1) Coverage in LAT
c -     2) Coverage in LON
c -     3) Coverage in EHT
c -     4) Vectors  in LAT, meters
c -     5) Vectors  in LON, meters
c -     6) Vectors  in EHT, meters
c -     7) Vectors  in HOR, meters
c -     8) Vectors  in LAT, arcseconds
c -     9) Vectors  in LON, arcseconds
c -    10) Vectors  in HOR, arcseconds
c --------------------------------------------------------------
c
c - Note on "igridsec":  Later in the NADCON5 processing,
c - "igridsec" will mean the number of arcseconds at which 
c - thinnging and gridding occur.  At this point, though,
c - it has not meaning.  We set it to "-1" to tell the
c - plotting programs to ignore it.


      igridsec = -1

      do 2001 ij=1,nplots
        write(99,990)trim(region),trim(fn(ij)),
     *  trim(region),trim(fn(ij))

c--------------------------------------
c - B/W COVERAGE PLOTS
c--------------------------------------
c - Make B/W Coverage Plots 
c - Latitude
        call bwplotcv('lat',gfncvacdlat,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LAT',ij,
     *  igridsec,fn)
c - Longitude
        call bwplotcv('lon',gfncvacdlon,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'LON',ij,
     *  igridsec,fn)
c - Ellipsoid Height
        call bwplotcv('eht',gfncvacdeht,bw,be,bs,bn,jm,
     *  b1,b2,maxplots,olddtm,newdtm,region,'EHT',ij,
     *  igridsec,fn)

c--------------------------------------
c - VECTORS
c--------------------------------------
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

c  - Vectors in LAT
        call bwplotvc('lat',gfnvmacdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *  lorvoghorm,lorvopc,igridsec,fn)
        call bwplotvc('lat',gfnvsacdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,
     *  lorvoghors,lorvopc,igridsec,fn)
c       call bwplotvc('lat',gfnvmacdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)
c       call bwplotvc('lat',gfnvsacdlat,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'LAT',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)


c  - Vectors in LON
        call bwplotvc('lon',gfnvmacdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *  lorvoghorm,lorvopc,igridsec,fn)
        call bwplotvc('lon',gfnvsacdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,
     *  lorvoghors,lorvopc,igridsec,fn)
c       call bwplotvc('lon',gfnvmacdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)
c       call bwplotvc('lon',gfnvsacdlon,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'LON',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)

c  - Vectors in EHT
        call bwplotvc('eht',gfnvmacdeht,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'EHT',ij,xvlon,xvlat,xllon,xllat,
     *  lorvogehtm,lorvopc,igridsec,fn)
c       call bwplotvc('eht',gfnvmacdeht,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'EHT',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)

c  - Vectors in HOR
        call bwplotvc('hor',gfnvmacdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *  lorvoghorm,lorvopc,igridsec,fn)
        call bwplotvc('hor',gfnvsacdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
     *  olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,
     *  lorvoghors,lorvopc,igridsec,fn)
c       call bwplotvc('hor',gfnvmacdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)
c       call bwplotvc('hor',gfnvsacdhor,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *  olddtm,newdtm,region,'HOR',ij,xvlon,xvlat,xllon,xllat,ncmhor,
c    *  q1hor,igridsec,fn)

 2001 continue

c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------
c - GMT Batch creation loop BOTTOM
c --------------------------------------------------------------
c --------------------------------------------------------------
c --------------------------------------------------------------

      write(99,1031)trim(gmtfile)
 1031 format('echo END batch file ',a)
      close(99)

      write(6,9999)
 9999 format('END makeplotfiles01.f')



  990 format(
     *'# ------------------------------',/,
     *'# Plots for region: ',a,', sub-region: ',a,/,
     *'# ------------------------------',/,
     *'echo Creating plots for region: ',a,', sub-region: ',a)

      end
c
c
c
      include 'Subs/getmapbounds.f'
      include 'Subs/plotcoast.f'
      include 'Subs/bwplotcv.f'
      include 'Subs/bwplotvc.f'
      include 'Subs/onzd2.f'
