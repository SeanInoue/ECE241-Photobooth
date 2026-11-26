set source_dir .
if {[file exists top/sdram_frame_buffer_tb.sv]} {
    set source_dir top
}
if {![file isdirectory work]} {
    vlib work
}
vlog -sv [file join $source_dir sdram_frame_buffer.v] [file join $source_dir sdram_frame_buffer_tb.sv]
vsim -onfinish stop -voptargs=+acc work.sdram_frame_buffer_tb

set tb sim:/sdram_frame_buffer_tb
add wave -label clock $tb/clock
add wave -label resetn $tb/resetn

add wave -divider {Pixel input and FIFO}
add wave -label pixel_valid $tb/pixel_valid
add wave -label pixel -radix hexadecimal $tb/pixel
add wave -label pixel_x -radix unsigned $tb/pixel_x
add wave -label pixel_y -radix unsigned $tb/pixel_y
add wave -label fifo_used -radix unsigned $tb/dut/fifo_used

add wave -divider {SDRAM requests}
add wave -label mem_write $tb/mem_write
add wave -label mem_read $tb/mem_read
add wave -label mem_waitrequest $tb/mem_waitrequest
add wave -label mem_address -radix unsigned $tb/mem_address
add wave -label mem_writedata -radix hexadecimal $tb/mem_writedata
add wave -label write_accepted $tb/write_accepted
add wave -label read_accepted $tb/read_accepted

add wave -divider {SDRAM responses and display}
add wave -label copying $tb/dut/copying
add wave -label mem_readdatavalid $tb/mem_readdatavalid
add wave -label mem_readdata -radix hexadecimal $tb/mem_readdata
add wave -label display_write $tb/display_write
add wave -label display_x -radix unsigned $tb/display_x
add wave -label display_y -radix unsigned $tb/display_y

run -all
if {[examine -radix unsigned $tb/test_passed] != 1} {
    error {SDRAM frame buffer test failed. See the simulator transcript.}
}
if {![batch_mode]} {
    view wave
    wave zoom full
}
