`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Sachin Shinde
//
// Create Date:   20:43:44 11/20/2012
// Design Name:   PHY_RX_Sample
// Module Name:   C:/Users/Sachin Shinde/Desktop/6.111/Final Project/Verilog/Final_Project/PHY_RX_Sample_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PHY_RX_Sample
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module PHY_RX_Sample_tb;

	// Inputs
	reg clk_40mhz;
	reg clk_160mhz;
	reg reset;
	reg RX;

	// Outputs
	wire out_ready;
	wire [7:0] RX_sampled;

	// DEBUG
	wire RX_stable_DEBUG;
	wire empty_DEBUG;
	wire [1:0] rd_d_cnt_DEBUG;
	wire start_DEBUG;
	// END DEBUG

	// Instantiate the Unit Under Test (UUT)
	PHY_RX_Sample uut (
		.clk_40mhz(clk_40mhz), 
		.clk_160mhz(clk_160mhz), 
		.reset(reset), 
		.RX(RX), 
		.out_ready(out_ready), 
		.RX_sampled(RX_sampled)
		,// DEBUG
		.RX_stable_DEBUG(RX_stable_DEBUG),
		.empty_DEBUG(empty_DEBUG),
		.rd_d_cnt_DEBUG(rd_d_cnt_DEBUG),
		.start_DEBUG(start_DEBUG)
		// END DEBUG
	);

	// Set clocks
	always #12.5 clk_40mhz = ~clk_40mhz;
	always #3.125 clk_160mhz = ~clk_160mhz;
	
	initial begin
		// Align clocks
		clk_40mhz = 0;
		clk_160mhz = 0;
		// Reset at start
		reset = 1;
		// Have no inputs at start
		RX = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(posedge clk_160mhz)
			reset = 0;
			RX = 1;
		@(posedge clk_160mhz)
			RX = 0;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 0;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 0;
		@(posedge clk_160mhz)
			RX = 0;
		// First byte written: 10110100
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 0;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 0;
		@(posedge clk_160mhz)
			RX = 1;
		// Second byte written: 11101101
		@(posedge clk_160mhz)
			RX = 1;
		@(posedge clk_160mhz)
			RX = 0;
		@(posedge clk_160mhz)
			RX = 1;
	end   
endmodule

