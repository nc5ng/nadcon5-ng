      program b2xyz

c - Program to convert standard "*.b" grid
c - formatted data to a binary xyz (lon, lat, value)
c - list, which can then be used by GMT for
c - various things (like running the GMT
c - routine "xyz2grd", to get a "*.grd" 
c - file, which is useful for plotting, etc)

      implicit real*8(a-h,o-z)
      character*200 fnamein,fnameout,prefix
      real*4 data(100000)
      integer*4 idata(100000)
      real*4 xlo,xla,val
      equivalence(data(1),idata(1))

c ------------------------------------------------
c - User-supplied file name
c ------------------------------------------------
      read(5,'(a)')fnamein
      open(1,file=fnamein,status='old',form='unformatted')
      read(1)glamn,glomn,dla,dlo,nla,nlo,ikind
c     ll = len(trim(fnamein))
c     prefix = fnamein(1:ll-2)
c     fnameout = prefix//'.xyz'
      fnameout = 'temp.xyz'
      open(2,file=fnameout,status='new',form='binary')

c - Read, compute location, and write
      do 1 i=1,nla
        if(ikind.eq.1)read(1)( data(j),j=1,nlo)
        if(ikind.eq.0)read(1)(idata(j),j=1,nlo)
        xla = glamn + (i-1)*dla
        do 2 j=1,nlo
          xlo = glomn + (j-1)*dlo
          if(ikind.eq.1)val = data(j)
          if(ikind.eq.0)val = dble(idata(j))
          write(2)xlo,xla,val
    2   continue
    1 continue
      end  
