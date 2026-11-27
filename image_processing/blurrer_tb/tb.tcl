quit -sim

vlib work;

vlog ../*.v
vlog *.v

vsim work.tb -Lf 220model -Lf altera_mf_ver -Lf verilog

log -r /*

do wave.do

run 100 ns
