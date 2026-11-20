onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label enable_invert -height 50 /tb/enable_invert
add wave -noupdate -label RGB -height 50 /tb/RGB
add wave -noupdate -label RGB_inverted -height 50 /tb/RGB_inverted
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64843 ps} 0}
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
