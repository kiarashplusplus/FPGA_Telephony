onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tRcv_tb/uut/clk
add wave -noupdate -format Logic /tRcv_tb/uut/reset
add wave -noupdate -format Logic /tRcv_tb/uut/rcvSignal
add wave -noupdate -format Literal /tRcv_tb/uut/packetIn
add wave -noupdate -format Logic /tRcv_tb/uut/sessionBusy
add wave -noupdate -format Literal /tRcv_tb/uut/sendingToSession
add wave -noupdate -format Literal -radix hexadecimal /tRcv_tb/uut/data
add wave -noupdate -format Literal /tRcv_tb/uut/dafuq
add wave -noupdate -format Literal /tRcv_tb/uut/rcvIn
add wave -noupdate -format Logic /tRcv_tb/uut/rcv_rd_en
add wave -noupdate -format Logic /tRcv_tb/uut/rcv_wr_en
add wave -noupdate -format Literal -radix decimal /tRcv_tb/uut/rcv_data_count
add wave -noupdate -format Literal -radix binary /tRcv_tb/uut/rcvOut
add wave -noupdate -format Logic /tRcv_tb/uut/rcvEmpty
add wave -noupdate -format Logic /tRcv_tb/uut/rcvFull
add wave -noupdate -format Literal /tRcv_tb/uut/rcvState
add wave -noupdate -format Literal -radix decimal /tRcv_tb/uut/packetSizeCounter
add wave -noupdate -format Literal -radix decimal /tRcv_tb/uut/counter
add wave -noupdate -format Literal /tRcv_tb/uut/buffer
add wave -noupdate -format Literal -radix decimal /tRcv_tb/uut/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {762600 ps} 0}
configure wave -namecolwidth 248
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
WaveRestoreZoom {740373 ps} {899221 ps}
