c> \ingroup core
c> \if MANPAGE     
c> \page qterp
c> \endif      
c> 
c> This function fits a quadratic function through 3 points
c> 
c> This function fits a parabola (quadratic) function through
c> three *equally* spaced points along the x-axis
c> at indices 0, 1, and 2.  The spacing along the
c> x-axis is "dx"
c> 
c> Thus:
c> 
c> \f{eqnarray*}{
c>     f0 = f_0 &= y(x_0) \\
c>     f1 = f_1 &= y(x_1) \\ 
c>     f2 = f_2 &= y(x_2) 
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
c> between 0 and 2.  The output value (qterp) is
c> the quadratic function at x.
c> 
c> 
c> \param[in] x Compute Interpolation at this positon, a value between 0 and 3 
c>      it is scaled relative to `x_0` `x_2` and `dx`. For example,
c>      the  value of 1.5 is `x_0 + 1.5*dx` which falls between `x1` and `x2`
c> \param[in] f0 `y` value at `x_0`
c> \param[in] f1 `y` value at `x_1 = x_0 + dx`
c> \param[in] f2 `y` value at `x_2 = x_0 + dx`
c> \return `real` quadratically interpolated value of `f(x*)` where `x* = x_0 + x*dxx`
c> 
c> This function uses Newton-Gregory forward polynomial
c> 
c> \f{eqnarray*}{
c>     \nabla f_0 &=& f_1 -f_0 \\
c>     \nabla f_1 &=& f_2 -f_1 \\
c>     \nabla^2 f_0 &=& \nabla f_1 - \nabla f_0 \\
c>     qterp(x, f_0, f_1, f_2) &=& f_0 + x \nabla f_0 + 0.5 x \left( x-1.0 \right) \nabla^2 f_0
c> \f}
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
