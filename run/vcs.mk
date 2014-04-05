#
# vcs.mk
#

# user definable variables

# NONE

# constants

vcs_compile_opts := $(compile_opts) -timescale=1ns/10ps -ntb_opts uvm -sverilog +define+CL_USE_VCS 
vcs_run_opts     := $(run_opts)

# targets

vcs: run_vcs

prep_vcs:

run_vcs: 
	vcs $(vcs_compile_opts) $(compile_files)
	./simv $(vcs_run_opts)

clean_vcs:
	rm -rf ./simv ./simv.daidir ./simv.vdb ./csrc