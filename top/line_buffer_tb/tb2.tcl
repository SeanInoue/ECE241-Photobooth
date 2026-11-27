quit -sim

vlib work;

vlog ../*.v
vlog *.v

vsim work.tb2 -Lf 220model -Lf altera_mf_ver -Lf verilog

log -r /*

do wave2.do

run 1000 ns
