Build Manual  {#makereadme}
============



`NADCON5-ng` has been updated from the original development to use GNU Make as the target build system

\tableofcontents

# NADCON5.0 Data Pipeline         {#sdatapipe}


The toplevel \ref Makefile defines the rules to construct the NADCON5-ng dataset in the traditional NADCON5.0 fashion, using the same fortran programs, simply managed by Make

To generate the target NADCON data, from the command line

     $ cd nadcon5-ng
     $ make OLD_DATUM=ussd NEW_DATUM=nad27 REGION=conus GRIDSPACING=900 MAPLEVEL=0
     $ cd build/out.ussd.nad27.conus.900.0

Where the variables are specified and indicate

 - `OLD_DATUM` = Source Datum
 - `NEW_DATUM` = Target Datum
 - `REGION`    = Geographic Region to Compute
 - `GRIDSPACING` = The Grid Spacing in arcsec
 - `MAPLEVEL` = The zoom level of images to generate (`0,1,2`)

For more Information on the meaning of thes parameter see the documentation of functions in: \ref doers

\note Conversion between datums is restricted in a strictly one-step chronoligical direction. Not all Regions are possible with all conversions


## Step-by-step {#ss-step-by-step}

With no arguments Make will execute the default target, in this case `all`, which is defined to run the data pipeline.

Additional targets are defined to step through the data pipeline.

These targets approximately mimic the steps taken in the upstream build scritpts `doitX.bat`

    $ make doit
    $ make doit2
    $ make doit3
    $ make doit4


, will execute the build system in the same step-by step fashion as the upstream batch files. Generating a portion of the output each time.

These `doit` targets use programs defined in \ref doers to generated Generic Mapping Tools (GMT) batch files in the output directory. Additionally, as a first step a "work" file is constructed (see \ref makework )

Dataset construction can be done by stepping through these GMT scripts

    $ make workfile
    $ make gmtbat01
    $ make gmtbat02
    ...
    $ make gmtbat07

Allowing one to manually execute the batch file in the build directory

\note These scripts call GMT functions without explicitly calling `gmt` which may not work on all distributions, shell wrappers for gmt are provided in `gmt_wrappers/`  and can be added to path for convenience.

## Data Archive {#ss-data-archive}

An archive file, with a unix timestamp is constructed with the `archive` target

That is,
 
    $ make archive

This creates a file

     build/nadcon5-TIMESTAMP.OLD_DATUM.NEW_DATUM.REGION.GRIDSPACING.MAPLEVEL.tgz


## Output Files {#ss-output-files}

Output files are generated in the folder

     build/out.OLD_DATUM.NEW_DATUM.REGION.GRIDSPACING.MAPLEVEL

# Source Compilation {#s-source-compile}

The required files are compiled by the Data Pipeline automatically, but if you need to do this manually it can be done from the `src/` directory

    $ cd nadcon5-ng/src
    $ make


Binaries are placed in the directory

    build/bin


# Documentation Compilation {#s-docs-compile}

This page, as well as all the documentation on this page is also generated using Make

## HTML {#ss-html-docs}

To produce html documentation suitable for browsing or hosting

    $ cd nadcon5-ng/docs
    $ make full_docs

Additionally, other output forms are available

All forms of documentation can be compiled at once by omitting the target

    $ cd nadcon5-ng/docs
    $ make

## Latex and PDF: {#ss-latex-docs}
Latex sources and compiled PDF can
be created by calling (in the docs folder)

    $ make latex_docs

## manpage {#ss-man-docs}

*NIX style manual pages, suitable for use by the `man` command can be generated with the `bin_manual` and `lib_manual` targets

Generate manual pages for the Compiled Programs (`man.1`)

    $ make bin_manual


Generate Documentation for subroutines and functions

    $ make lib_manual




# Dependencies {#s-deps}


 - Oracle Fortran
 - Generic Mapping Tools `GMT`
 - GNU Make
 - Doxygen
 - 

# Makefile Primer {#s-make-primer}

**Note:** This primer has been adapted from other sources and is not specific to `NADCON5-ng`

Makefiles define **rules** to make **targets**. 

A Makefile may look something like this.


  	
	# Target to Compile a single file.
	#  The first line defines the target
	#  further lines define the commands
	#  that are run 
	object.o: 
	  cc -o object.o object.c

	# Target to link executable with external releaselib.
	#  object.o is a dependency of release_exec
	release_exec: object.o
	  ld  -r -o release_exec  releaselib object.o 

	# Convenience Target 
	release: release_exec

	# Since "release" does not actually produce a file 
	#  this is required boiler plate
	.PHONY: release


This Makefile is actually equivalent to a simple compiler one-liner. 


    cc -o release_exec -lreleaselib object.c


However, it already provides power behind the scenes. 

For example Calling 


    make release


Will not recompile the executable if `object.c` has not been changed. 

The real power of `Make` comes from "Pattern Rules" constructed using [Automatic variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html) 
and [Pattern Matching](https://www.gnu.org/software/make/manual/html_node/Pattern-Match.html#Pattern-Match) which result in a more general rule. 


	# The target name is special
	#  and the variable $@ 
	#  refers to the target name 
	test.o:
      cc -o $@ object.c
	
	# The dependency name is special
	#  and the variable $< refers to the 
	#  first (only) dependency
	better_test.o: object.c
      cc -o $@ $<
	
	# Multiple Dependencies
	#  can be refered to by the variable
	#  $^
	other_test.a: test.o better_test.o
      ld -r -o $@ $^
	
	# Pattern matching makes general rules
	#  The following  rule compiles all .c files to .o files
	%.o:%.c
      cc -o $@ $<
	
	# PHONY rules can be used to build multiple
	#  dependencies
	build_some_libs: pattern_lib.o \
                     pattern_lib2.o \
	                 pattern_lib3.o \
	                 other_test.a
	.PHONY: build_all_libs



By default `Make` assumes that the target is a real file that is created, and will track the state of 
dependency based on the file and if it exists. 

As such when dealing with build directories, a target must be specified with its path for make to track its status.

The `.PHONY` target is a special target that indicates that
it should not be tracked and will be rebuilt every time, often this is good for things like printing debug output
or a convenience target that builds multiple targets (e.g. `all`). 


In our Makefiles you will see things like the following, this example is our default rule for building fortran programs

    $(BIN_DIR)/%:$(notdir %).f | $(BIN_DIR)
      $(FC) $(FFLAGS) $< -o $@



In this case, `FC`, `FFLAGS`, are variables define in our Makefile which can be overridden at the command line, this is described below. `BIN_DIR` is a Makefile Variable  and is the directory where binary programs artifacts are to be placed after building.

This default rule maps all programs like `/path/to/build/bin/myprogram` to compile from the file `myprogram.f` using the Fortran Compile `FC` and the compilation flags `FFLAGS`




