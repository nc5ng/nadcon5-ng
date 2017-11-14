#! /bin/csh
# Batch file "undoit4.bat"
#
# Takes in 3 arguments:
# Argument 1 = lower case, old datum name (character*10)
# Argument 2 = lower case, new datum name (character*10)
# Argument 3 = lower case, region         (character*10)
# Argument 4 = Grid Spacing, arcseconds   (character*5)
#
# Example of how to execute this batch file:
#       %undoit4.bat ussd nad27 conus 900 <return>
# The only allowable combinations are:
# (The "*" represents any value of arcseconds
#  between 1 and 99999)
#   For CONUS:
#                 ussd nad27 conus *
#                 nad27 nad83_1986 conus *
#                 nad83_1986 nad83_harn conus *
#                 nad83_harn nad83_fbn conus *
#                 nad83_fbn nad83_2007 conus *
#                 nad83_2007 nad83_2011 conus *
#   For ALASKA:
#                 nad27 nad83_1986 alaska *
#                 nad83_1986 nad83_fbn alaska *
#                 nad83_fbn nad83_2007 alaska *
#                 nad83_2007 nad83_2011 alaska *
#   For PRVI:
#                 nad27 nad83_1986 prvi *
#                 nad83_1986 nad83_harn0 prvi *  
#                 nad83_harn0 nad83_harn prvi *
#                 nad83_harn nad83_fbn prvi *
#                 nad83_fbn nad83_2007 prvi *
#                 nad83_2007 nad83_2011 prvi *
#   For HAWAII:
#                 ohd nad83_1986 hawaii *
#                 nad83_1986 nad83_fbn hawaii *
#                 nad83_fbn nad83_pa11 hawaii *
#
date
echo 'undoit4.bat -- BEGIN'
echo 'undoit4.bat: Number of Arguments Received          = '$#argv
echo 'undoit4.bat: Old Datum                             = '$argv[1]
echo 'undoit4.bat: New Datum                             = '$argv[2]
echo 'undoit4.bat: Region                                = '$argv[3]
echo 'undoit4.bat: Grid Spacing, ArcSeconds              = '$argv[4]
# --------------------------------------
# - DELETE the grid interpolated vector files, All
# --------------------------------------
echo 'undoit4.bat: Removing Grid-Interpolated vector files with All points'
rm -f vsagilat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsagilon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmagieht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmagilat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmagilon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmagihor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsagihor.$argv[1].$argv[2].$argv[3].$argv[4]
#
# --------------------------------------
# - DELETE the grid interpolated vector files, Thinned
# --------------------------------------
echo 'undoit4.bat: Removing Grid-Interpolated vector files with Thinned points'
rm -f vstgilat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vstgilon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtgieht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtgilat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtgilon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtgihor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vstgihor.$argv[1].$argv[2].$argv[3].$argv[4]
#
# --------------------------------------
# - DELETE the grid interpolated vector files, Dropped
# --------------------------------------
echo 'undoit4.bat: Removing Grid-Interpolated vector files with Dropped points'
rm -f vsdgilat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsdgilon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdgieht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdgilat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdgilon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdgihor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsdgihor.$argv[1].$argv[2].$argv[3].$argv[4]
#
# --------------------------------------
# - DELETE the double differenced vector files, All
# --------------------------------------
echo 'undoit4.bat: Removing Double Differenced vector files with All points'
rm -f vsaddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsaddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmaddeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmaddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmaddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmaddhor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsaddhor.$argv[1].$argv[2].$argv[3].$argv[4]
#
# --------------------------------------
# - DELETE the double differenced vector files, Thinned
# --------------------------------------
echo 'undoit4.bat: Removing Double Differenced vector files with Thinned points'
rm -f vstddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vstddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtddeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtddhor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vstddhor.$argv[1].$argv[2].$argv[3].$argv[4]
#
# --------------------------------------
# - DELETE the double differenced vector files, Dropped
# --------------------------------------
echo 'undoit4.bat: Removing Double Differenced vector files with Dropped points'
rm -f vsdddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsdddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdddeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdddhor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsdddhor.$argv[1].$argv[2].$argv[3].$argv[4]
#
# --------------------------------------
# - DELETE the fourth GMT batch file
# --------------------------------------
echo undoit4.bat: Removing fourth GMT batch file 
rm -f gmtbat04.$argv[1].$argv[2].$argv[3].$argv[4].*
# --------------------------------------
# - DELETE the temporary stat-holding file
# --------------------------------------
echo undoit4.bat: Removing stats.tmp 
rm -f dvstats.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the grid-interpolated vector plots, All
# --------------------------------------
echo 'undoit4.bat: Removing Grid-Interpolated vector plots with All points'
rm -f vsagilat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsagilon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmagieht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmagilat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmagilon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsagihor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmagihor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#
# --------------------------------------
# - DELETE the grid-interpolated vector plots, Thinned
# --------------------------------------
echo 'undoit4.bat: Removing Grid-Interpolated vector plots with Thinned points'
rm -f vstgilat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vstgilon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtgieht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtgilat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtgilon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vstgihor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtgihor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#
# --------------------------------------
# - DELETE the grid-interpolated vector plots, Dropped
# --------------------------------------
echo 'undoit4.bat: Removing Grid-Interpolated vector plots with Dropped points'
rm -f vsdgilat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsdgilon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdgieht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdgilat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdgilon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsdgihor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdgihor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the double differenced vector plots, All
# --------------------------------------
echo 'undoit4.bat: Removing Double Differenced vector plots with All points'
rm -f vsaddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsaddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmaddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmaddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmaddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsaddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmaddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#
# --------------------------------------
# - DELETE the double differenced vector plots, Thinned
# --------------------------------------
echo 'undoit4.bat: Removing Double Differenced vector plots with Thinned points'
rm -f vstddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vstddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vstddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#
# --------------------------------------
# - DELETE the double differenced vector plots, Dropped
# --------------------------------------
echo 'undoit4.bat: Removing Double Differenced vector plots with Dropped points'
rm -f vsdddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsdddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsdddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the RMS'd differential vector files
# --------------------------------------
echo 'undoit4.bat: Removing RMSd differential vector files'
rm -f vsrddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsrddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmrddeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmrddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmrddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsrddhor.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmrddhor.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the RMS'd differential vector plots
# --------------------------------------
echo 'undoit4.bat: Removing RMSd differential vector files'
rm -f vsrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsrddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmrddhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the RMS'd differential coverage files
# --------------------------------------
echo 'undoit4.bat: Removing RMSd differential vector coverage files'
rm -f cvrddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f cvrddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f cvrddeht.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the RMS'd differential vector files (for use in surface)
# --------------------------------------
echo 'undoit4.bat: Removing RMSd differential vector files (for use in surface)'
rm -f ssrddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f ssrddlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f smrddeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f smrddlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f smrddlon.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the fifth GMT batch file
# --------------------------------------
echo undoit4.bat: Removing fifth GMT batch file : gmtbat05.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f gmtbat05.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the gridded ".grd" files
# --------------------------------------
echo 'undoit4.bat: Removing gridded .grd files'
rm -f vsrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vsrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vmrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vmrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vmrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
# --------------------------------------
# - DELETE the gridded ".xyz" files
# --------------------------------------
echo 'undoit4.bat: Removing gridded .xyz files'
rm -f vsrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vsrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vmrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vmrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vmrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
# --------------------------------------
# - DELETE the gridded RMS'd ".b" files ("data noise" grids)
# --------------------------------------
echo 'undoit4.bat: Removing gridded RMS DD .b files'
rm -f vsrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vsrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vmrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vmrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vmrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.b
#
# --------------------------------------
# - DELETE the sixth GMT batch file
# --------------------------------------
echo undoit4.bat: Removing sixth GMT batch file 
rm -f gmtbat06.$argv[1].$argv[2].$argv[3].$argv[4].*
# --------------------------------------
# - DELETE the Total Error grids, .b format
# --------------------------------------
echo 'undoit4.bat: Removing Total Error grids, .b format'
rm -f vmetelat.$argv[1].$argv[2].$argv[3].$argv[4].b
rm -f vsetelat.$argv[1].$argv[2].$argv[3].$argv[4].b
rm -f vmetelon.$argv[1].$argv[2].$argv[3].$argv[4].b
rm -f vsetelon.$argv[1].$argv[2].$argv[3].$argv[4].b
rm -f vmeteeht.$argv[1].$argv[2].$argv[3].$argv[4].b
# --------------------------------------
# - DELETE the Total Error grids, .grd format
# --------------------------------------
echo 'undoit4.bat: Removing Total Error grids, .grd format'
rm -f vmetelat.$argv[1].$argv[2].$argv[3].$argv[4].grd
rm -f vsetelat.$argv[1].$argv[2].$argv[3].$argv[4].grd
rm -f vmetelon.$argv[1].$argv[2].$argv[3].$argv[4].grd
rm -f vsetelon.$argv[1].$argv[2].$argv[3].$argv[4].grd
rm -f vmeteeht.$argv[1].$argv[2].$argv[3].$argv[4].grd

# --------------------------------------
# - DELETE the "premask" total error ".b" files (HARN/FBN/CONUS only)
# (Added 2016 07 01)
# --------------------------------------
echo 'undoit4.bat: Removing gridded total error .b.premask files, meters'
rm -f vmetelat.$argv[1].$argv[2].$argv[3].$argv[4].b.premask
rm -f vmetelon.$argv[1].$argv[2].$argv[3].$argv[4].b.premask
rm -f vmeteeht.$argv[1].$argv[2].$argv[3].$argv[4].b.premask
echo 'undoit4.bat: Removing gridded total error .b.premask files, arcseconds'
rm -f vsetelat.$argv[1].$argv[2].$argv[3].$argv[4].b.premask
rm -f vsetelon.$argv[1].$argv[2].$argv[3].$argv[4].b.premask

# --------------------------------------
# - DELETE the Differential Vector COVERAGE plots
# --------------------------------------
echo 'undoit4.bat: Removing RMSd differential vector COVERAGE (dcr) plots'
rm -f cvrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cvrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cvrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the Differential VECTOR plots
# --------------------------------------
#echo 'undoit4.bat: Removing RMSd differential vector COVERAGE (dvr) plots'
#rm -f vsrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#rm -f vsrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#rm -f vmrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#rm -f vmrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#rm -f vmrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the color plots of RMS'd DD grids
# --------------------------------------
echo 'undoit4.bat: Removing RMSd differential vector COLOR plots'
rm -f csrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f csrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmrddeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmrddlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmrddlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the color plots of total error grids
# --------------------------------------
echo 'undoit4.bat: Removing Total Error COLOR plots'
rm -f cmetelat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f csetelat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmetelon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f csetelon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmeteeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
echo 'undoit4.bat -- END'
date
