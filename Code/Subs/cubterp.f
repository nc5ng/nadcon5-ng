      real function cubterp(x,f0,f1,f2,f3)

c - x = real*4
c - f0,f1,f2,f3 = real*4

c - This function fits a cubic function through
c - four points, *equally* spaced along the x-axis
c - at indices 0, 1, 2 and 3.  The spacing along the
c - x-axis is "dx"
c - Thus:
c - 
c -    f0 = y(x(0))
c -    f1 = y(x(1))
c -    f2 = y(x(2))
c -    f3 = y(x(3))
c -       Where
c -       x(1) = x(0) + dx
c -       x(2) = x(1) + dx
c -       x(3) = x(2) + dx

c - The input value is some value of "x" that falls
c - between 0 and 3.  The output value (cubterp) is
c - the cubic function at x.
c - 
c - This function uses Newton-Gregory forward polynomial

c     df0 =f1 -f0
c     df1 =f2 -f1
c     d2f0=df1-df0

c     qterp=f0 + x*df0 + 0.5*x*(x-1.0)*d2f0

      df0 = f1 - f0
      df1 = f2 - f1
      df2 = f3 - f2
     
      d2f0 = df1 - df0
      d2f1 = df2 - df1

      d3f0 = d2f1 - d2f0

      cubterp=f0 + x*df0 + 0.5*x*(x-1.0)*d2f0 
     *     +(1.0/6.0)*d3f0*x*(x-1.0)*(x-2.0)

      return
      end
