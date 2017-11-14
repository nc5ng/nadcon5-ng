      subroutine inout(xx,yy,x,y,mx,iq)

c - Version 2014 05 29
c - Dru Smith

c - Subroutine to test whether a point is inside or outside of a
c - closed polygon.

c - Given:  xx,yy are the X and Y coords of our point
c - Given:  x(mx),y(mx) are the X/Y coordinate pairs for our
c -         polygon.  Can be clockwise or counterclockwise, but
c           can not cross over itself and the first and last
c           values must be identical
c   Given:  mx = number of points (including the first and
c                last, being identical but counted separately)         
c   Find:   iq = 1 if the point is inside the polygon
c              = 0 if the point is outside the polygon

c   Method:  Draw a line segment (A) from our point to a point significantly
c            outside the limits of the polygon, and test how many
c            polygon line segments line segment A intersects.  If
c            odd, then inside, if even, then outside

      implicit real*8(a-h,o-z)
      integer*4 mx,iq
      real*8 x(mx),y(mx),xx,yy

      x3 = xx
      y3 = yy

c - Pick a 4th point to tie to the testing point
c - that is way outside our range
      x4 = 999
      y4 = 999

c     write(6,*) ' Testing point: ',xx,yy
      

c - Test each and every line segment of the polygon
      nin = 0
c     write(6,*) ' # segments = ',mx-1
      do 1 i=1,mx-1 
        x1=x(i)
        y1=y(i)
        x2=x(i+1)
        y2=y(i+1)
        d123 = (x2-x1)*(y3-y1)-(x3-x1)*(y2-y1) 
        d124 = (x2-x1)*(y4-y1)-(x4-x1)*(y2-y1)
        d341 = (x3-x1)*(y4-y1)-(x4-x1)*(y3-y1)
        d342 = d123 - d124 + d341

c       write(6,*) 'D(123),D(124) = ',d123,d124
c       write(6,*) 'D(341),D(342) = ',d341,d342

        if(d123*d124.lt.0 .and. d341*d342.lt.0)then
          nin=nin+1
c         write(6,*) ' Intersection',nin
        endif
        
    1 continue

c - Odd => Inside
      if(mod(nin,2).eq.1)then
        iq=1
c - Even => Outside
      else
        iq=0
      endif

c     write(6,101)nin,iq
  101 format(i8,1x,i1)
c     if(iq.eq.1)pause
      return  
      end


