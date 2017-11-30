c> \ingroup doers
c> \if MANPAGE     
c> \page makework
c> \endif      
c> 
c> **Program** to create a *work* file which will
c> serve as the primary information needed to
c> analyze and create NADCON v5.0 grids.
c>       
c> 
c> This program is based on previous programs that
c> were created by Dru Smith during the GEOCON v2.0
c> process.  It has been modified specifically to be a tool
c> for NADCON v5.0.
c> 
c> Rather than have multiple programs (1, 2, 3, 4 as
c> was the case for GEOCON v2.0), It was decided
c> make ONE working "makework.f" program (this one)
c> and have it feed off of an input file which 
c> can be modified. 
c>      
c> The input file will reflect all that is necessary
c> to create a work file.
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> They are enumerated here
c> \param oldtm Source Datum
c> \param newdtm Target Datum,region
c> \param region Conversion Region 
c>      
c> ### Program Inputs:
c> 
c>- A *control file* in directory `Control/`, the name is generated from
c>  input arguments     
c> 
c> Known control file names are:
c> 
c>     cfname = control.ussd.nad27.conus
c>     cfname = control.nad27.nad83_1986.conus
c>
c>- A *manual edits* file, called `workedits` in
c> directory `Work/`
c>     
c> ## By way of example...
c>      
c> **If** the input file controlling the creation of the work file is:
c>      
c>     Control/control.ussd.nad27.conus
c>      
c> then the output data file is:
c>      
c>     Work/work.ussd.nad27.conus
c>      
c> The work file has the following format:
c>      
c>     Cols  Format Description
c>       1-  6   a6    PID
c>           7   1x    - blank -
c>       8-  9   a2    State
c>          10   a1    Reject code for missing latitude pair (blank for good)
c>          11   a1    Reject code for missing longitude pair (blank for good)
c>          12   a1    Reject code for missing ellip ht pair (blank for good)
c>          13   1x    - blank -
c>      14- 27 f14.10  Latitude (Old Datum), decimal degrees (-90 to +90)
c>          28   1x    - blank -
c>      29- 42 f14.10  Lonitude (Old Datum), decimal degrees (0 to 360)
c>          43   1x    - blank -
c>      44- 51   f8.3  Ellipsoid Height (Old datum), meters
c>          52   1x    - blank -
c>      53- 61   f9.5  Delta Lat (New Datum minus Old Datum), arcseconds
c>          62   1x    - blank -
c>      63- 71   f9.5  Delta Lon (New Datum minus Old Datum), arcseconds
c>          72   1x    - blank -
c>      73- 81   f9.3  Delta Ell Ht (New Datum minus Old Datum), meters
c>          82   1x    - blank - 
c>      83- 91   f9.3  Delta Horizontal (absolute value), arcseconds
c>          92   1x    - blank -
c>      93-101   f9.5  Azimuth of Delta Horizontal (0-360), degrees
c>         102   1x    - blank - 
c>     103-111   f9.3  Delta Lat (New Datum minus Old Datum), meters
c>         112   1x    - blank -
c>     113-121   f9.3  Delta Lon (New Datum minus Old Datum), meters
c>         122   1x    - blank -
c>     123-131   f9.3  Delta Horizontal (absolute value), meters
c>         132   1x    - blank -
c>     133-142   a10   Old Datum Name
c>         143   1x    - blank - 
c>     144-153   a10   New Datum Name
c>         format(a6,1x,a2,a1,a1,a1,1x,f14.10,1x,f14.10,1x,f8.3,1x,
c>        *f9.5,1x,f9.5,1x,f9.3,1x,f9.3,1x,f9.5,1x,f9.3,1x,f9.3,1x,f9.3,
c>         1x,a10,1x,a10)
c>      
c> 
c>  This differs from Dennis's GEOCON v1.0 in that:
c>   - 3 reject codes
c>   - 10 decimal places in latitude (See DRU-10, p. 123)
c>   - 10 decimal places in longitude (See DRU-10, p. 123)
c>   - Lat, Lon and Horizontal in both arcseconds and meters each
c>   - Azimuth of Horizontal 
c>   - Identification of which datums are transformed
c>     
c>  ##References
c>  ### NADCON5:
c>      
c>  See:
c>    - DRU-11, p. 124
c>  
c>  ### GEOCON v2.0:
c>  
c>  See:    
c>    - DRU-10, p. 143
c>    - DRU-11, p. 10
c>    - DRU-11, p. 26
c>    - DRU-11, p. 56
c>
c>  ## Changelog    
c>      
c>  ### 2017 11 19 (**NG**)
c>  Formated Comments to be compatible with Doxygen     
c>  Due to deprecation of various arguments for GMT tools, invocation of `xyz2grd`
c>  and `grd2xyz` have arguments options changed in generated files
c>   - `-bos` ->  `-bo3f` with equivalent meaning of a 3 column single precision output
c>   - `-bis` ->  `-bi3f` with equivalent meaning of a 3 column single precision input     
c>      
c>  ### 2016 09 14:
c>  Due to some complications in mymedian5.f which happen if
c>  data is in the *work* file that is not to be sorted and used, I've decided
c>  to put the *out of grid* point removal code here, so that such points
c>  will go into the *work* file but will all get a `111` set of reject codes
c>  so they don't go forward in the processing.
c>  
c>  ### 2016 09 13:
c>  Fixed a bug that sends an incoming `0` reject flag as a **zero**.  All
c>  later programs expect a BLANK for a "good" reject code.  The incoming `0` is
c>  from the `workedits` file and is fine to come in, but must go OUT as a BLANK.
c>  
c>  Also, put in code to correct situations where an entry is in `workedits`, but 
c>  the PID for that entry isn't actually in the incoming data.  This relies
c>  on a new vector `EditTracker`
c>
c>  ### 2016 02 26:
c>  Change (see: DRU-12, p. 18) to reflect the decision that "manual edits" should ONLY
c>  edit data OUT and **not** add data back in.
c>
c>  ### 2016 01 07:
c>  Changed to split "Relevant Edits" into
c>  three counts:  lat, lon and eht   
      program makework

      implicit double precision(a-h,o-z)
      parameter(maxedits = 10000)

      character*58 fname0
      character*200 cfname
      character*200 wfname
      character*200 efname
      character*80 card

c - Information extracted from control file
      character*6  cline
      character*80 cheader
      character*30 cregion
      character*30 cdatum1
      character*30 cdatum2

c - Variables for working with manual edit file
      character*10 dummy1,dummy2,dummy3
      character*10 EditRegion(maxedits)
      character*10 EditOldDtm(maxedits)
      character*10 EditNewDtm(maxedits)
      character*6  EditPID(maxedits)
      character*1  EditRejLat(maxedits)
      character*1  EditRejLon(maxedits)
      character*1  EditRejEht(maxedits)

c - Each *.in file (including directory):
      character*100 fname

c - "h" and "f" are artifacts.  "h" for HARN meaning
c - "old datum".  "f" for FBN meaning "new datum".
c - Too much trouble to go back and fix variable names.
c - Just know that "f" means NEW and "h" means OLD,
c - no matter what the datums themselves ARE.
      character*15 nameh
      character*15 namef
      character*6 pid
      character*2 state
      character*13 clath,clatf
      character*14 clonh,clonf
      character*9  cehth,cehtf

      character*10 olddtm,newdtm,region

      character*1 rejlat,rejlon,rejeht

      character*200 suffix1

      logical badlat,badlon,badeht

c - 2016 09 13 - To track the use of each so-called "relevant" edit,
c - in case some of them aren't actually relevant (e.g. the PID
c - doesn't match what's coming in)
      logical EditTracker(maxedits)

c ------------------------------------------------------------------
c - BEGIN PROGRAM
c ------------------------------------------------------------------
      write(6,1001)
 1001 format('BEGIN program makework.f')

c ------------------------------------------------------------------
c - User-supplied input
c ------------------------------------------------------------------
      read(5,'(a)')olddtm
      read(5,'(a)')newdtm
      read(5,'(a)')region

c ------------------------------------------------------------------
c - 2016 09 14 : Get the official grid bounds for this region,
c - so that we can auto-reject (Flag with "111") any points
c - that come in and are not inside the official grid bounds.
c ------------------------------------------------------------------
      call getgridbounds(region,xn,xs,xw,xe)
      noutside = 0

c ------------------------------------------------------------------
c - Generate the suffixes used in all our files
c ------------------------------------------------------------------
      suffix1=trim(olddtm)//'.'//trim(newdtm)//'.'//trim(region)

c ------------------------------------------------------------------
c - Open the control file 
c ------------------------------------------------------------------
      cfname='Control/control.'//trim(suffix1)
      open(1,file=cfname,status='old',form='formatted')
      write(6,1004)trim(cfname)
 1004 format(6x,'makework.f: Accessing control file ',a)

c ------------------------------------------------------------------
c - Open the "manual edits" file 
c ------------------------------------------------------------------
      efname='Work/workedits'
      open(20,file=efname,status='old',form='formatted')
      write(6,1006)trim(efname)
 1006 format(6x,'makework.f: Accessing workedits file ',a)

c ------------------------------------------------------------------
c - Create and open the work file 
c ------------------------------------------------------------------
c -  The location of the "work*" file
      wfname = 'Work/work.'//trim(suffix1)
      open(2,file=wfname,status='new',form='formatted')

      write(6,1002)trim(wfname)
 1002 format(6x,'makework.f: Creating work file ',a)

c ------------------------------------------------------------------
c - Some necessary constants.
c ------------------------------------------------------------------
      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0
      re = 6371000.d0

c ------------------------------------------------------------------
c - Initialize statistical mins and maxes
c ------------------------------------------------------------------
      xlatmin =  90.0000
      xlatmax = -90.0000
      xlonmin = 360.0000
      xlonmax =   0.0000

c ------------------------------------------------------------------
c - 2016 09 13
c - Initialize counts for final report
c ------------------------------------------------------------------
      npts = 0
      nptsLat = 0
      nptsLon = 0
      nptsEht = 0

c ------------------------------------------------------------------
c - Read the control file in and prepare things.  
c - For now, presume it is in the exact order below, rather than searching.
c ------------------------------------------------------------------
c - Header line.  Can contain anything.
      cline='HEADER'
      read(1,'(a)')card
      if(card(1:6).ne.cline)then
        write(6,6000)cline,trim(cfname)
        stop
      endif
      cheader = trim(card(8:200))

c - REGION.  Must conform to the following list (expand as needed):
c    conus, alaska, prvi, hawaii, guamcnmi, as, pribilof, stlawrence
      cline='REGION'
      read(1,'(a)')card
      if(card(1:6).ne.cline)then
        write(6,6000)cline,trim(cfname)
        stop
      endif
      cregion = trim(card(8:200))

c - DATUM1.  The older datum, chronologically.
      cline='DATUM1'
      read(1,'(a)')card
      if(card(1:6).ne.cline)then
        write(6,6000)cline,trim(cfname)
        stop 
      endif
      cdatum1 = trim(card(8:200))

c - DATUM2.  The newer datum, chronologically.
      cline='DATUM2'
      read(1,'(a)')card
      if(card(1:6).ne.cline)then
        write(6,6000)cline,trim(cfname)
        stop 
      endif
      cdatum2 = trim(card(8:200))

c - REJMET.  The rejection criteria in meters.
c - Basically if any latitude shift or longitude
c - shift or horizontal shift exceeds this value
c - (in absolute value), then all shifts for this
c - point are set to zero (to avoid asterisks in
c - the output file) but the whole line is labeled 
c - with a triple reject criteria, effectively
c - eliminating the pair from use.
      cline='REJMET'
      read(1,'(a)')card
      if(card(1:6).ne.cline)then
        write(6,6000)cline,trim(cfname)
        stop 
      endif
      read(trim(card(8:200)),*)rejmet

c - NFILES.  The number of *.in files which connect
c - the old and new datums in the region being
c - addressed.
      cline='NFILES'
      read(1,'(a)')card
      if(card(1:6).ne.cline)then
        write(6,6000)cline,trim(cfname)
        stop 
      endif
      read(card(9:10),*)nfiles

 6000 format(6x,'makework.f: Expecting ',a6,' line in ',
     *a,' but not found. Stopping')
c ------------------------------------------------------------------
c - Read the "manual edits" (workedits) file into RAM, so that it may
c - be applied on the fly as we go through the "in" files and build
c - the "work" file.  Note that the "workedits" file contains every
c - manual edit, for every point, for every combination of 
c - old datum/new datum/region that we might work in.  This prevents
c - the need for multiple files and allows easy access to every change
c - requested.
c - 2016 09 13:  Update:  Also set all "EditTracker" values to ".false."
c - so that they can be turned on to ".true." as they actually
c - get applied.  Then we can look for remainign ".false." ones.
c ------------------------------------------------------------------

      neditsTotal = 0
      neditsRelevant = 0
      neditsRelevantLat = 0
      neditsRelevantLon = 0
      neditsRelevantEht = 0
c - 2016 09 13
      neditsRelevantUsed = 0
      neditsRelevantUsedLat = 0
      neditsRelevantUsedLon = 0
      neditsRelevantUsedEht = 0

  701 read(20,702,end=703)card
c - If I find a comment or blank, skip out.  Otherwise
c - pick up one edit's worth of data, and then loop back up
        if(card(1:1).eq.'#' .or. card(1:1).eq.' ')goto 701
        neditsTotal = neditsTotal + 1
        if(trim(card(   1: 10)) .eq. trim(olddtm) .and.
     *     trim(card(  12: 21)) .eq. trim(newdtm) .and.
     *     trim(card(  23: 32)) .eq. trim(region) )then
          neditsRelevant = neditsRelevant + 1
c - 2016 09 13:
          EditTracker(neditsRelevant) = .false.

          if(card(41:41).eq.'1')then
            neditsRelevantLat = neditsRelevantLat + 1
          endif
          if(card(42:42).eq.'1')then
            neditsRelevantLon = neditsRelevantLon + 1
          endif
          if(card(43:43).eq.'1')then
            neditsRelevantEht = neditsRelevantEht + 1
          endif

          EditOldDtm(neditsRelevant) = card(  1: 10)
          EditNewDtm(neditsRelevant) = card( 12: 21)
          EditRegion(neditsRelevant) = card( 23: 32)
          EditPID(neditsRelevant)    = card( 34: 39)
          EditRejLat(neditsRelevant) = card( 41: 41)
          EditRejLon(neditsRelevant) = card( 42: 42)
          EditRejEht(neditsRelevant) = card( 43: 43)
c - 2016 09 13:  FORCE the "0" flags to be " "
          if(EditRejLat(neditsRelevant).eq.'0')then
            EditRejLat(neditsRelevant) = ' '
          endif
          if(EditRejLon(neditsRelevant).eq.'0')then
            EditRejLon(neditsRelevant) = ' '
          endif
          if(EditRejEht(neditsRelevant).eq.'0')then
            EditRejEht(neditsRelevant) = ' '
          endif
        endif
      goto 701
  702 format(a)
c 703 write(6,704)neditsTotal,neditsRelevant
c 704 format(6x,'makework.f: Total Manual Edits Found: ',i6,/,
c    *       6x,'         Relevant Manual Edits Found: ',i6)

  703 write(6,704)neditsTotal,neditsRelevant,
     *neditsRelevantLat,neditsRelevantLon,neditsRelevantEht
  704 format(6x,'makework.f: Total Manual Edits Found: ',i6,/,
     *       6x,' Initial Relevant Manual Edits Found: ',i6,/,
     *       6x,'             ...of these, # in LAT  : ',i6,/,
     *       6x,'                          # in LON  : ',i6,/,
     *       6x,'                          # in EHT  : ',i6)

c - Loop over all *.in files, compute stuff, populate work file.

      do 1 i=1,nfiles
        read(1,'(a)')fname0
        fname='InFiles/'//trim(fname0)
        write(6,999)trim(fname)
  999   format(6x,'makework.f: Processing file: ',a)
        open(10,file=fname,status='old',form='formatted')

        read(10,100)nameh,namef
c       write(6,100)nameh,namef
    2   read(10,101,end=98)pid,state,clath,clonh,cehth,clatf,clonf,cehtf
          badlat=.false.
          badlon=.false.
          badeht=.false.
          if(clath(11:13).eq.'N/A' .or. 
     *       clatf(11:13).eq.'N/A')badlat=.true.
          if(clonh(12:14).eq.'N/A' .or. 
     *       clonf(12:14).eq.'N/A')badlon=.true.
          if(cehth( 7: 9).eq.'N/A' .or.   
     *       cehtf( 7: 9).eq.'N/A')badeht=.true.

c - See DRU-10, p. 142 for the below decision
          if    (     badlat .and.      badlon .and.      badeht)then
            rejlat = '1'
            rejlon = '1'
            rejeht = '1'
          elseif(     badlat .and.      badlon .and. .not.badeht)then
            rejlat = '1'
            rejlon = '1'
            rejeht = '2'
          elseif(     badlat .and. .not.badlon .and.      badeht)then
            rejlat = '1'
            rejlon = '2'
            rejeht = '1'
          elseif(     badlat .and. .not.badlon .and. .not.badeht)then
            rejlat = '1'
            rejlon = '2'
            rejeht = '2'
          elseif(.not.badlat .and.      badlon .and.      badeht)then
            rejlat = '2'
            rejlon = '1'
            rejeht = '1'
          elseif(.not.badlat .and.      badlon .and. .not.badeht)then
            rejlat = '2'
            rejlon = '1'
            rejeht = '2'
          elseif(.not.badlat .and. .not.badlon .and.      badeht)then
            rejlat = ' '
            rejlon = ' '
            rejeht = '1'
          elseif(.not.badlat .and. .not.badlon .and. .not.badeht)then
            rejlat = ' '
            rejlon = ' '
            rejeht = ' '
          else
            stop 10005
          endif

         
          if(.not.badlat)then
            read(clath(2: 3),'(i2.2)')ilatdh
            read(clath(4: 5),'(i2.2)')ilatmh
            read(clath(6:13),'(f8.5)')xlatsh
            read(clatf(2: 3),'(i2.2)')ilatdf
            read(clatf(4: 5),'(i2.2)')ilatmf
            read(clatf(6:13),'(f8.5)')xlatsf
            xlath = dble(ilatdh) + dble(ilatmh)/60.d0 + xlatsh/3600.d0
            if(clath(1:1).eq.'S')xlath = -xlath
            xlatf = dble(ilatdf) + dble(ilatmf)/60.d0 + xlatsf/3600.d0
            if(clatf(1:1).eq.'S')xlatf = -xlatf

            dlat    = xlatf - xlath
            dlatsec = dlat * 3600.d0
            dlatm   = dlat*d2r*re 

          endif

          if(.not.badlon)then
            read(clonh(2: 4),'(i3.3)')ilondh
            read(clonh(5: 6),'(i2.2)')ilonmh
            read(clonh(7:14),'(f8.5)')xlonsh
            read(clonf(2: 4),'(i3.3)')ilondf
            read(clonf(5: 6),'(i2.2)')ilonmf
            read(clonf(7:14),'(f8.5)')xlonsf
            xlonh = dble(ilondh) + dble(ilonmh)/60.d0 + xlonsh/3600.d0
            if(clonh(1:1).eq.'W')xlonh = 360.d0 - xlonh
            xlonf = dble(ilondf) + dble(ilonmf)/60.d0 + xlonsf/3600.d0
            if(clonf(1:1).eq.'W')xlonf = 360.d0 - xlonf

c - Need a cosine of latitude.  On the super rare off chance that either the
c - HARN or the FBN latitude are "N/A", despite both of the longitudes
c - NOT being "N/A", I will look for this eventuality and account for it...
            if(clath(11:13).ne.'N/A')then
              coslat = dcos(xlath*d2r)
            else
              if(clatf(11:13).ne.'N/A')then
                coslat = dcos(xlatf*d2r)
              else
                coslat = 0.d0
                rejlon = '3'
              endif
            endif

            dlon    = xlonf - xlonh
            dlonsec = dlon * 3600.d0
            dlonm   = coslat*dlon*d2r*re
          endif

          if(.not.badeht)then
            read(cehth(1: 9),'(f9.3)')xehth
            read(cehtf(1: 9),'(f9.3)')xehtf
            dehtm = xehtf - xehth
          endif

          if(.not.badlat .and. .not.badlon)then
            dhorsec = dsqrt(dlatsec**2 + dlonsec**2)
            dhorm   = dsqrt(dlatm**2 + dlonm**2)
            azhor = datan2(dlonm,dlatm)/d2r
            if(azhor.lt.0)azhor = azhor + 360.d0
          endif

c - 2015 08 14 -- Do an auto-rejection on ridiculously large shifts
          if(dabs(dlatm).gt.rejmet .or.
     *       dabs(dlonm).gt.rejmet .or.
     *       dabs(dhorm  ).gt.rejmet )then
             badlat =.true.
             badlon =.true.
             badeht =.true.
             rejlat ='1'
             rejlon ='1'
             rejeht ='1'
           endif

c - If there was a bad lat pair, bad lon pair or bad height pair
c - then turn this value to 0.0
          if(badlat)then
            xlath = 0.d0
            dlatsec = 0.d0
            dlatm = 0.d0
            dhorsec = 0.d0
            dhorm = 0.d0
            azhor = 0.d0 
          endif
            
          if(badlon)then
            xlonh = 0.d0
            dlonsec = 0.d0
            dlonm = 0.d0
            dhorsec = 0.d0
            dhorm = 0.d0
            azhor = 0.d0 
          endif
            
          if(badeht)then
            xehth = 0.d0
            dehtm = 0.d0
          endif


c - 2016 09 14:  Check if this point is out side of the
c - official grid bounds for this region.  If so, 
c - flag it as bad in lat/lon/eht.
           if(xlath.lt.xs.or.xlath.gt.xn .or.
     *        xlonh.lt.xw.or.xlonh.gt.xe) then
              noutside = noutside + 1
              badlat = .true.
              badlon = .true.
              badeht = .true.
              rejlat = '4'
              rejlon = '4'
              rejeht = '4'
              write(6,2003)pid,xlath,xlonh
          endif
 2003       format(
     *      6x,'program makework.f: InFile point found',
     *      ' and flagged with 444 which is outside ',
     *      ' the grid boundaries:',a6,1x,f14.10,1x,f14.10)



c - Now, using only GOOD points, let's find the min/max of everything
          if(.not.badlat .and. .not.badlon)then
            if(xlath.lt.xlatmin)xlatmin=xlath
            if(xlath.gt.xlatmax)xlatmax=xlath
            if(xlonh.lt.xlonmin)xlonmin=xlonh
            if(xlonh.gt.xlonmax)xlonmax=xlonh
          endif

c - At this point I should be able to print out what I need. 
c - Cycle through all of the Relevant manual edits, looking
c - for this PID, and apply the manual rejections.

          do 720 irel = 1,neditsRelevant
c           write(6,751)irel,trim(EditPID(irel)),pid
  751 format('Checking irel=',i4,' PID=',a6,
     *' against true pid=',a6)
            if(trim(EditPID(irel)).ne.pid)goto 720

c - Updated 2016 09 13:  If I get here, I'm using this
c - "relevant edit", so track it:
c           write(6,*) ' HERE'
            EditTracker(irel) = .true. 

c - Updated 9/13/2016:  The final reject code given to "ok" values
c -                     must be a BLANK, not a ZERO!  I've switched
c -                     the code earlier, so all "EditRejXXX" values that were zeros
c - are blanks.  So this code is good here now.
c - Modified 2/26/2016:  *ONLY* replace a rejection code under these
c - rules:
c       A "0" or " "  never replaces a standing "1" (or "2")
c       A "1" always replaces a standing "0" or " "
c       (And for ease of coding, a standing "0" or " " can be replaced with another "0" or " ")

            if(rejlat.eq.'0' .or. rejlat.eq.' ')
     *        rejlat = EditRejLat(irel)
            if(rejlon.eq.'0' .or. rejlon.eq.' ')
     *        rejlon = EditRejLon(irel)
            if(rejeht.eq.'0' .or. rejeht.eq.' ')
     *        rejeht = EditRejEht(irel)
c       rejlat = EditRejLat(irel)
c       rejlon = EditRejLon(irel)
c       rejeht = EditRejEht(irel)
c - End of 2/26/2016 Modification

  720     continue

c     write(6,104)pid,state,rejlat,rejlon,rejeht,xlath,xlonh,xehth,
c    *dlatsec,dlonsec,dehtm,dhorsec,azhor,dlatm,dlonm,dhorm,
c    *olddtm,newdtm


          write(2,104)pid,state,rejlat,rejlon,rejeht,xlath,xlonh,xehth,
     *    dlatsec,dlonsec,dehtm,dhorsec,azhor,dlatm,dlonm,dhorm,
     *    olddtm,newdtm

c - 2016 09 13
          npts = npts + 1
          if(rejlat.eq.' ')nptsLat = nptsLat + 1
          if(rejlon.eq.' ')nptsLon = nptsLon + 1
          if(rejeht.eq.' ')nptsEht = nptsEht + 1

  104     format(a6,1x,a2,a1,a1,a1,1x,f14.10,1x,f14.10,1x,f8.3,1x,
     *    f9.5,1x,f9.5,1x,f9.3,1x,f9.5,1x,f9.5,1x,f9.3,1x,f9.3,1x,f9.3,
     *    1x,a10,1x,a10)

c - The new file has the following format:
c   Cols  Format Description
c   1-  6   a6    PID
c       7   1x    - blank -
c   8-  9   a2    State
c      10   a1    Reject code for missing latitude pair (blank for good)
c      11   a1    Reject code for missing longitude pair (blank for good)
c      12   a1    Reject code for missing ellip ht pair (blank for good)
c      13   1x    - blank -
c  14- 27 f14.10  Latitude (HARN), decimal degrees (-90 to +90)
c      28   1x    - blank -
c  29- 42 f14.10  Lonitude (HARN), decimal degrees (0 to 360)
c      43   1x    - blank -
c  44- 51   f8.3  Ellipsoid Height (HARN), meters
c      52   1x    - blank -
c  53- 61   f9.5  Delta Lat (FBN-HARN), arcseconds
c      62   1x    - blank -
c  63- 71   f9.5  Delta Lon (FBN-HARN), arcseconds
c      72   1x    - blank -
c  73- 81   f9.3  Delta Ell Ht (FBN-HARN), meters
c      82   1x    - blank - 
c  83- 91   f9.5  Delta Horizontal (absolute value), arcseconds
c      92   1x    - blank -
c  93-101   f9.5  Azimuth of Delta Horizontal (0-360), degrees
c     102   1x    - blank - 
c 103-111   f9.3  Delta Lat (FBN-HARN), meters
c     112   1x    - blank -
c 113-121   f9.3  Delta Lon (FBN-HARN), meters
c     122   1x    - blank -
c 123-131   f9.3  Delta Horizontal (absolute value), meters

        goto 2

   98 continue

c     write(6,103)trim(fname)
      close(10)
c     pause
    
    1 continue

c - Updated 2016 09 13:
c -   I notice that sometimes there is a typo in the workedits file
c -   and a "relevant" edit isn't really relevant, because, while
c -   it matches olddatum/newdatum/region, the actual PID isn't
c -   even in the InFiles for this olddatum/newdatum/region.
c -   So in the above code, I've been tracking who got used
c -   in "EditTracker".  Let's spin over all so-called "Relevant Edits"
c -   and see who did NOT get used.

c         write(6,*)EditTracker
c         pause

          iNotRel = 0
          iNotRelLat = 0
          iNotRelLon = 0
          iNotReleht = 0
          
          do 740 irel = 1,neditsRelevant
            if(EditTracker(irel))goto 740
            iNotRel = iNotRel + 1
            if(EditRejLat(irel).eq.'1')then
              iNotRelLat = iNotRelLat + 1
            endif
            if(EditRejLon(irel).eq.'1')then
              iNotRelLon = iNotRelLon + 1
            endif
            if(EditRejEht(irel).eq.'1')then
              iNotRelEht = iNotRelEht + 1
            endif
            write(6,731)EditPID(irel)
  731       format(
     *      6x,'program makework.f: So-called Relevant Edit not used',
     *      ' since PID is not in the incoming data:',a6)
  740     continue   

          neditsRelevantUsed = neditsRelevant - iNotRel
          neditsRelevantUsedLat = neditsRelevantLat - iNotRelLat
          neditsRelevantUsedLon = neditsRelevantLon - iNotRelLon
          neditsRelevantUsedEht = neditsRelevantEht - iNotRelEht

          write(6,732)neditsRelevantUsed,neditsRelevantUsedLat,
     *    neditsRelevantUsedLon,neditsRelevantUsedEht
  732     format(6x,'makework.f: ',/,
     *       6x,'   Final Relevant Manual Edits Found: ',i6,/,
     *       6x,'             ...of these, # in LAT  : ',i6,/,
     *       6x,'                          # in LON  : ',i6,/,
     *       6x,'                          # in EHT  : ',i6)

      

      write(6,1005)xlatmin,xlatmax,xlonmin,xlonmax
 1005 format(
     *6x,'program makework.f: Minimum latitude: ',f14.10,/,
     *6x,'program makework.f: Maximum latitude: ',f14.10,/,
     *6x,'program makework.f: Minimum longitude: ',f14.10,/,
     *6x,'program makework.f: Maximum longitude: ',f14.10)


c - 2016 09 13
      write(6,1010)npts,nptsLat,nptsLon,nptsEht
 1010 format(
     *6x,'program makework.f: Total records in work file: ',i9,/,
     *6x,'program makework.f:   With a usable LAT diff  : ',i9,/,
     *6x,'program makework.f:   With a usable LON diff  : ',i9,/,
     *6x,'program makework.f:   With a usable EHT diff  : ',i9)



   99 write(6,1003)
 1003 format('END program makework.f')

  
        
     
  100 format(27x,a15,26x,a15)
  101 format(a6,1x,a2,5x,a13,1x,a14,1x,a9,3x,a13,1x,a14,1x,a9)
  102 format(f15.9,1x,f14.9,1x,f5.1)
  103 format(6x,'makework.f: Done with file : ',a)


      end
      include 'Subs/getgridbounds.f'
