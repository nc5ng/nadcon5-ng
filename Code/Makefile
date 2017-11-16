# NADCON5-NG Makefile
#
# Adapted from CSH Script `compileCode` in the original distribution
# 
#


########################################
##### Global Variables #################
########################################

_TOP_DIR := ../
TOP_DIR   = $(shell cd $(_TOP_DIR); pwd)
BUILD_DIR = $(TOP_DIR)/build
BIN_DIR   = $(BUILD_DIR)/bin



########################################
##### Build Commands/Binaries ##########
########################################


ECHO  = echo
MKDIR = mkdir
RM    = rm

# Orace Fortran
_ORACLE_STUDIO_BIN = ../../OracleDeveloperStudio12.6-linux-x86-bin/developerstudio12.6/bin
FC = $(_ORACLE_STUDIO_BIN)/f95

#Existing Flags
FFLAGS = "-O5 -libmil -fsimple=0 -dalign -xlibmopt -ftrap=%none -xvector=yes -xprefetch=yes -parallel -reduction -xloopinfo -s -stackvar -m64"



########################################
##### Input and Output Files  ##########
########################################

VPATH += BinSource ../Masks

#MAIN_SRC = $(basename $(notdir $(wildcard *.f)))
MAIN_SRC = checkgrid makeplotfiles01 makeplotfiles02 makeplotfiles03 makework mymedian5 myrms
AIN_BIN = $(addprefix $(BIN_DIR)/,  $(MAIN_SRC) )

#HELPER_SRC = $(basename $(notdir $(wildcard BinSource/*.f)))
HELPER_SRC = xyz2b subtrc gabs gscale b2xyz gsqr gsqrt addem regrd2 convlv decimate 
HELPER_BIN = $(addprefix $(BIN_DIR)/,$(HELPER_SRC) )

#MASK_SRC = $(basename $(notdir $(wildcard ../Masks/*.f)))
MASK_SRC =  makeharnfbnmask 
MASK_BIN = $(addprefix $(BIN_DIR)/,  $(MASK_SRC) )

### All Targets
BIN_TARGETS = $(MAIN_BIN) $(MASK_BIN) $(HELPER_BIN)


########################################
##### Target Definition       ##########
########################################


## Directory
$(BIN_DIR):
	$(MKDIR) -p $@

## Binaries
$(BIN_DIR)/%:%.f | $(BIN_DIR)
	$(FC) $(FFLAGS) $< -o $@



## Phony "Virtual" Targets
.PHONY: main helpers masks all clean mrclean build-info

main: $(MAIN_BIN)
helpers: $(HELPER_BIN)
masks: $(MASK_BIN)
all: main helpers masks


clean:
	$(RM) -rf $(BIN_DIR)

mrclean:
	$(RM) -rf $(BUILD_DIR)


build-info:
	@$(ECHO) "TOP_DIR        = $(TOP_DIR)"
	@$(ECHO) "BIN_DIR        = $(BIN_DIR)"
	@$(ECHO) "FC             = $(FC)"
	@$(ECHO) "FFLAGS         = $(FFLAGS)"
	@$(ECHO) "Main Bins      = $(MAIN_BIN)"
	@$(ECHO) "Helper Bins    = $(MAIN_BIN)"
	@$(ECHO) "Mask Bins      = $(MAIN_BIN)"


