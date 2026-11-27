onerror {resume}
quietly virtual signal -install /tb { /tb/RGB_sharpened[8:6]} R_channel_sharpened
quietly virtual function -install /tb/u_sharpener -env /tb/u_sharpener { &{/tb/u_sharpener/multiple[20], /tb/u_sharpener/multiple[19], /tb/u_sharpener/multiple[18], /tb/u_sharpener/multiple[17], /tb/u_sharpener/multiple[16], /tb/u_sharpener/multiple[15], /tb/u_sharpener/multiple[14] }} R_channel_multiple
quietly virtual function -install /tb/u_sharpener -env /tb/u_sharpener { &{/tb/u_sharpener/negative_blur[20], /tb/u_sharpener/negative_blur[19], /tb/u_sharpener/negative_blur[18], /tb/u_sharpener/negative_blur[17], /tb/u_sharpener/negative_blur[16], /tb/u_sharpener/negative_blur[15], /tb/u_sharpener/negative_blur[14] }} R_channel_negative_blur
quietly virtual function -install /tb/u_sharpener -env /tb/u_sharpener { &{/tb/u_sharpener/sum[20], /tb/u_sharpener/sum[19], /tb/u_sharpener/sum[18], /tb/u_sharpener/sum[17], /tb/u_sharpener/sum[16], /tb/u_sharpener/sum[15], /tb/u_sharpener/sum[14] }} R_channel_sum
quietly virtual function -install /tb -env /tb/u_sharpener { &{/tb/window_1_1[8], /tb/window_1_1[7], /tb/window_1_1[6] }} R_window_1_1
quietly virtual function -install /tb -env /tb/u_sharpener { &{/tb/RGB_blurred[17], /tb/RGB_blurred[16], /tb/RGB_blurred[15], /tb/RGB_blurred[14], /tb/RGB_blurred[13], /tb/RGB_blurred[12] }} R_blurred
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/enable_sharpen
add wave -noupdate -label R_blurred -radix unsigned /tb/R_blurred
add wave -noupdate -label R_window_1_1 -radix unsigned /tb/R_window_1_1
add wave -noupdate -label R_channel_sharpened -radix unsigned /tb/R_channel_sharpened
add wave -noupdate -label R_channel_multiple -radix decimal /tb/u_sharpener/R_channel_multiple
add wave -noupdate -label R_channel_negative_blur -radix decimal /tb/u_sharpener/R_channel_negative_blur
add wave -noupdate -label R_channel_sum -radix decimal /tb/u_sharpener/R_channel_sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34789 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 146
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
