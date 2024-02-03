set script_dir [file normalize [file dirname [info script]]]
set hdl_dir [file normalize "${script_dir}/../hdl"]
set sim_dir [file normalize "${script_dir}/../sim"]
set sim_proj_dir [file normalize "${script_dir}/../sim_proj"]

if {[file exists ${sim_proj_dir}] == 0} {file mkdir ${sim_proj_dir}}

create_project "sim_proj" ${sim_proj_dir} -part xc7a35tcpg236-1
set_property board_part digilentinc.com:basys3:part0:1.2 [current_project]

# read all design files
foreach testbench [glob -nocomplain ${sim_dir}/*.v] {
    set sim_name [file tail [file rootname $testbench]]
    create_fileset -simset ${sim_name}
    add_files -fileset ${sim_name} -norecurse [glob -nocomplain ${hdl_dir}/*.v]
    add_files -fileset ${sim_name} -norecurse ${testbench}
    set_property top ${sim_name} [get_filesets ${sim_name}]
    set_property top_lib xil_defaultlib [get_filesets ${sim_name}]
    update_compile_order -fileset ${sim_name}
}