_TOP_DIR := ../
# NADCON5-NG Makefile
#
# Adapted from CSH Script `compileCode` in the original distribution
# 
#


########################################
##### Global Variables #################
########################################

## Fixed Directories
TOP_DIR   ?= $(shell cd $(_TOP_DIR); pwd)
DATA_DIR  ?= $(TOP_DIR)/data

## Build Output
BUILD_DIR ?= $(TOP_DIR)/build
LIB_DIR   ?= $(BUILD_DIR)/lib
BIN_DIR   ?= $(BUILD_DIR)/bin
MASK_DIR  ?= $(BIN_DIR)/masks


DIR_TARGETS := $(BUILD_DIR) $(BIN_DIR) $(MASK_DIR) $(LIB_DIR) $(LIB_DIR)/utils $(LIB_DIR)/tools 

###
### Source Directories
###

UTILS_DIR ?= $(shell cd Subs; pwd)
TOOLS_DIR ?= $(shell cd BinSource; pwd)
ROOT_DIR ?= $(shell pwd)

NC5NG_DIR ?= $(TOP_DIR)/nc5ng

########################################
##### Build Commands/Binaries ##########
########################################


ECHO  ?= echo
MKDIR ?= mkdir
RM    ?= rm

# Orace Fortran
_ORACLE_STUDIO_BIN ?= ../../OracleDeveloperStudio12.6-linux-x86-bin/developerstudio12.6/bin
FC ?= $(_ORACLE_STUDIO_BIN)/f95

#Existing Flags
FFLAGS ?= "-O5 -libmil -fsimple=0 -dalign -xlibmopt -ftrap=%none -xvector=yes -xprefetch=yes -parallel -reduction -xloopinfo -s -stackvar -m64"

F2PY ?= f2py
F2PY_OPTS ?= "--f90exec=$(FC) --f90flags=$(FFLAGS)"

########################################
##### Input and Output Files  ##########
########################################

VPATH += BinSource $(DATA_DIR)/Masks

####
## Explicitly Compiled Programs per compileCode
####

#MAIN_SRC = $(basename $(notdir $(wildcard *.f)))
MAIN_SRC = checkgrid makeplotfiles01 makeplotfiles02 makeplotfiles03 makework mymedian5 myrms
MAIN_BIN = $(addprefix $(BIN_DIR)/,  $(MAIN_SRC) )

#HELPER_SRC = $(basename $(notdir $(wildcard BinSource/*.f)))
HELPER_SRC = xyz2b subtrc gabs gscale b2xyz gsqr gsqrt addem regrd2 convlv decimate 
HELPER_BIN = $(addprefix $(BIN_DIR)/,$(HELPER_SRC) )

#MASK_SRC = $(basename $(notdir $(wildcard ../Masks/*.f)))
MASK_SRC =  makeharnfbnmask 
MASK_BIN = $(addprefix $(MASK_DIR)/,  $(MASK_SRC) )

### All Binaries
BIN_TARGETS = $(MAIN_BIN) $(MASK_BIN) $(HELPER_BIN)


### Source to Fortran2Py convenience
UTILS_SRC = $(basename $(notdir $(wildcard $(UTILS_DIR)/*.f $(UTILS_DIR)/*.for)))
UTILS_PYF = $(addsuffix .pyf, $(addprefix $(NC5NG_DIR)/utils/, $(UTILS_SRC) ) )
UTILS_LIB = $(addsuffix .so, $(addprefix $(LIB_DIR)/utils/, $(UTILS_SRC)) )

TOOLS_SRC = $(basename $(notdir $(wildcard $(TOOLS_DIR)/*.f $(TOOLS_DIR)/*.for)))
TOOLS_PYF = $(addsuffix .pyf, $(addprefix $(NC5NG_DIR)/tools/, $(TOOLS_SRC) ) )
TOOLS_LIB = $(addsuffix .so, $(addprefix $(LIB_DIR)/tools/, $(TOOLS_SRC)) )

ROOT_SRC = $(basename $(notdir $(wildcard $(ROOT_DIR)/*.f $(ROOT_DIR)/*.for)))
ROOT_PYF = $(addsuffix .pyf, $(addprefix $(NC5NG_DIR)/, $(ROOT_SRC) ) )
ROOT_LIB = $(addsuffix .so, $(addprefix $(LIB_DIR)/, $(ROOT_SRC)) )

PYF_TARGETS = $(UTILS_PYF) $(TOOLS_PYF) $(ROOT_PYF)
PYL_TARGETS = $(UTILS_LIB) $(TOOLS_LIB) $(ROOT_LIB)



########################################
##### Target Definition       ##########
########################################

#Default Target (Defined Later)
all:

## Directory Targets
$(DIR_TARGETS):
	$(MKDIR) -p $@

## Binaries
$(BIN_DIR)/%:$(notdir %).f | $(BIN_DIR)
	$(FC) $(FFLAGS) $< -o $@

## Masks
$(MASK_DIR)/%:$(notdir %).f | $(MASK_DIR)
	$(FC) $(FFLAGS) $< -o $@

$(NC5NG_DIR)/%.pyf:%.f 
	$(F2PY) -h $(F2PY_OPTS) $@ $< -m $*
$(NC5NG_DIR)/utils/%.pyf:Subs/%.f 
	$(F2PY) -h $(F2PY_OPTS) $@ $< -m $*
$(NC5NG_DIR)/utils/%.pyf:Subs/%.for
	$(F2PY) -h $(F2PY_OPTS) $@ $< -m $*
$(NC5NG_DIR)/tools/%.pyf:BinSource/%.f 
	$(F2PY) -h $(F2PY_OPTS) $@ $< -m $*



$(LIB_DIR)/%.so: $(NC5NG_DIR)/%.pyf | $(LIB_DIR)/tools $(LIB_DIR)/utils $(LIB_DIR)
	$(F2PY) -c $(F2PY_OPTS) $^ -m $(notdir $*)
	mv $(notdir $*).*.so $@


## Phony "Virtual" Targets
.PHONY: main helpers masks all clean mrclean build-info pyf pyl

main: $(MAIN_BIN)
helpers: $(HELPER_BIN)
masks: $(MASK_BIN)
all:  build-info main helpers masks

##Fortran 2 Python

## Generate Signature files in our python package
pyf: $(PYF_TARGETS)
## Compile Python Modules Directly (outside of setup.y)
pyl: $(PYL_TARGETS)


clean:
	$(RM) -rf $(BIN_DIR)
	$(RM) -rf $(LIB_DIR)

mrclean:
	$(RM) -rf $(BUILD_DIR)


build-info:
	@$(ECHO) "==========================="
	@$(ECHO) "NADCON5 Top Level Make File"
	@$(ECHO) "---------------------------"
	@$(ECHO) "TOP_DIR        = $(TOP_DIR)"
	@$(ECHO) "BIN_DIR        = $(BIN_DIR)"
	@$(ECHO) "FC             = $(FC)"
	@$(ECHO) "FFLAGS         = $(FFLAGS)"
	@$(ECHO) "Main Bins      = $(MAIN_BIN)"
	@$(ECHO) "Helper Bins    = $(HELPER_BIN)"
	@$(ECHO) "Mask Bins      = $(MASK_BIN)"
	@$(ECHO) "NC5NG Dir      = $(NC5NG_DIR)"
	@$(ECHO) "---------------------------"


