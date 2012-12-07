`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:07:32 11/22/2012 
// Design Name: 
// Module Name:    Text_Scroller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Takes ASCII data and displays it as string data on the screen.
//                 Use the ready signal to indicate when data is being sent, with
//                 sent data starting at the time when the ready signal goes
//                 active high and ending at the time when ready goes inactive low.
//                 
//                 Synchronous reset blanks the screen. In this implementation, 
//                 a single block of BRAM is used for the character memory, 
//                 putting a maximum on message length of 2048 characters. Note
//                 that all parameter counts must be greater than 20.
// 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Text_Scroller #(
	parameter SCROLL_SPEED_CNT = 9000000,   // Counter limit before scrolling by one
	parameter SCROLL_BEGIN_CNT = 27000000,  // Counter limit before starting to scroll
	parameter SCROLL_END_CNT = 27000000     // Counter limit before moving back to start
	)(
	input clk,
	input reset,
	// Data In
	input [7:0] ascii_data,
	input ascii_data_ready,
	// Data Out
	output [127:0] string_data
	,// DEBUG
	output wr_en_DEBUG,
	output [7:0] wr_data_DEBUG,
	output [10:0] wr_addr_DEBUG,
	output cntr_DEBUG,
	output set_disp_DEBUG,
	output [3:0] rel_pos_DEBUG,
	output [10:0] rd_addr_DEBUG,
	output [7:0] rd_data_DEBUG
	// END DEBUG
	);

	// Determine parameters
	parameter SCROLL_SPEED_LMT = SCROLL_SPEED_CNT - 1;
	parameter SCROLL_BEGIN_LMT = SCROLL_BEGIN_CNT - 1;
	parameter SCROLL_END_LMT = SCROLL_END_CNT - 1;

	// Instantiate state vars
	reg [10:0] msg_length;         // Really message length minus one
	reg [7:0] string_data_reg [0:15];   // Storage for string data output
	
	// Assign output
	assign string_data = {string_data_reg[0],
	                      string_data_reg[1],
	                      string_data_reg[2],
	                      string_data_reg[3],
	                      string_data_reg[4],
	                      string_data_reg[5],
	                      string_data_reg[6],
	                      string_data_reg[7],
	                      string_data_reg[8],
	                      string_data_reg[9],
	                      string_data_reg[10],
	                      string_data_reg[11],
	                      string_data_reg[12],
	                      string_data_reg[13],
	                      string_data_reg[14],
	                      string_data_reg[15]
								 };
	
	// Instantiate Dual-Port BRAM for storing ASCII chars
	reg [10:0] wr_addr, rd_addr;
	reg wr_en;
	reg [7:0] wr_data;
	wire [7:0] rd_data;
	UI_Text_Scroller_BRAM UI_TEXT_SCROLLER_BRAM_1(
		.clka(clk),
		.clkb(clk),
		.addra(wr_addr),
		.addrb(rd_addr),
		.dina(wr_data),
		.doutb(rd_data),
		.wea(wr_en)
	);
	
	// Assign write data
	always @(posedge clk)
		wr_data <= ascii_data;
	
	// Manage writes
	always @(posedge clk) begin
		if (reset) begin
			wr_en <= 1'b0;
			msg_length <= 11'd0;
			wr_addr <= 11'd0;
		end
		else begin
			wr_en <= ascii_data_ready;
			if (wr_en) begin
				wr_addr <= wr_addr + 1;
				msg_length <= wr_addr;
			end
			else
				wr_addr <= 11'd0;
		end
	end
	
	// Create variable limit counter
	reg [24:0] cntr_lim, cntr_val;  // limit to 33554431
	reg cntr;
	wire cntr_reset, manual_cntr_reset;
	assign cntr_reset = reset | manual_cntr_reset;
	assign manual_cntr_reset = ascii_data_ready & !wr_addr[10:4];
	always @(posedge clk) begin
		if (cntr_reset) begin
			cntr_val <= 0;
			cntr <= 1'b0;
		end
		else begin
			cntr_val <= (cntr_val == cntr_lim) ? 0: cntr_val + 1;
			cntr <= !cntr_val;
		end
	end
	
	// Manage display chars position and counter timing limit
	reg [10:0] disp_pos;
	wire [10:0] disp_pos_last;
	assign disp_pos_last = (msg_length[10:4]) ? (msg_length - 15): 0;
	always @(posedge clk) begin
		if (cntr_reset) begin
			disp_pos <= 0;
			cntr_lim <= SCROLL_BEGIN_LMT;
		end
		else if (cntr) begin
			disp_pos <= (disp_pos == disp_pos_last) ? 0: (disp_pos + 1);
			cntr_lim <= (!disp_pos) ? SCROLL_BEGIN_LMT: 
			            (disp_pos == disp_pos_last) ? SCROLL_END_LMT:
							SCROLL_SPEED_LMT;
		end
	end
	
	// Update display chars when counter goes active high
	reg [3:0] rel_pos;
	reg set_disp, set_disp_delay;
	always @(posedge clk) begin
		if (cntr_reset) begin
			set_disp <= 1'b0;
			set_disp_delay <= 1'b0;
			// Blank on reset
			string_data_reg[0] <= 8'h20;
			string_data_reg[1] <= 8'h20;
			string_data_reg[2] <= 8'h20;
			string_data_reg[3] <= 8'h20;
			string_data_reg[4] <= 8'h20;
			string_data_reg[5] <= 8'h20;
			string_data_reg[6] <= 8'h20;
			string_data_reg[7] <= 8'h20;
			string_data_reg[8] <= 8'h20;
			string_data_reg[9] <= 8'h20;
			string_data_reg[10] <= 8'h20;
			string_data_reg[11] <= 8'h20;
			string_data_reg[12] <= 8'h20;
			string_data_reg[13] <= 8'h20;
			string_data_reg[14] <= 8'h20;
			string_data_reg[15] <= 8'h20;
		end
		else if (cntr) begin
			rd_addr <= disp_pos;
			rel_pos <= 4'd0;
			set_disp <= 1'b1;
		end
		else if (set_disp) begin  // need delay for BRAM one-cycle read latency
			set_disp <= 1'b0;
			set_disp_delay <= 1'b1;
			rd_addr <= rd_addr + 1;
		end
		else if (set_disp_delay) begin
			rd_addr <= rd_addr + 1;
			rel_pos <= rel_pos + 4'd1;
			set_disp_delay <= ~(&rel_pos);
			string_data_reg[rel_pos] <= (rel_pos > msg_length) ? 8'h20: rd_data;
		end
	end
	
	// DEBUG
	assign wr_en_DEBUG = wr_en;
	assign wr_data_DEBUG = wr_data;
	assign wr_addr_DEBUG = wr_addr;
	assign cntr_DEBUG = cntr;
	assign set_disp_DEBUG = set_disp;
	assign rel_pos_DEBUG = rel_pos;
	assign rd_addr_DEBUG = rd_addr;
	assign rd_data_DEBUG = rd_data;
	// END DEBUG
	
endmodule
