#! /bin/csh
# Batch file "undoit.bat"
# - Deletes all files created from "doit.bat"
#
# Takes in 3 arguments:
# Argument 1 = lower case, old datum name (character*10)
# Argument 2 = lower case, new datum name (character*10)
# Argument 3 = lower case, region         (character*10)
#
# Example of how to execute this batch file:
#       %undoit.bat ussd nad27 conus <return>
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
echo 'undoit.bat -- BEGIN'
echo 'undoit.bat: Number of Arguments Received          = '$#argv
echo 'undoit.bat: Old Datum                             = '$argv[1]
echo 'undoit.bat: New Datum                             = '$argv[2]
echo 'undoit.bat: Region                                = '$argv[3]
# --------------------------------------
# - DELETE the work file
# --------------------------------------
echo 'undoit.bat: Removing work file'
rm -f Work/work.$argv[1].$argv[2].$argv[3]
#
# --------------------------------------
#
echo 'undoit.bat -- END'
date
