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
	 input s0,
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
	 input [2:0] inc_command,
	 input init,
	 input [7:0] inc_address,
    output [7:0] address,
    output [2:0] command,
    output [2:0] current_state,
	 output [5:0] current_menu_item
    );
///////////////////////////////////////////////////////	
	//states
	parameter [2:0] idle=0; //no current calls
	parameter [2:0] incoming=3'd1; //user is being called
	parameter [2:0] outgoing=3'd2; //user calls another party
	parameter [2:0] busy=3'd3; //call in progress
	parameter [2:0] call_while_busy=3'd4; //user in call, receiving incoming call
	parameter [2:0] initialize=3'd5; //initialize node
//////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////	
	//overall parameters
	assign init=0; //should this be assigned by me?
	parameter conference=0; //conference call on/off
	parameter selective=0; //selective mode switch for call forwarding
	parameter block_state=0; //0=off,1=on call blocking
	reg voicemail_state=0; //0=off,1=on
///////////////////////////////////////////////////////////	
	
//	//call forward mode states
//	parameter [1:0] all=0;
//	parameter [1:0] busy_f=3'd1;
//	parameter [1:0] no_answer=3'd2;
//	parameter [1:0] selective=3'd3;
//	
//	
//	parameter [1:0] fwd_mode_state = 3'd3; //call forward mode, default is selective
//	parameter [1:0] temp_fwd_mode;
//	parameter fwd_state = 0; //toggle forwarding on/off
//	
	//main menu parameters
	parameter call_number=0;//start a phone call
	parameter volume=6'd1; //set headphone volume
	parameter voicemail=6'd2;//voicemail options
	// parameter call_block=6'd5;//call block options
	// parameter call_fwd=6'd6;//call forwarding options
	parameter get_num=6'd3;//display FPGA's number
	parameter set_time=6'd4;//set system date and time
	
	//call number
	parameter dialing=6'd7;
	
	//volume
	parameter change_vol=6'd8;
	
	//voicemail menu
	parameter toggle_v=6'd9; //toggle voicemail on/off
	parameter unread=6'd10; //unread voicemail
	parameter saved=6'd11; //saved voicemail
	
	//unread voicemail menu
	parameter play_unread=6'd12; //play unread voicemail
	parameter del_unread=6'd13; //delete unread voicemail
	parameter del_all_unread=6'd14; //delete all unread voicemail
	
	//saved voicemail menu
	parameter play_saved=6'd15; //play saved voicemail
	parameter del_saved=6'd16; //delete saved voicemail
	parameter del_all_saved=6'd17; //delete all saved voicemail
	
//	//call blocking menu
//	parameter  toggle_block=6'd18; //toggle call blocking on/off
//	parameter  view_blocked=6'd19; //view blocked numbers
//	parameter  add_blocked=6'd20; //add blocked number
//	parameter  del_blocked=6'd21; //delete a blocked number
//	parameter  del_all_blocked=6'd22; //delete all blocked numbers
//
//	//call forward menu
//	parameter  toggle_fwd=6'd23; //toggle call forwarding on/off
//	parameter  fwd_mode=6'd24; //set forwarding mode
//	parameter  set_fwd_number=6'd25; //set forwarding number
//	parameter  view_sel_num=6'd26;	//view selective numbers
//	parameter  add_sel_num=6'd27;	//add selective numbers
//	parameter  del_sel_num=6'd28;	//delete selective numbers
//	parameter  del_all_sel_num=6'd29; //delete all selective numbers
	
//	parameter [7:0] fwd_address; //forward address added
	
	//display user's number
	parameter  disp_num = 6'd30;
	
	//set system date and time
	parameter  set_dt=6'd31;
	
	//incoming call menu
	parameter  def_incoming=6'd32;
	parameter  accept=6'd33; 
	parameter  reject=6'd34; 
	parameter  send_to_v=6'd35; //send to voicemail
	
	//outgoing call menu
	parameter  def_outgoing=6'd36;
	parameter  end_call=6'd37; 
	
	//busy (call-in-progress) menu
	parameter  def_busy=6'd38;	
	parameter  end_call_b=6'd39;
	parameter  set_volume=6'd40;
//	parameter  called_IDs=6'd41;
//	parameter  xfer_call=6'd42;
//	parameter  hold_call=6'd43;
//	parameter  resume_call=6'd44;
//	parameter  conf_call=6'd45;
	
	//incoming while busy 
	parameter  reject_call=6'd46;
	parameter  send_2_v=6'd47; //send to voicemail
	parameter  end_call_inc=6'd48;
	parameter  hold_curr=6'd49; //hold current call
	
	//default displays
	parameter  def_welcome=6'd50; //welcome for idle state
	parameter  def_init=6'd51;
	parameter  def_inc_busy=6'd52; //default display for incoming-while-busy state
	parameter  def_sys=6'd53; //sys date and time for idle state
	
	
	
//////////////////////////////////////////////	
	//UI=>application layer commands
	parameter [2:0] init_signal=0; //user wants to initialize system
	parameter [2:0] make_call=3'd1;	 //user trying to make phone call
	parameter [2:0] stop_call=3'd2; //user wants to end call
	
	
	//application layer=>UI commands
	parameter [2:0] connected=3'd1; //call went through successfully
	parameter [2:0] sent_to_v=3'd2; //user's call sent to voicemail
	parameter [2:0] failed=3'd4; //call dropped or didn't go through
	parameter [2:0] incoming_call=3'd5; //incoming call
	parameter [2:0] call_ended=3'd6;
/////////////////////////////////////////////////

	
////////////////////////////////////////////////	
	//temp variables for outputs + initialization
	reg [2:0] state=initialize;
	reg [2:0] c_state=initialize;
	
	reg [7:0] temp_addr;
	reg [7:0] temp_command;
	
		
	reg [5:0] menu_item=def_init;
	reg [5:0] menu_item_latch;
	
/////////////////////////////////////////////////	
	

	
//////////////////////////////////////////////////////////	
	//I/O for text_scroller_interface
	 reg start;
	 reg [10:0] addr;
	 reg [10:0] length;
	 wire [7:0] ascii_out;
	 wire ascii_out_ready;
	 wire done;
	 
	 //outputs for text_scroller
	wire [127:0] string_data;
	wire wr_en_DEBUG;
	wire [7:0] wr_data_DEBUG;
	wire [10:0] wr_addr_DEBUG;
	wire cntr_DEBUG;
	wire set_disp_DEBUG;
	wire [3:0] rel_pos_DEBUG;
	wire [10:0] rd_addr_DEBUG;
	wire [7:0] rd_data_DEBUG;
	
	
	Text_Scroller_Interface tsi(.clk(clk),.reset(reset),
	.addr(addr),.length(length),.start(start),
	.ascii_out(ascii_out),.ascii_out_ready(ascii_out_ready),.done(done));
	
	Text_Scroller ts (.clk(clk),.reset(reset),.ascii_data(ascii_out),
	.ascii_data_ready(ascii_out_ready),.string_data(string_data),.wr_en_DEBUG(wr_en_DEBUG)
	,.wr_data_DEBUG(wr_data_DEBUG),.wr_addr_DEBUG(wr_addr_DEBUG)
	,.cntr_DEBUG(cntr_DEBUG),.set_disp_DEBUG(set_disp_DEBUG),
	.rel_pos_DEBUG(rel_pos_DEBUG),.rd_addr_DEBUG(rd_addr_DEBUG),
	.rd_data_DEBUG(rd_data_DEBUG));
//////////////////////////////////////////////////////////////	

	
//set display text here	
	always @(posedge clk) begin
		menu_item_latch <= menu_item;
		
		start<=menu_item_latch!=menu_item;
		
		if (menu_item_latch!=menu_item) begin
				case (menu_item) //select address for start of text, set length as well
			//initialization state
						def_init: begin
							addr<=0; //text=Press "Enter" to start network initialization
							length<=11'd45;
						end
						
						
						
			//idle state
						//welcome
						def_welcome:begin
							addr<=11'd72; //text=Welcome
							length<=11'd7;
						end
						
						//main menu
						def_sys:begin
							//still confused about this part
						end
						call_number:begin
							addr<=11'd80; //text=Call Number
							length<=11'd11;
						end
						volume: begin
							addr<=11'd92; //text=Set Headphone Volume
							length<=11'd20;
						end
						voicemail: begin
							addr<=11'd128; //text=Voicemail
							length<=11'd9;
						end
						get_num: begin
							addr<=11'd468; //text=Display System Number
							length<=11'd21;
						end
						set_time:begin
							addr<=11'd452; //text=Set Date & Time
							length<=11'd15;
						end
						
						//call number
						dialing: begin
							//convert switches somehow, display in hex or binary?
						end
						
						//volume
						change_vol: begin
							//current volume
						end
						
						//voicemail
						toggle_v:begin
							if (voicemail_state) begin //voicemail currently on
								addr<=11'd138; //text=Turn Voicemail Off
								length<=11'd18;
							end
							
							else begin //voicemail currently off
								addr<=11'd157;//text=Turn Voicemail On
								length<=11'd17;
							end
						end
						
						unread: begin	//text=Unread Voicemail
							addr<=11'd175;
							length<=11'd16;
						end
						
						saved: begin	//text=Saved Voicemail
							addr<=11'd270;
							length<=11'd15;
						end
						
						//unread voicemail menu
						play_unread:begin	//text=Play Unread Voicemail
							addr<=11'd191;
							length<=11'd25;
						end
						del_unread:begin	//text=Delete Unread Voicemail
							addr<=11'd218;
							length<=11'd23;			
						end
						del_all_unread:begin	//text=Delete All Unread Voicemail
							addr<=11'd242;
							length<=11'd27;				
						end
						
						//saved voicemail menu
						play_saved:begin	//text=Play Saved Voicemail
							addr<=11'd286;
							length<=11'd24;
						end
						del_saved:begin	//text=Delete Saved Voicemail
							addr<=11'd311;
							length<=11'd22;
						end
						del_all_saved:begin //text=Delete All Saved Voicemail
							addr<=11'd334;
							length<=11'd26;
						end

						//get number
						disp_num:begin
							//disp. in hex or binary?
						end
						
						//set time
						set_dt:begin
							//?		
						end
						
				//incoming state	
					accept:begin //text=Accept Incoming Call
						addr<=11'd375;
						length<=11'd20;
					end
					reject:begin	//text=Reject Incoming Call
						addr<=11'd396;
						length<=11'd20;
					end
					send_to_v:begin	//text=Send to Voicemail
						addr<=11'd417;
						length<=11'd17;
					end
					def_incoming:begin	//text=Incoming Call
						addr<=11'd361;
						length<=11'd13;
					end
					
				//outgoing state
				def_outgoing:begin //text=Calling
					addr<=11'd435;
					length<=11'd7;
				end
				end_call:begin	//text=End Call
					addr<=11'd443;
					length<=11'd8;
				end
					
					
				//busy state
				def_busy:begin //text=Current Call
					addr<=11'd490;
					length<=11'd12;
				end
				end_call_b:begin //text=End Call
					addr<=11'd443;
					length<=11'd8;
				end			
			endcase					
		end
		
	end
	
	
	always @(posedge clk) begin
		c_state<=state;
		
		if (reset) begin
			menu_item<=def_init; //right place for this?
			state<=initialize;
			voicemail_state<=0;
			
		end
		
		else begin
			case (state) 
				//initialize state logic
				initialize: begin	//text=Press "Enter" to start network initialization
						if (enter) begin	
							menu_item<=def_welcome;				
							state<=idle;					
						end
					end		
				
				
				
				
				
				
				
				// idle state logic
				idle: begin		
					if (inc_command==incoming_call) begin
						menu_item<=def_incoming;
						state<=incoming;		
					end
			 
					else if (up) begin //up button pressed
						case (menu_item) 
							call_number: menu_item<=set_time;//main_menu
							toggle_v: menu_item<=saved; //voicemail
							play_unread: menu_item<=del_all_unread; //unread voicemail
							play_saved: menu_item<=del_all_saved; //saved voicemail
							accept: menu_item<=send_to_v; //incoming call menu	
							end_call: menu_item<=set_volume; //busy
							default: menu_item<=menu_item-1;
						endcase

					end
					
					else if (down) begin //down button pressed
						case (menu_item) 
							set_time: menu_item<=call_number;//main_menu
							saved: menu_item<=toggle_v; //voicemail
							del_all_unread: menu_item<=play_unread;//unread voicemail
							del_all_saved: menu_item<=play_saved; //saved voicemail
							accept: menu_item<=send_to_v; //incoming call menu	
							set_volume: menu_item<=end_call; //busy
							default: menu_item<=menu_item+1;		
						endcase
					end
					
					else if (right) begin //menu item selected
						case (menu_item) 
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
									temp_addr<={s7,s6,s5,s4,s3,s2,s1,s0};
									temp_command<=make_call;
								end
							end
							
							//change volume
							change_vol: begin
							end
							
							//voicemail menu
							toggle_v: begin
								case (voicemail_state)
									1:voicemail_state<=0;
									0:voicemail_state<=1;
								endcase
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
						endcase
					end
					
					
					else if (left) begin //move to higher level menu
						case (menu_item) 
							//go back to system date and time
							call_number: menu_item<=def_sys;
							volume: menu_item<=def_sys;
							voicemail: menu_item<=def_sys;
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
							
							//escape to get number
							disp_num: menu_item<=call_number;
							
							//escape to set time
							set_dt: menu_item<=call_number;
						endcase
					end	
				end
				
				
				
				
				//incoming state logic
				incoming: begin
					if (up) begin
						case (menu_item) 
							def_incoming: menu_item<=send_to_v;
							default: menu_item<=menu_item-1;
						endcase
					end
					
					else if (down) begin
						case (menu_item) 
							send_to_v: menu_item<=def_incoming;		
							default: menu_item<=menu_item+1;
						endcase
					end
					
					else if (right||enter) begin
						case (menu_item) 
							def_incoming:begin
								menu_item<=def_busy;
								state<=busy;
							end
							accept: begin
								menu_item<=def_busy;
								state<=busy;
							end
							reject: state<=idle;
							send_to_v: begin
							end
						endcase
					end
				end
				
				
				
				//outgoing state logic
				outgoing: begin
					if (up) begin
						case (menu_item)
							def_outgoing: menu_item<=end_call;
							default: menu_item<=menu_item-1;
						endcase
					end
					
					else if (down) begin
						case (menu_item) 
							end_call: menu_item<=def_outgoing;
							default: menu_item<=menu_item+1;
						endcase
					end
					
					else if (enter||right) begin
						case(menu_item)
							end_call: begin
								temp_command<=stop_call;
								if (inc_command==call_ended) begin
									menu_item<=def_sys;
									state<=idle;
								end
							end
						endcase
					end
					
					if (inc_command==connected) begin
						menu_item<=def_busy;
						state<=busy;
					end
					
					else if (inc_command==failed) begin
						menu_item<=def_sys;
						state<=idle;
					end
					
					else if (inc_command==sent_to_v) begin
						//eventually go back to idle
					end
				end
				
				
				
				
				//busy state
				busy: begin
					if (up) begin
						case (menu_item)
							def_busy: menu_item<=set_volume;
							default: menu_item<=menu_item-1;
						endcase
					end
					else if (down) begin
						case (menu_item) 
							set_volume: menu_item<=def_busy;
							default: menu_item<=menu_item+1;
						endcase
					end
					else if (right||enter) begin
						case (menu_item) 
							end_call_b:	temp_command<=stop_call;
							set_volume: menu_item<=change_vol;
							change_vol:begin
							end
						endcase
					end
					else if (left) begin
						case (menu_item) 
							change_vol: menu_item<=set_volume;
						endcase
					end
					
					case (menu_item) //no button presses currently
						end_call_b: begin
							if (inc_command==call_ended) begin
								menu_item<=def_sys;
								state<=idle;
							end
						end
					endcase
				
				end									
			endcase	
		end
		
	end
	
	
	//assign outputs
	assign current_state=c_state;
	assign address=temp_addr;
	assign command=temp_command;
	assign current_menu_item=menu_item;

	


endmodule

				