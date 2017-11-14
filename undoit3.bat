#! /bin/csh
# Batch file "undoit3.bat"
#
# Takes in 3 arguments:
# Argument 1 = lower case, old datum name (character*10)
# Argument 2 = lower case, new datum name (character*10)
# Argument 3 = lower case, region         (character*10)
# Argument 4 = Grid Spacing, arcseconds   (character*5)
#
# Example of how to execute this batch file:
#       %undoit3.bat ussd nad27 conus 900 <return>
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
echo 'undoit3.bat -- BEGIN'
echo 'undoit3.bat: Number of Arguments Received          = '$#argv
echo 'undoit3.bat: Old Datum                             = '$argv[1]
echo 'undoit3.bat: New Datum                             = '$argv[2]
echo 'undoit3.bat: Region                                = '$argv[3]
echo 'undoit3.bat: Grid Spacing, ArcSeconds              = '$argv[4]
# --------------------------------------
# - DELETE the second GMT batch file
# --------------------------------------
echo undoit3.bat: Removing second GMT batch file : gmtbat02.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f gmtbat02.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the thinned coverage and vector files
# --------------------------------------
echo 'undoit3.bat: Removing thinned coverage files'
rm -f cvtcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f cvtcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f cvtcdeht.$argv[1].$argv[2].$argv[3].$argv[4]
echo 'undoit3.bat: Removing thinned vector files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmtcdhor.$argv[1].$argv[2].$argv[3].$argv[4]
echo 'undoit3.bat: Removing thinned vector files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vstcdhor.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the thinned coverage and vectors plots
# --------------------------------------
echo 'undoit3.bat: Removing Thinned Coverage JPGs'
rm -f cvtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cvtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cvtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
echo 'undoit3.bat: Removing Thinned Vector JPGs, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmtcdhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
echo 'undoit3.bat: Removing Thinned Vector JPGs, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vstcdhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the dropped coverage and vector files
# --------------------------------------
echo 'undoit3.bat: Removing dropped coverage files'
rm -f cvdcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f cvdcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f cvdcdeht.$argv[1].$argv[2].$argv[3].$argv[4]
echo 'undoit3.bat: Removing dropped vector files, meters'
rm -f vmdcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdcdeht.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vmdcdhor.$argv[1].$argv[2].$argv[3].$argv[4]
echo 'undoit3.bat: Removing dropped vector files, arcseconds'
rm -f vsdcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsdcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f vsdcdhor.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the dropped coverage and vectors plots
# --------------------------------------
echo 'undoit3.bat: Removing Dropped Coverage JPGs'
rm -f cvdcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cvdcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cvdcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
echo 'undoit3.bat: Removing Dropped Vector JPGs, meters'
rm -f vmdcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vmdcdhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
echo 'undoit3.bat: Removing Dropped Vector JPGs, arcseconds'
rm -f vsdcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsdcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f vsdcdhor.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
# --------------------------------------
# - DELETE the thinned vector files for surface
# --------------------------------------
echo 'undoit3.bat: Removing thinned vectors files for surface, meters'
rm -f smtcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f smtcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f smtcdeht.$argv[1].$argv[2].$argv[3].$argv[4]
echo 'undoit3.bat: Removing thinned vectors files for surface, arcseconds'
rm -f sstcdlat.$argv[1].$argv[2].$argv[3].$argv[4]
rm -f sstcdlon.$argv[1].$argv[2].$argv[3].$argv[4]
# --------------------------------------
# - DELETE the gridded ".grd" files
# --------------------------------------
echo 'undoit3.bat: Removing gridded .grd files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
echo 'undoit3.bat: Removing gridded .grd files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.grd
# --------------------------------------
# - DELETE the gridded ".xyz" files
# --------------------------------------
echo 'undoit3.bat: Removing gridded .xyz files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
echo 'undoit3.bat: Removing gridded .xyz files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz
# --------------------------------------
# - DELETE the gridded ".b" files
# --------------------------------------
echo 'undoit3.bat: Removing gridded .b files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.b
echo 'undoit3.bat: Removing gridded .b files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.b
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.b
# --------------------------------------
# - DELETE the "premask" ".b" files (HARN/FBN/CONUS only)
# --------------------------------------
echo 'undoit3.bat: Removing gridded .b.premask files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.b.premask
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.b.premask
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.b.premask
echo 'undoit3.bat: Removing gridded .b.premask files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.b.premask
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.b.premask
# --------------------------------------
# - DELETE the "premask" ".xyz" files (HARN/FBN/CONUS only)
# --------------------------------------
echo 'undoit3.bat: Removing gridded .xyz.premask files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz.premask
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz.premask
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz.premask
echo 'undoit3.bat: Removing gridded .xyz.premask files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz.premask
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.xyz.premask
# --------------------------------------
# - DELETE the "premask" ".grd" files (HARN/FBN/CONUS only)
# --------------------------------------
echo 'undoit3.bat: Removing gridded .grd.premask files, meters'
rm -f vmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.grd.premask
rm -f vmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.grd.premask
rm -f vmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.grd.premask
echo 'undoit3.bat: Removing gridded .grd.premask files, arcseconds'
rm -f vstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.grd.premask
rm -f vstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.grd.premask
# --------------------------------------
# - DELETE the third GMT batch file
# --------------------------------------
echo 'undoit3.bat: Removing third GMT batch file'
rm -f gmtbat03.$argv[1].$argv[2].$argv[3].$argv[4].*
# --------------------------------------
# - DELETE the color plots
# --------------------------------------
echo 'undoit3.bat: Removing color plots, meters'
rm -f cmtcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmtcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cmtcdeht.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
echo 'undoit3.bat: Removing color plots, arcseconds'
rm -f cstcdlat.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
rm -f cstcdlon.$argv[1].$argv[2].$argv[3].$argv[4].*.jpg
#
#
#
echo 'undoit3.bat -- END'
date
