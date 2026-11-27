onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/enable_blur
add wave -noupdate /tb/enable_sharpen
add wave -noupdate -radix binary /tb/window_0_1
add wave -noupdate -radix binary /tb/window_1_0
add wave -noupdate -radix binary -childformat {{{/tb/window_1_1[8]} -radix binary} {{/tb/window_1_1[7]} -radix binary} {{/tb/window_1_1[6]} -radix binary} {{/tb/window_1_1[5]} -radix binary} {{/tb/window_1_1[4]} -radix binary} {{/tb/window_1_1[3]} -radix binary} {{/tb/window_1_1[2]} -radix binary} {{/tb/window_1_1[1]} -radix binary} {{/tb/window_1_1[0]} -radix binary}} -subitemconfig {{/tb/window_1_1[8]} {-radix binary} {/tb/window_1_1[7]} {-radix binary} {/tb/window_1_1[6]} {-radix binary} {/tb/window_1_1[5]} {-radix binary} {/tb/window_1_1[4]} {-radix binary} {/tb/window_1_1[3]} {-radix binary} {/tb/window_1_1[2]} {-radix binary} {/tb/window_1_1[1]} {-radix binary} {/tb/window_1_1[0]} {-radix binary}} /tb/window_1_1
add wave -noupdate -radix binary /tb/window_1_2
add wave -noupdate -radix binary /tb/window_2_1
add wave -noupdate -radix binary /tb/RGB_blurred
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15424 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 141
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
