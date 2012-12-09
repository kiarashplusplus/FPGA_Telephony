`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:14:18 12/06/2012
// Design Name:   user_interface
// Module Name:   /afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI/ui_test.v
// Project Name:  UI
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: user_interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ui_test;

	// Inputs
	reg clk;
	reg s7;
	reg s6;
	reg s5;
	reg s4;
	reg s3;
	reg s2;
	reg s1;
	reg b3;
	reg b2;
	reg b1;
	reg b0;
	reg reset;
	reg enter;
	reg up;
	reg down;
	reg left;
	reg right;
	reg [2:0] inc_command;
	reg init;
	reg incoming_call;

	// Instantiate the Unit Under Test (UUT)
	user_interface uut (
		.clk(clk), 
		.s7(s7), 
		.s6(s6), 
		.s5(s5), 
		.s4(s4), 
		.s3(s3), 
		.s2(s2), 
		.s1(s1), 
		.b3(b3), 
		.b2(b2), 
		.b1(b1), 
		.b0(b0), 
		.reset(reset), 
		.enter(enter), 
		.up(up), 
		.down(down), 
		.left(left), 
		.right(right), 
		.inc_command(inc_command), 
		.init(init), 
		.incoming_call(incoming_call)
	);

	always #5 clk=!clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		s7 = 0;
		s6 = 0;
		s5 = 0;
		s4 = 0;
		s3 = 0;
		s2 = 0;
		s1 = 0;
		b3 = 0;
		b2 = 0;
		b1 = 0;
		b0 = 0;
		reset = 0;
		enter = 0;
		up = 0;
		down = 0;
		left = 0;
		right = 0;
		inc_command = 0;
		init = 0;
		incoming_call = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		enter=1;
		#10;
		enter=0; //should be in idle mode
		

	end
      
endmodule

