c> \ingroup core
c> \if MANPAGE     
c> \page getgridbounds
c> \endif      
c> 
c> Subroutine to collect up the GRID boundaries
c> for use in creating NADCON 5
c>
c> This CAN BE different than the MAP boundaries
c> as such:
c>
c> GRID boundaries will be just four values (n/s/w/e) for any region
c>
c> MAP boundaries will allow multiple maps to be made and may or may
c> not align with the GRID boundaries.  Used to allow for more 
c> "close up" maps and such, without the need to screw up the
c> MAP boundaries.
c>
c> \param[in] region Region Name
c> \param[out] xn north boundary for this region
c> \param[out] xs south boundary for this region
c> \param[out] xw west boundary for this region
c> \param[out] xe east boundary for this region
c>
c> ### Subroutine Input Files:
c>
c> - `Data/grid.parameters
c>
      subroutine getgridbounds(region,xn,xs,xw,xe)
c
c - Subroutine to collect up the GRID boundaries
c - for use in creating NADCON 5
c
c - This CAN BE different than the MAP boundaries
c - as such:
c
c -  GRID boundaries will be just four values (n/s/w/e) for any region
c
c -  MAP boundaries will allow multiple maps to be made and may or may
c -  not align with the GRID boundaries.  Used to allow for more 
c -  "close up" maps and such, without the need to screw up the
c -  MAP boundaries.

c - Input:
c     region
c - Output:
c     xn,xs,xw,xe = N/S/W/E boundaries of the grid to be 
c                   created for this region

      character*10 region
      real*8    xn,xs,xw,xe
      character*80 card

      ifile = 3

      open(ifile,
     *file='Data/grid.parameters',
     *status='old',form='formatted')

c - Read 2 header lines
      read(ifile,'(a)')card
      read(ifile,'(a)')card

c - Now loop and find our region
    1 read(ifile,'(a)',end=2)card 
        if(trim(card(1:10)).eq.trim(region))then
          read(card(14:23),*)xn
          read(card(27:36),*)xs
          read(card(40:49),*)xw
          read(card(53:62),*)xe
          close(ifile)
          return
        endif
      goto 1

c - If we get here, the region sent to this subroutine wasn't found
c - in our file /Data/grid.parameters.  Crash and burn.
    2 write(6,100)trim(region)
      stop 10001 
  100 format(6x,'FATAL Subroutine getgridbounds: Unknown region: ',a)

      end
