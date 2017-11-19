_TOP_DIR := ./
TOP_DIR   = $(shell cd $(_TOP_DIR); pwd)
BUILD_DIR = $(TOP_DIR)/build
BIN_DIR = $(BUILD_DIR)/bin
OUT_DIR = $(BUILD_DIR)/out
CODE_DIR = $(TOP_DIR)/Code
export PATH := $(PATH):$(BIN_DIR)

CONTROL_DIR = $(TOP_DIR)/Control
CONTROL_CPY_DIR = $(OUT_DIR)/Control

DATA_DIR = $(TOP_DIR)/Data
DATA_CPY_DIR = $(OUT_DIR)/Data

WORK_DIR = $(TOP_DIR)/Work
WORK_CPY_DIR = $(OUT_DIR)/Work

IN_DIR = $(TOP_DIR)/InFiles
IN_CPY_DIR = $(OUT_DIR)/InFiles

GMTDEFAULTS = $(TOP_DIR)/gmtdefaults4
GMTDEFAULTS_CPY = $(OUT_DIR)/.gmtdefaults4

CPY_TARGETS = $(WORK_CPY_DIR) $(DATA_CPY_DIR) $(IN_CPY_DIR) $(CONTROL_CPY_DIR) $(GMTDEFAULTS_CPY)

## Common System Commands
MKDIR=mkdir
RM=rm
ECHO=echo
CP=cp

## Driving Parameters 
OLD_DATUM = ussd
NEW_DATUM = nad27
REGION = conus
MAPLEVEL = 0
GRIDSPACING = 900

## Target Files
MAKEWORK_BIN = $(BIN_DIR)/makework
MAKEPLOT1_BIN = $(BIN_DIR)/makeplotfiles01
MAKEPLOT2_BIN = $(BIN_DIR)/makeplotfiles02
MYMEDIAN_BIN = $(BIN_DIR)/mymedian5

BIN_DEPS = $(MAKEWORK_BIN) $(MAKEPLOT1_BIN) $(MAKEPLOT2_BIN) $(MYMEDIAN_BIN)

OUT_FILE_1 = $(OUT_DIR)/Work/work.$(OLD_DATUM).$(NEW_DATUM).$(REGION)
OUT_FILE_2 = $(OUT_DIR)/gmtbat01.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(MAPLEVEL)
OUT_FILE_3 = $(OUT_DIR)/gmtbat02.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING)
OUT_FILE_4 = $(OUT_DIR)/gmtbat03.$(OLD_DATUM).$(NEW_DATUM).$(REGION).$(GRIDSPACING).$(MAPLEVEL)

## Targets

# Default
all: 


# Copy to build environment
$(CONTROL_CPY_DIR): $(CONTROL_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(DATA_CPY_DIR): $(DATA_DIR) | $(OUT_DIR)
	$(CP) -r $< $@


$(IN_CPY_DIR): $(IN_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(WORK_CPY_DIR): $(WORK_DIR) | $(OUT_DIR)
	$(CP) -r $< $@

$(GMTDEFAULTS_CPY): $(GMTDEFAULTS) | $(OUT_DIR)
	$(CP) -r $< $@

# Folders

$(OUT_DIR):
	$(MKDIR) -p $@

#Dependency for DOIT1
$(BIN_DEPS):
	$(MAKE) -C $(CODE_DIR) $@

#Output of DOIT1
define DOIT1_IN
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
endef
export DOIT1_IN
$(OUT_FILE_1): $(MAKEWORK_BIN) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR); \
	  echo "$$DOIT1_IN" \
		| $(MAKEWORK_BIN))

define DOIT2_IN
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
$(MAPLEVEL)
endef
export DOIT2_IN
$(OUT_FILE_2): $(MAKEPLOT1_BIN) $(OUT_FILE_1) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT2_IN" | $(MAKEPLOT1_BIN); \
	  chmod 777 $@; \
	)
define DOIT3_IN
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
$(GRIDSPACING)
endef
export DOIT3_IN
$(OUT_FILE_3): $(MYMEDIAN_BIN) $(OUT_FILE_2) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT3_IN" | $(MYMEDIAN_BIN); \
	  chmod 777 $@  ;\
	  csh $@ \
        )


define DOIT4_IN
$(OLD_DATUM)
$(NEW_DATUM)
$(REGION)
$(GRIDSPACING)
$(MAPLEVEL)
endef
export DOIT4_IN
$(OUT_FILE_4): $(MAKEPLOT2_BIN) $(OUT_FILE_3) $(CPY_TARGETS) | $(OUT_DIR)
	( cd $(OUT_DIR) ; \
	  echo "$$DOIT4_IN" | $(MAKEPLOT2_BIN); \
	  chmod 777 $@\
        )



### Phony (Virtual) Targets
src:
	$(MAKE) -C $(CODE_DIR) all
all: build-info src doit1 doit2 doit3
doit1: $(OUT_FILE_1)

doit2: $(OUT_FILE_2)
	( cd $(OUT_DIR) ; \
	  csh $(OUT_FILE_2) \
	)

doit3:  $(OUT_FILE_3) $(OUT_FILE_4)
	( cd $(OUT_DIR) ; \
	  csh $(OUT_FILE_4) \
	)

.PHONY: src all doit1 doit2 doit3


## Clean Up

clean:
	$(RM) -rf $(OUT_DIR)

mrclean:
	$(RM) -rf $(BUILD_DIR)


.PHONY: clean mrclean




## Logging/Info


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
	@$(ECHO) "OUT_FILE_1          = $(OUT_FILE_1)"
	@$(ECHO) "OUT_FILE_2          = $(OUT_FILE_2)"
	@$(ECHO) "MAKEWORK_BIN        = $(MAKEWORK_BIN)"
	@$(ECHO) "CONTROL_DIR         = $(CONTROL_DIR)"
	@$(ECHO) "DATA_DIR            = $(DATA_DIR)"
	@$(ECHO) "---------------------------"





