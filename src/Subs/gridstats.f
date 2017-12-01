c> \ingroup core
c> \if MANPAGE     
c> \page gridstats
c> \endif      
c> 
c> Subroutine to print grid statistics to stdout
c> 
c> \param[in] fname name of grid stat file 
c> \param[out] ave average  
c> \param[out] std standard deviatio
c> \param[out] median
c> 
      subroutine gridstats(fname,ave,std,med)
      implicit real*8(a-h,o-z)
      parameter(nmax = 1561*3541)
      real*8 med
      real*4 data(5000),s1,select2,arr(nmax)
      integer*4 nla,nlo,ikind
      character*200 fname
      open(11,file=fname,status='old',form='unformatted')

      ave = 0.d0
      rms = 0.d0

      read(11)glamn,glomn,dla,dlo,nla,nlo,ikind
      if(ikind.eq.0)stop 20304

      ikt = 0
      do 1 i=1,nla
        if(ikind.eq.1)read(11)(data(j),j=1,nlo)
        do 3 j=1,nlo
          ikt = ikt + 1
          arr(ikt) = data(j)
    3   continue
        do 2 j=1,nlo
          ave = ave + dble(data(j))
          rms = rms + dble(data(j))**2
    2   continue
    1 continue
      fact = dble(nla*nlo) / dble(nla*nlo - 1)

      ave = ave / dble(nla*nlo)
      rms = sqrt(rms / dble(nla*nlo))
      std = dsqrt(fact*(rms**2 - ave**2))

      npts = ikt
      nmed = 1+ ikt/2

      write(6,*) ' IN gridstats, npts = ',npts
      write(6,*) ' IN gridstats, nmed = ',nmed

c     nmed = ikt/3
      s1 = select2(nmed,npts,arr,nmax)

      write(6,*) ' IN gridstats, s1   = ',s1
      med = s1
      write(6,*) ' IN gridstats, med  = ',med

      write(6,100)trim(fname),ave,std,med
  100 format('gridstats for ',a,' = ',3f20.10)

      close(11)

      return
      end
