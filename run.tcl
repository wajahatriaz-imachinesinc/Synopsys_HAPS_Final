database load RCPU -autocreate -technology HAPS-200
#report rtl_diagnostics -srclist vlog_inputs.txt -top_module top -out rd0

#source option.tcl

launch uc -utf uc_compile.utf -ucdb top_ucdb -v 2.0

run compile -ucdb top_ucdb -out c0
#run compile -ucdb top_ucdb -idc debug.idc -out c0

run pre_partition -tss board.tss -fdc design.fdc -area_est 1 -out pp0
export file top.est -path pp0_area

run partition -pcf partition.pcf -out pa0

run system_route -pcf partition.pcf -fdc design.fdc -optimization_priority multi_hop_path -out sr0

run system_generate -fdc design.fdc -path synthesis_files -out sg0

launch protocompiler -script ./synthesis_files/FB1_F0/FB1_F0_srs.tcl -script ./synthesis_files/FB1_F1/FB1_F1_srs.tcl

launch vivado -script ./synthesis_files/FB1_F0/vivado_srs/run_vivado_haps.tcl -script ./synthesis_files/FB1_F1/vivado_srs/run_vivado_haps.tcl

export runtime -path UC_LED_DEMO_runtime
exec copybit.sh
