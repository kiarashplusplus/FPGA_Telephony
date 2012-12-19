`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   05:33:41 11/22/2012
// Design Name:   Button_Contention_Resolver
// Module Name:   C:/Users/Sachin Shinde/Desktop/6.111/Final Project/Verilog/Final_Project/Button_Contention_Resolver_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Button_Contention_Resolver
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Button_Contention_Resolver_tb;

	// Inputs
	reg clk;
	reg reset;
	reg button0_in;
	reg button1_in;
	reg button2_in;
	reg button3_in;
	reg button_enter_in;
	reg button_left_in;
	reg button_right_in;
	reg button_up_in;
	reg button_down_in;

	// Outputs
	wire button0_out;
	wire button1_out;
	wire button2_out;
	wire button3_out;
	wire button_enter_out;
	wire button_left_out;
	wire button_right_out;
	wire button_up_out;
	wire button_down_out;

	// Instantiate the Unit Under Test (UUT)
	Button_Contention_Resolver uut (
		.clk(clk), 
		.reset(reset), 
		.button0_in(button0_in), 
		.button1_in(button1_in), 
		.button2_in(button2_in), 
		.button3_in(button3_in), 
		.button_enter_in(button_enter_in), 
		.button_left_in(button_left_in), 
		.button_right_in(button_right_in), 
		.button_up_in(button_up_in), 
		.button_down_in(button_down_in), 
		.button0_out(button0_out), 
		.button1_out(button1_out), 
		.button2_out(button2_out), 
		.button3_out(button3_out), 
		.button_enter_out(button_enter_out), 
		.button_left_out(button_left_out), 
		.button_right_out(button_right_out), 
		.button_up_out(button_up_out), 
		.button_down_out(button_down_out)
	);
	
	// Create 100MHz clock
	always #5 clk = ~clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		button0_in = 0;
		button1_in = 0;
		button2_in = 0;
		button3_in = 0;
		button_enter_in = 0;
		button_left_in = 0;
		button_right_in = 0;
		button_up_in = 0;
		button_down_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(posedge clk)
			reset <= 0;
			button0_in <= 1;
		@(posedge clk)
			button1_in <= 1;
		@(posedge clk)
			button2_in <= 1;
		@(posedge clk)
			button3_in <= 1;
		@(posedge clk)
			button0_in <= 0;
		@(posedge clk)
			button1_in <= 0;
		@(posedge clk)
			button2_in <= 0;
		@(posedge clk)
			button3_in <= 0;
			button0_in <= 1;
		@(posedge clk)
			button0_in <= 0;
			button1_in <= 1;
		@(posedge clk)
			button1_in <= 0;
			button2_in <= 1;
		@(posedge clk)
			button2_in <= 0;
			button3_in <= 1;
	end
      
endmodule

