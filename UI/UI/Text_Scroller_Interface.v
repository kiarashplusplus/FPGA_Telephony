`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:20:01 12/05/2012 
// Design Name: 
// Module Name:    Text_Scroller_Interface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Text_Scroller_Interface(
	input clk,
	input reset,
   input [10:0] addr,
   input [10:0] length,
   input start,
   output [7:0] ascii_out,
   output ascii_out_ready,
   output done
   );
	 
	// Instantiate input latches
   reg [10:0] addr_reg;
   reg [10:0] length_reg;
	
	// Instantiate output registers
	reg done_reg;
	reg ascii_out_ready_reg;
	assign done = done_reg;
	assign ascii_out_ready = ascii_out_ready_reg;
	
	// Instantiate Block ROM
	Text_Storage TEXT_STORAGE(
		.clka(clk),
		.addra(addr_reg),
		.douta(ascii_out)
		);
	
	// Manage state transitions
	reg started;
	always @(posedge clk) begin
		if (reset) begin
			done_reg <= 1'b1;
			ascii_out_ready_reg <= 1'b0;
			started <= 1'b0;
		end
		else if (start) begin
			addr_reg <= addr;
			length_reg <= length;
			done_reg <= 1'b0;
			started <= 1'b1;
		end
		else if (started && |length_reg) begin
			length_reg <= length_reg - 1;
			addr_reg <= addr_reg + 1;
			ascii_out_ready_reg <= 1'b1;
		end
		else begin
			done_reg <= 1'b1;
			ascii_out_ready_reg <= 1'b0;
			started <= 1'b0;
		end
	end
endmodule
