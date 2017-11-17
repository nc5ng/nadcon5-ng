_TOP_DIR := ./
TOP_DIR   = $(shell cd $(_TOP_DIR); pwd)
BUILD_DIR = $(TOP_DIR)/build
BIN_DIR = $(BUILD_DIR)/bin
OUT_DIR = $(BUILD_DIR)/out
CODE_DIR = $(TOP_DIR)/Code
CONTROL_DIR = $(TOP_DIR)/Control
DATA_DIR = $(TOP_DIR)/Work
IN_DIR = $(TOP_DIR)/InFiles



## Common System Commands
MKDIR=mkdir
RM=rm
ECHO=echo

## Driving Parameters 
OLD_DATUM = ussd
NEW_DATUM = nad27
REGION = conus



## Target Files
MAKEWORK_BIN = $(BIN_DIR)/makework
OUT_FILE_1 = $(OUT_DIR)/work.$(OLD_DATUM).$(NEW_DATUM).$(REGION)


## Targets

# Default
all: 

# Folders

$(OUT_DIR):
	$(MKDIR) -p $@

#Dependency for DOIT1
$(MAKEWORK_BIN):
	$(MAKE) -C $(CODE_DIR) $@



#Output of DOIT1
$(OUT_FILE_1): $(MAKEWORK_BIN) | $(OUT_DIR)
	NADCON_CONTROL_DIR=$(CONTROL_DIR)/ \
	NADCON_OUT_DIR=$(OUT_DIR)/ \
	NADCON_DAT_DIR=$(DATA_DIR)/ \
	NADCON_IN_DIR=$(IN_DIR)/ \
	$(MAKEWORK_BIN) $(OLD_DATUM) $(NEW_DATUM) $(REGION)


### Phony (Virtual) Targets
src:
	$(MAKE) -C $(CODE_DIR) all
all: build-info src doit1
doit1: $(OUT_FILE_1)
.PHONY: src all


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
	@$(ECHO) "OUT_FILE_1          = $(OUT_FILE_1)"
	@$(ECHO) "MAKEWORK_BIN        = $(MAKEWORK_BIN)"
	@$(ECHO) "CONTROL_DIR         = $(CONTROL_DIR)"
	@$(ECHO) "DATA_DIR            = $(DATA_DIR)"
	@$(ECHO) "---------------------------"





