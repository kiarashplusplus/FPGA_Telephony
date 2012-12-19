`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Sachin Shinde
//
// Create Date:   22:06:57 11/22/2012
// Design Name:   Text_Scroller
// Module Name:   C:/Users/Sachin Shinde/Desktop/6.111/Final Project/Verilog/Final_Project/Text_Scroller_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Text_Scroller
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Text_Scroller_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] ascii_data;
	reg ascii_data_ready;

	// Outputs
	wire [127:0] string_data;
	// DEBUG
	wire wr_en_DEBUG;
	wire [7:0] wr_data_DEBUG;
	wire [10:0] wr_addr_DEBUG;
	wire cntr_DEBUG;
	wire set_disp_DEBUG;
	wire [3:0] rel_pos_DEBUG;
	wire [10:0] rd_addr_DEBUG;
	wire [7:0] rd_data_DEBUG;
	// END DEBUG

	// Instantiate the Unit Under Test (UUT)
	Text_Scroller #(
		.SCROLL_SPEED_CNT(30),
		.SCROLL_BEGIN_CNT(40),
		.SCROLL_END_CNT(40)
		) uut (
		.clk(clk), 
		.reset(reset), 
		.ascii_data(ascii_data), 
		.ascii_data_ready(ascii_data_ready), 
		.string_data(string_data)
		,// DEBUG
		.wr_en_DEBUG(wr_en_DEBUG),
		.wr_data_DEBUG(wr_data_DEBUG),
		.wr_addr_DEBUG(wr_addr_DEBUG),
		.cntr_DEBUG(cntr_DEBUG),
		.set_disp_DEBUG(set_disp_DEBUG),
		.rel_pos_DEBUG(rel_pos_DEBUG),
		.rd_addr_DEBUG(rd_addr_DEBUG),
		.rd_data_DEBUG(rd_data_DEBUG)
		// DEBUG
	);
	// Set 100Mhz clock
	always #5 clk = ~clk;
	
	// Instantiate counter
	reg count_reset, count_fin;
	reg [31:0] count_lmt;
	reg [31:0] count_val;
	always @(posedge clk) begin
		if (count_reset) begin
			count_val <= 0;
			count_fin <= 0;
		end
		else begin
			count_val <= (count_val == count_lmt) ? count_lmt: (count_val + 1);
			count_fin <= (count_val == count_lmt);
		end
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		ascii_data = 0;
		ascii_data_ready = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		// Set 00112233445566778899AABBCCDDEEFFFFEEDDCCBBAA99887766554433221100
		@(posedge clk)
			reset = 0;
			ascii_data_ready = 1;
			ascii_data = 8'h00;
		@(posedge clk)
			ascii_data = 8'h11;
		@(posedge clk)
			ascii_data = 8'h22;
		@(posedge clk)
			ascii_data = 8'h33;
		@(posedge clk)
			ascii_data = 8'h44;
		@(posedge clk)
			ascii_data = 8'h55;
		@(posedge clk)
			ascii_data = 8'h66;
		@(posedge clk)
			ascii_data = 8'h77;
		@(posedge clk)
			ascii_data = 8'h88;
		@(posedge clk)
			ascii_data = 8'h99;
		@(posedge clk)
			ascii_data = 8'hAA;
		@(posedge clk)
			ascii_data = 8'hBB;
		@(posedge clk)
			ascii_data = 8'hCC;
		@(posedge clk)
			ascii_data = 8'hDD;
		@(posedge clk)
			ascii_data = 8'hEE;
		@(posedge clk)
			ascii_data = 8'hFF;
		@(posedge clk)
			ascii_data = 8'hFF;
		@(posedge clk)
			ascii_data = 8'hEE;
		@(posedge clk)
			ascii_data = 8'hDD;
		@(posedge clk)
			ascii_data = 8'hCC;
		@(posedge clk)
			ascii_data = 8'hBB;
		@(posedge clk)
			ascii_data = 8'hAA;
		@(posedge clk)
			ascii_data = 8'h99;
		@(posedge clk)
			ascii_data = 8'h88;
		@(posedge clk)
			ascii_data = 8'h77;
		@(posedge clk)
			ascii_data = 8'h66;
		@(posedge clk)
			ascii_data = 8'h55;
		@(posedge clk)
			ascii_data = 8'h44;
		@(posedge clk)
			ascii_data = 8'h33;
		@(posedge clk)
			ascii_data = 8'h22;
		@(posedge clk)
			ascii_data = 8'h11;
		@(posedge clk)
			ascii_data = 8'h00;
		@(posedge clk)
			ascii_data_ready = 1'b0;
			ascii_data = 8'hFF;
			count_reset <= 1;
			count_lmt <= 2000;
		@(posedge clk)
			count_reset <= 0;
		// Wait until counter finished counting
		@(posedge count_fin)
		// Set DEADBEEF
		@(posedge clk)
			ascii_data_ready = 1'b1;
			ascii_data = 8'hDE;
		@(posedge clk)
			ascii_data = 8'hAD;
		@(posedge clk)
			ascii_data = 8'hBE;
		@(posedge clk)
			ascii_data = 8'hEF;
		@(posedge clk)
			ascii_data = 8'h00;
			ascii_data_ready = 1'b0;
		@(posedge clk)
			ascii_data_ready = 1'b1;
			ascii_data = 8'h42;
		@(posedge clk)
			ascii_data_ready = 1'b0; 
	end
      
endmodule

