`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Sachin Shinde
// 
// Create Date:    05:53:42 11/12/2012 
// Design Name: 
// Module Name:    PHY_RX_Sample 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Take samples at 160Mhz, output as 8-bit bus at 40Mhz w/ ready 
//              signal (ready signal initially low after reset, then high every
//              other cycle). New data available on rise of the ready. 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PHY_RX_Sample(
	input clk_40mhz,
	input clk_160mhz,
	input reset,
	input RX,
	output reg out_ready,
	output [7:0] RX_sampled
//	,// DEBUG OUTPUTS
//	output RX_stable_DEBUG,
//	output empty_DEBUG,
//	output [1:0] rd_d_cnt_DEBUG,
//	output start_DEBUG
//	// END DEBUG OUTPUTS
   );
	
	// Reduce odds of metastability in raw input signal
	reg RX_1, RX_2, RX_stable;
	always @(posedge clk_160mhz) begin
		RX_1 <= RX;
		RX_2 <= RX_1;
		RX_stable <= RX_2;
	end
	
	// Generate 1:8 Asymmetric Asynchronous FWFT FIFO for demultiplexing
	reg rd_en, wr_en;
	wire [7:0] RX_DMX;
	wire empty;
	wire [4:0] rd_d_cnt;
	PHY_RX_FIFO_1 RX_FIFO_1(
		.din(RX_stable),
		.rd_clk(clk_40mhz),
		.rd_en(rd_en),
		.rst(reset),
		.wr_clk(clk_160mhz),
		.wr_en(wr_en),
		.dout(RX_DMX),
		.empty(empty),
		.rd_data_count(rd_d_cnt)
	);
	
	// Read from FIFO
	reg start;  // Needed to buffer some data so 40Mhz output is continuous
	always @(posedge clk_40mhz) begin
		if (reset) begin
			out_ready <= 1'b0;
			wr_en <= 1'b0;
			rd_en <= 1'b0;
			start <= 1'b1;
		end
		else if (start) begin
			out_ready <= 1'b0;
			rd_en <= 1'b0;
			wr_en <= 1'b1;
			start <= (rd_d_cnt < 5'd2);
		end
		else begin
			out_ready <= rd_en;
			rd_en <= ~rd_en;
		end
	end
	
	// Assign output
	assign RX_sampled = RX_DMX;

	// DEBUG ASSIGN
//	assign RX_stable_DEBUG = RX_stable;
//	assign empty_DEBUG = empty;
//	assign rd_d_cnt_DEBUG = rd_d_cnt;
//	assign start_DEBUG = start;
	// END DEBUG ASSIGN
	
endmodule
