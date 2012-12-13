onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /complete_tb/uut/clk
add wave -noupdate -format Logic /complete_tb/uut/reset
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/onecurrent_state
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/twocurrent_state
add wave -noupdate -format Literal /complete_tb/uut/oneuserInp
add wave -noupdate -format Literal /complete_tb/uut/twouserInp
add wave -noupdate -format Literal /complete_tb/uut/onecmdIn
add wave -noupdate -format Logic /complete_tb/uut/twotransportBusy
add wave -noupdate -format Logic /complete_tb/uut/onetransportBusy
add wave -noupdate -format Logic /complete_tb/uut/onemicFlag
add wave -noupdate -format Literal /complete_tb/uut/onecmd
add wave -noupdate -format Literal /complete_tb/uut/onedataOut
add wave -noupdate -format Logic /complete_tb/uut/onesessionBusy
add wave -noupdate -format Literal /complete_tb/uut/onephoneOut
add wave -noupdate -format Literal /complete_tb/uut/onespkBufferOut
add wave -noupdate -format Logic /complete_tb/uut/onemicBufferFull
add wave -noupdate -format Logic /complete_tb/uut/onemicBufferEmpty
add wave -noupdate -format Logic /complete_tb/uut/onespkBufferFull
add wave -noupdate -format Logic /complete_tb/uut/onespkBufferEmpty
add wave -noupdate -format Literal /complete_tb/uut/onemicBufferOut
add wave -noupdate -format Logic /complete_tb/uut/sending
add wave -noupdate -format Literal /complete_tb/uut/sendPacketOut
add wave -noupdate -format Literal /complete_tb/uut/senderCounter
add wave -noupdate -format Logic /complete_tb/uut/sessionBusy
add wave -noupdate -format Literal /complete_tb/uut/sendingToSession
add wave -noupdate -format Literal /complete_tb/uut/sessionData
add wave -noupdate -format Literal /complete_tb/uut/dafuq
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/rcvCounter
add wave -noupdate -format Logic /complete_tb/uut/twomicFlag
add wave -noupdate -format Literal /complete_tb/uut/twoaudioOut
add wave -noupdate -format Literal /complete_tb/uut/twocmd
add wave -noupdate -format Literal /complete_tb/uut/twodataOut
add wave -noupdate -format Literal /complete_tb/uut/twophoneNum
add wave -noupdate -format Literal /complete_tb/uut/twospkBufferOut
add wave -noupdate -format Logic /complete_tb/uut/twomicBufferFull
add wave -noupdate -format Logic /complete_tb/uut/twomicBufferEmpty
add wave -noupdate -format Logic /complete_tb/uut/twospkBufferFull
add wave -noupdate -format Logic /complete_tb/uut/twospkBufferEmpty
add wave -noupdate -format Literal /complete_tb/uut/twomicBufferOut
add wave -noupdate -format Logic /complete_tb/uut/s2sending
add wave -noupdate -format Literal /complete_tb/uut/s2sendPacketOut
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/s2senderCounter
add wave -noupdate -format Literal -radix binary /complete_tb/uut/r2dafuq
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/r2rcvCounter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {855940 ps} 0}
configure wave -namecolwidth 329
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
WaveRestoreZoom {812155 ps} {874897 ps}
