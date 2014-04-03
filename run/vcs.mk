#
# vcs.mk
#

# user definable variables

# NONE

# constants

vcs_compile_opts := $(compile_opts) -sverilog +define+CL_USE_VCS
vcs_run_opts     := $(run_opts)

# targets

vcs: run_vcs

prep_vcs:

run_vcs: 
	vcs $(vcs_compile_opts) $(vcs_run_opts) $(compile_files)
	./simv

clean_vcs:
	rm -f ./simv