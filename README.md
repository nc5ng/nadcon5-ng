# NADCON5-ng

Tweaks and Updates to US National Geodetic Survey `NADCON5` Tool. Used to convert Geodetic Data between various US Datums, including: US Standard Datum (`USSD`) used  prior to `NAD27`, North American Datum of 1927 (`NAD27`(, and various realizations of the North American Datum of 1983 `NAD83` 

The intent of this project is to adapt the existing tool to be accessible to more users,  useable as a command line utility, and eventually an element in a Continuous Data Integration Pipeline using Docker or other container environment. 

> **NOTE**: This project is a personal project that is not in any way affiliated with the US Government, NOAA, or the National Geodetic Survey

**Derivative Work:** Additions and Modifications to this software are released explicitly under Public Domain. 

As a product of the United States Government NADCON5 is considered a work under public domain.

## What is NADCON5?

[NGS NADCON5 Front Page](https://www.ngs.noaa.gov/NADCON5/index.shtml)

[NGS NADCON5 Website](https://beta.ngs.noaa.gov/gtkweb)

The Following Information is Reproduced from the NADCON5 Webpage from NGS

### What is NADCON 5.0?

NADCON 5.0 performs three-dimensional (latitude, longitude, ellipsoid height) coordinate transformations for a wide range of datums and regions in the National Spatial Reference System. NADCON 5.0 is the replacement for all previous versions of the following tools:

- NADCON, which transformed coordinates between the North American Datum of 1927 (NAD 27) and early realizations of the North American Datum of 1983 (NAD 83), and
- GEOCON, which transformed coordinates between various latter realizations of NAD 83.

### How do I use NADCON 5.0?

NADCON 5.0 is functionally implemented in NGS’s Coordinate Conversion and Transformation Tool. Unlike earlier versions of NADCON and GEOCON, NADCON 5.0 is not a stand-alone tool.

Visit the NADCON 5.0 Digital Archive to access raw transformation data that make up NADCON 5.0 (e.g., grids, images, software).

### How can I learn more about NADCON 5.0?
[NOAA Technical Report NOS NGS 63 (PDF, 17 MB)](https://www.ngs.noaa.gov/PUBS_LIB/NOAA_TR_NOS_NGS_63.pdf) provides detailed information on NADCON 5.0, and the digital archive includes plots and data.




## Building `NADCON5-ng` 

Build simply with

    make

Which will build the initial tools and generate conversion output and images for the configured conversion 


### Dependencies

1. [Generic Mapping Tools](http://gmt.soest.hawaii.edu/) `**GMT**`
   - Tested with 5.2.1
   - Install on Debian Systems with `sudo apt-get install gmt gmt-dcw gmt-gshhg`
   - `PATH` Aliases must be provided for the following `GMT` modules `gmtset` `grd2xyz` `grdimage` `ps2raster` `psscale` `psxy` `surface` `grdcontour`  `makecpt`   `pscoast` `pstext` `xyz2grd` (see: [gmt_wrappers/](gmt_wrappers/))

2. Oracle Fortran (`f95`) available for free (as in money, but not freedom) in [Oracle Developer Studio](https://www.oracle.com/tools/developerstudio/index.html)
   - Set `f95` path with environment variable `FC` (Per [GNU Conventions](https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html))

3. GNU Make



### Build Options

The configurable options for the build steps are

1. `OLD_DATUM`   - source datum (default: `ussd`)
2. `NEW_DATUM`   - target datum (default: `nad27`)
3. `REGION`      - geographical region (default: `conus`)
4. `GRIDSPACING` - Grid Spacing in arc-seconds (default: `900`)
5. `MAP_LEVEL`   - Map Resolution Flag (default: `0`)

These can be set as environment variables or directly on the command line

    export OLD_DATUM=nad27
    export NEW_DATUM=nad83
    make
    # Equivalent
    OLD_DATUM=nad27 NEW_DATAUM=nad83 make

### Targets

The Upstream build sequence can be simulated by using the targets `doit` `doit2` `doit3` `doit4`, as in

    make doit
    make doit2
    make doit3
    make doit4

This can be useful to compare results from the vanilla `NADCON`

Additionally, for the intermediate scripts `gmtbat0X` convenience targets are provided to manually step through the asset compilation

    make gmtbat01
    make gmtbat02
    make gmtbat03
    make gmtbat04
    make gmtbat05
    make gmtbat06
    make gmtbat07


Cleaning up is easy

Delete only the current configured build 

    make clean

Delete all compiled output (deletes build directory)

    make mrclean


