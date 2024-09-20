set_db lib_search_path /umbc/software/cadence/installs/GENUS21_2023_09_08/share/synth/tutorials/tech
set_db library tutorial.lib

read_hdl -sv ../srcs/sources/fp_mult_24b.sv ../srcs/sources/FloatingMultiplication_v1.v
elaborate 
check_design -unresolved fp_mult_24b

syn_generic 
syn_map
syn_opt

report_gates fp_mult_24b > ./mult_fp24_gates.txt 
report_area fp_mult_24b > ./mult_fp24_area.txt 