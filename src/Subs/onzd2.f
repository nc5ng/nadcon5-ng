c> \ingroup core
c> \if MANPAGE     
c> \page onzd2
c> \endif      
c> 
c> Function to round a digit to one significant figure (one non zero digit), double precision
c>
c> Function "onzd" stands for "One Non Zero Digit"  
c>
c> Version 2 operates just like version 1 (onzd()), only the input
c> and output will be real*8 values, not real*4.
c>
c> It takes a Real*8 number as input, and rounds that 
c> number to the closest number containing only 1 non-zero digit.
c> The list of such numbers is infifinite, but contain
c> these, in order:
c>
c>     0.7 , 0.8 , 0.9 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9, 10 , 20 , 30 , etc etc
c> 
c> \param[in] x input value
c> \return `real*8` rounded value of x to one non zero digit 
c> 
c> Examples of input/output are:
c>
c>        0.000019      =>    0.000020
c>        0.007432      =>    0.007000
c>        1.7           =>    2.000000
c>        9.143         =>    9.000000
c>       17.4           =>   20.000000
c>      947.3           =>  900.000000
c>      987.432         => 1000.000000
c>     1014.8           => 1000.000000
c>     1502.7           => 2000.000000
c>
      function onzd2(x)
      implicit none
      real*8 onzd2,x,y
      real*8 q,qten
      integer*4 imag,iq,isign
      
c - Function "onzd2" stands for "One Non Zero Digit, version 2"  

c - Version 2 operates just like version 1 (onzd.f), only the input
c - and output will be real*8 values, not real*4.

c - It takes a Real*8 number as input, and rounds that 
c - number to the closest number containing only 1 non-zero digit.
c - The list of such numbers is infifinite, but contain
c - these, in order:
c -    0.7 , 0.8 , 0.9 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9, 10 , 20 , 30 , etc etc
c - 
c - Examples of input/output are:
c -       0.000019      =>    0.000020
c -       0.007432      =>    0.007000
c -       1.7           =>    2.000000
c -       9.143         =>    9.000000
c -      17.4           =>   20.000000
c -     947.3           =>  900.000000
c -     987.432         => 1000.000000
c -    1014.8           => 1000.000000
c -    1502.7           => 2000.000000

        y = x
        isign = +1
        if(x.lt.0)then
          isign = -1
          y = -x
        endif

c - 1) Determine magnitude of x, in terms of integer exponent of ten
        imag = floor(dlog10(y))

c - 1a) Get the multiplier
        qten = (10.d0**imag)

c - 2) Get into a range between 0.0 and 10.0
        q = dble(y) / qten

c - 3) Round to the closest integer (0 through 10)
        iq = nint(q)

c - 4) Scale back to the original size 
        onzd2 = isign * dble(iq) * qten

c       write(6,100)x,imag,qten,q,iq,onzd2
c 100   format(f30.15,1x,i10,1x,f30.15,1x,f30.15,1x,i10,1x,f30.15)
    
        return
        end

