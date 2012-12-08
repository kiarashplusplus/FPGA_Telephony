onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tSend_tb/clk
add wave -noupdate -format Logic /tSend_tb/reset
add wave -noupdate -format Literal /tSend_tb/cmd
add wave -noupdate -format Literal /tSend_tb/data
add wave -noupdate -format Logic /tSend_tb/sendData
add wave -noupdate -format Logic /tSend_tb/sending
add wave -noupdate -format Literal /tSend_tb/packetOut
add wave -noupdate -format Logic /tSend_tb/busy
add wave -noupdate -format Literal -radix decimal /tSend_tb/uut/packetSizeCounter
add wave -noupdate -format Literal -radix decimal /tSend_tb/uut/buffer_data_count
add wave -noupdate -format Logic /tSend_tb/uut/auFlag
add wave -noupdate -format Literal /tSend_tb/uut/twoCounter
add wave -noupdate -format Literal -radix decimal /tSend_tb/uut/ready_data_count
add wave -noupdate -format Logic /tSend_tb/uut/bufferEmpty
add wave -noupdate -format Logic /tSend_tb/uut/buffer_rd_en
add wave -noupdate -format Logic /tSend_tb/uut/buffer_wr_en
add wave -noupdate -format Logic /tSend_tb/uut/ready_wr_en
add wave -noupdate -format Literal /tSend_tb/uut/bufferOut
add wave -noupdate -format Literal /tSend_tb/uut/readyIn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {645000 ps} 0}
configure wave -namecolwidth 277
configure wave -valuecolwidth 65
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
WaveRestoreZoom {614057 ps} {731376 ps}
