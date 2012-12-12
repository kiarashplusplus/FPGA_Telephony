`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:43:30 12/11/2012
// Design Name:   combinedTransport
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz//combinedTransport_tb.v
// Project Name:  transport
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: combinedTransport
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module combinedTransport_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] cmd;
	reg [15:0] data;
	reg dummyBufferRd;

	// Outputs
	wire [7:0] packetOut;
	wire [7:0] phoneNum;
	wire [9:0] dummyBufferCount;
	wire dummyBufferEmpty;
	wire busy;

	// Instantiate the Unit Under Test (UUT)
	combinedTransport uut (
		.clk(clk), 
		.reset(reset), 
		.cmd(cmd), 
		.data(data), 
		.packetOut(packetOut), 
		.dummyBufferRd(dummyBufferRd),
		.busy(busy),
		.phoneNum(phoneNum), 
		.dummyBufferCount(dummyBufferCount), 
		.dummyBufferEmpty(dummyBufferEmpty)
	);
	
	always #5 clk= !clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		cmd = 0;
		data = 0;
		dummyBufferRd=0;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here	
		cmd=2'b01;
		data=16'b1010_0011_1111_0001;
		#50;
		cmd=0;
		#400;
		dummyBufferRd=1;
		cmd=2'b10;
		data=16'b1010_0011_1111_0001;
		
		
	end
      
endmodule

