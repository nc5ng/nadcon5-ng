      program gscale

*** scale grid by a factor

      implicit double precision(a-h,o-z)
      character*88 fname
      integer hrec1(200049)
      real*4  zrec1(200049),factor
      equivalence(hrec1(1),zrec1(1))

      lin1=1
      lout=3

      write(6,*) 'program gscale'

      write(6,3)
    3 format('Enter input file:  ',$)
      read(5,1) fname
    1 format(a)
      open(lin1,file=fname,status='old',form='unformatted')

      write(6,4)
    4 format('Enter scale factor:',$)
      read(*,*) factor

      write(6,2)
    2 format('Enter output file: ',$)
      read(5,1) fname
      open(lout,file=fname,status='new',form='unformatted')

      read(lin1) glamn1,glomn1,dgla1,dglo1,nla1,nlo1,ikind1
      write(lout) glamn1,glomn1,dgla1,dglo1,nla1,nlo1,ikind1

      if(ikind1.eq.0) then
        do 10 irow=1,nla1
        read (lin1) (hrec1(i),i=1,nlo1)
        do 11 i=1,nlo1
   11   hrec1(i)=nint(hrec1(i)*factor)
   10   write(lout) (hrec1(i),i=1,nlo1)
      else
        do 20 irow=1,nla1
        read (lin1) (zrec1(i),i=1,nlo1)
        do 21 i=1,nlo1
   21   zrec1(i)=zrec1(i)*factor
   20   write(lout) (zrec1(i),i=1,nlo1)
      endif

      stop
      end
