c> \ingroup core 
c> \if MANPAGE     
c> \page addem
c> \endif      
c> 
c> Part of the NADCON5 \ref core , adds one grid to another
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> When run from the command line, the program prints a prompt for each argument    
c>     
c> They are enumerated here
c> \param infileA First Input File Name
c> \param infileB Second Input File Name
c> \param outfile Output File Name of A+B
c>      
c> ### Program Inputs:
c> 
c> - `lin1` Input File A  
c> - `lin2` Input File B
c> - `lout` Output File to Write A+B
c>
      program addem

*** add one grid to another

      implicit double precision(a-h,o-z)
      character*388 fname
      integer hrec1(12049),hrec2(12049)
      real*4  zrec1(12049),zrec2(12049)
      equivalence(hrec1(1),zrec1(1))
      equivalence(hrec2(1),zrec2(1))

      lin1=1
      lin2=2
      lout=3

      write(6,*) 'program addem'

      write(6,3)
    3 format('Enter "first" input file:  ',$)
      read(5,1) fname
    1 format(a)
      open(lin1,file=fname,status='old',form='unformatted')

      write(6,4)
    4 format('Enter "second" input file: ',$)
      read(5,1) fname
      open(lin2,file=fname,status='old',form='unformatted')

      write(6,2)
    2 format('Enter "a+b" output file:   ',$)
      read(5,1) fname
      open(lout,file=fname,status='new',form='unformatted')

      read(lin1) glamn1,glomn1,dgla1,dglo1,nla1,nlo1,ikind1
      read(lin2) glamn2,glomn2,dgla2,dglo2,nla2,nlo2,ikind2

*** check compatability

      if(dabs(glomn1-glomn2).gt.1.d-7) stop 1
      if(dabs(glamn1-glamn2).gt.1.d-7) stop 6
      if(dabs(dgla1 -dgla2 ).gt.1.d-7) stop 2
      if(dabs(dglo1 -dglo2 ).gt.1.d-7) stop 3
      if(nlo1  .ne.nlo2  ) stop 4
      if(nla1  .ne.nla2  ) stop 7
      if(ikind1.ne.ikind2) stop 5

      write(lout) glamn1,glomn1,dgla1,dglo1,nla1,nlo1,ikind1
      if(ikind1.eq.0) then
        do 10 irow=1,nla1
        read (lin1) (hrec1(i),i=1,nlo1)
        read (lin2) (hrec2(i),i=1,nlo1)
        do 11 i=1,nlo1
   11   hrec1(i)=hrec1(i)+hrec2(i)
   10   write(lout) (hrec1(i),i=1,nlo1)
      else
        do 20 irow=1,nla1
        read (lin1) (zrec1(i),i=1,nlo1)
        read (lin2) (zrec2(i),i=1,nlo1)
        do 21 i=1,nlo1
   21   zrec1(i)=zrec1(i)+zrec2(i)
   20   write(lout) (zrec1(i),i=1,nlo1)
      endif

      stop
      end
