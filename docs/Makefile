# Makefile for NADCON5-ng Documentation
# Documentation built using doxygen 
#

.PHONY    : all clean doxy_docs full_docs thin_docs
_TOP_DIR   := ..
TOP_DIR = $(shell cd $(_TOP_DIR); pwd)

BUILD_TOP := $(TOP_DIR)/build
DOC_DIR  := $(BUILD_TOP)/docs



DOXY = doxygen
DOXY_FLAGS ?= 
DOXY_FILE = Doxyfile



### Our Doxyfile is structured such that we can export options from makefile
###
### Options for doxyfile are environment variables that we can set

### DOXY_PROJECT_NAME - the name of the project
DOXY_PROJECT_NAME= "NADCON5-ng"

### DOXY_PROJECT_NUMBER  - the version or revision default "UNVERSIONED"
DOXY_PROJECT_NUMBER := 0.0.2

### DOXY_OUTPUT_DIR - Directory to build in (DOC_DIR)
DOXY_OUTPUT_DIR := $(DOC_DIR)

### DOXY_PROJECT_BRIEF - Summary of Project
DOXY_PROJECT_BRIEF := "NADCON5 Next Generation" 

### DOXY_EXTRACT_ALL - Extract Everything (Private/public/protected/anon/static
### When no do extract private members and anonymous namespaces
DOXY_EXTRACT_ALL := NO

### DOXY_INPUT - space seperate list of source to process for documentation 
DOXY_INPUT := "modules ../src pages  ../README.md ../LICENSE.md ../Makefile "

### DOXY_ENABLE_SOURCE - append source to documentation
DOXY_ENABLE_SOURCE := NO

### DOXY_ENABLE_CLASS_GRAPHS - Enable Class Graph Creation
DOXY_ENABLE_CLASS_GRAPHS := NO

### DOXY_ENABLE_UML - Enable UML Graph Creation
DOXY_ENABLE_UML := YES

### DOXY_ENABLE_CALL_GRAPHS - Enable Call Graph Creation
DOXY_ENABLE_CALL_GRAPHS := NO

## DOXY_CREATE_MANUAL - Create Manual page (.man) in section 3
DOXY_CREATE_MANUAL := NO

## DOXY_MANUAL_SECTION - Section of Manual to put docs
DOXY_MANUAL_SECTION := 3

### DOXY_CREATE_HTML - create html output
DOXY_CREATE_HTML := YES

### DOXY_CREATE_LATEX - Generate LATEX 
DOXY_CREATE_LATEX := NO

### DOXY_DISABLE_CACHE Disable Caching - Default off because Caching in CI/CD isn't useful
DOXY_DISABLE_CACHE := YES

### DOXY_LAYOUT_FILE - Doxygen Menu Layout (XML), none = Doxygen Default
DOXY_LAYOUT_FILE := 

### DOXY_HTML_HEADER_FILE - Doxygen HTML Header File, none = Doxygen Default
DOXY_HTML_HEADER_FILE :=

### DOXY_HTML_FOOTER_FILE - Doxygen HTML Footer FIle, none = Doxygen Default 
DOXY_HTML_FOOTER_FILE :=

### DOXY_EXTRA_CSS_FILE - Doxygen CSS Overrider 
DOXY_EXTRA_CSS_FILE :=

### DOXY_BASE_CSS_FILE - Doxygen Root CSS (Not Recommended)
DOXY_BASE_CSS_FILE :=

### DOXY_MD_MAINPAGE - Markdown Mainpage (Common README)
DOXY_MD_MAINPAGE := ../README.md

### DOXY_ENABLED_SECTIONS - Optional Processing for a particular output type based on sections 
DOXY_ENABLED_SECTIONS :=

.PHONY: publish_docs full_docs doxy_docs clean


publish_docs: DOXY_LAYOUT_FILE=layout/default_layout.xml
publish_docs: DOXY_HTML_HEADER_FILE=layout/default_header.html
publish_docs: DOXY_HTML_FOOTER_FILE=layout/default_footer.html
publish_docs: DOXY_HTML_CSS_EXTRA_FILE=layout/default_style_overrides.css
publish_docs: DOXY_ENABLE_CALL_GRAPHS=YES
publish_docs: DOXY_EXTRACT_ALL=YES
publish_docs: DOXY_ENABLE_SOURCE=YES
publish_docs: DOXY_DISABLE_CACHE=NO
publish_docs: DOXY_CREATE_LATEX=YES
publish_docs: doxy_docs

full_docs: DOXY_ENABLE_CALL_GRAPHS=YES
full_docs: DOXY_EXTRACT_ALL=YES
full_docs: DOXY_ENABLE_SOURCE=YES
full_docs: DOXY_DISABLE_CACHE=NO
full_docs: DOXY_ENABLE_CLASS_GRAPHS=YES
full_docs: DOXY_CREATE_LATEX=YES
full_docs: publish_docs

bin_manual: DOXY_CREATE_HTML=NO
bin_manual: DOXY_CREATE_LATEX=NO
bin_manual: DOXY_CREATE_MANUAL=YES
bin_manual: DOXY_MANUAL_SECTION=1
bin_manual: DOXY_INPUT=" ../src/makework.f "
bin_manual: DOXY_EXTRACT_ALL=YES
bin_manual: DOXY_MD_MAINPAGE=
bin_manual: DOXY_ENABLED_SECTIONS=MANPAGE
bin_manual: doxy_docs


#workkhorse, all other targets simply set variables
doxy_docs:
	mkdir -p $(DOC_DIR)
	@echo "Starting Documentation Build"
	DOXY_PROJECT_NAME=$(DOXY_PROJECT_NAME) \
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
	DOXY_LAYOUT_FILE=$(DOXY_LAYOUT_FILE) \
	DOXY_HTML_HEADER_FILE=$(DOXY_HTML_HEADER_FILE) \
	DOXY_HTML_FOOTER_FILE=$(DOXY_HTML_FOOTER_FILE) \
	DOXY_EXTRA_CSS_FILE=$(DOXY_EXTRA_CSS_FILE) \
	DOXY_BASE_CSS_FILE=$(DOXY_BASE_CSS_FILE) \
	DOXY_MD_MAINPAGE=$(DOXY_MD_MAINPAGE) \
	DOXY_CREATE_MANUAL=$(DOXY_CREATE_MANUAL) \
	DOXY_MANUAL_SECTION=$(DOXY_MANUAL_SECTION) \
	DOXY_ENABLED_SECTIONS=$(DOXY_ENABLED_SECTIONS) \
		$(DOXY) $(DOXY_FLAGS) $(DOXY_FILE) 
#export DOC_DIR
#export FULL_PROJECT_VERSION
#@echo $(DOC_DIR)
#@echo $(FULL_PROJECT_VERSION)





clean:
	rm -rf $(DOC_DIR)



