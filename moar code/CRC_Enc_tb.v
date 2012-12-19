`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Sachin Shinde
//
// Create Date:   19:46:50 12/07/2012
// Design Name:   CRC_Enc
// Module Name:   /afs/athena.mit.edu/user/s/h/shinde/Desktop/Final_Project/CRC_Enc_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CRC_Enc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CRC_Enc_tb;

	// Inputs
	reg clk_40mhz;
	reg reset;
	reg [7:0] D_TX;
	reg D_TX_ready;
	reg [5:0] pckt_num;

	// Outputs
	wire sts;
	wire we;
	wire [10:0] addr;
	wire [7:0] data;

	// Instantiate the Unit Under Test (UUT)
	CRC_Enc uut (
		.clk_40mhz(clk_40mhz), 
		.reset(reset), 
		.sts(sts), 
		.D_TX(D_TX), 
		.D_TX_ready(D_TX_ready), 
		.pckt_num(pckt_num), 
		.we(we), 
		.addr(addr), 
		.data(data)
	);

	always #5 clk_40mhz = ~clk_40mhz;
	
	initial begin
		// Initialize Inputs
		clk_40mhz = 0;
		reset = 1;
		D_TX = 0;
		D_TX_ready = 0;
		pckt_num = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(negedge clk_40mhz)
			reset = 0;
		@(!sts)
		@(negedge clk_40mhz)
			D_TX_ready <= 1;
			D_TX <= 8'hEF;
			pckt_num <= 6'hAF;
		@(negedge clk_40mhz)
			D_TX <= 8'hBE;
		@(negedge clk_40mhz)
//			D_TX <= 8'hAD;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hFE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hCA;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hBE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hBA;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hCA;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hED;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hAC;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hEF;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hBE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hAD;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hFE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hCA;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hBE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hBA;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hCA;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hED;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hAC;
//		@(negedge clk_40mhz)
//			D_TX <= 8'hFF;
//		@(negedge clk_40mhz)
			D_TX_ready <= 0;
	end
      
endmodule

