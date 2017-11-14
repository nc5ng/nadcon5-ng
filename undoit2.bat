#! /bin/csh
# Batch file "undoit2.bat"
# - Deletes all files created from "doit2.bat"
#
# Takes in 3 arguments:
# Argument 1 = lower case, old datum name (character*10)
# Argument 2 = lower case, new datum name (character*10)
# Argument 3 = lower case, region         (character*10)
#
# Example of how to execute this batch file:
#       %undoit2.bat ussd nad27 conus <return>
# The only allowable combinations are:
#   For CONUS:
#                 ussd nad27 conus
#                 nad27 nad83_1986 conus
#                 nad83_1986 nad83_harn conus
#                 nad83_harn nad83_fbn conus
#                 nad83_fbn nad83_2007 conus
#                 nad83_2007 nad83_2011 conus
#   For ALASKA:
#                 nad27 nad83_1986 alaska
#                 nad83_1986 nad83_fbn alaska
#                 nad83_fbn nad83_2007 alaska
#                 nad83_2007 nad83_2011 alaska
#   For PRVI:
#                 nad27 nad83_1986 prvi 
#                 nad83_1986 nad83_harn0 prvi 
#                 nad83_harn0 nad83_harn prvi
#                 nad83_harn nad83_fbn prvi
#                 nad83_fbn nad83_2007 prvi
#                 nad83_2007 nad83_2011 prvi
#   For HAWAII:
#                 ohd nad83_1986 hawaii
#                 nad83_1986 nad83_fbn hawaii
#                 nad83_fbn nad83_pa11 hawaii
#
date
echo 'undoit2.bat -- BEGIN'
echo 'undoit2.bat: Number of Arguments Received          = '$#argv
echo 'undoit2.bat: Old Datum                             = '$argv[1]
echo 'undoit2.bat: New Datum                             = '$argv[2]
echo 'undoit2.bat: Region                                = '$argv[3]
# --------------------------------------
# - DELETE the first GMT batch file
# --------------------------------------
echo 'undoit2.bat: Removing first GMT batch file'
rm -f gmtbat01.$argv[1].$argv[2].$argv[3].*
# --------------------------------------
# - DELETE the coverage and vector files
# --------------------------------------
echo 'undoit2.bat: Removing coverage files'
rm -f cvacdlat.$argv[1].$argv[2].$argv[3]
rm -f cvacdlon.$argv[1].$argv[2].$argv[3]
rm -f cvacdeht.$argv[1].$argv[2].$argv[3]
echo 'undoit2.bat: Removing vector files, meters'
rm -f vmacdlat.$argv[1].$argv[2].$argv[3]
rm -f vmacdlon.$argv[1].$argv[2].$argv[3]
rm -f vmacdeht.$argv[1].$argv[2].$argv[3]
rm -f vmacdhor.$argv[1].$argv[2].$argv[3]
echo 'undoit2.bat: Removing vector files, arcseconds'
rm -f vsacdlat.$argv[1].$argv[2].$argv[3]
rm -f vsacdlon.$argv[1].$argv[2].$argv[3]
rm -f vsacdhor.$argv[1].$argv[2].$argv[3]
# --------------------------------------
# - DELETE the Coverage and Vectors plots
# - The "*" below allows for multiple
# - plots (nplots>1) in any of the
# - "bound(region).f" subroutines.
# --------------------------------------
echo 'undoit2.bat: Removing Coverage JPGs'
rm -f cvacdlat.$argv[1].$argv[2].$argv[3].*.jpg
rm -f cvacdlon.$argv[1].$argv[2].$argv[3].*.jpg
rm -f cvacdeht.$argv[1].$argv[2].$argv[3].*.jpg
echo 'undoit2.bat: Removing Vector JPGs, meters'
rm -f vmacdlat.$argv[1].$argv[2].$argv[3].*.jpg
rm -f vmacdlon.$argv[1].$argv[2].$argv[3].*.jpg
rm -f vmacdeht.$argv[1].$argv[2].$argv[3].*.jpg
rm -f vmacdhor.$argv[1].$argv[2].$argv[3].*.jpg
echo 'undoit2.bat: Removing Vector JPGs, arcseconds'
rm -f vsacdlat.$argv[1].$argv[2].$argv[3].*.jpg
rm -f vsacdlon.$argv[1].$argv[2].$argv[3].*.jpg
rm -f vsacdhor.$argv[1].$argv[2].$argv[3].*.jpg
#
# --------------------------------------
#
echo 'undoit2.bat -- END'
date
