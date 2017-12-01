c> \ingroup core
c> \if MANPAGE     
c> \page getmap
c> \endif      
c> 
c> Subroutine to return the magnitude of a double precision
c> value.
c> 
c> \param[out] x result, magnitude of ix
c> \param[in] ix input douple precision 
c> 
      subroutine getmag(x,ix)
c - Subroutine to return the magnitude of a double precision
c - value.
      implicit real*8 (a-h,o-z)
      y = dlog10(x)
      ix = floor(y) 
      write(6,*) ' getmag: x,y,ix = ',x,y,ix
      return
      end
  
      
