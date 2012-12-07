`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:05:03 12/05/2012 
// Design Name: 
// Module Name:    text_scroll_int 
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
module text_scroll_int(
    input [10:0] mem_addr,
    input [10:0] length,
    input start,
	 input clk,
	 input reset,
    output done,
    output ready,
    output [7:0] data
    );
	 
	 // Instantiate input latches
	 reg [10:0] mem_addr_reg;
    reg [10:0] length_reg;
	 
	 always @(posedge clk) begin
		if (reset) begin
			done<=0;
			data<=0;
			ready<=0;
		end
		
		else 
			if (start) begin
				
			end
		
	 end


endmodule
