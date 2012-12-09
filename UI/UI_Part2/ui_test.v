`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:33:42 12/06/2012
// Design Name:   user_interface
// Module Name:   /afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI_Part2/ui_test.v
// Project Name:  UI_Part2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: user_interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ui_test;

	// Inputs
	reg clk;
	reg s7;
	reg s6;
	reg s5;
	reg s4;
	reg s3;
	reg s2;
	reg s1;
	reg s0;
	reg b3;
	reg b2;
	reg b1;
	reg b0;
	reg reset;
	reg enter;
	reg up;
	reg down;
	reg left;
	reg right;
	reg [2:0] inc_command;
	reg init;
	
	//Outputs
	wire [15:0] audio_in_data;
	wire ready;
	wire voicemail_status;
	wire voicemail_command;
	wire [7:0] phn_num;
	wire [15:0] dout;
	wire [15:0] din;
	wire disp_control;
	wire [7:0] inc_address;
	wire [7:0] address;
   wire [2:0] command;
   wire [2:0] current_state;
	wire [5:0] current_menu_item;
	wire [4:0] headphone_volume;
	wire [15:0] audio_out_data;

	// Instantiate the Unit Under Test (UUT)
	user_interface uut (
		.clk(clk), 
		.s7(s7), 
		.s6(s6), 
		.s5(s5), 
		.s4(s4), 
		.s3(s3), 
		.s2(s2), 
		.s1(s1), 
		.s0(s0),
		.b3(b3), 
		.b2(b2), 
		.b1(b1), 
		.b0(b0), 
		.reset(reset), 
		.enter(enter), 
		.up(up), 
		.down(down), 
		.left(left), 
		.right(right), 
		.inc_command(inc_command), 
		.init(init), 
		.audio_in_data(audio_in_data),
		.ready(ready),
		.voicemail_status(voicemail_status),
	   .voicemail_command(voicemail_command),
		.phn_num(phn_num),
		.dout(dout),
		.din(din),
	   .disp_control(disp_control),
		.inc_address(inc_address),
		.address(address),
		.command(command),
		.current_state(current_state),
		.current_menu_item(current_menu_item),
		.headphone_volume(headphone_volume),
		.audio_out_data(audio_out_data)
	);
	
	always #5 clk=!clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		s7 = 0;
		s6 = 0;
		s5 = 0;
		s4 = 0;
		s3 = 0;
		s2 = 0;
		s1 = 0;
		b3 = 0;
		b2 = 0;
		b1 = 0;
		b0 = 0;
		reset = 0;
		enter = 0;
		up = 0;
		down = 0;
		left = 0;
		right = 0;
		inc_command = 0;
		init = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		enter=1;
		#10;
		enter=0; //should be in idle mode - checked
		#10;
		right=1;
		#10;
		right=0; //move from welcome message to main menu - checked
		#10;
		inc_command=3'd5; //incoming call, move to incoming mode - checked
		#10;
		down=1; //move to accept menu item -checked
		#10;
		down=0;	
		#10;
		enter=1; //accept call, move to busy state - checked
		#10;
		enter=0; //caller ID menu item - checked
		#10
		down=1;
		#10;
		down=0; //move to end call menu item -
		#10;
		enter=1;	//end call, wait for signal from application layer - 
		#10
		enter=0;
		#10; 
		inc_command=3'd6; //call ended, back to idle state - checked
		#10; //system date and time should be displayed -checked
		right=1;
		#10;
		right=0; //enter main menu, call number menu item - checked
		#10; 
		left=1;
		#10;
		left=0; //display sys date & time -checked
		#10;
		right=1; //back to main menu - checked
		#10;
		right=0;
		#10;
		enter=1; //call number, dialing menu item - checked
		#10;
		enter=0; 
		#10;
		s2=1; //dial number 4, transition to outgoing state - checked
		#10;	
		enter=1;	//transition to outgoing state - checked
		#10;
		enter=0;
		#10;
		inc_command=3'd1;//connected, go to busy state - checked
		#30;
		down=1;
		#10;
		down=0; //move to end call menu item -
		#10;
		enter=1;	//end call, wait for signal from application layer - checked
		#10
		enter=0;
		#10;
		inc_command=3'd6; //call ended, back to idle state - checked
		#10; //system date and time should be displayed -checked	
		reset=1;
		#10;
		reset=0;//back to initialization state - checked
		
		
		
		
		

	end
      
endmodule

