      real function qterp(x,f0,f1,f2)

c - x = real*4
c - f0,f1,f2 = real*4

c - This function fits a parabola (quadratic) through
c - three points, *equally* spaced along the x-axis
c - at indices 0, 1 and 2.  The spacing along the
c - x-axis is "dx"
c - Thus:
c - 
c -    f0 = y(x(0))
c -    f1 = y(x(1))
c -    f2 = y(x(2))
c -       Where
c -       x(1) = x(0) + dx
c -       x(2) = x(1) + dx

c - The input value is some value of "x" that falls
c - between 0 and 2.  The output value (qterp2) is
c - the parabolic function at x.
c - 
c - This function uses Newton-Gregory forward polynomial

      df0 =f1 -f0
      df1 =f2 -f1
      d2f0=df1-df0

      qterp=f0 + x*df0 + 0.5*x*(x-1.0)*d2f0

      return
      end
