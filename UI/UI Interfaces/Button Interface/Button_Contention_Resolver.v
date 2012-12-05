`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:08:44 11/22/2012 
// Design Name: 
// Module Name:    Button_Contention_Resolver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Takes debounced button inputs, and manages button contention
//                 such that only one button signal is high per clock. There is 
//                 also guaranteed to be at least one cycle of no button presses 
//                 between consecutive button presses. This is useful for
//                 generically determining when a button is released, as it
//                 becomes the bitwise-or of the button signals.  
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Button_Contention_Resolver(
	input clk,
	input reset,
	// Button Inputs
	input button0_in,
	input button1_in,
	input button2_in,
	input button3_in,
	input button_enter_in,
	input button_left_in,
	input button_right_in,
	input button_up_in,
	input button_down_in,
	// Button Outputs
	output button0_out,
	output button1_out,
	output button2_out,
	output button3_out,
	output button_enter_out,
	output button_left_out,
	output button_right_out,
	output button_up_out,
	output button_down_out
	);
		
	// Instantiate state var
	reg state;
	
	// Define state parameters
	parameter S_RESET = 0;
	parameter S_SET =   1;
	
	// Assign input
	wire [8:0] button_in;
	assign button_in =
	       {button0_in, button1_in, button2_in, button3_in, button_enter_in,
			  button_left_in, button_right_in, button_up_in, button_down_in};
	
	// Assign output
	reg [8:0] button_out;
	assign {button0_out, button1_out, button2_out, button3_out, button_enter_out,
			  button_left_out, button_right_out, button_up_out, button_down_out}
	       = button_out;
	
	// Manage state transitions and output
	wire [8:0] button_in_minus_one;
	assign button_in_minus_one = button_in - 1;
	always @(posedge clk) begin
		if (reset) begin
			state <= S_RESET;
			button_out <= 9'd0;
		end
		else begin
			case (state)
				S_RESET: begin
					if ((|button_in) & !(button_in_minus_one & button_in)) begin
						state <= S_SET;
						button_out <= button_in;
					end
				end
				S_SET: begin
					if (!(button_out & button_in)) begin
						state <= S_RESET;
						button_out <= 9'd0;
					end
				end
			endcase
		end
	end
endmodule
