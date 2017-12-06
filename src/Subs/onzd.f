c> \ingroup core
c> \if MANPAGE     
c> \page onzd
c> \endif      
c> 
c> Function to round a digit to one significant figure (one non zero digit), single precision
c>
c> Function "onzd" stands for "One Non Zero Digit"  
c>
c> It takes a Real*4 number as input, and rounds that 
c> number to the closest number containing only 1 non-zero digit.
c> The list of such numbers is infifinite, but contain
c> these, in order:
c>
c>     0.7 , 0.8 , 0.9 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9, 10 , 20 , 30 , etc etc
c> 
c> \param[in] x input value
c> \return `real*4` rounded value of x to one non zero digit 
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
      function onzd(x)
      implicit none
      real*4 onzd,x,y
      real*8 q,qten
      integer*4 imag,iq,isign
      
c - Function "onzd" stands for "One Non Zero Digit"  

c - It takes a Real*4 number as input, and rounds that 
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

         isign = +1
         y = x
         if(x.lt.0)then
           isign = -1
           y = -x
         endif

c - 1) Determine magnitude of x, in terms of integer exponent of ten
        imag = floor(log10(y))

c - 1a) Get the multiplier
        qten = (10.d0**imag)

c - 2) Get into a range between 0.0 and 10.0
        q = dble(y) / qten

c - 3) Round to the closest integer (0 through 10)
        iq = nint(q)

c - 4) Scale back to the original size 
        onzd = isign * dble(iq) * qten

c       write(6,100)x,imag,qten,q,iq,onzd
c 100   format(f30.15,1x,i10,1x,f30.15,1x,f30.15,1x,i10,1x,f30.15)
    
        return
        end

