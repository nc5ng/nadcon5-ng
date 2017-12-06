c> \ingroup core
c> \if MANPAGE     
c> \page bwplotvc
c> \endif      
c> 
c> Subroutine to make GMT calls to do a B/W vector plot
c> 
c> ## Changelog
c> 
c> ### 2016 08 29:
c> Expanded the refence vector calls to be 6 decimal places, as well
c> as the initial -R call for S/N/W/E
c> and also the -B part of that call
c> 
c> ### 2016 08 25:
c> `.gmtdefaults4` has been changed so X_ORIGIN is equal to 0.0
c> Center the plot with "-Xc" at first "psxy" call
c> Remove all "-JM**i+" references, and just use the actual
c> width (jm) that came out of the "getmapbounds" routine and
c> was sent here.
c> 
c> ### 2016 07 29:  
c> Updated the reference vector call to 
c> have the "-N" option, so it'll plot outside the map
c> 
c> ### 2016 07 21:
c> Modified use of JM command based on new forced sizes.  
c> 
c> ### 2015 02 15:
c> Updated  to allow this subroutine to work
c> earlier (in makeplotfiles01()), before `igridsec` was defined.
c> See DRU-11, p. 139
c> 
      subroutine bwplotvc(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
     *olddtm,newdtm,region,elecap,ij,xvlon,xvlat,xllon,xllat,lorvog,
     *lorvopc,igridsec,fn)

c - 2016 08 29:
c     Expanded the refence vector calls to be 6 decimal places, as well
c     as the initial -R call for S/N/W/E
c     and also the -B part of that call

c - 2016 08 25:
c     .gmtdefaults4 has been changed so X_ORIGIN is equal to 0.0
c     Center the plot with "-Xc" at first "psxy" call
c     Remove all "-JM**i+" references, and just use the actual
c       width (jm) that came out of the "getmapbounds" routine and
c       was sent here.


c - 2016 07 29:  Updated the reference vector call to 
c - have the "-N" option, so it'll plot outside the map

c - 2016 07 21:  Updated JM usage for new forced sizes

c     subroutine bwplotvc(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *olddtm,newdtm,region,elecap,ij,xvlon,xvlat,xllon,xllat,ncm,
c    *q1,igridsec,fn)
c - Subroutine to make GMT calls to do a B/W vector plot

c - Updated 10/2/2015 to allow this subroutine to work
c - earlier (in makeplotfiles01.f), before "igridsec" was defined.
c - See DRU-11, p. 139

      implicit real*8(a-h,o-z)
      integer*4 maxplots
      character*3 ele,elecap
      character*200 fname
      character*10 olddtm,newdtm,region
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
      character*5 extra
      character*20 units
      character*20 gridnote
      character*20 gridnote2

      real*8 lorvopc,lorvog

c ----------------------------------------------------
c - All vector  type files begin with either "vm"
c - (meters) or "vs" (arcseconds).
c - The 3rd element tells me all, thinned, dropped or RMS
c - The 4th/5th elements tell me if these are coordinate
c - differnces or double differences.  Elements 6,7,8
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
    1 format('FATAL in bwplotvc.  Bad character in spot 3: ',a)

      if(.not.(fname(1:2).eq.'vm'.or.fname(1:2).eq.'vs'))then
        write(6,2)trim(fname)
        stop
      endif
    2 format('FATAL in bwplotvc.  Bad character in spots 1-2: ',a)

      if(.not.(fname(4:5).eq.'cd' .or. fname(4:5).eq.'dd' .or.
     *         fname(4:5).eq.'gi'))then
        write(6,3)trim(fname)
        stop
      endif
    3 format('FATAL in bwplotvc.  Bad character in spots 4-5: ',a)

      if(fname(6:8).ne.ele)then
        write(6,4)trim(fname),ele
        stop
      endif
    4 format('FATAL in bwplotvc.  Bad match of fname / ele: ',a,1x,a)

c - Just in case we forgot to set "igridsec" to be -1
c - when we came here from makeplotfiles01:
      if(fname(1:3).eq.'vmacd' .or. fname(1:3).eq.'vsacd')then
        igridsec = -1
      endif

      if    (fname(2:2).eq.'m')then
        units='meters'
      elseif(fname(2:2).eq.'s')then
        units='arcseconds' 
      else
        write(6,5)trim(fname)
        stop
      endif
    5 format('FATAL in bwplotvc.  Bad units in name: ',a)

      if(igridsec.le.0)then
        gridnote = ''
        gridnote2 = ''
      else
        write(gridnote,10)igridsec
        write(gridnote2,11)igridsec
      endif
   10 format('(',i0,' sec)')
   11 format(i0,'.')

c ----------------------------------------------------
c - FAILSAFES: END
c ----------------------------------------------------


c ----------------------------------------------
c - GMT COMMANDS: BEGIN
c ----------------------------------------------

c - Header of commands/echoes:
      write(99,991)ele,extra,trim(units),trim(region),trim(fn(ij)),
     *ele,extra,trim(units),trim(region),trim(fn(ij))

c - Plot the actual vectors, and the title, with PSXY command
      write(99,903)trim(fname),bw(ij),be(ij),bs(ij),bn(ij),
     *jm(ij),b1(ij),b2(ij),trim(newdtm),trim(olddtm),elecap,
     *extra,trim(gridnote),trim(region),trim(fn(ij)),fname(2:5)



c - Plot the reference vector
      write(99,908)xvlon,xvlat,90.d0,lorvopc
c     write(99,908)xvlon,xvlat,90.d0,q1

c - Label the reference vector
c - HACK
c     write(6,807)trim(fname),trim(units)
c 807 format('File: ',a,/,'Units: ',a)
      if    (trim(units).eq.'arcseconds')then
        write(99,1909)xllon,xllat,lorvog,trim(units)
      elseif(trim(units).eq.'meters')then
        write(99, 909)xllon,xllat,lorvog,trim(units)
      endif

c - ALWAYS plot the coast last, as it closes the PS file
      call plotcoast(region,99)

c - Convert PS to JPG
      write(99,905)

c - Rename the JPG to my naming scheme
c     write(99,906)trim(fname),trim(gridnote2),trim(fn(ij))
      write(99,906)trim(fname),trim(fn(ij))

c ----------------------------------------------
c - GMT COMMANDS: END
c ----------------------------------------------

  991 format(
     *'# -----------------------------------------------------',/,
     *'# vectors in ',a,a,1x,a,1x,a,1x,a,/,
     *'# -----------------------------------------------------',/,
     *'echo ...vectors in ',a,a,1x,a,1x,a,1x,a)

c - Plot the actual vectors
c - 2016 08 29
  903 format('psxy ',a,' -Xc -R',f0.6,'/',f0.6,'/',sp,f0.6,'/',f0.6,
     *  ss,' -JM',f3.1,'i -B',f0.6,'/',f0.6,':."',
     *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
     *  1x,a,'-',a,1x,a,
     *'": -SV0.0001i/0.02i/0.02i ',
     *  '-Gblack -K > plot.ps')
c - 2016 08 25:
c 903 format('psxy ',a,' -Xc -R',f0.2,'/',f0.2,'/',sp,f0.2,'/',f0.2,
c    *  ss,' -JM',f3.1,'i -B',f0.2,'/',f0.2,':."',
c    *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
c    *  1x,a,'-',a,1x,a,
c    *'": -SV0.0001i/0.02i/0.02i ',
c    *  '-Gblack -K > plot.ps')

c 903 format('psxy ',a,' -R',f0.2,'/',f0.2,'/',sp,f0.2,'/',f0.2,
c    *  ss,' -JM',f3.1,'i -B',f0.2,'/',f0.2,':."',
c    *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
c    *  1x,a,'-',a,1x,a,
c    *'": -SV0.0001i/0.02i/0.02i ',
c    *  '-Gblack -K > plot.ps')
c 903 format('psxy ',a,' -R',f0.2,'/',f0.2,'/',sp,f0.2,'/',f0.2,
c    *  ss,' -JM',f3.1,'i+ -B',f0.2,'/',f0.2,':."',
c    *  'NADCON v5.0 ',a,' minus ',a,' ',a3,a5,a,
c    *  1x,a,'-',a,1x,a,
c    *'": -SV0.0001i/0.02i/0.02i ',
c    *  '-Gblack -K > plot.ps')

c - 908 = Plot a REFERENCE vector
c - 2016 08 29:  More decimal places
  908 format('psxy -SV0.0001i/0.02i/0.02i -N -R -O -K -JM',
     *  ' -Gred >> plot.ps << !',/,
     *  f10.6,1x,f10.6,1x,f5.1,1x,f9.1,/,
     *  '!')
c - 2016 07 29:  Make reference vector appear outside of map
c 908 format('psxy -SV0.0001i/0.02i/0.02i -N -R -O -K -JM',
c    *  ' -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,f5.1,1x,f9.1,/,
c    *  '!')
c 908 format('psxy -SV0.0001i/0.02i/0.02i -R -O -K -JM',
c    *  ' -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,f5.1,1x,f9.1,/,
c    *  '!')

c - 909 = Label the REFERENCE vector
c - 2016 08 29:  More decimal places
  909 format('pstext -N -O -K -R -JM -Gred >> plot.ps << !',/,
     *  f10.6,1x,f10.6,1x,'12 0 1 TL ',f10.3,1x,a,/,
     *  '!')
c - 2016 07 29:  Use -N to plot it outside
c 909 format('pstext -N -O -K -R -JM -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,'12 0 1 TL ',f10.3,1x,a,/,
c    *  '!')
c - 2016 08 29:  More decimal places
 1909 format('pstext -N -O -K -R -JM -Gred >> plot.ps << !',/,
     *  f10.6,1x,f10.6,1x,'12 0 1 TL ',f10.6,1x,a,/,
     *  '!')
c1909 format('pstext -N -O -K -R -JM -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,'12 0 1 TL ',f10.6,1x,a,/,
c    *  '!')
c 909 format('pstext -O -K -R -JM -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,'12 0 1 TL ',f10.3,1x,a,/,
c    *  '!')
c1909 format('pstext -O -K -R -JM -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,'12 0 1 TL ',f10.6,1x,a,/,
c    *  '!')

c 909 format('pstext -O -K -R -JM -Gred >> plot.ps << !',/,
c    *  f6.2,1x,f6.2,1x,'12 0 1 TL ',i6,' cm',/,
c    *  '!')

c - 905 = Convert PS to JPG
  905 format('ps2raster plot.ps -Tj -P -A ')

c - Rename to our naming scheme
c 906 format('mv -f plot.jpg ',a,
c    *'.',a,a,'.jpg',/,'rm -f plot.ps')
  906 format('mv -f plot.jpg ',a,
     *'.',a,'.jpg',/,'rm -f plot.ps')

      return
      end
