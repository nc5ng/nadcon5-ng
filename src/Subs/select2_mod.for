c copied from /home/dru/NumRec/Modified/select2.for
c> \ingroup core
c> \if MANPAGE     
c> \page select2_mod
c> \endif      
c> 
c> Function to select an element of a partially filled, but packed multi dimensional array, single precision
c> 
c> Finds the "kth" element of an array, "arr", which
c> is dimensioned to be "nmax" values long, but which
c> only has data in the first "n" cells.
c>
c> ## Changelog
c>
c> ### 7/17/2008: 
c> Like "select2" but modified by D. Smith 
c> to allow an "nmax" array given, but which only
c> has values in elements 1-n, and to have "arr"
c> be Integer*2
c>
      FUNCTION select2(k,n,arr,nmax)
c - Like "select" but modified by D. Smith on 7/17/2008
c - to allow an "nmax" array given, but which only
c - has values in elements 1-n.  Maintain the Real*4 nature of arr.

c - Finds the "kth" element of an array, "arr", which
c - is dimensioned to be "nmax" values long, but which
c - only has data in the first "n" cells.

      INTEGER k,n,nmax
      REAL*4 select2,arr(nmax)
      INTEGER i,ir,j,l,mid
      REAL*4 a,temp
      l=1
      ir=n
1     if(ir-l.le.1)then
        if(ir-l.eq.1)then
          if(arr(ir).lt.arr(l))then
            temp=arr(l)
            arr(l)=arr(ir)
            arr(ir)=temp
          endif
        endif
        select2=arr(k)
        return
      else
        mid=(l+ir)/2
        temp=arr(mid)
        arr(mid)=arr(l+1)
        arr(l+1)=temp
        if(arr(l+1).gt.arr(ir))then
          temp=arr(l+1)
          arr(l+1)=arr(ir)
          arr(ir)=temp
        endif
        if(arr(l).gt.arr(ir))then
          temp=arr(l)
          arr(l)=arr(ir)
          arr(ir)=temp
        endif
        if(arr(l+1).gt.arr(l))then
          temp=arr(l+1)
          arr(l+1)=arr(l)
          arr(l)=temp
        endif
        i=l+1
        j=ir
        a=arr(l)
3       continue
          i=i+1
        if(arr(i).lt.a)goto 3
4       continue
          j=j-1
        if(arr(j).gt.a)goto 4
        if(j.lt.i)goto 5
        temp=arr(i)
        arr(i)=arr(j)
        arr(j)=temp
        goto 3
5       arr(l)=arr(j)
        arr(j)=a
        if(j.ge.k)ir=j-1
        if(j.le.k)l=i
      endif
      goto 1
      END
