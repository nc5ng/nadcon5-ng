c> \ingroup core
c> \if MANPAGE     
c> \page coplot
c> \endif      
c> 
c> Subroutine to make GMT calls to do Color Raster Rendering of Gridded Data
c> 
c> ## Changelog
c> 
c> ### 2016 09 08:
c> Had to up the D_FORMAT default to %.3G because tight scalebar ranges
c> with the newly allowed "more free" average values were showing
c> repeating values when only 2 digits could be shown.
c> 
c> ### 2016 09 07:
c> Had to add lines pre/post "makecpt" to change the D_FORMAT.  This is because
c> I *had* been forcing the "scave" in cpt.f to be ONZD.  But that yielded
c> bad values sometimes, so I switched it.  With that switch, the scave could
c> have lots of digits.  Well, that means the newly adopted "D_FORMAT" of %.2G
c> was insufficient for the CPT table.  Who knew that D_FORMAT affected that!
c> Anyway, so change "D_FORMAT" pre/post all makecpt calls.
c> 
c> ### 2016 08 30:
c> See item #39 in Google ToDo list 
c> Changed "grdcontour" to have a blank "-R" call so it'll mimic whatever
c> decimal places are in the "grdimage" call that came before it.
c> 
c> ### 2016 08 29:
c> Updated the initial -R and -B calls to 6 decimal places
c> 
c> ### 2016 08 25:
c> -.gmtdefaults4 has been changed so X_ORIGIN is equal to 0.0
c> - Center the plot with "-Xc" at grdimage
c> - Center the scalebar by setting its Xcoordinate, which runs in "plot frame"
c>  coordinates (0/0 at lower left) , to be equal to "jm/2" 
c> - Force the scale bar to be exactly 4 inches wide, always
c> - Change the format for "makecpt" from 0.6 to 0.10
c> 
c> ### 2016 07 29:
c> Update to put more data into comment/echo
c> 
c> Also, 
c>  - forced the -Ctemp.cpt option in "grdcontour" to make the contours line up with the color palette
c>  - For d3 plots, to drop all contours
c>  - For d3 plots to only use "coverage" part *only* if "ij" is not "1" 
c>  - Same for "09" and "ete" grids
c> 
c> ### 2016 07 21:
c>   - Set the "JM" code in "grdcontour" to just be "-JM" and let it therefore 
c>     run with whatever JM size is used in "grdimage"
c>   - Set the "A" code in "grdcontour" to be "-A-" which should turn off 
c>     the labels on all contours
c>   - Fixed size of scale bar
c> 
c> ### 2016 03 01:
c> 1. Changed to a continuous color plot
c>   - Get rid of "-Z" in "makecpt"
c> 2. Changed to an 8 color, from 6 color, plot (without changing the RANGE yet...see DRU-12, p. 19)
c>   - Change varible that comes in from "cptin" to "cptin6"
c>   - Compute cptin = cptin6 * 0.75d0 immediately
c> 
c> ### Update 2016 02 29:
c> 1. Removed all shading from color plots
c>   - Get rid of "grdgradient" call
c>   - Remove from "grdimage" the "-Itempi.grd" part
c>   - Remove the "rm -f tempi.grd" line
c> 
c> 
c> 
c> 
      subroutine coplot(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
     *olddtm,newdtm,region,elecap,ij,cptlo,cpthi,cptin6,suffixused,
     *igridsec,fn)

c - 2016 09 08
c   Had to up the D_FORMAT default to %.3G because tight scalebar ranges
c   with the newly allowed "more free" average values were showing
c   repeating values when only 2 digits could be shown.

c - 2016 09 07
c    Had to add lines pre/post "makecpt" to change the D_FORMAT.  This is because
c    I *had* been forcing the "scave" in cpt.f to be ONZD.  But that yielded
c    bad values sometimes, so I switched it.  With that switch, the scave could
c    have lots of digits.  Well, that means the newly adopted "D_FORMAT" of %.2G
c    was insufficient for the CPT table.  Who knew that D_FORMAT affected that!
c    Anyway, so change "D_FORMAT" pre/post all makecpt calls.

c - 2016 08 30:  See item #39 in Google ToDo list
c     Changed "grdcontour" to have a blank "-R" call so it'll mimic whatever
c     decimal places are in the "grdimage" call that came before it.

c - 2016 08 29:
c     Updated the initial -R and -B calls to 6 decimal places

c - 2016 08 25:
c     .gmtdefaults4 has been changed so X_ORIGIN is equal to 0.0
c     Center the plot with "-Xc" at grdimage
c     Center the scalebar by setting its Xcoordinate, which runs in "plot frame"
c       coordinates (0/0 at lower left) , to be equal to "jm/2" 
c     Force the scale bar to be exactly 4 inches wide, always
c     Change the format for "makecpt" from 0.6 to 0.10

c - 2016 07 29:
c     Update to put more data into comment/echo
c     Also forced the -Ctemp.cpt option in "grdcontour" to make the contours line up with the color palette

c     For d3 plots, to drop all contours
c     For d3 plots to only use "coverage" part *only* if "ij" is not "1"
c     Same for "09" and "ete" grids


c     subroutine coplot(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *olddtm,newdtm,region,elecap,ij,cptlo,cpthi,cptin,suffixused,
c    *igridsec,fn)

c - Update 2016 07 21:
c   - Set the "JM" code in "grdcontour" to just be "-JM" and let it therefore 
c     run with whatever JM size is used in "grdimage"
c   - Set the "A" code in "grdcontour" to be "-A-" which should turn off 
c     the labels on all contours
c   - Fixed size of scale bar

c - Update 2016 03 01:
c    - 1) Changed to a continuous color plot
c         * Get rid of "-Z" in "makecpt"
c      2) Changed to an 8 color, from 6 color, plot (without changing the RANGE yet...see DRU-12, p. 19)
c         * Change varible that comes in from "cptin" to "cptin6"
c         * Compute cptin = cptin6 * 0.75d0 immediately

c - Update 2016 02 29:
c    - 1) Removed all shading from color plots
c         * Get rid of "grdgradient" call
c         * Remove from "grdimage" the "-Itempi.grd" part
c         * Remove the "rm -f tempi.grd" line


c     subroutine coplot(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *olddtm,newdtm,region,elecap,ij,cptlo,cpthi,cptin,suffix2,
c    *igridsec,fn)

c     subroutine coplot(ele,fname,bw,be,bs,bn,jm,b1,b2,maxplots,
c    *olddtm,newdtm,region,elecap,ij,ave,std,suffix2,igridsec,fn)

      implicit real*8(a-h,o-z)

c - Subroutine to make GMT calls to do a color raster rendering
c - of gridded data

      integer*4 maxplots
      character*3 ele,elecap
      character*200 fname
      character*10 olddtm,newdtm,region
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
      real*8 ave,std
      character*200 suffixused
      character*20 units
      character*20 gridnote
      character*20 gridnote2

c ----------------------------------------------------
c - FAILSAFES: BEGIN
c ----------------------------------------------------
      if(.not.(fname(1:3).eq.'vmt'.or.fname(1:3).eq.'vst' .or.
     *         fname(1:3).eq.'vmr'.or.fname(1:3).eq.'vsr' .or.
     *         fname(1:3).eq.'vme'.or.fname(1:3).eq.'vse'))then
        write(6,2)trim(fname)
        stop
      endif
    2 format('FATAL in coplot.  Bad character in spots 1-3: ',a)

      if(.not.(fname(4:5).eq.'cd' .or. fname(4:5).eq.'dd' .or.
     *         fname(4:5).eq.'te' ))then
        write(6,3)trim(fname)
        stop
      endif
    3 format('FATAL in coplot.  Bad character in spots 4-5: ',a)

      if(fname(6:8).ne.ele)then
        write(6,4)trim(fname),ele
        stop
      endif
    4 format('FATAL in coplot.  Bad match of fname / ele: ',a,1x,a)

      if(fname(2:2).eq.'m')then
        units='meters'
      elseif(fname(2:2).eq.'s')then
        units='arcseconds'
      else
        write(6,5)trim(fname)
        stop
      endif
    5 format('FATAL in coplot.  Bad units in name: ',a)

      if(igridsec.le.0)then
        write(6,6)igridsec
      else
        write(gridnote,10)igridsec
        write(gridnote2,11)igridsec
      endif
    6 format('FATAL in coplot.  Bad igridsec: ',i0)
   10 format('(',i0,' sec)')
   11 format(i0,'.')

c ----------------------------------------------------
c - FAILSAFES: END
c ----------------------------------------------------

c ------------------------------------------------------------------
c - Contour interval and labeling
c ------------------------------------------------------------------
c - 2016 07 29:  Just use cptin6 as it came in
      cptin = cptin6
c - Begin 2016 03 01
c     cptin = cptin6 * 0.75d0 
c - End 2016 03 01

      conin = cptin
      conlb = conin / 2.d0

c ----------------------------------------------
c - GMT COMMANDS: BEGIN
c ----------------------------------------------


c - Header of commands/echoes:
c - 2016 07 29:
      write(99,991)ele,trim(units),trim(region),trim(fn(ij)),
     *trim(suffixused),
     *ele,trim(units),trim(region),trim(fn(ij)),
     *trim(suffixused)
c     write(99,991)ele,trim(units),trim(region),trim(fn(ij)),
c    *ele,trim(units),trim(region),trim(fn(ij))

c - GMT call to create the color palette:
c - Store the palette as file "temp.cpt", to be
c - deleted later.
      write(99,901)cptlo,cpthi,cptin

c - Begin 2016 03 01:
c 901 format(
c    *'makecpt -Crainbow -T',f0.6,'/',f0.6,'/',f0.6,
c    *' -Z > temp.cpt')
c 901 format(
c    *'makecpt -Crainbow -T',f0.6,'/',f0.6,'/',f0.6,
c    *' > temp.cpt')
c - 2016 08 25
c 901 format(
c    *'makecpt -Crainbow -T',f0.10,'/',f0.10,'/',f0.10,
c    *' > temp.cpt')
c - 2016 09 07
c 901 format(
c    *'gmtset D_FORMAT %.12G',/,
c    *'makecpt -Crainbow -T',f0.10,'/',f0.10,'/',f0.10,
c    *' > temp.cpt',/,
c    *'gmtset D_FORMAT %.2G')
c - 2016 09 08
  901 format(
     *'gmtset D_FORMAT %.12G',/,
     *'makecpt -Crainbow -T',f0.10,'/',f0.10,'/',f0.10,
     *' > temp.cpt',/,
     *'gmtset D_FORMAT %.3G')

c - GMT call to create the gradient file from
c - the "grd" formatted version of our input grid.
c - Store the gradients as file "tempi.grd" to be
c - deleted later.

c - Updated 2016 02 29:
c     write(99,902)fname(1:8),trim(suffixused)
  902 format(
     *'grdgradient ',a,'.',a,
     *'.grd -N4.8 -A90 -M -Gtempi.grd')
c - Until here 2016 02 29

c - GMT call to create the color render of the
c - gridded data.   Store as file "plot.ps"
c - to be deleted later.

      write(99,903)fname(1:8),trim(suffixused),
     *bw(ij),be(ij),bs(ij),bn(ij),
     *jm(ij),b1(ij),b2(ij),
     *trim(newdtm),trim(olddtm),elecap,igridsec,
     *trim(region),trim(fn(ij)),fname(2:5)


c - Commented this out for 2016 03 01:
c 903 format(
c    *'grdimage ',a,'.',a,'.grd',
c    *' -Ei -Itempi.grd',
c    *' -R',f0.2,'/',f0.2,'/',f0.2,'/',f0.2,
c    *' -JM',f3.1,'i -B',f0.2,'/',f0.2,
c    *':."NADCON v5.0 ',a,' minus ',a,' ',a3,
c    *'(',i0,' sec)',
c    *1x,a,'-',a,1x,a,
c    *':" -Ctemp.cpt -K > plot.ps')
c 903 format(
c    *'grdimage ',a,'.',a,'.grd',
c    *' -Ei ',
c    *' -R',f0.2,'/',f0.2,'/',f0.2,'/',f0.2,
c    *' -JM',f3.1,'i -B',f0.2,'/',f0.2,
c    *':."NADCON v5.0 ',a,' minus ',a,' ',a3,
c    *'(',i0,' sec)',
c    *1x,a,'-',a,1x,a,
c    *':" -Ctemp.cpt -K > plot.ps')
c - Below for 2016 08 25:
c 903 format(
c    *'grdimage ',a,'.',a,'.grd',
c    *' -Ei -Xc',
c    *' -R',f0.2,'/',f0.2,'/',f0.2,'/',f0.2,
c    *' -JM',f3.1,'i -B',f0.2,'/',f0.2,
c    *':."NADCON v5.0 ',a,' minus ',a,' ',a3,
c    *'(',i0,' sec)',
c    *1x,a,'-',a,1x,a,
c    *':" -Ctemp.cpt -K > plot.ps')
c - 2016 08 29:
  903 format(
     *'grdimage ',a,'.',a,'.grd',
     *' -Ei -Xc',
     *' -R',f0.6,'/',f0.6,'/',f0.6,'/',f0.6,
     *' -JM',f3.1,'i -B',f0.6,'/',f0.6,
     *':."NADCON v5.0 ',a,' minus ',a,' ',a3,
     *'(',i0,' sec)',
     *1x,a,'-',a,1x,a,
     *':" -Ctemp.cpt -K > plot.ps')

c - GMT call to put a color scale on the map.  Add it
c - to file "plot.ps".

c - 2016 07 21
c     write(99,904)trim(units)
c     qqa = jm(ij) - 1.d0
c     qqb = qqa / 2.d0
c     write(99,904)qqb,qqa,trim(units)
c - 2016 08 25
      qqa = jm(ij)/2
      write(99,904)qqa,trim(units)
 
  904 format(
     *'psscale -D',f3.1,'i/-0.4i/4.0i/0.2ih',
     *' -Ctemp.cpt -I0.4 -B/:',a,
     *': -O -K >> plot.ps')

c 904 format(
c    *'psscale -D4i/-0.4i/8i/0.2ih -Ctemp.cpt -I0.4 -B/:',a,
c    *': -O -K >> plot.ps')



c - GMT call to put contours on the map.
c - 2016 07 29
c - 2016 07 21

c 2016 07 29:  skip contours if this is a d3, 09 or "ete" plot
      ll = len(trim(suffixused))
      if(suffixused(ll-1:ll).eq.'d3')goto 807
      if(suffixused(ll-1:ll).eq.'09')goto 807
      if(fname(3:5).eq.'ete')goto 807



      write(99,908)fname(1:8),trim(suffixused)

c     write(99,908)fname(1:8),trim(suffixused),
c    *bw(ij),be(ij),bs(ij),bn(ij)
c     write(99,908)fname(1:8),trim(suffixused),conin,
c    *bw(ij),be(ij),bs(ij),bn(ij)
c     write(99,908)fname(1:8),trim(suffixused),conin,
c    *bw(ij),be(ij),bs(ij),bn(ij),
c    *jm(ij),conlb

c - 2016 08 30:
  908 format(
     *'grdcontour ',a,'.',a,'.grd',
     *' -Ctemp.cpt',
     *' -R',
     *' -JM -Wthin',
     *' -A- -O -K >> plot.ps')
c - 2016 07 29
c 908 format(
c    *'grdcontour ',a,'.',a,'.grd',
c    *' -Ctemp.cpt',
c    *' -R',f0.2,'/',f0.2,'/',f0.2,'/',f0.2,
c    *' -JM -Wthin',
c    *' -A- -O -K >> plot.ps')
c - 2016 07 21
c 908 format(
c    *'grdcontour ',a,'.',a,'.grd',
c    *' -C',f0.5,
c    *' -R',f0.2,'/',f0.2,'/',f0.2,'/',f0.2,
c    *' -JM -Wthin',
c    *' -A- -O -K >> plot.ps')
c 908 format(
c    *'grdcontour ',a,'.',a,'.grd',
c    *' -C',f0.5,
c    *' -R',f0.2,'/',f0.2,'/',f0.2,'/',f0.2,
c    *' -JM',f3.1,'i -Wthin',
c    *' -A',f0.5,' -O -K >> plot.ps')

c - 2016 07 28 - Skip to here (skipping contours) for d3, 09 or "ete"  plots
  807 continue

c - GMT call to create the shoreline.  Add it to
c - file "plot.ps".
c - ALWAYS plot the coast last, as it closes the PS file
      call plotcoast(region,99)

c - GMT call to convert the plot.ps file to plot.jpg.
      write(99,905)
  905 format(
     *'ps2raster plot.ps -Tj -P -A')

c - Change name of JPG to its final name:
      write(99,906)fname(2:8),trim(suffixused),trim(fn(ij))
  906 format('mv plot.jpg c',a,'.',a,'.',a,'.jpg')

c - Remove all the temporary files
      write(99,907)

c - Update 2016 02 29:
c 907 format(
c    *'rm -f temp.cpt',/,
c    *'rm -f tempi.grd',/,
c    *'rm -f plot.ps')
  907 format(
     *'rm -f temp.cpt',/,
     *'rm -f plot.ps')
c - Until here 2016 02 29


c - 2016 07 29:
  991 format(
     *'# -----------------------------------------------------',/,
     *'# color plots in ',a,1x,a,1x,a,1x,a,1x,' Grid:',a /,
     *'# -----------------------------------------------------',/,
     *'echo ...color plots in ',a,1x,a,1x,a,1x,a,1x,' Grid:',a)
c 991 format(
c    *'# -----------------------------------------------------',/,
c    *'# color plots in ',a,1x,a,1x,a,1x,a,/,
c    *'# -----------------------------------------------------',/,
c    *'echo ...color plots in ',a,1x,a,1x,a,1x,a)

      return
      end
