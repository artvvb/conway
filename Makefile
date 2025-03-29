HDL_FILES := $(wildcard hdl/*.sv)
TB_FILES := $(wildcard hdl/*_tb.sv)

sim: xsim.dir/counter_tb_snapshot.wdb
.PHONY: sim

bit: $(BIT_FILE)
.PHONY: bit

xsim.dir/work/counter.sdb: hdl/counter.sv
	xvlog --sv hdl/counter.sv
xsim.dir/work/counter_tb.sdb: hdl/counter_tb.sv
	xvlog --sv hdl/counter_tb.sv
xsim.dir/counter_tb_snapshot.wdb: xsim.dir/work/counter_tb.sdb xsim.dir/work/counter.sdb
	xelab --debug typical --top counter_tb --snapshot counter_tb_snapshot
	xsim counter_tb_snapshot --tclbatch xsim_cfg.tcl
 
# Make a bitstream in Vivado
top.bit: $(wildcard hdl/*)
	vivado -mode batch -source build.tcl -tclargs top.bit

clean:
	rm -rf xsim.dir
	rm -f top.bit
	rm -f counter_tb_snapshot.wdb