`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:43:25 12/10/2012
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
	reg [3:0] oneInp;
	reg [3:0] twoInp;

	// Outputs
	wire [3:0] onecurrent_state;
	wire [3:0] twocurrent_state;

	// Instantiate the Unit Under Test (UUT)
	complete uut (
		.clk(clk), 
		.reset(reset), 
		.oneInp(oneInp), 
		.twoInp(twoInp), 
		.onecurrent_state(onecurrent_state), 
		.twocurrent_state(twocurrent_state)
	);

	always #5 clk=!clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		oneInp = 0;
		twoInp = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		oneInp=4'h1;
		#500;
		twoInp=4'h5;
		
		

	end
      
endmodule

