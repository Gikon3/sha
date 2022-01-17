export test_name ?=engine

# Paths
root_dir := $(shell pwd)/
rtl_dir  := $(root_dir)rtl/
tb_dir   := $(root_dir)tb/
sim_dir  := $(root_dir)sim/
rtl_inc  := $(rtl_dir)rtl_inc.f

top_module := tb_$(test_name)
nsim_opts  ?=

tb_file  := $(tb_dir)$(top_module).sv

# Targets
.PHONY: irun

irun:
	@clear
	@clear
	@mkdir -p $(sim_dir)$(test_name)
	@cd $(sim_dir); \
	irun \
	-64bit \
	-clean \
	-sv \
	-nowarn NONPRT \
	-disable_sem2009 \
	-debug \
	-ALLOWREDEFINITION \
	-timescale 1ns/1ps \
	+define+TEST_NAME\=\"$(test_name)\" \
	-F $(rtl_inc) \
	$(tb_file) \
	-top $(top_module) \
	-l $(sim_dir)log/$(top_module).log \
	$(nsim_opts)

clean:
	@rm $(sim_dir)*
