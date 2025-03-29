#! vivado -mode batch -source build.tcl -tclargs ./blinky.bit
set script_dir [file normalize [file dirname [info script]]]
set hdl_dir [file normalize "${script_dir}/hdl"]

# read all design files
foreach f [glob -nocomplain ${hdl_dir}/*.v] {
    if {![string match ${f} "*_tb.*"]} {
        read_verilog ${f}
    }
}
foreach f [glob -nocomplain ${hdl_dir}/*.sv] {
    if {![string match ${f} "*_tb.*"]} {
        read_verilog ${f}
    }
}
foreach f [glob -nocomplain ${hdl_dir}/*.vhd] {
    if {![string match ${f} "*_tb.*"]} {
        read_vhdl ${f}
    }
}
# read constraints
foreach f [glob -nocomplain ${hdl_dir}/*.xdc] {
    read_xdc ${f}
}

# Synthesize Design
# Target Basys 3 part
synth_design -top top -part xc7a35ticsg324-1L
# Opt Design 
opt_design
# Place Design
place_design 
# Route Design
route_design
# Write out bitfile
set index_last [expr [llength ${argv}] - 1]
write_bitstream -force [lindex ${argv} ${index_last}]