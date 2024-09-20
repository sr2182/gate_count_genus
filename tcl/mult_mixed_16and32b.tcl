set_db lib_search_path /umbc/software/cadence/installs/GENUS21_2023_09_08/share/synth/tutorials/tech
set_db library tutorial.lib

read_hdl -sv ../srcs/sources/mult_mixed_16and32.sv
read_hdl -sv ../srcs/sources/f32_to_p16.sv 
read_hdl -sv ../srcs/sources/p16_to_f32.sv
read_hdl ../srcs/sources/FloatingMultiplication_v1.v 

elaborate 
check_design -unresolved mult_mixed_16and32 

syn_generic 
syn_map
syn_opt

check_design mult_mixed_16and32
report_gates mult_mixed_16and32 > ./mult_mixed_16and32_gates.txt
report_area mult_mixed_16and32 > ./mult_mixed_16and32_area.txt