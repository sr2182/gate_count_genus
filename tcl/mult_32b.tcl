set_db lib_search_path /umbc/software/cadence/installs/GENUS21_2023_09_08/share/synth/tutorials/tech
set_db library tutorial.lib

read_hdl -sv ../src/fp_mult_32b.sv ../src/FloatingMultiplication_v1.v
elaborate 
check_design -unresolved fp_mult_32b

syn_generic 
syn_map
syn_opt

report_gates fp_mult_32b > ./mult_fp32_gates.txt 
