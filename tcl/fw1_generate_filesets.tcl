# set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
# set_property board_part www.digilentinc.com:pynq-z1:part0:1.0 [current_project]

# list_property  [current_project]
# BASE_BOARD_PART BOARD BOARD_CONNECTIONS BOARD_PART CLASS 
# COMPXLIB.ACTIVEHDL_COMPILED_LIBRARY_DIR COMPXLIB.FUNCSIM COMPXLIB.IES_COMPILED_LIBRARY_DIR COMPXLIB.MODELSIM_COMPILED_LIBRARY_DIR COMPXLIB.OVERWRITE_LIBS COMPXLIB.QUESTA_COMPILED_LIBRARY_DIR COMPXLIB.RIVIERA_COMPILED_LIBRARY_DIR COMPXLIB.TIMESIM COMPXLIB.VCS_COMPILED_LIBRARY_DIR COMPXLIB.XSIM_COMPILED_LIBRARY_DIR 
# CORECONTAINER.ENABLE DEFAULT_LIB DIRECTORY 
# DSA.ACCELERATOR_BINARY_CONTENT DSA.ACCELERATOR_BINARY_FORMAT DSA.BOARD_ID DSA.DESCRIPTION DSA.DR_BD_BASE_ADDRESS DSA.EMU_DIR DSA.FLASH_INTERFACE_TYPE DSA.FLASH_OFFSET_ADDRESS DSA.FLASH_SIZE DSA.HOST_ARCHITECTURE DSA.HOST_INTERFACE DSA.NUM_COMPUTE_UNITS DSA.PLATFORM_STATE DSA.ROM.DEBUG_TYPE DSA.ROM.PROM_TYPE DSA.VENDOR DSA.VERSION 
# ENABLE_OPTIONAL_RUNS_STA ENABLE_VHDL_2008 EXAMPLE_PROJECT GENERATE_IP_UPGRADE_LOG ID IP_CACHE_PERMISSIONS IP_INTERFACE_INFERENCE_PRIORITY IP_OUTPUT_REPO IP_REPO_PATHS IS_READONLY LEGACY_IP_REPO_PATHS MEM.ENABLE_MEMORY_MAP_GENERATION NAME PART PROJECT_TYPE PR_FLOW SIM.CENTRAL_DIR SIM.IP.AUTO_EXPORT_SCRIPTS SIM.USE_IP_COMPILED_LIBS SIMULATOR_LANGUAGE SOURCE_MGMT_MODE TARGET_LANGUAGE TARGET_SIMULATOR TOOL_FLOW XPM_LIBRARIES XSIM.ARRAY_DISPLAY_LIMIT XSIM.RADIX XSIM.TIME_UNIT XSIM.TRACE_LIMIT

source -notrace [format "%s/settings_paths.tcl" [file dirname [file normalize [info script]]]]
source -notrace [format "%s/settings_project.tcl" $project_sources_tcl]

set fw_flow_current 1
global call_by_script
set call_by_script 1

if { ! [file exists [format "%s/misc_fw_flow.tcl" $project_generated_sources_tcl]] } {
	set flowfile [open [format "%s/misc_fw_flow.tcl" $project_generated_sources_tcl] "w+"]
	puts $flowfile "set fw_flow_execute 1"
	close $flowfile
}

source -notrace [format "%s/misc_fw_flow.tcl" $project_generated_sources_tcl]

if { $fw_flow_execute != $fw_flow_current } {
	error "wrong call order of files, current call index is 1, expected call index is $fw_flow_execute"
}

import_files -norecurse "$project_import_sources_hdl/counter_fixed.v"
import_files -norecurse "$project_import_sources_hdl/RO_ref.v"
import_files -norecurse "$project_import_sources_hdl/ro_toplevel.v"
import_files -norecurse "$project_import_sources_hdl/ro4.v"
import_files -norecurse "$project_import_sources_hdl/timer_fixed.v"
import_files -norecurse "$project_import_sources_hdl/toplevel.v"
import_files -norecurse "$project_import_sources_hdl/system_wrapper.v"

set_property  ip_repo_paths "$project_import_sources_repo" [current_project]
update_ip_catalog

source -notrace "$project_import_sources_bd/cr_bd_system.tcl"
cr_bd_system ""

generate_target all [get_files "$project_sources_bd/system.bd"]

create_fileset -constrset constrs_synth

create_fileset -constrset constrs_static_1
import_files -fileset constrs_static_1 -norecurse "$project_import_sources_constr_static1/partial.xdc"
import_files -fileset constrs_static_1 -norecurse "$project_import_sources_constr_static1/pins.xdc"
import_files -fileset constrs_static_1 -norecurse "$project_import_sources_constr_static1/prohibits.xdc"
import_files -fileset constrs_static_1 -norecurse "$project_import_sources_constr_static1/puf_ref_ro4.xdc"
import_files -fileset constrs_static_1 -norecurse "$project_import_sources_constr_static1/timings.xdc"
import_files -fileset constrs_static_1 -norecurse "$project_import_sources_constr_static1/vivado.xdc"

set_property target_constrs_file "$project_sources_constr_static_1/vivado.xdc" [get_filesets constrs_static_1]
set_property used_in_synthesis false [get_files  "$project_sources_constr_static_1/pins.xdc"]
set_property used_in_synthesis false [get_files  "$project_sources_constr_static_1/vivado.xdc"]
set_property used_in_synthesis false [get_files  "$project_sources_constr_static_1/puf_ref_ro4.xdc"]


create_fileset -constrset constrs_static_2
import_files -fileset constrs_static_2 -norecurse "$project_import_sources_constr_static2/partial.xdc"
import_files -fileset constrs_static_2 -norecurse "$project_import_sources_constr_static2/pins.xdc"
import_files -fileset constrs_static_2 -norecurse "$project_import_sources_constr_static2/prohibits.xdc"
import_files -fileset constrs_static_2 -norecurse "$project_import_sources_constr_static2/puf_ref_ro4.xdc"
import_files -fileset constrs_static_2 -norecurse "$project_import_sources_constr_static2/timings.xdc"
import_files -fileset constrs_static_2 -norecurse "$project_import_sources_constr_static2/vivado.xdc"

set_property target_constrs_file "$project_sources_constr_static_2/vivado.xdc" [get_filesets constrs_static_2]
set_property used_in_synthesis false [get_files  "$project_sources_constr_static_2/pins.xdc"]
set_property used_in_synthesis false [get_files  "$project_sources_constr_static_2/vivado.xdc"]
set_property used_in_synthesis false [get_files  "$project_sources_constr_static_2/puf_ref_ro4.xdc"]


set_property constrset constrs_synth [get_runs synth_1]


set flowfile [open [format "%s/misc_fw_flow.tcl" $project_generated_sources_tcl] "w+"]
puts $flowfile [format "set fw_flow_execute %d" [expr { $fw_flow_current + 1 } ]]
close $flowfile

set call_by_script 0