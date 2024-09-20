set_db lib_search_path /umbc/software/cadence/installs/GENUS21_2023_09_08/share/synth/tutorials/tech
set_db library tutorial.lib

read_hdl -sv src/mult_mixed_16and24.sv
read_hdl -sv src/f32_to_p16.sv 
read_hdl -sv src/p16_to_f32.sv
read_hdl src/FloatingMultiplication_v1.v 

elaborate 
check_design -unresolved mult_mixed_16and24 

syn_generic 
syn_map
syn_opt

report_gates mult_mixed_16and24 > ./mult_mixed_16and24_gates.txt
report_area mult_mixed_16and24 > ./mult_mixed_16and24_area.txt
