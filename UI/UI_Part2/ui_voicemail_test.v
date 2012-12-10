`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:26:31 12/08/2012
// Design Name:   user_interface
// Module Name:   /afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI_Part2/ui_voicemail_test.v
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

module ui_voicemail_test;
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
	reg [3:0] voicemail_status;
	
	//Outputs
	wire [15:0] audio_in_data;
	wire ready;
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
	wire [127:0] string_data;
	wire [7:0] ascii_out;
	wire ascii_out_ready;
	wire [11:0] txt_addr;
	wire [11:0] txt_length;
	wire txt_start;
	wire done;
	wire set_dt;

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
		.audio_out_data(audio_out_data),
		.string_data(string_data),
		.ascii_out(ascii_out),
		.ascii_out_ready(ascii_out_ready),
		.txt_addr(txt_addr),
		.txt_length(txt_length),
		.txt_start(txt_start),
		.done(done)
		.set_dt(set_dt)
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
		voicemail_status = 0;

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

