c> \ingroup core
c> \if MANPAGE     
c> \page cpt
c> \endif      
c> 
c> This subroutine generates the color pallette variables
c> for a GMT color plot
c> 
c> \param[in] ave  Average of the gridded data
c> \param[in] std  Standard deviation of the gridded data
c> \param[in] csm  Color Sigma Multiplier (how many sigmas on each
c>       side of the average do you want the colors to range?)
c> \param[out] xlo  Low value
c> \param[out] xhi  High value
c> \param[out] xin  Interval
c> 
c> ## Changelog
c> 
c> ### 2016 09 06:
c> Modified because the forcing of "scave" to be one non zero
c> digit was throwing off the scalebar so far in Guam that
c> the data in Guam wasn't even plotting.  Change to make
c> the interval still be one non zero digit, but then a 
c> simpler formula for the scaled average was put in.
c> 
c> ### 2016 07 29:
c> Modified from original version to reflect "new math" invented
c> this week that helps shrink the color bar and/or widen the
c> color bar (see issues 14 and 15 in DRU-12, p. 48)
c> 
      subroutine cpt(ave,std,csm,xlo,xhi,xin)

c - 2016 09 06
c   Modified because the forcing of "scave" to be one non zero
c   digit was throwing off the scalebar so far in Guam that
c   the data in Guam wasn't even plotting.  Change to make
c   the interval still be one non zero digit, but then a 
c   simpler formula for the scaled average was put in.

c - 2016 07 29
c   Modified from original version to reflect "new math" invented
c   this week that helps shrink the color bar and/or widen the
c   color bar (see issues 14 and 15 in DRU-12, p. 48)

      implicit none
      real*8 ave,std,csm,xlo,xhi,xin
      real*8 qv,qq,scave
      integer*4 iv,iq
      real*8 spread8,onzd2
c - This subroutine generates the color pallette variables
c - for a GMT color plot
c
c - Input:
c    ave = Average of the gridded data
c    std = Standard deviation of the gridded data
c    csm = Color Sigma Multiplier (how many sigmas on each
c          side of the average do you want the colors to range?)
c - Output:
c    xlo = Low value
c    xhi = High value
c    xin = Interval

      spread8 = 2 * csm * std / 8.d0
      xin = onzd2(spread8) 

c     iv = floor(dlog10(std))
c     qv = 10.d0**iv
c     qq = std / qv
c     iq = nint(qq)

c - 2016 09 06
c     write(6,*) ' cpt: ave (pre  onzd2) = ',ave
c     scave = onzd2(ave)
c     write(6,*) ' cpt: ave (post onzd2) = ',ave
      scave = xin * nint(ave / xin)

c     xin = iq * qv
c     scave = qv * nint(ave/qv)

c     xlo = scave - csm*xin
c     xhi = scave + csm*xin

      xlo = scave - 4*xin
      xhi = scave + 4*xin

      write(6,*) ' ---------------------'
      write(6,*) 'cpt: ave      = ',ave
      write(6,*) 'cpt: std      = ',std
      write(6,*) 'cpt: csm      = ',csm
      write(6,*) 'cpt: spread8  = ',spread8
      write(6,*) 'cpt: targ low = ',ave-csm*std
      write(6,*) 'cpt: targ high= ',ave+csm*std
      write(6,*) ' '
      write(6,*) 'cpt: xin      = ',xin
      write(6,*) 'cpt: scave    = ',scave
      write(6,*) 'cpt: xlo      = ',xlo  
      write(6,*) 'cpt: xhi      = ',xhi 

      return
      end
      include 'onzd2.f'
