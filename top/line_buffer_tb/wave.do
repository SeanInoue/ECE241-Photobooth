onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label resetn /tb/resetn
add wave -noupdate -label clock /tb/clock
add wave -noupdate -label sdram_rgb /tb/sdram_rgb
add wave -noupdate -label display_x /tb/display_x
add wave -noupdate -label display_y /tb/display_y
add wave -noupdate -label display_write /tb/display_write
add wave -noupdate -label window_0_0 /tb/window_0_0
add wave -noupdate -label window_0_1 /tb/window_0_1
add wave -noupdate -label window_0_2 /tb/window_0_2
add wave -noupdate -label window_1_0 /tb/window_1_0
add wave -noupdate -label window_1_1 /tb/window_1_1
add wave -noupdate -label window_1_2 /tb/window_1_2
add wave -noupdate -label window_2_0 /tb/window_2_0
add wave -noupdate -label window_2_1 /tb/window_2_1
add wave -noupdate -label window_2_2 /tb/window_2_2
add wave -noupdate -label vga_x /tb/vga_x
add wave -noupdate -label vga_y /tb/vga_y
add wave -noupdate -label vga_write_real /tb/vga_write_real
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99449 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {105 ns}
