      subroutine vecstats(fname,n)
c - Subroutine to tell us how many thinned vectors were
c - used to make a grid
      character*200 fname
      integer*4 n
      character*80 card
      open(90,file=fname,status='old',form='formatted')
      n = 0
    1 read(90,'(a)',end=2)card
        n = n + 1
      goto 1
    2 return
      end
