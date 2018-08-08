# NADCON5-ng

Tweaks and Updates to US National Geodetic Survey `NADCON5` Tool. Used to convert Geodetic Data between various US Datums, including: US Standard Datum (`USSD`) used  prior to `NAD27`, North American Datum of 1927 (`NAD27`), and various realizations of the North American Datum of 1983 `NAD83`

Build the dataset with one command

    make


[Link To Doxygen Documentation Website](http://docs.nc5ng.org/latest)

The intent of this fork is to adapt the existing tool to be accessible to more users, developers, and data scientists.Through the implementation of additional interfaces and workflows on top of existing NADCON5 Code Base. 

> **NOTE**: This project is a personal project that is not in any way affiliated with the US Government, NOAA, or the National Geodetic Survey

**Derivative Work:** Additions and Modifications to NADCON5 code, Documentationfiles, the `nc5ng-core` python package  are released explicitly under Public Domain where applicable, with no rights reserved in perpetuity. However, certain published outputs associated with this project, e.g. builds and compiled documentation is released with CC-BY 4.0 License  Please see: [Licensing](#s-license)



## Project Status

This project is new, feature requests and development will be driven through issues filed in github.

At the time of this README was update, the following was true

1. The existing processing pipeline has been offloaded to GNU Make to eliminate in-source builds
2. Doxygen was strapped on top of the project to create documentation , source files were modified, superficially, to export documentation in doxygen 
3. Documentation and website live, hosted on `github-pages`, at url: https://docs.nc5ng.org/latest
4. Initial Framework for a python glue library, with several functioning submodules and functions
  - install with `pip install nc5ng`


On the Immediate Roadmap

1. Remove dependence on proprietary Oracle Fortran `f95`
  - Requires mapping build options to `gfortran` and correcting where necessary
  - Biggest issue is compiler specific handling of I/O and certain convenience extensions, not the math
2. Take over the "batch generator" programs (e.g. makework() , makeplotfiles01 , etc.) so that individual conversions can be done as needed, through Make or otherwise
3. Create an `install` target - install existing fortran programs onto system as a distribution
  - Some tweaks to programs to make this doable (path dependencies) 
  - Pruning of applications to core install package


---
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
    OLD_DATUM=ussd NEW_DATUM=nad27 make
    # Third Option
    make OLD_DATUM=ussd NEW_DATUM=nad27

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



## Licensing {#s-license}

As a work of the US Government, the original NADCON5 Source Code and Data is considered in the public domain within the United States of America. Elsewhere, the US Government reserves the right to copyright and license this material. The license status internationally is not clear to the authors of `NADCON5-ng` and the authors cannot offer advise in this regard.

For new contributions, including:

 - Modifications to National Geodetic Survey  `NADCON5.0` source code and data by `nc5ng` contributors
 - Makefile and build system
 - Documentation files and documentation embedded in source files
 - `nc5ng-core` python packages `nc5ng.core` and `nc5ng.nc5data`
 - Any auxiliary files produced by `nc5ng` contributors

Are released explicitly into the public domain in the United States and internationally as much as is allowed by law. The license file [LICENSE](LICENSE) states the terms of the Creative-Commons CC0 public domain disclaimer.

[![Creative Commons License](https://licensebuttons.net/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)


 However, in those jurisdictions where public domain is not recognized, or where the US Government asserts license rights or collects royalties from the source material, the fallback MIT License should be used instead. A copy is provided in the file [LICENSE-MIT](LICENSE-MIT)


Compiled assets are occasionally released in association with this source code, including:

  - HTML and PDF documentation and webpages
  - Printed documentation provided by `nc5ng.org` 
  - Packaged redistributable releases hosted by `nc5ng.org`
  - Compiled output data, grids, and images associated with this project
  - Any other websites or project pages related to this project hosted by `nc5ng.org` or its contributors
  - Any logos, brandings, or trademarks that may be applied to or distributed with compiled assets or public services hosting these files.

All Compiled  assets are provided with rights reserved under a Creative Commons Attribution 4.0 International License, unless a different license is provided in the work itself [![Creative Commons License](https://i.creativecommons.org/l/by/4.0/88x31.png)](http://creativecommons.org/licenses/by/4.0/)
