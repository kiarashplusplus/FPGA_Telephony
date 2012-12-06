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
	input reg [7:0] inc_address,
    output reg [7:0] address,
    output reg [2:0] command,
    output reg [2:0] current_state,
    );
	 
	 //inputs for text_scroller_interface
	 reg start;
	 reg [10:0] addr;
	 reg [10:0] length;
	
	
	
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
	
	//call forward mode states
	parameter [1:0] all=0;
	parameter [1:0] busy=3'b1;
	parameter [1:0] no_answer=3'b2;
	parameter [1:0] selective=3'b3;
	
	
	parameter [1:0] fwd_mode_state = 3'b3; //call forward mode, default is selective
	parameter [1:0] temp_fwd_mode;
	parameter fwd_state = 0; //toggle forwarding on/off
	
	//main menu parameters
	parameter call_number=0;//start a phone call
	parameter volume=6'b1; //set headphone volume
	parameter voicemail=6'b2;//voicemail options
	// parameter call_block=6'b5;//call block options
	// parameter call_fwd=6'b6;//call forwarding options
	parameter get_num=6'b3;//display FPGA's number
	parameter set_time=6'b4;//set system date and time
	
	//call number
	parameter dialing=6'b7;
	
	//volume
	parameter change_vol=6'b8;
	
	//voicemail menu
	parameter toggle_v=6'b9; //toggle voicemail on/off
	parameter unread=6'b10; //unread voicemail
	parameter saved=6'b11; //saved voicemail
	
	//unread voicemail menu
	parameter play_unread=6'b12; //play unread voicemail
	parameter del_unread=6'b13; //delete unread voicemail
	parameter del_all_unread=6'b14; //delete all unread voicemail
	
	//saved voicemail menu
	parameter play_saved=6'b15; //play saved voicemail
	parameter del_saved=6'b16; //delete saved voicemail
	parameter del_all_saved=6'b17; //delete all saved voicemail
	
	//call blocking menu
	parameter  toggle_block=6'b18; //toggle call blocking on/off
	parameter  view_blocked=6'b19; //view blocked numbers
	parameter  add_blocked=6'b20; //add blocked number
	parameter  del_blocked=6'b21; //delete a blocked number
	parameter  del_all_blocked=6'b22; //delete all blocked numbers

	//call forward menu
	parameter  toggle_fwd=6'b23; //toggle call forwarding on/off
	parameter  fwd_mode=6'b24; //set forwarding mode
	parameter  set_fwd_number=6'b25; //set forwarding number
	parameter  view_sel_num=6'b26;	//view selective numbers
	parameter  add_sel_num=6'b27;	//add selective numbers
	parameter  del_sel_num=6'b28;	//delete selective numbers
	parameter  del_all_sel_num=6'b29; //delete all selective numbers
	
	parameter [7:0] fwd_address; //forward address added
	
	//display user's number
	parameter  disp_num = 6'b30;
	
	//set system date and time
	parameter  set_dt=6'b31;
	
	//incoming call menu
	parameter  accept=6'b32; 
	parameter  reject=6'b33; 
	parameter  send_to_v=6'b34; //send to voicemail
	
	//outgoing call menu
	parameter  end_call=6'b35; 
	
	//busy (call-in-progress) menu 
	parameter  end_call=6'b36;
	parameter  set_volume=6'b37;
	parameter  called_IDs=6'b38;
	parameter  xfer_call=6'b39;
	parameter  hold_call=6'b40;
	parameter  resume_call=6'b41;
	parameter  conf_call=6'b42;
	
	//incoming while busy 
	parameter  reject_call=6'b43;
	parameter  send_2_v=6'b44; //send to voicemail
	parameter  end_call=6'b45;
	parameter  hold_curr=6'b46; //hold current call
	
	//default displays
	parameter  def_init=6'b47;
	parameter  def_welcome=6'b48; //welcome for idle state
	parameter  def_incoming=6'b49;
	parameter  def_outgoing=6'b50;
	parameter  def_busy=6'b51;
	parameter  def_inc_busy=6'b52; //default display for incoming-while-busy state
	parameter  def_sys=6'b53; //sys date and time for idle state
	
	
	
	
	//UI=>application layer commands
	parameter [2:0] init_signal=0; //user wants to initialize system
	parameter [2:0] make_call=3'b1;	 //user trying to make phone call
	
	
	reg [2:0] state=initialize;
	assign current_state=state;
	
	reg [5:0] menu_item=init;
	reg [5:0] menu_item_latch;.
	always @(posedge clk) menu_item_latch <= menu_item;
	
	always @(posedge clk) begin
		if (reset) begin
			state<=initialize;
			
		end
		
		else begin
			case (state) begin
				//initialize state logic
				initialize: begin
					//text=Press "Enter" to start network initialization
					if (init) begin //another node already initialized system	
						menu_item<=def_welcome;
						state<=idle;	
					end
					
					else if (enter) begin
						command<=init_signal;
						text<=208'h496e697469616c697a6174696f6e207369676e616c2073656e74; //Initialization signal sent
						
						if (init) begin	//text=system has been initialized
							menu_item<=def_welcome;				
							state<=idle;					
						end
					end		
				end
				
				// idle state logic
				idle: begin	
				
					if (incoming_call) begin
						//text=Call from 
						state<=incoming;		
					end
				
					
					else if (up) begin
						case (menu_item) begin
							call_number: menu_item<=set_time;//main_menu
							toggle: menu_item<=saved; //voicemail
							play_unread: menu_item<=del_all_unread; //unread voicemail
							play_saved: menu_item<=del_all_saved; //saved voicemail
							accept: menu_item<=send_to_v; //incoming call menu	
							end_call: menu_item<=set_volume; //busy
							default: menu_item<=menu_item-1;
						endcase

					end
					
					else if (down) begin //use else to prioritize button presses
						case (menu_item) begin
							set_time: menu_item<=call_number;//main_menu
							saved: menu_item<=toggle; //voicemail
							del_all_unread: menu_item<=play_unread;//unread voicemail
							del_all_saved: menu_item<=play_saved; //saved voicemail
							accept: menu_item<=send_to_v; //incoming call menu	
							set_volume: menu_item<=end_call; //busy
							default: menu_item<=menu_item+1;		
						endcase
					end
					
					else if (right) begin //menu item selected
						case (menu_item) begin
							def_welcome: menu_item<=call_number;
							def_sys: menu_item<=call_number;
							call_number: menu_item<=dialing;
							volume: menu_item<=change_vol;
							voicemail: menu_item<=toggle_v;
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
							
							//display Number
							get_num: begin				
							end
							
							//set sys date and time
							set_time: begin
							end
	
							default: def_welcome;
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
							dialing: menu_item<=call_number;
							
							//escape to volume
							change_vol: menu_item<=call_number;
							
							//escape to voicemail
							unread: menu_item<=call_number;
							play_unread: menu_item<=call_number;
							del_unread: menu_item<=call_number;
							saved: menu_item<=call_number;
							play_saved:menu_item<=call_number;
							del_saved:menu_item<=call_number;
							del_all_saved: menu_item<=call_number;
							
							//escape to call block
							toggle_block: menu_item<=call_number;
							view_blocked: menu_item<=call_number;
							add_blocked: menu_item<=call_number;
							del_blocked:menu_item<=call_number;
							del_all_blocked: menu_item<=call_number;
							
							//escape to call forward
							toggle_fwd:menu_item<=call_number;
							fwd_mode: menu_item<=call_number;
							set_fwd_number: menu_item<=call_number;
							
							//escape to get number
							disp_num: menu_item<=call_number;
							
							//escape to set time
							set_dt: menu_item<=call_number;
						endcase
					end
					
				
					
					//display text
					case (menu_item) begin
							//main menu
							def_welcome:
							def_sys: 
							call_number: 
							volume: 
							voicemail: 
							call_block: 
							call_fwd: 
							get_num: 
							set_time: 
							
							//call number
							
							//volume
							
							//voicemail
							
							//get number
							
							//set time
							
							
					endcase
					
					

					
					
				end
				
				//incoming state logic
				incoming: begin
					if (up) begin
						case (menu_item) begin
							def_incoming: menu_item<=send_to_v;
							accept: menu_item<=def_incoming;
							reject: menu_item<=accept;
							send_to_v: menu_item<=reject;
							
							default: def_incoming;
						endcase
					end
					
					else if (down) begin
						case (menu_item) begin
							def_incoming: menu_item<=accept;
							accept: menu_item<=reject;
							reject: menu_item<=send_to_v;
							send_to_v: menu_item<=def_incoming;
							
							default: def_incoming;
						endcase
					end
					
					else if (right||enter) begin
						case (menu_item) begin
							def_incoming: state<=busy;
							accept: state<=busy;
							reject: state<=idle;
							send_to_v: begin
							//put timer here
							
							end
							
							default: def_incoming;
						endcase
					end
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

				