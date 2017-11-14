#! /bin/csh
# Batch file "doit3.bat"
# - Third of many which are used to process,
# - analyze, and ultimately create, all of
# - the files for NADCON v5.0
# - Requires that "doit2.bat" has been run.
# - What this batch file does:
#    1) Reads the coverage and vectors files capable of GMT plotting
#    2) Thins the data using a block-median filter
#    3) Creates new coverage/vector files for the thinned data
#    4) Creates new coverage/vector files for the dropped data
#    5) Creates a GMT batch file (gmtbat02) to grid everything
#    6) Runs gmtbat02 to rids the thinned data using tensions 0.0, 0.4 and 1.0, and creates a "d3" grid representing the tension-based error 
#    7) Creates a GMT batch file (gmtbat03) to plot files mentioned in #3 and #4 and #6
#    8) Runs gmtbat03 to create JPGs of coverage, vectors and color plots of grids
#
# Takes in 5 arguments:
# Argument 1 = lower case, old datum name
# Argument 2 = lower case, new datum name
# Argument 3 = lower case, region
# Argument 4 = grid spacing, arcseconds (integer - show 5 digits)
# Argument 5 = map resolution flag (integer, 0, 1 or 2)
#
# Example of how to execute this batch file:
#       %doit3.bat ussd nad27 conus 900 0 <return>
#
# Any integer arcseconds are allowed, provided
# they lie between 00001 and 99999
#
# The map resolution flag (argument 5) can be 0, 1 or 2.  It is set to
# "0" in the examples below, but any of these combinations
# would be valid if the "0" were replaced with a "1" or a "2"
# Note also that a map resolution flag of "2" is treated as
# a "1" for all regions except "conus".
# The map resolution flags are:
#    0 = 1 map for the whole region
#    1 = Map 0 plus zoomed in maps for specific sub-regions
#    2 = Map 0 and Maps 1 PLUS hyper-zoomed maps
#        (one for each state, in CONUS only, otherwise treated as a "1")
# 
# The only allowable combinations of old datum/new datum/region are:
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
#   For STPAUL:
#                 sp1897 sp1952 stpaul
#                 sp1952 nad83_1986 stpaul
#   For STGEORGE:
#                 sg1897 sg1952 stgeorge
#                 sg1952 nad83_1986 stgeorge
#   For STLAWRENCE:
#                 sl1952 nad83_1986 stlawrence
#
date
echo 'doit3.bat -- BEGIN'
echo 'doit3.bat: Number of Arguments Received          = '$#argv
echo 'doit3.bat: Old Datum                             = '$argv[1]
echo 'doit3.bat: New Datum                             = '$argv[2]
echo 'doit3.bat: Region                                = '$argv[3]
echo 'doit3.bat: Grid Spacing, Arcseconds              = '$argv[4]
echo 'doit3.bat: Map Resolution Flag                   = '$argv[5]
# --------------------------------------
# - RUN "mymedian5.f"
# -   Thins the coverage and vector data using a 
# -   block median filter on a certain grid size
# - 
# -   Note that this FORTRAN program
# -   creates both the GMT-ready data
# -   files to show both coverage and
# -   vectors of thinned and dropped data
# -   as well as the actual
# -   GMT-based batch files which will
# -   use those files and create plots.
# --------------------------------------

# Error correction - 2016 06 29 : mymedian5 only takes in *4* arguments, not 5

echo 'doit3.bat -- Running mymedian5 (thinning vectors)'
mymedian5 << !
$argv[1]
$argv[2]
$argv[3]
$argv[4]
!
# -------------------------------------
# - RUN gmtbat02.(olddtm).(newdtm).(region).(gridspacing)
# -   Note, this batch file was created
# -   during the running of "mymedian5.f"
# -   above.  Note also, no dependence upon "mapflag"
# 
# - New part of this batch file, as of 
# - 2015/10/27;
# - Subtract the T=0.0 transformation grid
# - from the T=1.0 transformation grid.
# - Then take the absolute value of that
# - difference, and finally scale that
# - grid by 1/1.6929.  Do this for 
# - all 5 possible transformation grids
# -------------------------------------
echo 'doit3.bat -- Running the GMT batch file to grid thinned vectors'
chmod 777 gmtbat02.$argv[1].$argv[2].$argv[3].$argv[4]
./gmtbat02.$argv[1].$argv[2].$argv[3].$argv[4]
# -------------------------------------
# - RUN "makeplotfiles02.f"
# -   This program will create a 3rd GMT batch
# -   file which will do the following:
# -   1)Color Plots of the dlat/dlon/deht grids
# -   2)B/W plots of thinned vectors that went into the grid
# -   3)B/W plots of dropped vectors that did not go into the grid
# -   4)B/W plots of thinned coverage of points that went into the grid
# -   5)B/W plots of dropped coverage of points that did not go into the grid
# -------------------------------------
echo 'doit3.bat -- Running makeplotfiles02'
makeplotfiles02 << !
$argv[1]
$argv[2]
$argv[3]
$argv[4]
$argv[5]
!
# -------------------------------------
# - RUN gmtbat03.(olddtm).(newdtm).(region).(gridspacing).(mapflag)
# -   Note, this batch file was created
# -   during the running of "makeplotfiles02.f"
# -   above.  It depends upon "mapflag" as its GMT calls
# -   actual make our maps.
# -------------------------------------
echo 'doit3.bat -- Running the GMT batch file to plot things'
chmod 777 gmtbat03.$argv[1].$argv[2].$argv[3].$argv[4].$argv[5]
./gmtbat03.$argv[1].$argv[2].$argv[3].$argv[4].$argv[5]
#
#
#
echo 'doit3.bat -- END'
date
