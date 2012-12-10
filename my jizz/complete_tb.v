`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:12:42 12/10/2012
// Design Name:   complete
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz//complete_tb.v
// Project Name:  transport
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: complete
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
	reg [15:0] onepacketIn;
	reg [1:0] onecmdIn;
	reg sendData;
	reg [4:0] twouserInp;

	// Outputs
	wire [7:0] twophoneOut;
	wire twotransportBusy;

	// Instantiate the Unit Under Test (UUT)
	complete uut (
		.clk(clk), 
		.reset(reset), 
		.onephoneNum(onephoneNum), 
		.oneuserInp(oneuserInp), 
		.onepacketIn(onepacketIn), 
		.onecmdIn(onecmdIn), 
		.sendData(sendData), 
		.twouserInp(twouserInp), 
		.twophoneOut(twophoneOut), 
		.twotransportBusy(twotransportBusy)
	);
	always #5 clk=!clk;
	always #20 onepacketIn=onepacketIn+2;
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		onephoneNum = 8'h22;
		oneuserInp = 0;
		onepacketIn = 0;
		onecmdIn = 0;
		sendData = 1;
		twouserInp = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
      oneuserInp=5'h01;
		#100;
		oneuserInp=0;
		//#300;
		//oneuserInp=5'h5;
		#100;
		oneuserInp=0;
		#500;

		
	end
      
endmodule

