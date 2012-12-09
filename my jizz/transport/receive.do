onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tRcv_tb/clk
add wave -noupdate -format Logic /tRcv_tb/reset
add wave -noupdate -format Logic /tRcv_tb/rcvSignal
add wave -noupdate -format Literal /tRcv_tb/packetIn
add wave -noupdate -format Logic /tRcv_tb/sessionBusy
add wave -noupdate -format Literal /tRcv_tb/sendingToSession
add wave -noupdate -format Logic /tRcv_tb/dafuq
add wave -noupdate -format Logic /tRcv_tb/uut/rcv_rd_en
add wave -noupdate -format Logic /tRcv_tb/uut/rcv_wr_en
add wave -noupdate -format Literal -radix decimal /tRcv_tb/uut/rcv_data_count
add wave -noupdate -format Literal -radix decimal /tRcv_tb/uut/state
add wave -noupdate -format Literal /tRcv_tb/uut/rcvIn
add wave -noupdate -format Literal /tRcv_tb/uut/rcvOut
add wave -noupdate -format Literal /tRcv_tb/uut/buffer
add wave -noupdate -format Logic /tRcv_tb/uut/rcvFlag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {271903 ps} 0}
configure wave -namecolwidth 291
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
configure wave -timelineunits ps
update
WaveRestoreZoom {258530 ps} {314042 ps}
