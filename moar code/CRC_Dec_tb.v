`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Sachin Shinde
//
// Create Date:   00:45:13 12/08/2012
// Design Name:   CRC_Dec
// Module Name:   /afs/athena.mit.edu/user/s/h/shinde/Desktop/Final_Project/CRC_Dec_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CRC_Dec
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CRC_Dec_tb;

	// Inputs
	reg clk_40mhz;
	reg reset;
	reg [7:0] PHY_RX;
	reg PHY_RX_ready;

	// Outputs
	wire [7:0] D_RX;
	wire D_RX_ready;

	// Instantiate the Unit Under Test (UUT)
	CRC_Dec uut (
		.clk_40mhz(clk_40mhz), 
		.reset(reset), 
		.PHY_RX(PHY_RX), 
		.PHY_RX_ready(PHY_RX_ready), 
		.D_RX(D_RX), 
		.D_RX_ready(D_RX_ready)
	);

	always #5 clk_40mhz = ~clk_40mhz;

	initial begin
		// Initialize Inputs
		clk_40mhz = 0;
		reset = 1;
		PHY_RX = 0;
		PHY_RX_ready = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(negedge clk_40mhz)
			reset = 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
			PHY_RX_ready <= 1;
			PHY_RX <= 8'hEF;
		@(negedge clk_40mhz)
			PHY_RX <= 8'hBE;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h61;
		@(negedge clk_40mhz)
			PHY_RX <= 8'h88;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;
		@(negedge clk_40mhz)
		@(negedge clk_40mhz)
		
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 0;
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 0;
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 0;
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hA9;  // RANDOM BIT ERROR
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 0;
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 0;
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBD;  // RANDOM BIT ERROR
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 0;
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//		@(negedge clk_40mhz)
//			PHY_RX_ready <= 1;
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hEF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAD;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hBA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hCA;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hDE;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hED;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hAC;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'hFF;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h00;
//		@(negedge clk_40mhz)
//			PHY_RX <= 8'h82;
		@(negedge clk_40mhz)
			PHY_RX_ready <= 0;	
	end
      
endmodule

