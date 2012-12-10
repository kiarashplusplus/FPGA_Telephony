`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:37:42 12/10/2012
// Design Name:   user_interface
// Module Name:   /afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI_Part2/new_voicemail_interface.v
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

module new_voicemail_interface;

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
	reg [3:0] inc_command;
	reg init;
	reg [7:0] inc_address;
	reg ready;
	reg [3:0] voicemail_status;
	reg [15:0] dout;
	reg [15:0] audio_in_data;
	reg done;

	// Outputs
	wire [15:0] audio_out_data;
	wire [3:0] voicemail_command;
	wire [7:0] phn_num;
	wire [15:0] din;
	wire [1:0] disp_control;
	wire [7:0] address;
	wire [4:0] command;
	wire [2:0] current_state;
	wire [5:0] current_menu_item;
	wire [4:0] headphone_volume;
	wire [11:0] txt_addr;
	wire [11:0] txt_length;
	wire txt_start;
	wire set_date;

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
		.inc_address(inc_address), 
		.audio_out_data(audio_out_data), 
		.ready(ready), 
		.voicemail_status(voicemail_status), 
		.dout(dout), 
		.voicemail_command(voicemail_command), 
		.phn_num(phn_num), 
		.din(din), 
		.disp_control(disp_control), 
		.address(address), 
		.command(command), 
		.current_state(current_state), 
		.current_menu_item(current_menu_item), 
		.headphone_volume(headphone_volume), 
		.audio_in_data(audio_in_data), 
		.txt_addr(txt_addr), 
		.txt_length(txt_length), 
		.txt_start(txt_start), 
		.done(done), 
		.set_date(set_date)
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
		s0 = 0;
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
		inc_address = 0;
		ready = 0;
		voicemail_status = 0;
		dout = 0;
		audio_in_data = 0;
		done = 1;

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
		down=1;
		#10;
		down=0; 
		#10;
		down=1;	
		#10;
		down=0; //should be at get_num menu_item - checked
		#10;
		voicemail_status=4'd1; //CF card detected
		#10;
		up=1;
		#10;
		up=0; //should be at voicemail menu_item - checked
		#10;
		enter=1;
		#10;
		enter=0; //toggle voicemail menu - checked
		#10;
		enter=1;
		#10;
		enter=0; //turn voicemail on -checked
		
		

	end
      
endmodule

