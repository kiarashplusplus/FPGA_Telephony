`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:12:05 12/10/2012 
// Design Name: 
// Module Name:    connectedSys 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module complete(
	 input clk, input reset,	
	input [7:0] onephoneNum,
	input [4:0] oneuserInp,
	input [15:0] oneaudioIn,
	input [15:0] onepacketIn,
	input [1:0] onecmdIn,
	input sendData,
	input [4:0] twouserInp,
	
	output [7:0] twophoneOut,
	output [15:0] twoaudioIn,
	output twotransportBusy
	);
	
	
	wire onetransportBusy;
	
	wire oneaudioInFlag;
	wire oneaudioOutFlag;
	wire [15:0] oneaudioOut;
	wire [1:0] onecmd;
	wire [15:0] onedataOut;
	wire onesessionBusy;
	wire [7:0] onephoneOut;
	wire [3:0] onecurrent_state;
	
	
	session one (
		.clk(clk), 
		.reset(reset), 
		.phoneNum(onephoneNum), 
		.userInp(oneuserInp), 
		.audioIn(oneaudioIn), 
		.cmdIn(onecmdIn), 
		.packetIn(onepacketIn), 
		.transportBusy(onetransportBusy), 
		.audioInFlag(oneaudioInFlag), 
		.audioOutFlag(oneaudioOutFlag), 
		.audioOut(oneaudioOut), 
		.cmd(onecmd), 
		.dataOut(onedataOut), 
		.sessionBusy(onesessionBusy), 
		.phoneOut(onephoneOut), 
		.current_state(onecurrent_state)
	);

 
	wire sending;
	wire [7:0] sendPacketOut;
	wire [10:0] senderCounter;
	
	transportSend sender (
		.clk(clk), 
		.reset(reset), 
		.cmd(onecmd), 
		.data(onedataOut), 
		.sendData(sendData), 
		.sending(sending), 
		.packetOut(sendPacketOut), 
		.busy(onetransportBusy),
		.ready_data_count(senderCounter)
	);

	wire sessionBusy;

	wire [1:0] sendingToSession;
	wire [15:0] sessionData;
	wire [7:0] dafuq;
	wire [10:0] rcvCounter;

	transportRcv receive (
		.clk(clk), 
		.reset(reset), 
		.rcvSignal(sending), 
		.packetIn(sendPacketOut), 
		.sessionBusy(sessionBusy), 
		.sendingToSession(sendingToSession), 
		.data(sessionData), 
		.rcv_data_count(rcvCounter),
		.dafuq(dafuq)
	);


	wire twoaudioInFlag;
	wire twoaudioOutFlag;
	wire [15:0] twoaudioOut;
	wire [1:0] twocmd;
	wire [15:0] twodataOut;
	wire [7:0] twophoneNum;
	wire [3:0] twocurrent_state;


	session two (
		.clk(clk), 
		.reset(reset), 
		.phoneNum(twophoneNum), 
		.userInp(twouserInp), 
		.audioIn(twoaudioIn), 
		.cmdIn(sendingToSession), 
		.packetIn(sessionData), 
		.transportBusy(twotransportBusy), 
		.audioInFlag(twoaudioInFlag), 
		.audioOutFlag(twoaudioOutFlag), 
		.audioOut(twoaudioOut), 
		.cmd(twocmd), 
		.dataOut(twodataOut), 
		.sessionBusy(sessionBusy), 
		.phoneOut(twophoneOut), 
		.current_state(twocurrent_state)
	);	
	
	


endmodule
