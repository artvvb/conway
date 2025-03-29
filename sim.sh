xvlog --sv hdl/counter.sv
xvlog --sv sim/counter_tb.sv
xelab --debug typical --top counter_tb --snapshot counter_tb_snapshot
xsim counter_tb_snapshot --tclbatch xsim_cfg.tcl
xsim --gui ./counter_tb_snapshot.wdb