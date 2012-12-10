onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /complete_tb/uut/clk
add wave -noupdate -format Logic /complete_tb/uut/reset
add wave -noupdate -format Literal /complete_tb/uut/onephoneNum
add wave -noupdate -format Literal /complete_tb/uut/oneuserInp
add wave -noupdate -format Literal /complete_tb/uut/oneaudioIn
add wave -noupdate -format Literal /complete_tb/uut/onepacketIn
add wave -noupdate -format Literal /complete_tb/uut/onecmdIn
add wave -noupdate -format Logic /complete_tb/uut/sendData
add wave -noupdate -format Literal /complete_tb/uut/twophoneNum
add wave -noupdate -format Literal /complete_tb/uut/twouserInp
add wave -noupdate -format Literal /complete_tb/uut/twoaudioIn
add wave -noupdate -format Logic /complete_tb/uut/twotransportBusy
add wave -noupdate -format Logic /complete_tb/uut/onetransportBusy
add wave -noupdate -format Logic /complete_tb/uut/oneaudioInFlag
add wave -noupdate -format Logic /complete_tb/uut/oneaudioOutFlag
add wave -noupdate -format Literal /complete_tb/uut/oneaudioOut
add wave -noupdate -format Literal /complete_tb/uut/onecmd
add wave -noupdate -format Literal -radix hexadecimal /complete_tb/uut/onedataOut
add wave -noupdate -format Logic /complete_tb/uut/onesessionBusy
add wave -noupdate -format Literal /complete_tb/uut/onephoneOut
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/onecurrent_state
add wave -noupdate -format Logic /complete_tb/uut/sending
add wave -noupdate -format Literal /complete_tb/uut/sendPacketOut
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/senderCounter
add wave -noupdate -format Logic /complete_tb/uut/sessionBusy
add wave -noupdate -format Literal /complete_tb/uut/sendingToSession
add wave -noupdate -format Literal /complete_tb/uut/sessionData
add wave -noupdate -format Logic /complete_tb/uut/dafuq
add wave -noupdate -format Literal -radix decimal /complete_tb/uut/rcvCounter
add wave -noupdate -format Logic /complete_tb/uut/twoaudioInFlag
add wave -noupdate -format Logic /complete_tb/uut/twoaudioOutFlag
add wave -noupdate -format Literal /complete_tb/uut/twoaudioOut
add wave -noupdate -format Literal /complete_tb/uut/twocmd
add wave -noupdate -format Literal /complete_tb/uut/twodataOut
add wave -noupdate -format Literal /complete_tb/uut/twophoneOut
add wave -noupdate -format Literal /complete_tb/uut/twocurrent_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {285286 ps} 0}
configure wave -namecolwidth 275
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
WaveRestoreZoom {278920 ps} {432597 ps}
