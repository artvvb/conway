#! vivado -mode batch -source build.tcl -tclargs ./blinky.bit
set script_dir [file normalize [file dirname [info script]]]
set hdl_dir [file normalize "${script_dir}/hdl"]

set index_last [expr [llength ${argv}] - 1]
set top_module_name [lindex ${argv} ${index_last}]

# read top SystemVerilog design file and referenced includes
read_verilog -sv [file join $hdl_dir ${top_module_name}.sv]

# read constraints
read_xdc [file join ${hdl_dir} ${top_module_name}_synth.xdc]

# Note: https://adaptivesupport.amd.com/s/article/57297?language=en_US
#       Has some insight on designutils 20-411 errors - don't build from a directory in a OneDrive folder lol.

# Synthesize Design
# Target Basys 3 part
synth_design -include_dirs ${hdl_dir} -top ${top_module_name} -part xc7a35tcpg236-1
puts "====== Finished synth_design ======"

# todo: write dcps and include them in the makefile
# write_checkpoint -force $outputDir/post_synth.dcp
# report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
# report_utilization -file $outputDir/post_synth_util.rpt

# Read implementation constraints
read_xdc [file join ${hdl_dir} ${top_module_name}_impl.xdc]

# Opt Design 
opt_design
puts "====== Finished opt_design ======"

# Place Design
place_design
puts "====== Finished place_design  ======"

# Route Design
route_design
puts "====== Finished route_design ======"

# Write out bitfile
write_bitstream -force ${top_module_name}.bit
puts "====== Finished write_bitstream ======"