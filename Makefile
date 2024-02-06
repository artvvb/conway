# hello_tb.vcd: hello_tb.vvp
# 	vvp hello_tb.vvp
# hello_tb.vvp: hello_tb.v hello.v
# 	iverilog -o hello_tb.vvp hello_tb.v

TB_FILES := $(wildcard sim/*.v)
VVP_FILES := $(addsuffix .vvp, $(basename $(TB_FILES)))
VCD_FILES := $(addsuffix .vcd, $(basename $(TB_FILES)))
OBJ_FILES := $(VVP_FILES) $(VCD_FILES)
TOP_FILE := hdl/top.v
BIT_FILE := hdl/top.bit
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
$(BIT_FILE): $(wildcard hdl/*)
	vivado -mode batch -source $(BUILD_SCRIPT) -tclargs $(BIT_FILE)

clean:
	rm -f $(OBJ_FILES)