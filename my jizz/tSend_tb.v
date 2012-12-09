`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:42:21 12/08/2012
// Design Name:   transportSend
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz//tSend_tb.v
// Project Name:  transport
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: transportSend
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tSend_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] cmd;
	reg [15:0] data;
	reg sendData;

	// Outputs
	wire sending;
	wire [7:0] packetOut;
	wire busy;

	// Instantiate the Unit Under Test (UUT)
	transportSend uut (
		.clk(clk), 
		.reset(reset), 
		.cmd(cmd), 
		.data(data), 
		.sendData(sendData), 
		.sending(sending), 
		.packetOut(packetOut), 
		.busy(busy)
	);
	
	always #5 clk= !clk;
	always #20 data=data+1;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		cmd = 0;
		data = 16'b1000_0000_0000_0000;
		sendData = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		cmd=2'b01;
		#20;
		cmd=0;
		#200;
		cmd=2'b10;
		#400;
		cmd=0;
		#400;
		sendData=1;
		#20;
		sendData=0;
		#200;
		cmd=2'b10;
		#200;
		sendData=1;
		#20;
		sendData=0;
		#500;		

	end
      
endmodule

