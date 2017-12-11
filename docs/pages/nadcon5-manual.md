NADCON5.0 Reference Manual    {#nadcon5-manual}
==========================



Reference Manual for the NADCON5.0 Codebase

This document serves as a high level  reference for the filetypes and processing programs in NADCON5.0 .

A detailed Documentation of the Source Code is available in [Code Documentation](./modules.html) chapter. Where the primary build programs are described in \ref doers and the auxiliarly library functions and subroutines are described in \ref core



\tableofcontents


---
Input Files   {#sindatafiles}
===========

This Section Defines all the Files used by NADCON5.0 programs in the \ref core to generate the [GMT Batch Files](#sgmtbatscripts) and some of the [Output Files](#soutputfiles).



Control File    {#scontrolfile}
------------


The Control File describes the [In Files](#sinfiles) which contain data for a given transformation.

They are named

    control.OLD_DATUM.NEW_DATUM.REGION

Control Files exist in the folder `data/Control` . The existence of a control file means that the transformation is defined.

\note Conversely. If a control file does not exist, then the transformation is not defined


The Structure of the Control File is a list of valid input files with formatted header information.

We show this structure by using an example. 

    HEADER: Master File for creating a NADCON5 work file
    REGION: CONUS
    DATUM1: USSD
    DATUM2: NAD27
    REJMET: 10000
    NFILES: 49
    NADCON5.USSD.NAD27.AL.in
    NADCON5.USSD.NAD27.AR.in
    ...
    49 Total Files Listed
    ...
    

The Control file is used by \ref makework to generate the initial [Work File](#sworkfile)

\note It is critical that the header labels (`HEADER`, `REGION`, `DATUM1`, etc.)
are not changed, as the program \ref makework verifies each line against these strings.


**Parameter Details**

 - `HEADER` - Header line.  Can contain anything.
 - `REGION` - REGION Parameter from [Build Pipeline](#sdatapipeline).
    Must conform to the following list:
   - conus
   - alaska
   - prvi
   - hawaii
   - guamcnmi
   - as
   - pribilof
   - stlawrence
 - `DATUM1` - The older datum, chronologically.
   `OLD_DATUM` Parameter from [Build Pipeline](#sdatapipeline).
 - `DATUM2` - The newer datum, chronologically.
   `NEW_DATUM` Parameter from [Build Pipeline](#sdatapipeline).
 - `REJMET` The rejection criteria in meters.
   Basically if any latitude shift or longitude
   shift or horizontal shift exceeds this value
   (in absolute value), then all shifts for this
   point are set to zero (to avoid asterisks in
   the output file) but the whole line is labeled 
   with a triple reject criteria, effectively
   eliminating the pair from use.
 - `NFILES` -  The number of *.in files which connect
    the old and new datums in the region being
    addressed.


workedits File   {#sworkedits}
--------------

Used by \ref makework and located in \ref data/Work , the `workedits` is a database of rejected datum transformation points. That is, the `workedits` file provides a list of specific points in the [InFiles](#sinfiles) which should be rejected for various, manually identified, reasons.

The file format is fixed column delminted. The formatting is hardcoded in \ref makework with index records, the format each individual read is a complete string.  Strings are not "stripped" so left justification is required. 

The columns are:

    01- 10  : olddtm : lower case, left justified 
        11  : "|"    : vertcal spacer just for ease of reading
    12- 21  : newdtm : lower case, left justified 
        22  : "|"    : vertcal spacer just for ease of reading
    23- 32  : region : lower case, left justified (conus, alaska, hawaii, prvi, guamcnmi, as)
        33  : "|"    : vertcal spacer just for ease of reading
    34- 39  : PID    : upper case, left justified 
        40  : "|"    : vertcal spacer just for ease of reading
    41- 43  : rejects: Three digits (0's or 1's only) to reject lat, lon, eht, in that order.  '1' = reject, '0' = keep
        44  : "|"    : vertcal spacer just for ease of reading
    45-200  : reason : Upper/lower case, giving first your name then reason for the line to exist



Or, in other Words:

    olddtm   |newdtm    |region    |PID   |rej|Reason 
    lwr case |lwr case  |lwr case  |uprcas|0's|Give your name or initials first, then reason
    left     |left      |left      |6 char|or |Upper or lower case or both
    justified|justified |justified |      |1's|
    10 char  |10 char   |10 char   |      |   |


An Example:

    ussd      |nad27     |conus     |KG0640|110|DAS: USSD and NAD 27 coordinates are impossibly identical.
    ussd      |nad27     |conus     |DK3691|110|DAS: USSD and NAD 27 coordinates are impossibly identical.
    XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-XXXXXX-XXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      oldtm       newtm      region   pid   rej                                 comment













**Parameters:**

 - `oldtm` - Source Datum
 - `newtm` - Target Datum
 - `region` - Geographical Region (e.g. conus)
 - `pid` - Point ID
 - `rej` - Bit Field to reject lat, lon, eht
 - `Reason` - Comment Field


In Files      {#sinfiles}
--------
 
The In Files are located in \ref data/InFiles and contain the actual reference and transformation data for the construction of the NADCON5.0 dataset.

These files are created per state/territory and for every transformation vector.

The files are named per the convention

    NADCON5.DATUM1.DATUM2.STATE.in




The format of these files is a fixed format file. The format strings are defined in \ref makework

The first row of the file identifies the converted datums in comment header, with a Fortran Format specifier of

    100 format(27x,a15,26x,a15)

For example: (with format offsets and variable name indicated underneath)

                             US Standard Datum           |                  NAD 27         
    ---------------------------XXXXXXXXXXXXXXX--------------------------XXXXXXXXXXXXXXX
                                   nameh                                     namef


That is, 15 Character Strings with offsets `27` and `68` (`27+15+26`). 

\note Characters outside the defined 15 Character Region are simply ignored, in the above example, the String `US Standard Datum` would be truncated and trimed by Fortran to `Standard Datum`. However, this header line is not currently used for anything by \ref makework

The remaining rows define the actual datapoints, with a fortran format specifier of 

    101 format(a6,1x,a2,5x,a13,1x,a14,1x,a9,3x,a13,1x,a14,1x,a9)

For Example:

    AA5496 CA 085 N372639.93300 W1220955.92000       N/A | N372639.71836 W1220959.79579       N/A
    XXXXXX-XX-----XXXXXXXXXXXXX-XXXXXXXXXXXXXX-XXXXXXXXX---XXXXXXXXXXXXX-XXXXXXXXXXXXXX-XXXXXXXXX
    pid   state       clath         clonh        cehth       clatf           clonf         cehtf




**Parameters:**

 -  `pid` - Point ID (NGS Internal Unique Designator)
 -  `state` - State this point belongs to
 -  `clath` - Source Datum Lat. (Decimal Degrees with Cardinal Direction)
 -  `clonh` - Source Datum Lon. (Decimal Degrees with Cardinal Direction)
 -  `cehth` - Source Datum Height (Meters)
 -  `clatf` - Target Datum Lat.
 -  `clonf` - Target Datum Lon.
 -  `cehtf` - Target Datum Height


\note Partial Transformation points (e.g. no Height data) are specified by using `N/A` specifier to exclude the lat. , lon. , and/or height from the calculations.

The file is read until the last record indicated by an end of file (`EOF`), there is no footer or record counter.

grid.parameters    {#sgridparams}
---------------

The `grid.parameters` file lists the grid extents (W/E/N/S)  of each available region

This file is located in the folder `data/Data` and has a fixed format.

The format is defined hardcoded without a fortran format specified.

Records are matched by the region name, therefore any line which
does not start with a valid region name is a comment. The first
line of the file is a descriptive column header.



    Region       Grid North   Grid South    Grid West    Grid East 
    conus                50           24          235          294
    AAAAAAAAAA---XXXXXXXXXX---XXXXXXXXXX---XXXXXXXXXX---XXXXXXXXXX




XXXXXXXXXX---X
conus                50           24          235          294

---
GMT Batch Files     {#sgmtbatscript}
===============


\todo Write This Section



---
Output Files      {#soutputfiles}
============


Work File       {#sworkfile}
--------

The `workfile` is the first file created in the build pipeline. It serves as a local database of all the points and associated transformation data which is later used to construct images, grids, and other outputs.

The workfile is generated with the name

    work.DATUM1.DATUM2.REGION

And is placed (hardcoded) in the local `Work/` directory



The new file has the following format:


     Cols  Format Description
     1-  6   a6    PID
         7   1x    - blank -
     8-  9   a2    State
        10   a1    Reject code for missing latitude pair (blank for good)
        11   a1    Reject code for missing longitude pair (blank for good)
        12   a1    Reject code for missing ellip ht pair (blank for good)
        13   1x    - blank -
    14- 27 f14.10  Latitude (HARN), decimal degrees (-90 to +90)
        28   1x    - blank -
    29- 42 f14.10  Lonitude (HARN), decimal degrees (0 to 360)
        43   1x    - blank -
    44- 51   f8.3  Ellipsoid Height (HARN), meters
        52   1x    - blank -
    53- 61   f9.5  Delta Lat (FBN-HARN), arcseconds
        62   1x    - blank -
    63- 71   f9.5  Delta Lon (FBN-HARN), arcseconds
        72   1x    - blank -
    73- 81   f9.3  Delta Ell Ht (FBN-HARN), meters
        82   1x    - blank - 
    83- 91   f9.5  Delta Horizontal (absolute value), arcseconds
        92   1x    - blank -
    93-101   f9.5  Azimuth of Delta Horizontal (0-360), degrees
       102   1x    - blank - 
    103-111   f9.3  Delta Lat (FBN-HARN), meters
       112   1x    - blank -
    113-121   f9.3  Delta Lon (FBN-HARN), meters
       122   1x    - blank -
    123-131   f9.3  Delta Horizontal (absolute value), meters


Which is defined by fortran `format` Identifier

      104     format(a6,1x,a2,a1,a1,a1,1x,f14.10,1x,f14.10,1x,f8.3,1x,
     *    f9.5,1x,f9.5,1x,f9.3,1x,f9.5,1x,f9.5,1x,f9.3,1x,f9.3,1x,f9.3,
     *    1x,a10,1x,a10)




An example of a workfile record:

    BG3971 AL  1  30.3435430556 272.5144786111    0.000  -0.24400  -0.43700     0.000   0.50050 237.09789    -7.537   -11.649    13.874 ussd       nad27     
    XXXXXX-XXxXx-XXXXXXXXXXXXXX-XXXXXXXXXXXXXX-XXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX
    pid state|rej    xlath          xlonh        xehth    dlatsec   dlonsec    dehtm    dhorsec  azhor      dlatm     dlonm    dhorm      olddtm     newdtm