      program decimate

*** extract every 1 of "n" points

      implicit double precision(a-h,o-z)
      character*80 fname
      integer hrec(1000000)
      real*4  zrec(1000000)
      equivalence(hrec(1),zrec(1))

      lin=1
      lout=2

      write(6,*) 'program decimate'

      write(6,2)
    2 format('Enter input file:  ',$)
      read(5,1) fname
    1 format(a)
      open(lin,file=fname,status='old',form='unformatted')

      write(6,3)
    3 format('Enter output file: ',$)
      read(5,1) fname
      open(lout,file=fname,status='new',form='unformatted')

   14 write(6,4)
    4 format('Extract every 1 of "n" points in lat: ',$)
      read(5,'(i4)') ny
      if(ny.le.0) go to 14

   15 write(6,5)
    5 format('Extract every 1 of "n" points in lon: ',$)
      read(5,'(i4)') nx
      if(nx.le.0) go to 15

      read(lin) glamn,glomn,dgla,dglo,nla,nlo,ikind
      dgla2=ny*dgla
      dglo2=nx*dglo
      nla2=(nla-1)/ny+1
      nlo2=(nlo-1)/nx+1
      write(6,*)
      write(6,*) dgla,' --> ',dgla2
      write(6,*) dglo,' --> ',dglo2
      write(6,*) nla, ' --> ', nla2
      write(6,*) nlo, ' --> ', nlo2
      write(6,*)
      write(lout) glamn,glomn,dgla2,dglo2,nla2,nlo2,ikind

*** always process first record (bottom row)

      if(ikind.eq.0) then
        call inouti(lin,lout,nlo,nlo2,nx,hrec)
      else
        call inoutr(lin,lout,nlo,nlo2,nx,zrec)
      endif
      ila=1

  100 if(ila.lt.nla2) then
        if(ikind.eq.0) then
          do 10 iloop=2,ny
   10     read(lin) (hrec(j),j=1,nlo)
          call inouti(lin,lout,nlo,nlo2,nx,hrec)
        else
          do 20 iloop=2,ny
   20     read(lin) (zrec(j),j=1,nlo)
          call inoutr(lin,lout,nlo,nlo2,nx,zrec)
        endif
        ila=ila+1
        go to 100
      endif

      stop
      end
      subroutine inouti(lin,lout,nlo,nlo2,nx,hrec)

*** extract 1 of "nx" points in a record

      implicit double precision(a-h,o-z)
      integer hrec(*)

      read(lin) (hrec(i),i=1,nlo)
      write(lout) (hrec(nx*i+1),i=0,nlo2-1)

      return
      end
      subroutine inoutr(lin,lout,nlo,nlo2,nx,zrec)

*** extract 1 of "nx" points in a record

      implicit double precision(a-h,o-z)
      real*4 zrec(*)

      read(lin) (zrec(i),i=1,nlo)
      write(lout) (zrec(nx*i+1),i=0,nlo2-1)

      return
      end
