#!/bin/csh
# Batch file "doit.bat"
# - First of many which are used to process,
# - analyze, and ultimately create, all of
# - the files for NADCON v5.0

# - What this batch file does:
#    1) Creates a "work" file from "in" files 
#       and our "edit" file 
#
# Takes in 3 arguments:
# Argument 1 = lower case, old datum name
# Argument 2 = lower case, new datum name
# Argument 3 = lower case, region
#
# Example of how to execute this batch file:
#       %doit.bat ussd nad27 conus <return>
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
#                 nad83_1986 nad83_1992 alaska
#                 nad83_1992 nad83_2007 alaska
#                 nad83_2007 nad83_2011 alaska
#   For HAWAII:
#                 ohd nad83_1986 hawaii
#                 nad83_1986 nad83_1993 hawaii
#                 nad83_1993 nad83_pa11 hawaii
#   For PRVI:
#                 nad27 nad83_1986 prvi 
#                 nad83_1986 nad83_1993 prvi 
#                 nad83_1993 nad83_1997 prvi
#                 nad83_1997 nad83_2002 prvi
#                 nad83_2002 nad83_2007 prvi
#                 nad83_2007 nad83_2011 prvi
#   For GUAMCNMI:
#                 gu63 nad83_1993 guamcnmi
#                 nad83_1993 nad83_2002 guamcnmi
#                 nad83_2002 nad83_ma11 guamcnmi
#   For AS:
#                 as62 nad83_1993 as
#                 nad83_1993 nad83_2002 as
#                 nad83_2002 nad83_pa11 as
#
date
echo 'doit.bat -- BEGIN'
echo 'doit.bat: Number of Arguments Received          = '$#argv
echo 'doit.bat: Old Datum                             = '$argv[1]
echo 'doit.bat: New Datum                             = '$argv[2]
echo 'doit.bat: Region                                = '$argv[3]
# --------------------------------------
# - RUN "makework.f"
# -   Creates a file called "work.(olddtm).(newdtm).(region)"
# -   which contains all of the data needed
# -   to plot and analyze the transformation
# -   between two datums in one region.
# --------------------------------------
./makework << !
$argv[1]
$argv[2]
$argv[3]
!
#
# --------------------------------------
#
echo 'doit.bat -- END'
date
