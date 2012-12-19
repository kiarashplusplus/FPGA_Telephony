`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:28:35 11/24/2012
// Design Name:   CF_Interface
// Module Name:   C:/Users/Sachin Shinde/Desktop/6.111/Final Project/Verilog/Final_Project/CF_Interface_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CF_Interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CF_Interface_tb;

	// Inputs
	reg clk_27mhz;
	reg reset;
	reg [1:0] cmd;
	reg [27:0] LBA;
	reg [7:0] SC;
	reg [15:0] din;
	reg systemace_mpbrdy;

	// Outputs
	wire we_req;
	wire [15:0] dout;
	wire nd;
	wire CF_detect;
	wire [27:0] LBA_max;
	wire ready;
	wire [6:0] systemace_address;
	wire systemace_ce_b;
	wire systemace_we_b;
	wire systemace_oe_b;

	// Bidirs
	wire [15:0] systemace_data;
	reg [15:0] systemace_data_reg;
	assign systemace_data = systemace_data_reg;

	// Instantiate the Unit Under Test (UUT)
	CF_Interface uut (
		.clk_27mhz(clk_27mhz), 
		.reset(reset), 
		.cmd(cmd), 
		.LBA(LBA), 
		.SC(SC), 
		.din(din), 
		.we_req(we_req), 
		.dout(dout), 
		.nd(nd), 
		.CF_detect(CF_detect), 
		.LBA_max(LBA_max), 
		.ready(ready), 
		.systemace_data(systemace_data), 
		.systemace_address(systemace_address), 
		.systemace_ce_b(systemace_ce_b), 
		.systemace_we_b(systemace_we_b), 
		.systemace_oe_b(systemace_oe_b), 
		.systemace_mpbrdy(systemace_mpbrdy)
	);
	
	// Clock is 100MHz
	always clk_27mhz = ~clk_27mhz;

	initial begin
		// Initialize Inputs
		clk_27mhz = 0;
		reset = 0;
		cmd = 0;
		LBA = 0;
		SC = 0;
		din = 0;
		systemace_mpbrdy = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
	end
      
endmodule

