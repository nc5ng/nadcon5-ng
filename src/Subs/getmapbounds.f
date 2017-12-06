c> \ingroup core
c> \if MANPAGE     
c> \page getmapbounds
c> \endif      
c> 
c> Subroutine to collect up the MAP boundaries
c> for use in creating NADCON 5
c>
c> This CAN BE different than the GRID boundaries
c> as such:
c>
c> GRID boundaries will be just four values (n/s/w/e) for any region
c>
c> MAP boundaries will allow multiple maps to be made and may or may
c> not align with the GRID boundaries.  Used to allow for more 
c> "close up" maps and such, without the need to screw up the
c> MAP boundaries.
c>
c> \param[in] mapflag Map Generation Flag
c> \param[in] maxplots 
c> \param[in] region region to get map bounds
c> \param[out] nplots number of plots generated
c> \param[in] olddtm source datum
c> \param[in] newdtm target datum
c> \param[out] bw western bound of plot (Array of length `maxplots`)
c> \param[out] be eastern bound of plot (Array of length `maxplots`) 
c> \param[out] bs southern bound of plot (Array of length `maxplots`)
c> \param[out] bn northern bound of plot (Array of length `maxplots`)
c> \param[out] jm (Array of length `maxplots`)
c> \param[out] b1 (Array of length `maxplots`)
c> \param[out] b2 (Array of length `maxplots`)
c> \param[out] fn (Array of length `maxplots`)
c> \param[out] lrv (Array of length `maxplots`)
c> \param[out] rv0x (Array of length `maxplots`)
c> \param[out] rv0y (Array of length `maxplots`)
c> \param[out] rl0y (Array of length `maxplots`)
c>
c> Version for NADCON 5
c> Built upon the original version used in GEOCON v2.0
c> Do not use with GEOCON v2.0
c>
c> Broken down into sub-subroutines to make it easier
c> to swap out when I make different choices.
c>
c>
c> ## Changelog
c>
c>
c> ### 2016 08 29:  
c> Taking in olddtm and newdtm now, and adding
c> code to use that to filter out "Saint" regions in Alaska
c> when plotting transformations not supported in those regions.
c>
c> ### 2016 08 26:  
c> Used actual mercator projection math to compute
c> the exact reference vector and label locations 1/2 inch and
c> 3/4 inch respectively below the S/W corner of the plot.
c>
c> ### 2016 07 21:  
c> Two new columns added to "map.parameters", which 
c> have the location of the reference vector.  Return a logical "lrv"
c> as true if there is an optional special location for the reverence vector.
c> Return as false if not.  If true, return lon/lat coords of ref vector
c> origin in rv0x/rv0y.  If false, return zeros in those fields.
c> 
c> Also, compute "jm" on the fly, ignoring what is in the table.  All plots
c> will now be forced PORTRAIT and forced no wider than 6" and no taller
c> than 8", while maintaining proper X/Y ratios in a Mercator projection.
c> That means, make the biggest plot possible, with the right ratio, that
c> is neither wider than 6" nor taller than 8" and then, whatever the width
c> of that largest plot is -- return that width in the "jm" field.
c>

      subroutine getmapbounds(mapflag,maxplots,region,nplots,
     *olddtm,newdtm,
     *bw,be,bs,bn,jm,b1,b2,fn,lrv,rv0x,rv0y,rl0y)

c - 2016 08 29:  Taking in olddtm and newdtm now, and adding
c - code to use that to filter out "Saint" regions in Alaska
c - when plotting transformations not supported in those regions.

c - 2016 08 26:  Used actual mercator projection math to compute 
c - the exact reference vector and label locations 1/2 inch and
c - 3/4 inch respectively below the S/W corner of the plot.

c - Updated 2016 07 21:  Two new columns added to "map.parameters", which 
c - have the location of the reference vector.  Return a logical "lrv"
c - as true if there is an optional special location for the reverence vector.
c - Return as false if not.  If true, return lon/lat coords of ref vector
c - origin in rv0x/rv0y.  If false, return zeros in those fields.
c - 
c - Also, compute "jm" on the fly, ignoring what is in the table.  All plots
c - will now be forced PORTRAIT and forced no wider than 6" and no taller
c - than 8", while maintaining proper X/Y ratios in a Mercator projection.
c - That means, make the biggest plot possible, with the right ratio, that
c - is neither wider than 6" nor taller than 8" and then, whatever the width
c - of that largest plot is -- return that width in the "jm" field.

c
c - Subroutine to collect up the MAP boundaries
c - for use in creating NADCON 5
c
c - This CAN BE different than the GRID boundaries
c - as such:
c
c -  GRID boundaries will be just four values (n/s/w/e) for any region
c
c -  MAP boundaries will allow multiple maps to be made and may or may
c -  not align with the GRID boundaries.  Used to allow for more 
c -  "close up" maps and such, without the need to screw up the
c -  MAP boundaries.

c - Input:
c     region, maxplots, mapflag
c     olddtm, newdtm
c - Output:
c     number of plots, their bounds, their GMT scales and
c     label deltas

c - Version for NADCON 5
c - Built upon the original version used in GEOCON v2.0
c - Do not use with GEOCON v2.0

c - Broken down into sub-subroutines to make it easier
c - to swap out when I make different choices.

      character*10 region,olddtm,newdtm
      real*8    bw(maxplots),be(maxplots),bs(maxplots),bn(maxplots)
      real*4    jm(maxplots)
      real*4 b1(maxplots),b2(maxplots)
      character*10 fn(maxplots)
      character*1 mapflag


c - 2016 07 21:
      logical lrv(maxplots)
      real*8 rv0x(maxplots),rv0y(maxplots),rl0y(maxplots)
      character*3 c3x,c3y
      character*2 c2x,c2y
      real*8 pi,d2r

      character*200 card


      pi = 2.d0*dasin(1.d0)
      d2r = pi/180.d0

      ifile = 3

      open(ifile,
     *file='Data/map.parameters',
     *status='old',form='formatted')

c - Get numerical version of mapflag
      read(mapflag,*)iflag

c - Get the header out of the way
      read(ifile,'(a)')card
      read(ifile,'(a)')card

c - Loop over all map parameters, finding the ones relevant to 
c - our region and mapflag.
      i  = 0
    1 read(ifile,'(a)',end=2)card
        if(card( 1:10).ne.region)goto 1
        read(card(14:14),*)iflag0
        if(iflag0.gt.iflag)goto 1

c - 2016 08 29:
c - Specific to the case where we are looking at region=alaska,
c - and NOT region=<some saint island>, then for the specific
c - case of transforming from NAD 27 forward, let's skip
c - the <saint islands>
        if(region.eq.'alaska' .and.
     *     iflag.eq.2 .and.
     *     iflag0.eq.2 .and.
     *     (card(16:25).eq.'stpaul' .or.
     *      card(16:25).eq.'stgeorge' .or.
     *      card(16:25).eq.'stlawrence' .or.
     *      card(16:25).eq.'stmatthew') .and.
     *      olddtm.eq.'nad27' )goto 1

        i = i + 1
        fn(i) = trim(card( 16: 25))
        read(card( 27: 30),*)iwd
        read(card( 32: 33),*)iwm
        read(card( 35: 38),*)ied
        read(card( 40: 41),*)iem
        read(card( 43: 45),*)isd
        read(card( 47: 48),*)ism
        read(card( 50: 52),*)ind
        read(card( 54: 55),*)inm
        read(card( 57: 60),*)xjm
        read(card( 62: 64),*)ib1d
        read(card( 66: 67),*)ib1m
        read(card( 69: 71),*)ib2d
        read(card( 73: 74),*)ib2m
c - 2016 07 21:
        read(card( 76: 78),'(a3)')c3x
        read(card( 80: 81),'(a2)')c2x
        read(card( 83: 85),'(a3)')c3y
        read(card( 87: 88),'(a2)')c2y

        bw(i) = dble(iwd) + dble(iwm)/60.d0
        be(i) = dble(ied) + dble(iem)/60.d0
        if(ind.lt.0)inm = -inm
        if(isd.lt.0)ism = -ism
        bn(i) = dble(ind) + dble(inm)/60.d0
        bs(i) = dble(isd) + dble(ism)/60.d0
        jm(i) = xjm
        b1(i) = dble(ib1d) + dble(ib1m)/60.d0
        b2(i) = dble(ib2d) + dble(ib2m)/60.d0

c - 2016 07 21 (Optional reference vector locations):
        if(c3x.eq.'---')then
          lrv(i) = .false.
          rv0x(i) = 0
          rv0y(i) = 0
        else
          lrv(i) = .true.
          read(c3x,*)rv0xd
          read(c2x,*)rv0xm
          read(c3y,*)rv0yd
          read(c2y,*)rv0ym
          rv0x(i) = dble(rv0xd) + dble(rv0xm)/60.d0
          rv0y(i) = dble(rv0yd) + dble(rv0ym)/60.d0
        endif

c - 2016 07 21 (Forcing the map to keep its proper Mercator-projected X/Y ratio,
c - while filling the maximum space that does not exceed 6" wide nor 8" high)
        dx = (be(i) - bw(i)) * d2r 

        q1 = dtan(bn(i)*d2r)
        q2 = 1.d0 / dcos(bn(i)*d2r)          ! Secant
        yn = log(q1 + q2)

        q1 = dtan(bs(i)*d2r)
        q2 = 1.d0 / dcos(bs(i)*d2r)          ! Secant
        ys = log(q1 + q2)

        dy = yn - ys

        ratio = dx/dy

c - Max height and width
c       xmxht = 8
        xmxht = 6
        xmxwd = 6
  
        if(xmxht*ratio .gt. xmxwd)then
          jm(i) = xmxwd
c - And height = xmxwd / ratio...          
        else
          jm(i) = xmxht*ratio
c - And height = xmxht
        endif

c - 2016 08 26
c       See DRU-12, p. 56-57
c - dy/dphi is linear for latitudes south of 65. All of our plots
c - have at most a 65 degree south border.  So I can use that for
c - a pretty good approximation to compute the latitude of the
c - reference vector, in degrees, to send back as "rv0y".

c   First, get the ratio of dx/dy in the lower left part of the
c - plot.  Use 1% of the E/W span and apply that both ways.
        ddum = 0.01d0*(be(i) - bw(i))
        ydum = bs(i) + ddum
        xdum = bw(i) + ddum

        xw = bw(i) * d2r
        xe = xdum  * d2r

        dx = (xe - xw)

        q1 = dtan(ydum*d2r)
        q2 = 1.d0 / dcos(ydum*d2r)          ! Secant
        yn = log(q1 + q2)

        q1 = dtan(bs(i)*d2r)
        q2 = 1.d0 / dcos(bs(i)*d2r)          ! Secant
        ys = log(q1 + q2)

c - dy is in radians
        dy = yn - ys

c - Now I have a new "dx" and "dy" representing the lower left 1% of the plot,
c - in radians/radians.  Compute the new ratio for this part.
        ratio = dx/dy

c - Since radians to inches does NOT change in the E/W direction, and since 
c - I know exactly how wide the plot is, I can compute a radians/inch conversion
c - in E/W, for 1% of the width of the plot.  
        r2iew = (0.01d0 * jm(i)) / dx

c - The ratio of dx/dy, is going to be identical to the ratio of r2iew/r2ins:
        r2ins = r2iew / ratio

c - Convert r2ins into degrees-to-inches
        d2ins = r2ins * d2r

c - Now, the south edge is known in degrees.  I want the reference vector
c - to be 1/2 inch below that.  I want the reference vector label to 
c - be an additional 1/4 inches down.
        rv0y(i) = bs(i) - (0.50d0)/d2ins
        rl0y(i) = bs(i) - (0.65d0)/d2ins

c - And set the reference vector's left edge to equal the left edge of the plot
        rv0x(i) = bw(i)

c - Flags for debugging
        write(6,8) trim(fn(i))
   8    format('***************************',/,
     *  'Reference Vector Computations for',
     *  'Sub-Region: ',a)

        write(6,*) ' yn,ys,dy         = ',yn,ys,dy
        write(6,*) ' xe,xw,dx         = ',xe,xw,dx
        write(6,*) ' E/W width (jm)   = ',jm(i)
        write(6,*) ' SW ratio         = ',ratio
        write(6,*) ' SW bounds,Lat    = ',ydum,bs(i)
        write(6,*) ' SW bounds,Lon    = ',xdum,bw(i)
        write(6,*) ' r2i E/W          = ',r2iew
        write(6,*) ' r2i N/S          = ',r2ins
        write(6,*) ' d2i N/S          = ',d2ins
        write(6,*) ' Southwest corner = ',bs(i),bw(i)
        write(6,*) ' Ref Vector       = ',rv0y(i),rv0x(i)
        write(6,*) ' Ref Label        = ',rl0y(i),rv0x(i)

      goto 1

    2 nplots = i

      close(ifile)

      if(nplots.eq.0)then
        write(6,100)trim(region)
        stop 10001 
      endif
  100 format(6x,'FATAL Subroutine getmapbounds: Unknown region: ',a)
      return
      end
