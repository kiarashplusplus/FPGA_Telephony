`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:49:56 11/15/2012 
// Design Name: 
// Module Name:    user_interface 
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
module user_interface(
    input clk,
    input s7,
    input s6,
    input s5,
    input s4,
    input s3,
    input s2,
    input s1,
    input b3,
    input b2,
    input b1,
    input b0,
    input reset,
    input enter,
    input up,
    input down,
    input left,
    input right,
	input incoming_call,
	input inc_address,
    output reg [7:0] address,
    output reg [2:0] command,
	output text,
    output [2:0] current_state,
    );
	
	//states
	parameter [2:0] idle=0; //no current calls
	parameter [2:0] incoming=3'b1; //user is being called
	parameter [2:0] outgoing=3'b2; //user calls another party
	parameter [2:0] busy=3'b3; //call in progress
	parameter [2:0] call_while_busy=3'b4; //user in call, receiving incoming call
	parameter [2:0] initialize=3'b5; //initialize node
	
	//main menu parameters
	parameter [4:0] call_number=0;//start a phone call
	parameter [4:0] volume=5'b1; //set headphone volume
	parameter [4:0] voicemail=5'b2;//voicemail options
	parameter [4:0] call_block=5'b3;//call block options
	parameter [4:0] call_fwd=5'b4;//call forwarding options
	parameter [4:0] get_num=5'b5;//display FPGA's number
	parameter [4:0] set_time=5'b6;//set system date and time
	
	//call number
	parameter [4:0] dialing=5'b7;
	
	//volume
	parameter [4:0] change_vol=5'b8;
	
	//voicemail menu
	parameter [4:0] toggle_v=5'b9; //toggle voicemail on/off
	parameter [4:0] unread=5'b10; //unread voicemail
	parameter [4:0] play_unread=5'b11; //play unread voicemail
	parameter [4:0] del_unread=5'b12; //delete all unread voicemail
	parameter [4:0] saved=5'b13; //saved voicemail
	parameter [4:0] play_saved=5'b14; //play saved voicemail
	parameter [4:0] del_saved=5'b15; //delete saved voicemail
	parameter [4:0] del_all_saved=5'b16; //delete all saved voicemail
	
	parameter voicemail_state=0; //0=off,1=on
	
	//scrolling through voicemail?
	
	//call blocking menu
	parameter [4:0] toggle_block=5'b17; //toggle call blocking on/off
	parameter [4:0] view_blocked=5'b18; //view blocked numbers
	parameter [4:0] add_blocked=5'b19; //add blocked number
	parameter [4:0] del_blocked=5'b20; //delete a blocked number
	parameter [4:0] del_all_blocked=5'b21; //delete all blocked numbers
	
	parameter block_state=0; //0=off,1=on
	
	//how to make list of blocked numbers?
	
	//call forward menu
	parameter [4:0] toggle_fwd=5'b22; //toggle call forwarding on/off
	parameter [4:0] fwd_mode=5'b23; 
	parameter [4:0] set_fwd_number=5'b24; 
	 
	
	

	
	
	//UI=>application layer commands
	parameter [2:0] make_call;
	
	reg [2:0] state=initialize;
	assign current_state=state;
	
	reg [4:0] menu_item=0;
	

	
	always @(posedge clk) begin
		if (reset) begin
			state=>initialize;
		end
		
		else begin
			case (state) begin
				initialize: begin
					if (enter) begin
						state<=idle;
					end
				end
				
				idle: begin	// idle state logic
				
					
					if (up) begin
						case (menu_item) begin
							//navigate main menu
							call_number: menu_item<=set_time;
							volume: menu_item<=call_number;
							voicemail: menu_item<=volume;
							call_block: menu_item<=voicemail;
							call_fwd: menu_item<=call_block;
							get_num: menu_item<=call_fwd;
							set_time: menu_item<=get_num;		

							//voicemail menu
							toggle_v: menu_item<=saved;
							unread: menu_item<=toggle_v;
							saved:  menu_item<=unread;
							
							//call blocking menu
							toggle_block: menu_item<=del_all_blocked;
							view_blocked: menu_item<=toggle_block;
							add_blocked: menu_item<=view_blocked;
							del_blocked: menu_item<=add_blocked;
							del_all_blocked: menu_item<=del_blocked;
							
						endcase
					end
					
					else if (down) begin //use else to prioritize button presses
						case (menu_item) begin
							//navigate main menu
							call_number: menu_item<=volume;
							volume: menu_item<=voicemail;
							voicemail: menu_item<=call_block;
							call_block: menu_item<=call_fwd;
							call_fwd: menu_item<=get_num;
							get_num: menu_item<=set_time;
							set_time: menu_item<=call_number;

							//voicemail menu
							toggle_v: menu_item<=unread;
							unread: menu_item<=saved;
							saved:  menu_item<=toggle_v;	

							//call blocking menu
							toggle_block: menu_item<=view_blocked
							view_blocked: menu_item<=add_blocked;
							add_blocked: menu_item<=del_blocked;
							del_blocked: menu_item<=del_all_blocked;
							del_all_blocked: menu_item<=toggle_block;
						endcase
					end
					
					else if (right) begin //menu item selected
						case (menu_item) begin
							call_number: menu_item<=dialing;
							volume: menu_item<=change_vol;
							voicemail: menu_item<=toggle_v;
							call_block: menu_item<=call_fwd;
							call_fwd: menu_item<=get_num;
							get_num: menu_item<=set_time;
							set_time: menu_item<=call_number;	

							//call_number
							dialing: begin
								if(enter||right) begin
									address<={s7,s6,s5,s4,s3,s2,s1,s0};
									command<=make_call;
								end
							end
							
							//change volume
							change_vol: begin
							end
							
							//voicemail menu
							toggle_v: begin
								if (voicemail_state) begin
									voicemail_state<=0;
								end
								
								else begin
									voicemail_state<=1;
								end
							end
							
							unread: begin
							end
							
							saved: begin
							end
							
							//call blocking menu
							toggle_block: begin
								if(block_state) begin
									block_state<=0;
								end
								
								else begin
									block_state<=1;
								end
							end
							view_blocked: begin
							end
							add_blocked: begin
							end
							del_blocked: begin
							end
							del_all_blocked: begin
							end
							
							
							
						endcase
					end
					
					
					else if (left) begin //move to higher level menu
						case (menu_item) begin
							
						end
					end
					
					//choose which menu text to display based on current item
					case (menu_item) begin
							call_number: text<=128'h;
							volume: 
							voicemail: 
							call_block: 
							call_fwd: 
							get_num: 
							set_time: 						
					endcase
					
					
				end
				
			endcase
		end
	end
	
	


endmodule
