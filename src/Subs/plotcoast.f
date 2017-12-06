c> \ingroup core
c> \if MANPAGE     
c> \page plotcoast
c> \endif      
c> 
c> Subroutine to write GMT-based commands to create a shoreline
c> Write GMT-based commands to create a shoreline
c> based on region.
c> 
c> Use GMT-default coastline for:
c> - `conus`
c> - `alaska`
c> 
c> Use Dru's custome coastline for:
c> - hawaii
c> - prvi
c> - as
c> - guamcnmi
c> - stlawrence
c> - stmatthew 
c> - stgeorge  
c> - stpaul    
c> 
c> \param[in] region The Region to create coastline for 
c> \param[in] ifnum the file descriptor of the output file to write `GMT` commands to
c> 
c>
c> ## Changelog
c>
c> ### 2016 01 07:
c> Forced the Alaska region to plot the
c> islands of St. George, St. Matthew and St. Paul
c> (St. Lawrence is already plotted), as well
c> as 35 missing Aleutian Islands
c>
c> ### 2015 09 23:  
c> Added four new regions:
c> - St. Lawrence Island, Alaska
c> - St. Matthew Island, Alaska
c> - St. George Island, Alaska
c> - St. Paul Island, Alaska
c>
      subroutine plotcoast(region,ifnum)

c - 2016 01 07
c     Forced the Alaska region to plot the
c     islands of St. George, St. Matthew and St. Paul
c     (St. Lawrence is already plotted), as well
c     as 35 missing Aleutian Islands

c - 2015 09 23:  Added four new regions:
c      St. Lawrence Island, Alaska
c      St. Matthew Island, Alaska
c      St. George Island, Alaska
c      St. Paul Island, Alaska

      character*10 region

c - Write GMT-based commands to create a shoreline
c - based on region.
c - Use GMT-default coastline for:
c      conus
c      alaska
c - Use Dru's custome coastline for:
c      hawaii
c      prvi
c      as
c      guamcnmi
c      stlawrence
c      stmatthew 
c      stgeorge  
c      stpaul    


      if    (trim(region).eq.'conus')then
        write(ifnum,100) 
      elseif(trim(region).eq.'alaska')then
        write(ifnum,109) 
      elseif(trim(region).eq.'hawaii')then
        write(ifnum,101) 
      elseif(trim(region).eq.'prvi')then
        write(ifnum,102) 
      elseif(trim(region).eq.'guamcnmi')then
        write(ifnum,103) 
      elseif(trim(region).eq.'as')then
        write(ifnum,104) 
      elseif(trim(region).eq.'stlawrence')then
        write(ifnum,105) 
      elseif(trim(region).eq.'stmatthew')then
        write(ifnum,106) 
      elseif(trim(region).eq.'stgeorge')then
        write(ifnum,107) 
      elseif(trim(region).eq.'stpaul')then
        write(ifnum,108) 
     
      else
        write(6,200)region
        stop 10001
      endif
      return

  200 format('FATAL in plotcoast.f: Unknown region: ',a10)

c - CONUS 
  100 format(
     *'pscoast -Df -R -JM -W0.25p -N1 -N2 -A1200 -O >>  plot.ps')

c - HAWAII
  101 format(
     *'psxy Boundaries/HI_Hawaii.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Kahoolawe.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Kauai.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Lanai.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Maui.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Molokai.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Nihau.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/HI_Oahu.gmt -R -JM -B -O ',
     *' >> plot.ps')

c - PRVI
  102 format(
     *'psxy Boundaries/VQ_StCroix.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/VQ_StJohn.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/VQ_StThomas.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/PR_Culebra.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/PR_Desecheo.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/PR_Mona.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/PR_Viequez.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/PR_PuertoRico.gmt -R -JM -B -O ',
     *' >> plot.ps')
 
c - GUAM/CNMI
  103 format(
     *'psxy Boundaries/GQ_Guam.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Rota.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Saipan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Tinian.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Anatahan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Sarigan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Guguan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Alamagan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Pagan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Agrihan.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Asuncion.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_MaugWest.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_MaugEast.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_MaugNorth.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/CQ_Pajaros.gmt -R -JM -B -O',
     *' >> plot.ps')

c - AS  
  104 format(
     *'psxy Boundaries/AS_Aunuu.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Nuutele.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Ofu.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Olosega.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Rose.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Swains.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Tau.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AS_Tutila.gmt -R -JM -B -O ',
     *' >> plot.ps')

c - St. Lawrence Island, Alaska
  105 format(
     *'psxy Boundaries/AK_StLawrence.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_NorthPunuk.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_MiddlePunuk.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_SouthPunuk.gmt -R -JM -B -O ',
     *' >> plot.ps')

c - St. Matthew Island, Alaska
  106 format(
     *'psxy Boundaries/AK_StMatthew.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Hall.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Pinnacle.gmt -R -JM -B -O ',
     *' >> plot.ps')

c - St. George Island, Alaska
  107 format(
     *'psxy Boundaries/AK_StGeorge.gmt -R -JM -B -O',
     *' >> plot.ps')

c - St. Paul Island, Alaska
  108 format(
     *'psxy Boundaries/AK_StPaul.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Otter.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Walrus.gmt -R -JM -B -O ',
     *' >> plot.ps')

c - ALASKA
  109 format(
     *'pscoast -Df -R -JM -W0.25p -N1 -N2 -A1200 -O -K ',
     *' >>  plot.ps',/,
     *'psxy Boundaries/AK_NorthPunuk.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_MiddlePunuk.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_SouthPunuk.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_StMatthew.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Hall.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Pinnacle.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_StGeorge.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_StPaul.gmt -R -JM -B -O -K',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Otter.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Walrus.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Adak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Agattu.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Amchitka.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Amlia.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Amukta.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Andreanof.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Atka.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Attu.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Buldir.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Carlisle.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Chagulak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Chugul.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Fenimore.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_FourMountains.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_GreatSitkin.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Herbert.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Igitkin.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Ikiginak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Kagalaska.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Kagami.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Kanaga.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Kasatochi.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Kiska.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Koniuji.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Oglodak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Seguam.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Semichi.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Semisopochnoi.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Shemya.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Tagalak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Tanaga.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Ulak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Uliaga.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Umak.gmt -R -JM -B -O -K ',
     *' >> plot.ps',/,
     *'psxy Boundaries/AK_Yunaska.gmt -R -JM -B -O ',
     *' >> plot.ps')

      end
