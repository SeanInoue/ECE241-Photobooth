onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 50 -label CLOCK_50 /tb/CLOCK_50
add wave -noupdate -height 50 -label resetn /tb/resetn
add wave -noupdate -height 50 -label uart_read /tb/uart_read
add wave -noupdate -label counter -radix decimal /tb/u_filter_enable_reg/counter
add wave -noupdate -height 50 -label enable_i /tb/enable_i
add wave -noupdate -height 50 -label enable_o /tb/enable_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {77491 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 260
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
WaveRestoreZoom {0 ps} {262500 ps}
