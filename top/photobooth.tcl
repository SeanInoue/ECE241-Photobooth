# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../vga_adapter/*.v ../uart/*.v ../image_processing/*.v
# compile the Verilog code of the testbench
vlog *.v
# start the Simulator, including some libraries that may be needed
vsim work.photobooth_tb -Lf 220model -Lf altera_mf_ver -Lf verilog

log -r /*

# advance the simulation the desired amount of time
run 10000 ns
