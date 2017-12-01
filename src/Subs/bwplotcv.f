c> \ingroup core
c> \if MANPAGE     
c> \page bwplotcv
c> \endif      
c> 
c> Subroutine to make GMT calls to do a B/W coverage plot
c> 
c> ## Changelog
c> 
c> ### 2016 08 29:
c> Updated the `-R` and `-B` initial calls to 6 decimal places      
c> 
c> ### 2016 08 25:
c> `.gmtdefaults4` has been changed so X_ORIGIN is equal to 0.0
c> Center the plot with "-Xc" at first "psxy" call
c> Remove all "-JM**i+" references, and just use the actual
c> width (jm) that came out of the "getmapbounds" routine and
c> was sent here.
c> 
c> ### 2016 07 21:
c> Modified use of JM command based on new forced sizes.  
c> 
c> ### 2015 02 15:
c> Updated  to allow this subroutine to work
c> earlier (in makeplotfiles01()), before `igridsec` was defined.
c> See DRU-11, p. 139
c> 
      subroutine bwplotcv(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
     *olddtm,newdtm,region,elecap,ij,igridsec,fn)

c - 2016 08 29:
c   Updated the -R and -B initial calls to 6 decimal places      

c - 2016 08 25:
c     .gmtdefaults4 has been changed so X_ORIGIN is equal to 0.0
c     Center the plot with "-Xc" at first "psxy" call
c     Remove all "-JM**i+" references, and just use the actual
c       width (jm) that came out of the "getmapbounds" routine and
c       was sent here.

c - 2016 07 21:
c - Modified use of JM command based on new forced sizes.  

c - Subroutine to make GMT calls to do a B/W coverage plot

c - Updated 10/2/2015 to allow this subroutine to work
c - earlier (in makeplotfiles01.f), before "igridsec" was defined.
c - See DRU-11, p. 139

      integer*4 maxplots
      character*3 ele,elecap
      character*200 fname
      character*10 olddtm,newdtm,region
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
      character*5 extra
      character*20 gridnote

c ----------------------------------------------------
c - All coverage type files begin with "cv". 
c - The 3rd element tells me all, thinned, dropped or RMS 
c - The 4th/5th elements tell me if these are coordinate
c - differneces or double differences.  Elements 6,7,8
c - tell me what data we're plotting.
c ----------------------------------------------------


c ----------------------------------------------------
c - FAILSAFES: BEGIN
c ----------------------------------------------------
      if(fname(3:3).eq.'t')then
        extra='-thin'
      elseif(fname(3:3).eq.'d')then
        extra='-drop'
      elseif(fname(3:3).eq.'a')then
        extra='-all '
      elseif(fname(3:3).eq.'r')then
        extra='-RMSd'
      else
        write(6,1)trim(fname)
        stop
      endif
    1 format('FATAL in bwplotcv.  Bad character in spot 3: ',a)

      if(fname(1:2).ne.'cv')then
        write(6,2)trim(fname)
        stop
      endif
    2 format('FATAL in bwplotcv.  Bad character in spots 1-2: ',a)
      
      if(.not.(fname(4:5).eq.'cd' .or. fname(4:5).eq.'dd'))then
        write(6,3)trim(fname)
        stop
      endif
    3 format('FATAL in bwplotcv.  Bad character in spots 4-5: ',a)

      if(fname(6:8).ne.ele)then
        write(6,4)trim(fname),ele
        stop
      endif
    4 format('FATAL in bwplotcv.  Bad match of fname / ele: ',a,1x,a)

c - Just in case we forgot to set "igridsec" to be -1
c - when we came here from makeplotfiles01:
      if(fname(1:3).eq.'cvacd')then
        igridsec = -1
      endif

      if(igridsec.le.0)then
        gridnote = ''
      else
        write(gridnote,10)igridsec
      endif
   10 format('(',i0,' sec)')



c ----------------------------------------------------
c - FAILSAFES: END
c ----------------------------------------------------



c ----------------------------------------------
c - GMT COMMANDS: BEGIN
c ----------------------------------------------

c - Header of commands/echoes:
      write(99,991)ele,extra,trim(region),trim(fn(ij)),
     *ele,extra,trim(region),trim(fn(ij))

c - Write out the actual dots, and the title, with PSXY command
      write(99,904)trim(fname),bw(ij),be(ij),bs(ij),bn(ij),
     *jm(ij),b1(ij),b2(ij),trim(newdtm),trim(olddtm),elecap,
     *extra,trim(gridnote),trim(region),trim(fn(ij))

c - ALWAYS plot the coast last, as it closes the PS file
      call plotcoast(region,99)

c - Convert PS to JPG
      write(99,905)

c - Rename the JPG to my naming scheme 
      write(99,910)trim(fname),trim(fn(ij))
c ----------------------------------------------
c - GMT COMMANDS: END
c ----------------------------------------------



  991 format(
     *'# -----------------------------------------------------',/,
     *'# coverage in ',a,a,1x,a,1x,a,/,
     *'# -----------------------------------------------------',/,
     *'echo ...coverage in ',a,a,1x,a,1x,a)


c - Plot the actual coverage points
c - 2016 08 29
  904 format('psxy ',a,' -Xc -R',f0.6,'/',f0.6,'/',sp,f0.6,'/',f0.6,
     *  ss,' -JM',f3.1,'i -B',f0.6,'/',f0.6,':."',
     *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
     *  1x,a,'-',a,
     *  '": -Sc0.02i ',
     *  '-Gblack -K > plot.ps')



c - 2016 08 25:
c 904 format('psxy ',a,' -Xc -R',f0.2,'/',f0.2,'/',sp,f0.2,'/',f0.2,
c    *  ss,' -JM',f3.1,'i -B',f0.2,'/',f0.2,':."',
c    *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
c    *  1x,a,'-',a,
c    *  '": -Sc0.02i ',
c    *  '-Gblack -K > plot.ps')
c - 2016 07 21
c 904 format('psxy ',a,' -R',f0.2,'/',f0.2,'/',sp,f0.2,'/',f0.2,
c    *  ss,' -JM',f3.1,'i -B',f0.2,'/',f0.2,':."',
c    *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
c    *  1x,a,'-',a,
c    *  '": -Sc0.02i ',
c    *  '-Gblack -K > plot.ps')
c 904 format('psxy ',a,' -R',f0.2,'/',f0.2,'/',sp,f0.2,'/',f0.2,
c    *  ss,' -JM',f3.1,'i+ -B',f0.2,'/',f0.2,':."',
c    *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
c    *  1x,a,'-',a,
c    *  '": -Sc0.02i ',
c    *  '-Gblack -K > plot.ps')

c - 905 = Convert PS to JPG
  905 format('ps2raster plot.ps -Tj -P -A ')


c - Renaming 
  910 format('mv -f plot.jpg ',a,'.',a,'.jpg',/,
     *'rm -f plot.ps')
c 910 format('mv -f plot.jpg cv',a1,a3,'.',a,'.',a,'.',a,
c    *'.',i0,'.',a,'.jpg',/,'rm -f plot.ps')
 1910 format('mv -f plot.jpg cv',a3,'.',a,'.',a,'.',a,
     *'.',a,'.jpg',/,'rm -f plot.ps')

      return
      end
