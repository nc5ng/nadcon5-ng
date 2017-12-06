c> \ingroup core
c> \if MANPAGE     
c> \page cubterp
c> \endif      
c> 
c> This function fits a cubic function through four points
c> 
c> This function fits a cubic function through
c> four *equally* spaced points along the x-axis
c> at indices 0, 1, 2 and 3.  The spacing along the
c> x-axis is "dx"
c> 
c> Thus:
c> 
c> \f{eqnarray*}{
c>     f0 = f_0 &= y(x_0) \\
c>     f1 = f_1 &= y(x_1) \\ 
c>     f2 = f_2 &= y(x_2) \\
c>     f3 = f_3 &= y(x_3) 
c> \f}
c> 
c> Where:
c> 
c> \f{eqnarray*}{
c>     x_1 &= x_0 + dx \\
c>     x_2 &= x_1 + dx \\
c>     x_3 &= x_2 + dx
c> \f} 
c> 
c> The input value is some value of "x" that falls
c> between 0 and 3.  The output value (cubterp) is
c> the cubic function at x.
c> 
c> 
c> \param[in] x Compute Interpolation at this positon, a value between 0 and 3 
c>      it is scaled relative to `x_0` `x_3` and `dx`. For example,
c>      a value of 1.5 is `x_0 + 1.5*dx` which falls between `x1` and `x2`
c> \param[in] f0 `y` value at `x_0`
c> \param[in] f1 `y` value at `x_1 = x_0 + dx`
c> \param[in] f2 `y` value at `x_2 = x_0 + dx`
c> \param[in] f3 `y` value at `x_3 = x_0 + dx``
c> 
c> This function uses Newton-Gregory forward polynomial
c> 
c> \f{eqnarray*}{
c>     \nabla f_0 &=& f_1 -f_0 \\
c>     \nabla f_1 &=& f_2 -f_1 \\
c>     \nabla^2 f_0 &=& \nabla f_1 - \nabla f_0 \\
c>     cubterp(x, f_0, f_1, f_2, f_3) &=& f_0 + x \nabla f_0 + 0.5 x \left( x-1.0 \right) \nabla^2 f_0
c> \f}
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
