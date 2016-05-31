#
# Makefile
#

help:
	@echo "Usage: make SIMULATOR TUTORIAL=NUM"
	@echo "  Runs a simulation for the specified tutorial number using the specified simulator."
	@echo "  SIMULATOR can be 'modelsim', 'questa', 'incisive', or 'vcs'."
	@echo "  NUM can be 1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 21, 23, 24, 25, 26, 27, 28, 29, 32 or 33."
	@echo "Example: make vcs TUTORIAL=6"
	@echo "  Runs a simulation for tutorial #6 using VCS."

# conditionals
#-------------------------------------------------------------------------------

tutorial_files := no_source_code.sv
testname       := no_test
src_dir        := ../src

ifeq "$(TUTORIAL)" "$(filter $(TUTORIAL),1 2 3 4 5 6)"
  tutorial_files := $(src_dir)/tutorial_1_to_6.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "$(filter $(TUTORIAL),7 8)"
  tutorial_files := $(src_dir)/tutorial_7_and_8.sv
  testname := jelly_bean_recipe_test
endif

ifeq "$(TUTORIAL)" "9"
  tutorial_files := $(src_dir)/tutorial_9.sv
  testname := jelly_bean_reg_test
endif

ifeq "$(TUTORIAL)" "$(filter $(TUTORIAL),15 21)"
  tutorial_files := $(src_dir)/tutorial_$(TUTORIAL).sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "$(filter $(TUTORIAL),23 25 26 27 28 32 33)"
  tutorial_files := $(src_dir)/tutorial_$(TUTORIAL)/design.sv $(src_dir)/tutorial_$(TUTORIAL)/testbench.sv
  testname := jelly_bean_test
endif

ifeq "$(TUTORIAL)" "$(filter $(TUTORIAL),24 29)"
  tutorial_files := $(src_dir)/tutorial_$(TUTORIAL)/design.sv $(src_dir)/tutorial_$(TUTORIAL)/testbench.sv
  testname := jelly_bean_reg_test
endif

# constants
#-------------------------------------------------------------------------------

compile_files := $(tutorial_files)
compile_opts  := +define+TUTORIAL=$(TUTORIAL)
run_opts      := +UVM_TESTNAME=$(testname)
top_module    := top

include incisive.mk
include modelsim.mk
include questa.mk
include vcs.mk

clean_all: clean_incisive clean_modelsim clean_questa clean_vcs
