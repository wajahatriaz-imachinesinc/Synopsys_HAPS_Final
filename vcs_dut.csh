#!/bin/csh
 

#fail
#vlogan -full64 -work work -top R_FormatCPU -f vlog_inputs.txt -sverilog +incdir+./ "+define+synthesis" "+define+SYNTHESIS" -full64
#vcs -full64  work.top -top work.top -hw_top=R_FormatCPU

#ok
vlogan -full64 -work work -sverilog -f vlog_inputs.txt -l vlogan.log
vcs -full64 -timescale=1ns/1ns -top top -hw_top=top 



