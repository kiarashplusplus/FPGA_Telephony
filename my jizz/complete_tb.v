`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:26:46 12/10/2012
// Design Name:   connectedSys
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz//sys_tb.v
// Project Name:  transport
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: connectedSys
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module complete_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] onephoneNum;
	reg [4:0] oneuserInp;
	reg [15:0] oneaudioIn;
	reg [15:0] onepacketIn;
	reg [1:0] onecmdIn;
	reg sendData;
	reg[4:0] twouserInp;
	
	// Outputs
	wire [7:0] twophoneOut;
	wire [15:0] twoaudioIn;
	wire twotransportBusy;

	// Instantiate the Unit Under Test (UUT)
	complete uut (
		.clk(clk), 
		.reset(reset), 
		.onephoneNum(onephoneNum), 
		.oneuserInp(oneuserInp), 
		.oneaudioIn(oneaudioIn), 
		.onepacketIn(onepacketIn), 
		.onecmdIn(onecmdIn), 
		.sendData(sendData),
		.twophoneOut(twophoneOut), 
		.twouserInp(twouserInp), 
		.twoaudioIn(twoaudioIn), 
		.twotransportBusy(twotransportBusy)
	);
	
	always #5 clk= !clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		onephoneNum = 8'h17;
		oneuserInp = 0;
		oneaudioIn = 0;
		onepacketIn = 0;
		onecmdIn = 0;
		sendData=0;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		oneuserInp=5'h01;
		#100;
		oneuserInp=0;
		sendData=1;
		#500;
		twouserInp=5'h02;
		
		
		
	end
      
endmodule

