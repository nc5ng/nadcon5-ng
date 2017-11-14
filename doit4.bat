#! /bin/csh
# Batch file "doit4.bat"
# - Fourth of many which are used to process,
# - analyze, and ultimately create, all of
# - the files for NADCON v5.0
# - Requires that "doit.bat" , "doit2.bat" and
# - "doit3.bat" has been run.
#
# - What this batch file does:
# Takes in 5 arguments:
# Argument 1 = lower case, old datum name
# Argument 2 = lower case, new datum name
# Argument 3 = lower case, region
# Argument 4 = integer, flag for what detailed-level of maps to make
# Argument 5 = map resolution flag (integer, 0, 1 or 2)
#
# Example of how to execute this batch file:
#       %doit4.bat ussd nad27 conus 900 0 <return>
#
# Runs "checkgrid.f" which:
#    1) Reads in the grids of dlat/dlon/deht that were
#       created by gridding the thinned dlat/dlon/deht vectors
#    2) Reads in the thinned dlat/dlon/deht vectors
#    3) Reads in the dropped dlat/dlon/deht vectors
#    4) Interpolates from the grids and compares to the vectors,
#       generating DDlat/DDlon/DDeht vectors
#    5) Compiles statistics of DDlat/DDlon/DDeht for:
#       a) thinned-versus-gridded
#       b) dropped-versus-gridded
#       c) all-versus-gridded
#    6) Writes out three vector files of DDlat/DDlon/DDeht for
#       all input vectors
#
# The only allowable combinations are:
#  (The "*" represents "agridsec" and must be the
#  same value used when running "doit3.bat")
#
#   For CONUS:
#                 ussd nad27 conus *
#                 nad27 nad83_1986 conus *
#                 nad83_1986 nad83_harn conus *
#                 nad83_harn nad83_fbn conus *
#                 nad83_fbn nad83_2007 conus *
#                 nad83_2007 nad83_2011 conus *
#   For ALASKA:
#                 nad27 nad83_1986 alaska *
#                 nad83_1986 nad83_1992 alaska *
#                 nad83_1992 nad83_2007 alaska *
#                 nad83_2007 nad83_2011 alaska *
#   For HAWAII:
#                 ohd nad83_1986 hawaii *
#                 nad83_1986 nad83_1993 hawaii *
#                 nad83_1993 nad83_pa11 hawaii *
#   For PRVI:
#                 nad27 nad83_1986 prvi *
#                 nad83_1986 nad83_1993 prvi * 
#                 nad83_1993 nad83_1997 prvi *
#                 nad83_1997 nad83_2002 prvi *
#                 nad83_2002 nad83_2007 prvi *
#                 nad83_2007 nad83_2011 prvi *
#   For GUAMCNMI:
#                 gu63 nad83_1993 guamcnmi *
#                 nad83_1993 nad83_2002 guamcnmi *
#                 nad83_2002 nad83_ma11 guamcnmi *
#   For AS:
#                 as62 nad83_1993 as *
#                 nad83_1993 nad83_2002 as *
#                 nad83_2002 nad83_pa11 as *
#
#  For STPAUL:
#                 sp1897 sp1952 stpaul *
#                 sp1952 nad83_1986 stpaul *
#  For STGEORGE:
#                 sg1897 sg1952 stgeorge *
#                 sg1952 nad83_1986 stgeorge *
#  For STLAWRENCE:
#                 sl1952 nad83_1986 stlawrence *


date
echo 'doit4.bat -- BEGIN'
echo 'doit4.bat: Number of Arguments Received          = '$#argv
echo 'doit4.bat: Old Datum                             = '$argv[1]
echo 'doit4.bat: New Datum                             = '$argv[2]
echo 'doit4.bat: Region                                = '$argv[3]
echo 'doit4.bat: Grid Spacing, Arcseconds              = '$argv[4]
echo 'doit4.bat: Map Resolution Flag                   = '$argv[5]
# --------------------------------------
# - RUN "checkgrid.f"
# -  1) Compares our original vectors against
# -     grids created from only thinned vectors.
# -     Statistics are generated for the comparison
# -     against Thinned, Dropped and All vectors.
# -  2) Generates three new differential vector files (one for
# -     lat, one for lon, one for eht) which
# -     have "gridded minus original" vector *differences*
# -     though the format is "vector format" so it can
# -     be plotted if we wanted.
# -  3) Generates a GMT batch file to plot the
# -     differential vector files (not coverage,
# -     as that is unchanged from previous coverage
# -     plots.  Also, we will plot three different
# -     sets:  thinned, dropped, all.
# --------------------------------------
checkgrid << !
$argv[1]
$argv[2]
$argv[3]
$argv[4]
$argv[5]
!
# -------------------------------------
# - RUN gmtbat04.(olddtm).(newdtm).(region).(gridspacing)
# -   Note, this batch file was created
# -   during the running of "checkgrid.f", above.
# -------------------------------------
echo 'doit4.bat -- Running the GMT batch file to plot differential vectors'
chmod 777 gmtbat04.$argv[1].$argv[2].$argv[3].$argv[4].$argv[5]
./gmtbat04.$argv[1].$argv[2].$argv[3].$argv[4].$argv[5]
# --------------------------------------
# - RUN "myrms.f"
# -   Takes the "gridded minus original" vector
# -   data as created by "checkgrid.f", and
# -   tallies the RMS difference in each cell.
# -   This is NOT a "median filter" at all, though
# -   much of the logic is the same.  It actually
# -   just computes the RMS in a cell.
# -   This data will be used to create a grid
# -   of accuracies for the transformation.
# -
# -   Note that this FORTRAN program
# -   creates both the GMT-ready data
# -   files to show the RMS vector differences
# -   as well as the actual
# -   GMT-based batch file which will
# -   use those files and create plots.
# --------------------------------------
# - Corrected 2016 07 01 -- myrms only takes in 4 arguments
echo 'doit4.bat -- Running myrms (RMSing vector diffs)'
myrms << !
$argv[1]
$argv[2]
$argv[3]
$argv[4]
!
# -------------------------------------
# - RUN gmtbat05.(olddtm).(newdtm).(region).(gridspacing)
# -   Note, this batch file was created
# -   during the running of "myrms.f", above
# - NOTE:  This batch file ONLY grids things...no plots
# -        are made.  Thus no dependence upon "mapflag"
# -------------------------------------
echo 'doit4.bat -- Running the GMT batch file to grid RMSs of differential vectors'
chmod 777 gmtbat05.$argv[1].$argv[2].$argv[3].$argv[4]
./gmtbat05.$argv[1].$argv[2].$argv[3].$argv[4]
# - At this point I should insert a program to combine the
# - RMS grid and the "method noise" (T0vsT1) grid, so that
# - I can plot them in makeplotfiles03.f, unless I want to
# - just do that IN that program.... 
# -------------------------------------
# - RUN "makeplotfiles03.f"
# -   This program will create a 6th GMT batch
# -   file which will do the following:
# -   1)Color Plots of the rddlat/rddlon/rddeht grids (rdd = RMS of differential vectors)
# -   2)B/W plots of RMS'd differential vectors that went into the grid
# -   3)B/W plots of coverage of RMS'd differential vectors that went into the grid
# -------------------------------------
echo 'doit4.bat -- Running makeplotfiles03'
makeplotfiles03 << !
$argv[1]
$argv[2]
$argv[3]
$argv[4]
$argv[5]
!
# -------------------------------------
# - RUN gmtbat06.(olddtm).(newdtm).(region).(gridspacing).(mapflag)
# -   Note, this batch file was created
# -   during the running of "makeplotfiles03.f"
# -   above.  It depends upon "mapflag" as its GMT calls
# -   actual make our maps.
# -------------------------------------
echo 'doit4.bat -- Running the GMT batch file to plot things'
chmod 777 gmtbat06.$argv[1].$argv[2].$argv[3].$argv[4].$argv[5]
./gmtbat06.$argv[1].$argv[2].$argv[3].$argv[4].$argv[5]
#
#
#
echo 'doit4.bat -- END'
date
