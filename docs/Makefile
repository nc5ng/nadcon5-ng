# Makefile for NADCON5-ng Documentation
# Documentation built using doxygen 
#

.PHONY    : all clean doxy_docs full_docs thin_docs
_TOP_DIR   := ..
TOP_DIR = $(shell cd $(_TOP_DIR); pwd)

BUILD_TOP := $(TOP_DIR)/build
DOC_DIR  := $(BUILD_TOP)/docs



DOXY := doxygen
DOXY_FLAGS := 
DOXY_FILE := Doxyfile



### Our Doxyfile is structured such that we can export options from makefile
###
### Options for doxyfile are environment variables that we can set 
### DOXY_PROJECT_NUMBER  - the version or revision default "UNVERSIONED"
DOXY_PROJECT_NUMBER := DEVELOPMENT

### DOXY_OUTPUT_DIR - Directory to build in (DOC_DIR)
DOXY_OUTPUT_DIR := $(DOC_DIR)

### DOXY_PROJECT_BRIEF - Summary of Project
DOXY_PROJECT_BRIEF := "NADCON5 Next Generation" 

### DOXY_EXTRACT_ALL - Extract Everything (Private/public/protected/anon/static
### When no do extract private members and anonymous namespaces
DOXY_EXTRACT_ALL := NO

### DOXY_INPUT - space seperate list of source to process for documentation 
DOXY_INPUT := ../Code

### DOXY_ENABLE_SOURCE - append source to documentation
DOXY_ENABLE_SOURCE := NO

### DOXY_ENABLE_CLASS_GRAPHS - Enable Class Graph Creation
DOXY_ENABLE_CLASS_GRAPHS := NO

### DOXY_ENABLE_UML - Enable UML Graph Creation
DOXY_ENABLE_UML := YES

### DOXY_ENABLE_CALL_GRAPHS - Enable Class Graph Creation
DOXY_ENABLE_CALL_GRAPHS := NO

### DOXY_CREATE_HTML - create html output
DOXY_CREATE_HTML := YES

DOXY_CREATE_LATEX := NO

DOXY_DISABLE_CACHE := YES


publish_docs: full_docs
.PHONY: publish_docs

full_docs: DOXY_ENABLE_CALL_GRAPHS=YES
full_docs: DOXY_EXTRACT_ALL=YES
full_docs: DOXY_ENABLE_SOURCE=YES
full_docs: DOXY_DISABLE_CACHE=NO
full_docs: doxy_docs	

thin_docs: DOXY_DISABLE_CACHE=NO
thin_docs: doxy_docs

doxy_docs:
	mkdir -p $(DOC_DIR)
	@echo "Starting Documentation Build"
	DOXY_PROJECT_NUMBER=$(DOXY_PROJECT_NUMBER) \
	DOXY_OUTPUT_DIR=$(DOXY_OUTPUT_DIR) \
	DOXY_PROJECT_BRIEF=$(DOXY_PROJECT_BRIEF) \
	DOXY_EXTRACT_ALL=$(DOXY_EXTRACT_ALL) \
	DOXY_INPUT=$(DOXY_INPUT) \
	DOXY_ENABLE_SOURCE=$(DOXY_ENABLE_SOURCE) \
	DOXY_ENABLE_CLASS_GRAPHS=$(DOXY_ENABLE_CLASS_GRAPHS) \
	DOXY_ENABLE_UML=$(DOXY_ENABLE_UML) \
	DOXY_ENABLE_CALL_GRAPHS=$(DOXY_ENABLE_CALL_GRAPHS) \
	DOXY_CREATE_HTML=$(DOXY_CREATE_HTML) \
	DOXY_CREATE_LATEX=$(DOXY_CREATE_LATEX) \
		$(DOXY) $(DOXY_FLAGS) $(DOXY_FILE) 
#export DOC_DIR
#export FULL_PROJECT_VERSION
#@echo $(DOC_DIR)
#@echo $(FULL_PROJECT_VERSION)





clean:
	rm -rf $(DOC_DIR)
