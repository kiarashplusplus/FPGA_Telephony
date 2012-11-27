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
	input init,
	input incoming_call,
	input inc_address,
    output reg [7:0] address,
    output reg [2:0] command,
	output text,
    output reg [2:0] current_state,
    );
	
	//commands
	parameter [2:0] init_signal;
	
	//states
	parameter [2:0] idle=0; //no current calls
	parameter [2:0] incoming=3'b1; //user is being called
	parameter [2:0] outgoing=3'b2; //user calls another party
	parameter [2:0] busy=3'b3; //call in progress
	parameter [2:0] call_while_busy=3'b4; //user in call, receiving incoming call
	parameter [2:0] initialize=3'b5; //initialize node
	
	//overall parameters
	assign init=0; //should this be assigned by me?
	parameter def_display=1; //turn default display on or off
	parameter conference=0; //conference call on/off
	parameter selective=0; //selective mode switch for call forwarding
	parameter block_state=0; //0=off,1=on call blocking
	parameter voicemail_state=0; //0=off,1=on
	
	//main menu parameters
	parameter [5:0] call_number=0;//start a phone call
	parameter [5:0] volume=6'b1; //set headphone volume
	parameter [5:0] voicemail=6'b2;//voicemail options
	parameter [5:0] call_block=6'b3;//call block options
	parameter [5:0] call_fwd=6'b4;//call forwarding options
	parameter [5:0] get_num=6'b5;//display FPGA's number
	parameter [5:0] set_time=6'b6;//set system date and time
	
	//call number
	parameter [5:0] dialing=6'b7;
	
	//volume
	parameter [5:0] change_vol=6'b8;
	
	//voicemail menu
	parameter [5:0] toggle_v=6'b9; //toggle voicemail on/off
	parameter [5:0] unread=6'b10; //unread voicemail
	parameter [5:0] play_unread=6'b11; //play unread voicemail
	parameter [5:0] del_unread=6'b12; //delete all unread voicemail
	parameter [5:0] saved=6'b13; //saved voicemail
	parameter [5:0] play_saved=6'b14; //play saved voicemail
	parameter [5:0] del_saved=6'b15; //delete saved voicemail
	parameter [5:0] del_all_saved=6'b16; //delete all saved voicemail
	
	
	
	//scrolling through voicemail?
	
	//call blocking menu
	parameter [5:0] toggle_block=6'b17; //toggle call blocking on/off
	parameter [5:0] view_blocked=6'b18; //view blocked numbers
	parameter [5:0] add_blocked=6'b19; //add blocked number
	parameter [5:0] del_blocked=6'b20; //delete a blocked number
	parameter [5:0] del_all_blocked=6'b21; //delete all blocked numbers
	
	
	
	//how to make list of blocked numbers?
	
	//call forward menu
	parameter [5:0] toggle_fwd=6'b22; //toggle call forwarding on/off
	parameter [5:0] fwd_mode=6'b23; 
	parameter [5:0] set_fwd_number=6'b24; 
	
	//display user's number
	parameter [5:0] disp_num = 6'b48;
	
	//set system date and time
	parameter [5:0] set_dt=6'b49;
	
	//incoming call menu
	parameter [5:0] accept=6'b25; 
	parameter [5:0] reject=6'b26; 
	parameter [5:0] send_to_v=6'b27; //send to voicemail
	
	//outgoing call menu
	parameter [5:0] end_call=6'b28; 
	
	//busy (call-in-progress) menu 
	parameter [5:0] end_call=6'b29;
	parameter [5:0] set_volume=6'b31;
	parameter [5:0] called_IDs=6'b32;
	parameter [5:0] xfer_call=6'b33;
	parameter [5:0] hold_call=6'b34;
	parameter [5:0] resume_call=6'b35;
	parameter [5:0] conf_call=6'b36;
	
	//incoming while busy 
	parameter [5:0] reject_call=6'b37;
	parameter [5:0] send_2_v=6'b38; //send to voicemail
	parameter [5:0] end_call=6'b39;
	parameter [5:0] hold_curr=6'b40; //hold current call
	
	//default displays
	parameter [5:0] def_init=6'b41;
	parameter [5:0] def_welcome=6'b42; //welcome for idle state
	parameter [5:0] def_incoming=6'b43;
	parameter [5:0] def_outgoing=6'b44;
	parameter [5:0] def_busy=6'b45;
	parameter [5:0] def_inc_busy=6'b46; //default display for incoming-while-busy state
	parameter [5:0] def_sys=6'b47; //sys date and time for idle state
	
	
	
	
	//UI=>application layer commands
	parameter [2:0] make_call;
	
	reg [2:0] state=initialize;
	assign current_state=state;
	
	reg [5:0] menu_item=def_init;
	

	
	always @(posedge clk) begin
		if (reset) begin
			state=>initialize;
		end
		
		else begin
			case (state) begin
				initialize: begin
					if (init) begin //another node already initialized system
						menu_item<=def_welcome;
						state<=idle;			
					end
					
					else if (enter) begin
						command<=init_signal;
						if (init) begin	//system has been initialized
							menu_item<=def_welcome;
							state<=idle;					
						end
					end		
				end
				
				idle: begin	// idle state logic
				
					if (incoming_call) begin
						menu_item<=def_incoming;
						state<=incoming;		
					end
				
					
					else if (up) begin
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
							def_welcome: menu_item<=call_number;
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
							
							//display Number
							get_num: begin				
							end
							
							//set sys date and time
							set_time: begin
							end
	
						endcase
					end
					
					
					else if (left) begin //move to higher level menu
						case (menu_item) begin
							//go back to system date and time
							call_number: menu_item<=def_sys;
							volume: menu_item<=def_sys;
							voicemail: menu_item<=def_sys;
							call_block: menu_item<=def_sys;
							call_fwd: menu_item<=def_sys;
							get_num: menu_item<=def_sys;
							set_time: menu_item<=def_sys;
							
							//escape to call number
							dialing: menu_item<=def_sys;
							
							//escape to volume
							change_vol: menu_item<=def_sys;
							
							//escape to voicemail
							unread: menu_item<=def_sys;
							play_unread: menu_item<=def_sys;
							del_unread: menu_item<=def_sys;
							saved: menu_item<=def_sys;
							play_saved:menu_item<=def_sys;
							del_saved:menu_item<=def_sys;
							del_all_saved: menu_item<=def_sys;
							
							//escape to call block
							toggle_block: menu_item<=def_sys;
							view_blocked: menu_item<=def_sys;
							add_blocked: menu_item<=def_sys;
							del_blocked: menu_item<=def_sys;
							del_all_blocked: menu_item<=def_sys;
							
							//escape to call forward
							toggle_fwd: menu_item<=def_sys;
							fwd_mode: menu_item<=def_sys;
							set_fwd_number: menu_item<=def_sys;
							
							//escape to get number
							disp_num: menu_item<=def_sys;
							
							//escape to set time
							set_dt: menu_item<=def_sys;
						endcase
					end

					
					
				end
				
				incoming: begin
				end
				
				outgoing: begin
				end
				
				busy: begin
				end
				
				call_while_busy: begin
				end
				
				
				
			endcase
		end
	end
	
	


endmodule

				