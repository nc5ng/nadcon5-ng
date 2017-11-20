Build System Documentation  {#makereadme}
==========================



`NADCON5-ng` has been updated from the original development to use GNU Make as the target build system



## Makefile Primer

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



## Project Build System


### Code Compilation

Code Compilation occurs in the context of the Source Directory.

