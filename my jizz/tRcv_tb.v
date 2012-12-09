`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:41:36 12/08/2012
// Design Name:   transportRcv
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz//tRcv_tb.v
// Project Name:  transport
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: transportRcv
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tRcv_tb;

	// Inputs
	reg clk;
	reg reset;
	reg rcvSignal;
	reg [7:0] packetIn;
	reg sessionBusy;

	// Outputs
	wire [1:0] sendingToSession;
	wire [15:0] data;
	wire dafuq;

	// Instantiate the Unit Under Test (UUT)
	transportRcv uut (
		.clk(clk), 
		.reset(reset), 
		.rcvSignal(rcvSignal), 
		.packetIn(packetIn), 
		.sessionBusy(sessionBusy), 
		.sendingToSession(sendingToSession), 
		.data(data), 
		.dafuq(dafuq)
	);


	always #5 clk= !clk;
	always #5 packetIn=packetIn+2;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		rcvSignal = 0;
		packetIn = 8'b1000_0000;
		sessionBusy = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rcvSignal=1;
		#100;
		rcvSignal=0;
		#50;
		sessionBusy=0;
		#50;
		rcvSignal=1;
		#100;
		reset=1;
		#50;
		reset=0;

	end
      
endmodule

