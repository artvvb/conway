#! vivado -mode batch -source build.tcl -tclargs -top hdl/top.v -part xc7a35tcpg236-1 blinky.bit 
set script_dir [file normalize [file dirname [info script]]]
set hdl_dir [file normalize "${script_dir}/hdl"]

set original_dir [pwd]
cd ${hdl_dir}

# process tclargs
set last_index [expr [llength ${argv}] - 1]
set bit_name [lindex ${argv} ${last_index}]

set part_index [expr [lsearch ${argv} "-part"] + 1]
set fpga_part [lindex ${argv} ${part_index}]

# get top file name and use it to figure out language used and top module name
set top_index [expr [lsearch ${argv} "-top"] + 1]
set top_file [file normalize ${script_dir}/[lindex ${argv} ${top_index}]]
set top_module [file rootname [file tail $top_file]]
if {[file extension $top_file] == ".v"} {
    set lang "verilog"
} else {
    set lang "vhdl"
}
puts "top module is ${top_module}"

# read the top file and pick up other design files through include
foreach f [glob -nocomplain ${top_file}] {
    puts "reading ${f}"
    read_${lang} ${f}
}
# read constraints
foreach f [glob -nocomplain ${hdl_dir}/*.xdc] {
    puts "reading ${f}"
    read_xdc ${f}
}

# Synthesize Design
# Target Basys 3 part
synth_design -top ${top_module} -part ${fpga_part}
# Opt Design 
opt_design
# Place Design
place_design 
# Route Design
route_design
# Write out bitfile
write_bitstream -force [file join ${script_dir} ${bit_name}]

cd ${original_dir}