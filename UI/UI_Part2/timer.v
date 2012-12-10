`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:10:42 10/16/2012
// Design Name:
// Module Name:    timer
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
module timer(
	     input 	  start_timer,
	     input 	  sys_reset,
	     input 	  clk,
	     input 	  enable,
	     input [3:0]  clk_value,
	     output 	  expired,
	     output [3:0] countdown
	     );

   reg [3:0] 		  copy_clk = 0;
   wire 		  exp;
   reg 			  pulse;
   reg 			  flag;
   assign exp=((copy_clk==0))&&!(pulse);


   always @(posedge clk) begin
      pulse=(copy_clk==0);
      flag<=0;
      if (sys_reset) begin
	 //				exp<=0;
	 copy_clk<=0;
      end

      else
	if (start_timer) begin	//initialize
	   //					copy_clk<=clk_value;
	   flag<=(clk_value==0);
	   copy_clk<=(clk_value==0)?1:clk_value;
	end

	else if (enable||flag==1) begin	//decrement
	   if (copy_clk>0) begin
	      //						exp<=0;
	      copy_clk<=copy_clk-4'b0001;
	   end
	end



   end

   assign expired=exp;
   assign countdown=copy_clk;

endmodule

