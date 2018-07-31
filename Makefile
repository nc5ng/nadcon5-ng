## NADCON5-NG Top Makefile
##
##
##

## Internal Variable showing relative location to top of project
_TOP_DIR := ./

################################################################################
################################################################################
################################################################################
##### Global Variables #########################################################
################################################################################
################################################################################

#############################################################################
#### Driving Parameters                                                
####
#### Variables passed as arguments and used to create filenames by
#### NADCON5 build process
####
#### These can be set externally by environment variable or by passing to make
####
##############################################################################

## OLD_DATUM : Source Datum (usually arg[1])
OLD_DATUM ?= ussd

## NEW_DATUM : Target Datum (usually arg[2])
NEW_DATUM ?= nad27

## REGION : Target Region (usually arg[3])
REGION ?= conus

## MAPLEVEL : Target Map Generation Level (arg[4] or arg[5] always last)
MAPLEVEL ?= 0

## GRIDSPACING : Target Map Grid in arcsec (arg[4]) 
GRIDSPACING ?= 900


##############################################################################

## BASE_OUT_NAME : Full Qualified Name of this build used for constructing output
##                 directories
BASE_OUT_NAME := $(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING).$(MAPLEVEL)

##
## Fixed Directories
##

## TOP_DIR : The Project Folder Root
TOP_DIR   ?= $(shell cd $(_TOP_DIR); pwd)

## DATA_ROOT_DIR : Where the project data files reside
DATA_ROOT_DIR ?= $(TOP_DIR)/data

## BUILD_DIR : root for build output
BUILD_DIR ?= $(TOP_DIR)/build

## BIN_DIR : Output place for binaries
BIN_DIR ?= $(BUILD_DIR)/bin

## OUT_DIR : Output place for constructed date
OUT_DIR ?= $(BUILD_DIR)/out.$(BASE_OUT_NAME)

## GMT_WRAPPER_DIR : Place where our wrappers for gmt scripts live
GMT_WRAP_DIR ?= $(TOP_DIR)/gmt_wrappers

## CODE_DIR : Root for our Source Distribution
CODE_DIR ?= $(TOP_DIR)/src
export PATH := $(PATH):$(BIN_DIR):$(GMT_WRAP_DIR)

## CONTROL_DIR : Control Data Location, and Copy Destination
CONTROL_DIR ?= $(DATA_ROOT_DIR)/Control
CONTROL_CPY_DIR = $(OUT_DIR)/Control

## DATA_DIR : Data Folder Location and Copy Destination
DATA_DIR ?= $(DATA_ROOT_DIR)/Data
DATA_CPY_DIR = $(OUT_DIR)/Data

## WORK_DIR : Work Folder Location and Copy Destination
WORK_DIR ?= $(DATA_ROOT_DIR)/Work
WORK_CPY_DIR = $(OUT_DIR)/Work

## MASK_DIR : Mask Folder Location and Copy Destination
MASKS_DIR ?= $(DATA_ROOT_DIR)/Masks
MASKS_CPY_DIR = $(OUT_DIR)/Masks

## IN_DIR : In Files Location and Copy Destination
IN_DIR ?= $(DATA_ROOT_DIR)/InFiles
IN_CPY_DIR = $(OUT_DIR)/InFiles

## GMTDEFAULTS : Default GMT Setting File and copy destination
GMTDEFAULTS ?= $(DATA_ROOT_DIR)/gmtdefaults4
GMTDEFAULTS_CPY = $(OUT_DIR)/.gmtdefaults4 $(TOP_DIR)/.gmtdefaults4

## CPY_TARETS : List Of All Copy Destination Targets
##              Used to construct the build environment
CPY_TARGETS = $(WORK_CPY_DIR) $(DATA_CPY_DIR) $(IN_CPY_DIR) $(CONTROL_CPY_DIR) $(GMTDEFAULTS_CPY) $(MASKS_CPY_DIR)


################################################################################
################################################################################
##### Build Commands/Binaries ##################################################
################################################################################
################################################################################


##
## Common System Commands
##
MKDIR ?= mkdir
RM ?= rm
ECHO ?= echo
CP ?= cp
CD ?= cd
DATE ?= date
TIMESTAMP := $(shell $(DATE) +"%Y%m%d-%H%M%S")

##
## Compiled Programs (src/)
##
MAKEWORK_BIN = $(BIN_DIR)/makework
MAKEPLOT1_BIN = $(BIN_DIR)/makeplotfiles01
MAKEPLOT2_BIN = $(BIN_DIR)/makeplotfiles02
MAKEPLOT3_BIN = $(BIN_DIR)/makeplotfiles03
MYMEDIAN_BIN = $(BIN_DIR)/mymedian5
MYRMS_BIN = $(BIN_DIR)/myrms
CHECKGRID_BIN = $(BIN_DIR)/checkgrid


## DEP_TARGETS : Binary Dependencies - files needed to run
DEP_TARGETS = $(MAKEWORK_BIN) $(MAKEPLOT1_BIN) $(MAKEPLOT2_BIN) $(MYMEDIAN_BIN) $(MAKEPLOT3_BIN) $(MYRMS_BIN) $(CHECKGRID_BIN)


## GNU COnvention Programs
INSTALL = install
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_PROGRAM = $(INSTALL)


################################################################################
################################################################################
##### TARGET VARIABLES        ##################################################
################################################################################
################################################################################

##
## Target Files (Files Created)
##

## WORK_OUT_FILE: Generated Work File
WORK_OUT_FILE = $(WORK_CPY_DIR)/work.$(OLD_DATUM).$(NEW_DATUM).$(REGION)

## BAT_FILE_1 : First GMT Command Bat File
BAT_FILE_1 = $(OUT_DIR)/gmtbat01.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(MAPLEVEL)

## BAT_FILE_2 : Second GMT Command Bat File
BAT_FILE_2 = $(OUT_DIR)/gmtbat02.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING)

## BAT_FILE_3 : Third GMT Command Bat File
BAT_FILE_3 = $(OUT_DIR)/gmtbat03.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING).$(MAPLEVEL)

## BAT_FILE_4 : Fourth GMT Command Bat File
BAT_FILE_4 = $(OUT_DIR)/gmtbat04.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING).$(MAPLEVEL)

## BAT_FILE_5 : Fifth GMT Command Bat File
BAT_FILE_5 = $(OUT_DIR)/gmtbat05.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING)

## BAT_FILE_6 : Sixth GMT Command Bat File
BAT_FILE_6 = $(OUT_DIR)/gmtbat06.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING).$(MAPLEVEL)

## OUT_TARGETS : List of all generated output files
OUT_TARGETS = $(WORK_OUT_FILE) $(BAT_FILE_1) $(BAT_FILE_2) $(BAT_FILE_3) $(BAT_FILE_4) $(BAT_FILE_5) $(BAT_FILE_6) 



#############################################################################
#### Installation Target Variables
####
#### variables conforming to GNU standards for the installation of binaries
#### libraries, manuals, and data into the correct locations 
####
##############################################################################


prefix = /usr/local

exec_prefix = $(prefix)

datarootdir = $(prefix)/share

datadir = $(datarootdir)

bindir = $(exec_prefix)/bin

libdir = $(exec_prefix)/libexec

mandir = $(datarootdir)/man

man1dir = $(mandir)/man1

man3dir = $(mandir)/man3

docdir = $(datarootdir)/doc/nadcon5-ng

htmldir = $(docdir)

pdfdir = $(docdir)

install_dirs = $(bindir) $(datadir) $(man1dir) $(man3dir)  $(docdir) $(libdir) 

GNU_DIR_TARGETS = $(addprefix $(DESTDIR), $(install_dirs))



################################################################################
###############################################################################
##### Target Definition       ##################################################
################################################################################
################################################################################

##
## Default - all
##
all: 


#############################################################################
#### Output Directory and Dependency Construction
####
#### Targets to construct the output directory to generate the datum conversion
#### data                 
####
#### These targets create directories and copy input data to the right
#### Locations
####
##############################################################################

##
## Copy to build environment
##
$(CONTROL_CPY_DIR): $(CONTROL_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(DATA_CPY_DIR): $(DATA_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(IN_CPY_DIR): $(IN_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(WORK_CPY_DIR): $(WORK_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(MASKS_CPY_DIR): $(MASKS_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(GMTDEFAULTS_CPY): $(GMTDEFAULTS) | $(OUT_DIR)
	$(CP) -r $< $@

##
## Output Folder
##
$(OUT_DIR):
	$(MKDIR) -p $@

##
## Dependencies - pass along to source makefile
##
$(DEP_TARGETS):
	$(MAKE) -C $(CODE_DIR) $@



#############################################################################
#### Output and Output Script Targets
####
#### These Targets generate and execute the intermediate gmt batch scripts                 
####
#### These targets create the same files as created in the upstream doit
#### batch scripts
####
##############################################################################


##
## DOIT_ARGS_3
##
## Only Used 3 Argument Input
## 
define DOIT_ARGS_3
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
endef
export DOIT_ARGS_3

##
## DOIT_ARGS_4_MAPLEVEL
##
## 4 Argument Input with MAPLEVEL
##
define DOIT_ARGS_4_MAPLEVEL
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
$(MAPLEVEL)
endef
export DOIT_ARGS_4_MAPLEVEL

##
## DOIT_ARGS_4_GRIDSPACING
##
## 4 Argument Input with GRIDSPACING
##
define DOIT_ARGS_4_GRIDSPACING
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
$(GRIDSPACING)
endef
export DOIT_ARGS_4_GRIDSPACING

##
## DOIT_ARGS_5
##
## Only Used 5 (All) Argument Inpu
##
define DOIT_ARGS_5
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
$(GRIDSPACING)
$(MAPLEVEL)
endef
export DOIT_ARGS_5



##
## Output File Targets
##
## Generate Intermediate Batch Script by calling compiled program
## and passing arguments using echo and linux pipes
##
##
## In this implementation each target also runs its generated script
## this behavior is not guaranteed to continue
## but the targets are standardized
## 
$(WORK_OUT_FILE): $(MAKEWORK_BIN) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR); \
	  echo "$$DOIT_ARGS_3" \
		| $(MAKEWORK_BIN))

$(BAT_FILE_1): $(MAKEPLOT1_BIN) $(WORK_OUT_FILE) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT_ARGS_4_MAPLEVEL" | $(MAKEPLOT1_BIN); \
	  chmod 777 $@; \
	  $@ ;\
	)
$(BAT_FILE_2): $(MYMEDIAN_BIN) $(BAT_FILE_1) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT_ARGS_4_GRIDSPACING" | $(MYMEDIAN_BIN); \
	  chmod 777 $@  ;\
	  $@ ;\
        )

$(BAT_FILE_3): $(MAKEPLOT2_BIN) $(BAT_FILE_2) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT_ARGS_5" | $(MAKEPLOT2_BIN); \
	  chmod 777 $@\
	  $@ ;\
        )

$(BAT_FILE_4): $(CHECKGRID_BIN) $(BAT_FILE_3) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT_ARGS_5" | $(CHECKGRID_BIN); \
	  chmod 777 $@  ;\
	  $@ ;\
        )

$(BAT_FILE_5): $(MYRMS_BIN) $(BAT_FILE_4) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT_ARGS_4_GRIDSPACING" | $(MYRMS_BIN); \
	  chmod 777 $@  ;\
	  $@ ;\
        )

$(BAT_FILE_6): $(MAKEPLOT3_BIN) $(BAT_FILE_5) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT_ARGS_5" | $(MAKEPLOT3_BIN); \
	  chmod 777 $@  ;\
	  $@ ;\
        )


#############################################################################
#### Convenience and Aggregate Targets
####
#### These Targets have fixed names and are either aliases or aggregates
#### of other targets
####
#### These Targets are declared PHONY and should not be used as a dependency
####
####
##############################################################################


##
## binaries
##
## create all binaries, recursive make call
##
binaries:
	$(MAKE) -C $(CODE_DIR) binaries

##
## libraries
##
## create all linkable libraries, recursive make call
##
libraries:
	$(MAKE) -C $(CODE_DIR) libraries

##
## dependencies
##
## create all dependencies, recursive make calls
##
dependencies: $(DEP_TARGETS)

##
## all
##
## build everything that is standard
## - binaries and output data
##
all: build-info binaries doit4

##
## doitX
##
## Step-by-step sequence as originally provided in upstream
## doitX.bat, now moved to old/doitX.bat
##
doit: $(WORK_OUT_FILE)
doit2: $(BAT_FILE_2)
doit3: $(BAT_FILE_4)
doit4: $(BAT_FILE_6)

##
## arch
##
## Create an archive of the data from current build
##
##
archive: $(BAT_FILE_6)
	( cd $(BUILD_DIR) ;\
	  tar -czvf nadcon5-$(TIMESTAMP).$(BASE_OUT_NAME).tgz out.$(BASE_OUT_NAME) ;\
	)



##
## gmtbatXX
##
## Convenience targets to generate all the intermediate scripts step by step
## allows debugging,
##
## However, script is currently executed always when built, note that this
## behavior may change
##
workfile: $(WORK_OUT_FILE)

gmtbat01: $(BAT_FILE_1)

gmtbat02: $(BAT_FILE_2)

gmtbat03: $(BAT_FILE_3)

gmtbat04: $(BAT_FILE_4)

gmtbat05: $(BAT_FILE_5)

gmtbat06: $(BAT_FILE_6)



.PHONY: src all doit doit2 doit3 doit4 gmtbat01 gmtbat02 gmtbat03 gmtbat04 gmtbat05 gmtbat06  arch workfile


#############################################################################
#### Python Targets
####
#### Targets related to building, testing, or developing the python extensions
####                  
####
####
##############################################################################



##
## pybuild
##
## Pre-Compile the python wrapper objects
##
pybuild:
	./setup.py build

##
## pydevelop
##
## deploy nc5ng in setup.py develop mode (link and not copy0
##
pydevelop: pybuild
	./setup.py develop

##
## pyundevelop
##
## undeploy nc5ng
##
pyundevelop:
	./setup.py develop -u

## 
## pyinstall
##
## Python install to site-packages
##
pyinstall:
	./setup.py install

.PHONY: pybuild pydevelop pyinstall


#############################################################################
#### Clean Up Targets
####
#### Targets related deleting created files and resetting the state of the
#### repository
####
##############################################################################


##
## clean
##
## cleanup output directory for this build only!
##
clean:
	$(RM) -rf $(OUT_DIR)
	-$(RM) -rf $(BUILD_DIR)/install

##
## mrclean
##
## cleanup everything
##
mrclean:
	$(RM) -rf $(BUILD_DIR)
distclean: mrclean

##
## pyclean
##
## cleanup python stuff that setup.py can't
##
pyclean:
	$(RM) -rf nc5ng/__pycache__
	$(RM) -rf nc5ng/core/__pycache__
	$(RM) -rf nc5ng/core/*.f
	$(RM) -rf nc5ng/core/*.c
	$(RM) -rf nc5ng/core/*.so
	$(RM) -rf dist/
	$(RM) -rf build/src.*
	$(RM) -rf build/lib.*
	$(RM) -rf build/temp.*
	$(RM) -rf ./*.egg-info
	./setup.py develop -u
	./setup.py clean	


.PHONY: clean mrclean pyclean distclean


#############################################################################
#### Documentation Targets
####
#### Targets related to building and publishing documentation
####                  
####
####
##############################################################################

docs:
	$(MAKE) -C docs publish_docs

all_docs:
	$(MAKE) -C docs all

pdf_docs:
	$(MAKE) -C docs latex_docs
man_docs:
	$(MAKE) -C docs bin_manual
	$(MAKE) -C docs lib_manual

.PHONY: docs all_docs pdf_docs man_docs




#############################################################################
#### GNU Convention Targets
####
#### Installation and other targets that are commonly used by GNU tools
####
#### They are "standardized" by convention
####
#### https://www.gnu.org/prep/standards/html_node/Standard-Targets.html
####
####
##############################################################################

$(GNU_DIR_TARGETS):
	$(MKDIR) -p $@

install: BINS =  xyz2b subtrc gabs gscale b2xyz gsqr gsqrt addem regrd2 convlv decimate
install: binaries $(GNU_DIR_TARGETS) man_docs
	$(PRE_INSTALL)
	$(NORMAL_INSTALL)
	$(INSTALL_PROGRAM) $(addprefix $(BIN_DIR)/, $(BINS))  $(DESTDIR)$(bindir)
	-$(INSTALL_DATA)  $(addprefix $(BUILD_DIR)/docs/man/man1/, $(addsuffix .1 , $(BINS)))  $(DESTDIR)$(man1dir)
	#-$(INSTALL_DATA)  $(addprefix $(BUILD_DIR)/docs/man/man3/, $(addsuffix .3 , $(BINS))) $(DESTDIR)$(man3dir)
	$(POST_INSTALL)



install-pdf: pdf
	$(PRE_INSTALL)
	$(NORMAL_INSTALL)
	$(INSTALL_DATA) $(BUILD_DIR)/docs/latex/refman.pdf $(DESTDIR)$(pdfdir)
pdf: latex_docs

install-html: html
	$(PRE_INSTALL)
	$(NORMAL_INSTALL)
	$(INSTALL_DATA) $(BUILD_DIR)/docs/html/* $(DESTDIR)$(htmldir)
html: docs

uninstall: BINS =  xyz2b subtrc gabs gscale b2xyz gsqr gsqrt addem regrd2 convlv decimate
uninstall:
	$(PRE_UNINSTALL)
	$(NORMAL_UNINSTALL)
	$(RM) $(addprefix $(DESTDIR)$(bindir)/, $(BINS))
	-$(RM)  $(addprefix $(DESTDIR)$(man1dir), $(addsuffix .1 , $(BINS)))  
	#-$(INSTALL_DATA)  $(addprefix $(DESTDIR)$(man3dir), $(addsuffix .3 , $(BINS))) 

.PHONY: install-html install-pdf install html pdf uninstall 





#############################################################################
#### Informational targets
####
#### Targets which print various debug or other information about the build
#### it is possible that some targets create informational files
####                  
####
####
##############################################################################

help:     ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)


build-info:
	@$(ECHO) "==========================="
	@$(ECHO) "NADCON5 Top Level Make File"
	@$(ECHO) "---------------------------"
	@$(ECHO) "CODE_DIR            = $(CODE_DIR)"
	@$(ECHO) "OUT_DIR             = $(OUT_DIR)"
	@$(ECHO) "BUILD_DIR           = $(BUILD_DIR)"
	@$(ECHO) "IN_DIR              = $(IN_DIR)"
	@$(ECHO) "OLD_DATUM           = $(OLD_DATUM)"
	@$(ECHO) "NEW_DATUM           = $(NEW_DATUM)"
	@$(ECHO) "REGION              = $(REGION)"
	@$(ECHO) "MAPLEVEL            = $(MAPLEVEL)"
	@$(ECHO) "WORK_OUT_FILE       = $(WORK_OUT_FILE)"
	@$(ECHO) "BAT_FILE_1          = $(BAT_FILE_1)"
	@$(ECHO) "MAKEWORK_BIN        = $(MAKEWORK_BIN)"
	@$(ECHO) "CONTROL_DIR         = $(CONTROL_DIR)"
	@$(ECHO) "DATA_DIR            = $(DATA_DIR)"
	@$(ECHO) "---------------------------"





.phony: build-info help


## */
