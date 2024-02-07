# hello_tb.vcd: hello_tb.vvp
# 	vvp hello_tb.vvp
# hello_tb.vvp: hello_tb.v hello.v
# 	iverilog -o hello_tb.vvp hello_tb.v

TB_FILES := $(wildcard sim/*.v)
SOURCES := $(wildcard hdl/*.v)

VVP_FILES := $(addsuffix .vvp, $(basename $(TB_FILES)))
VCD_FILES := $(addsuffix .vcd, $(basename $(TB_FILES)))
OBJ_FILES := $(VCD_FILES)

TOP_MODULE := top
TOP_FILE := hdl/$(TOP_MODULE).v
BIT_FILE := hdl/$(TOP_MODULE).bit
TESTBENCH := sim/$(TOP_MODULE)_sim.v

FPGA_PART := xc7a35tcpg236-1
BUILD_SCRIPT := build.tcl

sim: $(OBJ_FILES)
.PHONY: sim

bit: $(BIT_FILE)
.PHONY: bit

# Create dump files for GTKWave using IVerilog
$(VVP_FILES): sim/%.vvp: sim/%.v
	iverilog -o $@ $<
$(VCD_FILES): sim/%.vcd: sim/%.vvp
	vvp $<

# Make a bitstream in Vivado
$(BIT_FILE): $(wildcard hdl/*.v)
	vivado -mode batch -source $(BUILD_SCRIPT) -tclargs -top $(TOP_FILE) -part $(FPGA_PART) $(BIT_FILE)

clean:
	rm -f $(BIT_FILES)
	rm -f $(VCD_FILES)
	rm -f $(VVP_FILES)
	rm -rf *.jou
	rm -rf *.log