onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label resetn -radix unsigned /tb2/resetn
add wave -noupdate -label clock -radix unsigned /tb2/clock
add wave -noupdate -label sdram_rgb -radix unsigned /tb2/sdram_rgb
add wave -noupdate -label display_x -radix unsigned /tb2/display_x
add wave -noupdate -label display_y -radix unsigned /tb2/display_y
add wave -noupdate -label display_write -radix unsigned /tb2/display_write
add wave -noupdate -label window_0_0 -radix unsigned /tb2/window_0_0
add wave -noupdate -label window_0_1 -radix unsigned /tb2/window_0_1
add wave -noupdate -label window_0_2 -radix unsigned /tb2/window_0_2
add wave -noupdate -label window_1_0 -radix unsigned /tb2/window_1_0
add wave -noupdate -label window_1_1 -radix unsigned /tb2/window_1_1
add wave -noupdate -label window_1_2 -radix unsigned /tb2/window_1_2
add wave -noupdate -label window_2_0 -radix unsigned /tb2/window_2_0
add wave -noupdate -label window_2_1 -radix unsigned /tb2/window_2_1
add wave -noupdate -label window_2_2 -radix unsigned /tb2/window_2_2
add wave -noupdate -label vga_x -radix unsigned /tb2/vga_x
add wave -noupdate -label vga_y -radix unsigned /tb2/vga_y
add wave -noupdate -label vga_write_real -radix unsigned /tb2/vga_write_real
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {577268 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 46
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {252378 ps} {673010 ps}
bookmark add wave bookmark0 {{252378 ps} {673010 ps}} 0
