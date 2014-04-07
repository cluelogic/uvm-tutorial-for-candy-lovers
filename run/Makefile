#
# Makefile
#

help:
	@echo "Usage: make SIMULATOR TUTORIAL=NUM"
	@echo "  Runs a simulation for the specified tutorial number using the specified simulator."
	@echo "  SIMULATOR can be 'modelsim', 'questa', 'incisive', or 'vcs'."
	@echo "  NUM can be 1, 2, 3, 4, 5, 6, 7, 8, 9, 15, or 21."
	@echo "Example: make vcs TUTORIAL=6"
	@echo "  Runs a simulation for tutorial #6 using VCS."

# conditionals
#-------------------------------------------------------------------------------

tutorial_file := no_source_code.sv
testname := no_test

ifeq "$(TUTORIAL)" "1"
  tutorial_file := tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "2"
  tutorial_file := tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "3"
  tutorial_file := tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "4"
  tutorial_file := tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "5"
  tutorial_file := tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "6"
  tutorial_file := tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "7"
  tutorial_file := tutorial_7_and_8.sv
  testname := jelly_bean_recipe_test
endif

ifeq "$(TUTORIAL)" "8"
  tutorial_file := tutorial_7_and_8.sv
  testname := jelly_bean_recipe_test
endif

ifeq "$(TUTORIAL)" "9"
  tutorial_file := tutorial_9.sv
  testname := jelly_bean_reg_test
endif

ifeq "$(TUTORIAL)" "15"
  tutorial_file := tutorial_15.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "21"
  tutorial_file := tutorial_21.sv
  testname := jelly_bean_test
endif

# constants
#-------------------------------------------------------------------------------

src_dir       := ../src
compile_files := $(src_dir)/$(tutorial_file)
compile_opts  := +define+TUTORIAL=$(TUTORIAL)
run_opts      := +UVM_TESTNAME=$(testname)
top_module    := top

include incisive.mk
include modelsim.mk
include questa.mk
include vcs.mk

clean_all: clean_incisive clean_modelsim clean_questa clean_vcs