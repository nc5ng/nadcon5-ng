#! /bin/csh
# Batch file "doit2.bat"
# - Second of many which are used to process,
# - analyze, and ultimately create, all of
# - the files for NADCON v5.0
# - Requires that "doit.bat" has been run.
# - What this batch file does:
#    1) Reads the "work" file
#    2) Creates coverage and vector files capable of GMT plotting
#    3) Creates a GMT batch file to plot files mentioned in #2
#    4) Runs the GMT batch file mentioned in #3
#
# Takes in 4 arguments:
# Argument 1 = lower case, old datum name
# Argument 2 = lower case, new datum name
# Argument 3 = lower case, region
# Argument 4 = integer, flag for what detailed-level of maps to make
#
# Example of how to execute this batch file:
#       %doit2.bat ussd nad27 conus 0 <return>
#
# The map flag (argument 4) can be 0, 1 or 2.  It is set to
# "0" in the examples below, but any of these combinations
# would be valid if the "0" were replaced with a "1" or a "2"
# Note also that a map resolution flag of "2" is treated as
# a "1" for all regions except "conus".
# The map resolution flags are:
#    0 = 1 map for the whole region
#    1 = Map 0 plus zoomed in maps for specific sub-regions
#    2 = Map 0 and Maps 1 PLUS hyper-zoomed maps (one for each state, in CONUS only, otherwise treated as a "1")
#
# The only allowable combinations are:
#   For CONUS:
#                 ussd nad27 conus 0
#                 nad27 nad83_1986 conus 0
#                 nad83_1986 nad83_harn conus 0
#                 nad83_harn nad83_fbn conus 0
#                 nad83_fbn nad83_2007 conus 0
#                 nad83_2007 nad83_2011 conus 0
#   For ALASKA:
#                 nad27 nad83_1986 alaska 0
#                 nad83_1986 nad83_1992 alaska 0
#                 nad83_1992 nad83_2007 alaska 0
#                 nad83_2007 nad83_2011 alaska 0
#   For HAWAII:
#                 ohd nad83_1986 hawaii 0
#                 nad83_1986 nad83_1993 hawaii 0
#                 nad83_1993 nad83_pa11 hawaii 0
#   For PRVI:
#                 nad27 nad83_1986 prvi 0
#                 nad83_1986 nad83_1993 prvi 0 
#                 nad83_1993 nad83_1997 prvi 0
#                 nad83_1997 nad83_2002 prvi 0
#                 nad83_2002 nad83_2007 prvi 0
#                 nad83_2007 nad83_2011 prvi 0
#   For GUAMCNMI:
#                 gu63 nad83_1993 guamcnmi 0
#                 nad83_1993 nad83_2002 guamcnmi 0
#                 nad83_2002 nad83_ma11 guamcnmi 0
#   For AS:
#                 as62 nad83_1993 as 0
#                 nad83_1993 nad83_2002 as 0
#                 nad83_2002 nad83_pa11 as 0
#
date
echo 'doit2.bat -- BEGIN'
echo 'doit2.bat: Number of Arguments Received          = '$#argv
echo 'doit2.bat: Old Datum                             = '$argv[1]
echo 'doit2.bat: New Datum                             = '$argv[2]
echo 'doit2.bat: Region                                = '$argv[3]
echo 'doit2.bat: Map Resoluton Flag                    = '$argv[4]
# --------------------------------------
# - RUN "makeplotfiles01.f"
# -   Note that this FORTRAN program
# -   creates both the GMT-ready data
# -   files to show both coverage and
# -   vectors as well as the actual
# -   GMT-based batch files which will
# -   use those files and create plots.
# --------------------------------------
./makeplotfiles01 << !
$argv[1]
$argv[2]
$argv[3]
$argv[4]
!
# -------------------------------------
# - RUN gmtbat01.(olddtm).(newdtm).(region).(mapflag)
# -   Note, this batch file was created
# -   during the running of "makeplotfiles01.f"
# -   above.
# -------------------------------------
chmod 777 gmtbat01.$argv[1].$argv[2].$argv[3].$argv[4]
./gmtbat01.$argv[1].$argv[2].$argv[3].$argv[4]
#
# -------------------------------------
#
echo 'doit2.bat -- END'
date
