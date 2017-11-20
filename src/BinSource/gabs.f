c> \ingroup core 
c> Part of the NADCON5 \ref core , Convert values in a `*.b` grid to absolute value
c>     
c> Belongs to the suite of ".b" file manipulators
c>     
c> This program will convert every value in a ".b" grid
c> to its absolute value.
c>     
c> ### Program arguments
c> Arguments are newline terminated and read from standard input
c>     
c> When run from the command line, the program prints a prompt for each argument    
c>     
c> They are enumerated here
c> \param infile  Input File Name 
c> \param outfile Output File Name 
c>      
c> ### Program Inputs:
c> 
c> - `lin` Input File  (`*.b` grid)
c> 
c> ### Program Outputs:
c> 
c> - `lout` Output File (`*.b` grid)
c>
      program gabs

c - Belongs to the suite of ".b" file manipulators.

c - This program will convert every value in a ".b" grid
c - to its absolute value.

      implicit real*8(a-h,o-z)
      character*200 fnamei,fnameo
      integer hrec(100000)
      real*4  zrec(100000),nw,ne,sw,se,zmin,zmax
      integer*2 srec(100000)
      equivalence(hrec(1),zrec(1),srec(1))

      lin  = 1
      lout = 99

      write(6,*) 'Program gabs - converts a grid to ABS values'

      write(6,2) 
    2 format('Enter the input grid file name: ',$)
      read(5,'(a)') fnamei
      open(lin,file=fnamei,status='old',form='unformatted')

      write(6,3) 
    3 format('Enter the output grid file name: ',$)
      read(5,'(a)') fnameo
      open(lout,file=fnameo,status='new',form='unformatted')


*** display header contents

      read(lin) glamn,glomn,dgla,dglo,nla,nlo,ikind
      write(lout) glamn,glomn,dgla,dglo,nla,nlo,ikind

*** read records south to north (elements are west to east)

      if(ikind.eq.0) then
        do 9 irow=1,nla
          read(lin)(hrec(i),i=1,nlo)
          do 8 i=1,nlo
            hrec(i) = int(abs(hrec(i)))
    8     continue
          write(lout)(hrec(i),i=1,nlo)
    9   continue

      elseif(ikind.eq.1)then
        do 7 irow=1,nla
          read(lin) (zrec(i),i=1,nlo)
          do 6 i=1,nlo
            zrec(i) = abs(zrec(i))
    6     continue
          write(lout)(zrec(i),i=1,nlo)
    7   continue

      elseif(ikind.eq.-1)then
        do 10 irow=1,nla
          read(lin) (srec(i),i=1,nlo)
          do 11 i=1,nlo
            srec(i) = int(abs(srec(i)))
   11     continue
          write(lout)(srec(i),i=1,nlo)
   10   continue

      elseif(ikind.eq.2)then
        do 90 irow=1,nla
          read(lin) (srec(i),i=1,nlo)
          do 91 i=1,nlo
            srec(i) = int(abs(srec(i)))
   91     continue
          write(lout)(srec(i),i=1,nlo)
   90   continue

      else
        stop 'Bad ikind'
      endif

      stop
      end
