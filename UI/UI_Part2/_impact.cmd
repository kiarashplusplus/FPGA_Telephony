setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 2 -file "/afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI_Part2/labkit.bit"
Program -p 2 
setMode -bs
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
