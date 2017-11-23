# NADCON5-NG Makefile
#
# Adapted from CSH Script `compileCode` in the original distribution
# 
#

_TOP_DIR := ../

################################################################################
################################################################################
################################################################################
##### Global Variables #########################################################
################################################################################
################################################################################


##
## Fixed Directories
##
TOP_DIR   ?= $(shell cd $(_TOP_DIR); pwd)
DATA_DIR  ?= $(TOP_DIR)/data

##
## Build Output Directories
##
BUILD_DIR ?= $(TOP_DIR)/build
LIB_DIR   ?= $(BUILD_DIR)/lib
BIN_DIR   ?= $(BUILD_DIR)/bin
MASK_DIR  ?= $(BIN_DIR)/masks


###
### Source Directories
###
CORE_LIB_SRC_DIR ?= $(shell cd Subs; pwd)
CORE_BIN_SRC_DIR ?= $(shell cd BinSource; pwd)
DOER_BIN_SRC_DIR ?= $(shell pwd)

###
### NC5NG Python Library
###
NC5NG_DIR ?= $(TOP_DIR)/nc5ng
NC5NG_CORE_DIR ?= $(NC5NG_DIR)/core




################################################################################
################################################################################
##### Build Commands/Binaries ##################################################
################################################################################
################################################################################




###
### Basic Shell Utilities
###
ECHO  ?= echo
MKDIR ?= mkdir
RM    ?= rm

###
### Orace Fortran
###
ORACLE_STUDIO_BIN ?= $(TOP_DIR)/../OracleDeveloperStudio12.6-linux-x86-bin/developerstudio12.6/bin

###
### Fortran Compiler
###
FC = $(ORACLE_STUDIO_BIN)/f95

###
### Existing FF Flags
###
FFLAGS ?= -O5 -libmil -fsimple=0 -dalign -xlibmopt -ftrap=%none -xvector=yes -xprefetch=yes  -reduction -xloopinfo -s -stackvar -m64

###
### Fortran 2 Python Wrapper (courtesy of numpy)
###
F2PY = f2py
F2PY_OPTS ?= #"--f90exec=$(FC) --f90flags=$(FFLAGS)"




################################################################################
################################################################################
##### TARGET VARIABLES        ##################################################
################################################################################
################################################################################



###
### Default Search Path (GNU Make)
###
VPATH += BinSource $(DATA_DIR)/Masks Subs

#############################################################################
#### Doer Programs Target Variables                                                
####
#### Variables for Targets that run the doer scripts
####
#### Consists of Programs under the root src directory
####
#### Doer Binaries are put in Bin Directory (Compiled Complete Programs)
####
####
##############################################################################


## DOER_SRC : list of Fortran files for our "doer" scripts
DOER_SRC = checkgrid.f makeplotfiles01.f makeplotfiles02.f makeplotfiles03.f makework.f mymedian5.f myrms.f

## DOER_BIN : Binary Targets for doers
DOER_BIN = $(addprefix $(BIN_DIR)/,  $(DOER_SRC:.f='') )


#############################################################################
#### Core Library Target Variables                                                
####
#### Variables for Targets in the Core Library
####
#### Consists of Programs under BinSource/ and Functions under Subs/
####
#### Core Binaries are put in Bin Directory (Compiled Complete Programs)
####
#### Core Libraries get compiled to linkable objects (.o), as well as
#### python wrappers and usable shared objects with f2py
####
##############################################################################


## CORE_BIN_SRC : list of Fortran files for our core programs 
CORE_BIN_SRC = xyz2b.f subtrc.f gabs.f gscale.f b2xyz.f gsqr.f gsqrt.f addem.f regrd2.f convlv.f decimate.f

## CORE_BIN : Binary Targets for doers
CORE_BIN = $(addprefix $(BIN_DIR)/,$(CORE_BIN_SRC:.f='') )

## CORE_LIB_SRC : List of Fortran files for subroutines and functions
CORE_LIB_SRC = $(basename $(notdir $(wildcard $(CORE_LIB_SRC_DIR)/*.f $(CORE_LIB_SRC_DIR)/*.for)))

## CORE_LIB_PYF : List of .PYF Header for F2PY, generating in python directory
CORE_LIB_PYF = $(addsuffix .pyf, $(addprefix $(NC5NG_CORE_DIR)/, $(CORE_LIB_SRC) ) )

## CORE_F2PY_LIB : Direct Compile of fortran with F2PY
CORE_F2PY_LIB = $(addsuffix .so, $(addprefix $(LIB_DIR)/, $(CORE_LIB_SRC)) )

## CORE_LIB : Linkable objects for core library
CORE_LIB = $(addsuffix .o, $(addprefix $(LIB_DIR)/, $(CORE_LIB_SRC)))


#############################################################################
#### Mask Target Variables                                                
####
#### Variables for Targets in the Masks sub directory
####
#### Binaries are placed in the binary directory 'bin/masks'
####
##############################################################################


MASK_SRC =  makeharnfbnmask 
MASK_BIN = $(addprefix $(MASK_DIR)/,  $(MASK_SRC) )



################################################################################
###############################################################################
##### Target Definition       ##################################################
################################################################################
################################################################################


### All Binaries
BIN_TARGETS = $(ROOT_BIN) $(MASK_BIN) $(CORE_LIB_BIN)

### All Libraries (excludes F2PY Convenience Builds)
LIB_TARGETS = $(CORE_LIB) 

### All F2PY
PYF_TARGETS = $(CORE_LIB_PYF)

### F2PY so's
PYL_TARGETS = $(CORE_F2PY_LIB)

### Targets for directories we may need to create
DIR_TARGETS := $(BUILD_DIR) $(BIN_DIR) $(MASK_DIR) $(LIB_DIR)


##
##Default Target (Defined Later) is "all"
##
all:

##
## Directory Targets:
## Rule to create the dirs
## 
$(DIR_TARGETS):
	$(MKDIR) -p $@


##
## Binaries
## Primary Rule Compile to Executable
##
$(BIN_DIR)/%:$(notdir %).f | $(BIN_DIR)
	$(FC) $(FFLAGS) $< -o $@


##
## Libraries
##
##
$(LIB_DIR)/%.o:$(CORE_LIB_SRC_DIR)/%.f | $(LIB_DIR)
	$(FC) -c $(FFLAGS) $< -o $@
$(LIB_DIR)/%.o:$(CORE_LIB_SRC_DIR)/%.for | $(LIB_DIR)
	$(FC) -c $(FFLAGS) $< -o $@


##
## Masks
## Primary Rule to Compile  Executable
##
$(MASK_DIR)/%:$(notdir %).f | $(MASK_DIR)
	$(FC) $(FFLAGS) $< -o $@ 


###
### PYF
### Rule to Create the F2PY Header Files
### (if they do not exist)
###
$(NC5NG_DIR)/core/%.pyf:Subs/%.f 
	$(F2PY) -h $(F2PY_OPTS) $@ $< -m $*
$(NC5NG_DIR)/core/%.pyf:Subs/%.for
	$(F2PY) -h $(F2PY_OPTS) $@ $< -m $*


###
### Shared Library (Python)
### Rule to Build the F2PY Shared Library Object
###
$(LIB_DIR)/%.so: $(NC5NG_CORE_DIR)/%.pyf | $(LIB_DIR)
	$(F2PY) -c $(F2PY_OPTS) $^ -m $(notdir $*)
	mv $(notdir $*).*.so $@

##
## List Phony "Virtual" Targets
## 
.PHONY: core doers masks all clean mrclean build-info pyf pyl libraies binaries dirs

## All Directories
dirs: $(DIR_TARGETS)

## All Binaries
binaries: $(BIN_TARGETS)

## All Libraries
libraries: $(LIB_TARGETS)

## Generate Signature files in our python package
pyf: $(PYF_TARGETS)

## Compile Python Modules Directly (outside of setup.y)
pyl: $(PYL_TARGETS)

## Convenience targets
doers: $(DOER_BIN)
core: $(CORE_BIN)
corelib: $(CORE_LIB)
masks: $(MASK_BIN)

## Primary "All Target"
all:  build-info binaries libraries



## Cleanup 
clean:
	$(RM) -rf $(BIN_DIR)
	$(RM) -rf $(LIB_DIR)

mrclean:
	$(RM) -rf $(BUILD_DIR)


## Logging
build-info:
	@$(ECHO) "==========================="
	@$(ECHO) "NADCON5 Top Level Make File"
	@$(ECHO) "---------------------------"
	@$(ECHO) "TOP_DIR        = $(TOP_DIR)"
	@$(ECHO) "BIN_DIR        = $(BIN_DIR)"
	@$(ECHO) "FC             = $(FC)"
	@$(ECHO) "FFLAGS         = $(FFLAGS)"
	@$(ECHO) "DOER Bins      = $(DOER_BIN)"
	@$(ECHO) "CORE Bins      = $(HELPER_BIN)"
	@$(ECHO) "Mask Bins      = $(MASK_BIN)"
	@$(ECHO) "NC5NG Dir      = $(NC5NG_DIR)"
	@$(ECHO) "---------------------------"


