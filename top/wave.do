onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clock -radix binary /photobooth_tb/u_photobooth/clock
add wave -noupdate -label resetn -radix binary /photobooth_tb/u_photobooth/resetn
add wave -noupdate -label enable_invert -radix binary /photobooth_tb/u_photobooth/enable_invert
add wave -noupdate -label enable_grayscale -radix binary /photobooth_tb/u_photobooth/enable_grayscale
add wave -noupdate -divider pixel
add wave -noupdate -label X -radix unsigned /photobooth_tb/u_photobooth/X
add wave -noupdate -label Y -radix unsigned /photobooth_tb/u_photobooth/Y
add wave -noupdate -format Analog-Step -height 74 -label RGB -max 511.0 -radix unsigned /photobooth_tb/u_photobooth/RGB
add wave -noupdate -format Analog-Step -height 74 -label RGB_processed -max 511.0 -radix unsigned /photobooth_tb/u_photobooth/RGB_processed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95000 ps} 0}
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
WaveRestoreZoom {0 ps} {10500 ns}
