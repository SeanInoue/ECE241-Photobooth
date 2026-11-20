quit -sim

vlib work;

vlog ../vga_adapter/*.v ../uart/*.v ../image_processing/*.v
vlog *.v

vsim work.photobooth_tb -Lf 220model -Lf altera_mf_ver -Lf verilog

log -r /*

do wave.do

run 25000 ns
