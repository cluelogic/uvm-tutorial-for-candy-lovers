#
# questa.mk
#

# user definable variables

QUESTA_LIB_DIR  := ./work
QUESTA_LIB_NAME := work

# constants

questa_compile_opts := $(compile_opts) +define+CL_USE_QUESTA
questa_run_opts     := $(run_opts)
questa_run_cmd_file := modelsim.cmd

# targets

questa: prep_questa run_questa

prep_questa:
	vlib $(QUESTA_LIB_DIR)
	vmap $(QUESTA_LIB_NAME) $(QUESTA_LIB_DIR)

run_questa:
	vlog $(questa_compile_opts) $(compile_files)
	vsim $(questa_run_opts) $(top_module) < $(questa_run_cmd_file)

clean_questa:
	vdel -lib $(QUESTA_LIB_NAME) -all
