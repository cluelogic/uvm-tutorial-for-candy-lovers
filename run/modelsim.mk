#
# modelsim.mk
#

# user definable variables

MODELSIM_LIB_DIR  := ./work
MODELSIM_LIB_NAME := work

# constants


modelsim_compile_files := $(UVM_HOME)/src/uvm_pkg.sv $(UVM_HOME)/src/dpi/uvm_dpi.cc $(compile_files) 
modelsim_compile_opts  := $(compile_opts) +incdir+$(UVM_HOME)/src +define+CL_USE_MODELSIM -ccflags "-DQUESTA"
modelsim_run_opts      := $(run_opts)
modelsim_run_cmd_file  := modelsim.cmd

# targets

modelsim: prep_modelsim run_modelsim

prep_modelsim:
	vlib $(MODELSIM_LIB_DIR)
	vmap $(MODELSIM_LIB_NAME) $(MODELSIM_LIB_DIR)

run_modelsim:
	vlog $(modelsim_compile_opts) $(modelsim_compile_files)
	vsim $(modelsim_run_opts) $(top_module) < $(modelsim_run_cmd_file)

clean_modelsim:
	vdel -lib $(MODELSIM_LIB_NAME) -all
