c> \ingroup core
c> \if MANPAGE     
c> \page cpt2
c> \endif      
c> 
c> This subroutine generates the color pallette variables
c> for a GMT color plot.  
c>
c> This particular routine is best
c> for data that are all positive, but cluster near a small
c> value while having a lot of outliers to the high-side.
c> The color plot uses the MEDIAN (and a multiplier) 
c> to set the upper limit, while forcing the lower limit
c> to be ZERO.
c>
c> \param[in] med  Median of the gridded data
c> \param[in] csm  Color Sigma Multiplier (The maximum color range will
c>       be based on csm*med.  The minimum color range will be zero)
c> \param[out] xlo Low value
c> \param[out] xhi High value
c> \param[out] xin Interval
c>
c>
      subroutine cpt2(med,csm,xlo,xhi,xin)
      implicit none
      real*8 med,csm,xlo,xhi,xin
      real*8 qv,qq,spread,std
      integer*4 iv,iq
c - This subroutine generates the color pallette variables
c - for a GMT color plot.  This particular routine is best
c - for data that are all positive, but cluster near a small
c - value while having a lot of outliers to the high-side.
c - The color plot uses the MEDIAN (and a multiplier) 
c - to set the upper limit, while forcing the lower limit
c - to be ZERO.
c
c - Input:
c    med = Median of the gridded data
c    csm = Color Sigma Multiplier (The maximum color range will
c          be based on csm*med.  The minimum color range will 
c          be zero)
c - Output:
c    xlo = Low value
c    xhi = High value
c    xin = Interval

      spread = csm*med
      std = spread/8.d0

      iv = floor(dlog10(std))
      qv = 10.d0**iv
      qq = std / qv
      iq = nint(qq)

      xin = iq * qv

      xlo = 0.d0
      xhi = 8 * xin
      return
      end
