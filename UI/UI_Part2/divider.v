`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    22:08:51 10/10/2012
// Design Name:
// Module Name:    Divider
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
//
//////////////////////////////////////////////////////////////////////////////////
module Divider #(parameter N=27000000, parameter W=25) ( //W=width
							 input 	    clk,
							 input 	    reset,
							 input 	    sys_reset,
							 output reg new_clk //enable
							 );

   reg [W-1:0] count; //counter is state

   always @(posedge clk) begin
      if (reset||sys_reset) begin
		count<=N;
      end

      else begin
	 if (count>0) begin
	    count<=count-1;
	    new_clk<=0;
	 end

	 else begin
	    new_clk<=1;
	    count<=N;	//reset counter
	 end
      end

   end


endmodule

