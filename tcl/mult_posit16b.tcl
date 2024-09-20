set_db lib_search_path /umbc/software/cadence/installs/GENUS21_2023_09_08/share/synth/tutorials/tech
set_db library tutorial.lib

read_hdl -sv ../srcs/pacogen_multiplier_16.sv ../srcs/mult_N32_ES6_PIPE6_v1.v
elaborate 
check_design -unresolved posit_multiplier_16

syn_generic 
syn_map
syn_opt

report_gates posit_multiplier_16 > ./mult_posit16_gates.txt 
report_area posit_multiplier_16 > ./mult_posit16_area.txt 
