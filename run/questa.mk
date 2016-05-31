#
# questa.mk
#

# user definable variables

QUESTA_LIB_DIR  := ./work
QUESTA_LIB_NAME := work
UVM_VERSION     := uvm-1.2
# QUESTA_PRECOMPILED_UVM := # used if defined; e.g. <questa_install_dir>/uvm-1.2

# constants

questa_compile_files := $(compile_files)

ifdef QUESTA_PRECOMPILED_UVM
questa_compile_opts  := $(compile_opts) +define+CL_USE_QUESTA -L $(QUESTA_PRECOMPILED_UVM)
questa_run_opts      := $(run_opts) -L $(QUESTA_PRECOMPILED_UVM)
else
questa_compile_opts  := $(compile_opts) +define+CL_USE_QUESTA
questa_run_opts      := $(run_opts)
endif

questa_run_cmd_file  := modelsim.cmd

# targets

questa: prep_questa run_questa

prep_questa:
	vlib $(QUESTA_LIB_DIR)
	vmap $(QUESTA_LIB_NAME) $(QUESTA_LIB_DIR)

run_questa:
	vlog $(questa_compile_opts) $(questa_compile_files)
	vsim $(questa_run_opts) $(top_module) < $(questa_run_cmd_file)

clean_questa:
	vdel -lib $(QUESTA_LIB_NAME) -all
