`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nandi Bugg
// 
// Create Date:    12:49:56 11/15/2012 
// Design Name: 
// Module Name:    user_interface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
// 1. Responsible for displaying menu items on screen. Muxes between the time module,
// voicemail module, and itself to do so.
// 2. Chooses proper audio from session layer and voicemail module
// 3. Sends and receives commands from application layer to achieve goals
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
	 input [3:0] inc_command,
	 input init,
	 input [7:0] inc_address,
	 output [15:0] audio_out_data,
	 input ready,
	 input [3:0] voicemail_status,
	 input [15:0] dout,
	 output [3:0] voicemail_command,
	 output [7:0] phn_num,
	 output [15:0] din,
	 output [1:0] disp_control, //who has control over display
    output [7:0] address,
    output [4:0] command,
    output [2:0] current_state,
	 output [5:0] current_menu_item,
	 output [4:0] headphone_volume,
	 input [15:0] audio_in_data,
	 output [11:0] txt_addr,
	 output [11:0] txt_length,
	 output txt_start,
	 input done,
	 output set_date
    );
	 
	 
	 
///////////////////////////////////////////////////////	
//States
//////////////////////////////////////////////////////
	parameter [2:0] idle=0; //no current calls
	parameter [2:0] incoming=3'd1; //user is being called
	parameter [2:0] outgoing=3'd2; //user calls another party
	parameter [2:0] busy=3'd3; //call in progress
	parameter [2:0] call_while_busy=3'd4; //user in call, receiving incoming call
	parameter [2:0] initialize=3'd5; //initialize node
	parameter [2:0] in_voicemail=3'd6;
//////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////	
//Overall parameters
/////////////////////////////////////////////////////////
	parameter conference=0; //conference call on/off
	parameter selective=0; //selective mode switch for call forwarding
	parameter block_state=0; //0=off,1=on call blocking
	reg voicemail_state=0; //0=off,1=on
	reg override=1; //used for transferring control over up/down buttons from UI to voicemail
/////////////////////////////////////////////////////////	
	
	
	
	
///////////////////////////////////////////////////////////	
//Menu Items
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
	//////////////////////////////////////
	//Main menu parameters
	///////////////////////////////////////
	parameter call_number=0;//start a phone call
	parameter volume=6'd1; //set headphone volume
	parameter voicemail=6'd2;//voicemail options
	// parameter call_block=6'd5;//call block options
	// parameter call_fwd=6'd6;//call forwarding options
	parameter get_num=6'd3;//display FPGA's number
	parameter set_time=6'd4;//set system date and time
	
	//////////////////////////////////////////
	//Call number
	/////////////////////////////////////////
	parameter dialing=6'd7;
	
	///////////////////////////////////////
	//Volume
	//////////////////////////////////////
	parameter change_vol=6'd8;
	
	////////////////////////////////////////
	//Voicemail menu
	////////////////////////////////////////
	parameter toggle_v=6'd9; //toggle voicemail on/off
	parameter unread=6'd10; //unread voicemail
	parameter saved=6'd11; //saved voicemail
	
	////////////////////////////////////////
	//Unread voicemail menu
	///////////////////////////////////////
	parameter play_unread=6'd12; //play unread voicemail
	parameter del_unread=6'd13; //delete unread voicemail
	parameter del_all_unread=6'd14; //delete all unread voicemail
	
	///////////////////////////////////////
	//Saved voicemail menu
	/////////////////////////////////////////
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
	
	/////////////////////////////////////////////
	//Display user's number
	////////////////////////////////////////////
	parameter  disp_num = 6'd30;
	
	//////////////////////////////////////////////
	//Set system date and time
	/////////////////////////////////////////////
	parameter  set_dt=6'd31;
	
	/////////////////////////////////////////////
	//Incoming call menu
	//////////////////////////////////////////////
	parameter  def_incoming=6'd32;
	parameter  accept=6'd33; 
	parameter  reject=6'd34; 
	parameter  send_to_v=6'd35; //send to voicemail
	
	/////////////////////////////////////////////
	//Outgoing call menu
	/////////////////////////////////////////////
	parameter  def_outgoing=6'd36;
	parameter  end_call=6'd37; 
	
	///////////////////////////////////////////////
	//Busy (call-in-progress) menu
	///////////////////////////////////////////////
	parameter  def_busy=6'd38;	
	parameter  end_call_b=6'd39;
	parameter  set_volume=6'd40;
//	parameter  called_IDs=6'd41;
//	parameter  xfer_call=6'd42;
//	parameter  hold_call=6'd43;
//	parameter  resume_call=6'd44;
//	parameter  conf_call=6'd45;
	
	///////////////////////////////////////////////
	//Incoming while busy 
	//////////////////////////////////////////////
	parameter  reject_call=6'd46;
	parameter  send_2_v=6'd47; //send to voicemail
	parameter  end_call_inc=6'd48;
	parameter  hold_curr=6'd49; //hold current call
	
	///////////////////////////////////////////////
	//Default displays
	//////////////////////////////////////////////
	parameter  def_welcome=6'd50; //welcome for idle state
	parameter  def_init=6'd51;
	parameter  def_inc_busy=6'd52; //default display for incoming-while-busy state
	parameter  def_sys=6'd53; //sys date and time for idle state
//////////////////////////////////////////////////////////////////	
	
	
	
	
//////////////////////////////////////////////	
//UI=>application layer commands
////////////////////////////////////////////
	parameter init_signal=0; //user wants to initialize system
	parameter make_call=5'h1;	 //user trying to make phone call
	parameter answer_call=5'h2; //user accepts call
	parameter go_to_voicemail=3'h3; //user wants to send call to voicemail
	parameter disconnect=5'h5; //user wants to end call
/////////////////////////////////////////////	
	
	
//////////////////////////////////////////////	
//Application layer=>UI commands
//////////////////////////////////////////////
   parameter disconnected=4'd0; //no current call
	parameter outgoing_call=4'd1; //outgoing call
	parameter connected=4'd2; //call went through successfully
	parameter no_answer=4'd3; //pickup didn't occur during 30s and voicemail is off
	parameter sent_to_v=4'd4; //incoming call sent to voicemail
	parameter connected_to_v=4'd5; //outgoing call in voicemail
	parameter incoming_call=4'd6; //incoming call
/////////////////////////////////////////////////

	
////////////////////////////////////////////////	
//Temp variables for outputs + initialization
//////////////////////////////////////////////
	reg [2:0] state=initialize;
	reg [2:0] c_state=initialize;
	
	reg [7:0] temp_addr;
	reg [7:0] temp_command;
	
		
	reg [5:0] menu_item=def_init;
	reg [5:0] menu_item_latch;
	
	reg [3:0] temp_voicemail_command;
	
	reg temp_set_date;
	
	//parameters for display control
	parameter UI=0;
	parameter date_time=2'd1;
	parameter voicemail_disp=2'd2;
	reg [1:0] temp_display_control=UI;
	
/////////////////////////////////////////////////	
	

	
//////////////////////////////////////////////////////////	
// I/O for text_scroller_interface
///////////////////////////////////////////////////////////
	 reg start;
	 reg [10:0] addr;
	 reg [10:0] length;
//	 wire [7:0] ascii_out;
//	 wire ascii_out_ready;
//	 wire done;
//////////////////////////////////////////////////////////////
//Voicemail commands/statuses 
/////////////////////////////////////

//commands
parameter CMD_IDLE       = 4'd0;
parameter CMD_START_RD   = 4'd1;
parameter CMD_END_RD     = 4'd2;
parameter CMD_START_WR   = 4'd3;
parameter CMD_END_WR     = 4'd4;
parameter CMD_VIEW_UNRD  = 4'd5;
parameter CMD_VIEW_SAVED = 4'd6;
parameter CMD_DEL        = 4'd7;
parameter CMD_SAVE       = 4'd8;	

//statuses
parameter STS_NO_CF_DEVICE = 4'd0;
parameter STS_CMD_RDY      = 4'd1;
parameter STS_BUSY         = 4'd2;
parameter STS_RDING        = 4'd3;
parameter STS_RD_FIN       = 4'd4;
parameter STS_WRING        = 4'd5;
parameter STS_WR_FIN       = 4'd6;
parameter STS_ERR_VM_FULL  = 4'd7;
parameter STS_ERR_RD_FAIL  = 4'd8;
parameter STS_ERR_WR_FAIL  = 4'd9;

////////////////////////////////////////////////////////////
//Audio
//////////////////////////////////////////////////////////// 
reg [4:0] temp_headphone_volume=5'd16; //default volume
reg [4:0] headphone_change; //amount user has changed headphone volume by


//Audio Mux (switches between voicemail and call audio)
//AC97_PCM ac(.clock_27mhz(clk),.reset(reset),.volume(headphone_volume),
//.audio_in_data(audio_in_data),.audio_out_data(audio_out_data),
//.ready(ready),
//.audio_reset_b(audio_reset_b),.ac97_sdata_out(ac97_sdata_out),
//.ac97_sdata_in(ac97_sdata_in),
//.ac97_synch(ac97_synch),.ac97_bit_clock(ac97_bit_clock));

assign audio_out_data=(menu_item==play_unread||menu_item==play_saved
||inc_command==sent_to_v)?(dout):(audio_in_data);




///////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
//Timer for Incoming Calls
///////////////////////////////////////////////////////////
//I/Os
wire enable;
wire start_timer;
reg start_t;
wire expired;
wire countdown;
wire [4:0] inc_timer=5'd30;


 //Divider
Divider#(.N(27000000),.W(25)) div(.clk(clk),.reset(reset),.sys_reset(reset),
				     .new_clk(enable));

 //Timer
timer tim(.start_timer(start_timer),.sys_reset(sys_reset),.clk(clk),
	     .enable(enable),.clk_value(inc_timer),.expired(expired),.countdown(countdown));



///////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//Latches for Buttons
//////////////////////////////////////////////////////////////
reg up_latch;
reg down_latch;
reg right_latch;
reg left_latch;
reg b0_latch;
reg b1_latch;
reg b2_latch;
reg b3_latch;
reg enter_latch;
reg reset_latch;
////////////////////////////////////////////////////////////


//set display text here	
	always @(posedge clk) begin
		//deal with latches here
		up_latch<=up;
      down_latch<=down;
      right_latch<=right;
		left_latch<=left;
		b0_latch<=b0;
		b1_latch<=b1;
		b2_latch<=b2;
		b3_latch<=b3;
		enter_latch<=enter;
      reset_latch<=reset;
		
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
							addr<=11'd45; //text=Welcome
							length<=11'd7;
						end
						
						call_number:begin
							addr<=11'd52;//text=Call Number
							length<=11'd11;
						end
						volume: begin
							addr<=11'd63;//91 //text=Set Headphone Volume
							length<=11'd20;
						end
						voicemail: begin
							addr<=11'd83; //text=Voicemail
							length<=11'd9;
						end
						get_num: begin
							addr<=11'd92; //text=Display System Number
							length<=11'd21;
						end
						set_time:begin
							addr<=11'd113; //text=Set Date & Time
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
								addr<=11'd142; //text=Turn Voicemail Off
								length<=11'd18;
							end
							
							else begin //voicemail currently off
								addr<=11'd160;//text=Turn Voicemail On
								length<=11'd17;
							end
						end
						
						unread: begin	//text=Unread Voicemail
							addr<=11'd177;
							length<=11'd16;
						end
						
						saved: begin	//text=Saved Voicemail
							addr<=11'd268;
							length<=11'd15;
						end

						//get number
						disp_num:begin
							//disp. in hex or binary?
						end
						
				//incoming state	
					accept:begin //text=Accept Incoming Call
						addr<=11'd374;
						length<=11'd20;
					end
					reject:begin	//text=Reject Incoming Call
						addr<=11'd395;
						length<=11'd20;
					end
					send_to_v:begin	//text=Send to Voicemail
						addr<=11'd416;
						length<=11'd17;
					end
					def_incoming:begin	//text=Incoming Call
						addr<=11'd360;
						length<=11'd13;
					end
					
				//outgoing state
				def_outgoing:begin //text=Calling
					addr<=11'd434;
					length<=11'd7;
				end
				end_call:begin	//text=End Call
					addr<=11'd442;
					length<=11'd8;
				end
					
					
				//busy state
				def_busy:begin //text=Current Call
					addr<=11'd489;
					length<=11'd12;
				end
				end_call_b:begin //text=End Call
					addr<=11'd442;
					length<=11'd8;
				end			
			endcase					
		end
		
	end
	
	
	always @(posedge clk) begin
		c_state<=state;
		
		if (reset&&!reset_latch) begin
			menu_item<=def_init; 
			state<=initialize;
			voicemail_state<=0;	
		end
		
		else if (voicemail_command!=0) 
			temp_voicemail_command<=CMD_IDLE;
			
		else if (done) begin
			case (state) 
				//initialize state logic
				initialize: begin	//text=Press "Enter" to start network initialization
						if (enter&&!enter_latch) begin	
							menu_item<=def_welcome;				
							state<=idle;					
						end
					end		
				
				
				
				
				
				
				
				// idle state logic
				idle: begin		
					if (inc_command==incoming_call) begin
						menu_item<=def_incoming;
						start_t<=1;
						state<=incoming;		
					end
			 
					else if (up&&override&&!up_latch) begin //up button pressed
						case (menu_item) 
							call_number: menu_item<=set_time;//main_menu
							toggle_v: menu_item<=saved; //voicemail
							play_unread: menu_item<=play_unread; //unread voicemail
							play_saved: menu_item<=play_saved; //saved voicemail
							accept: menu_item<=send_to_v; //incoming call menu	
							end_call: menu_item<=set_volume; //busy
							change_vol: begin
								if (headphone_volume<31)
									headphone_change<=headphone_change+1;
							end
							get_num:begin
								if (voicemail_status==STS_NO_CF_DEVICE) //no CF device found so hide voicemail menu
									menu_item<=volume;
								else
									menu_item<=voicemail;
							end
							def_sys: menu_item<=def_sys;
							def_init:menu_item<=def_init;
							def_welcome:menu_item<=def_welcome;
							set_dt:menu_item<=set_dt;
							default: menu_item<=menu_item-1;
						endcase

					end
					
					else if (down&&override&&!down_latch) begin //down button pressed
						case (menu_item) 
							set_time: menu_item<=call_number;//main_menu
							saved: menu_item<=toggle_v; //voicemail
							play_unread: menu_item<=play_unread;//unread voicemail
							play_saved: menu_item<=play_saved; //saved voicemail
							accept: menu_item<=send_to_v; //incoming call menu	
							set_volume: menu_item<=end_call; //busy
							change_vol: begin
								if (headphone_volume>0)
									headphone_change<=headphone_change-1;
							end	
							volume:begin
								if (voicemail_status==STS_NO_CF_DEVICE) //no CF device found so hide voicemail menu
									menu_item<=get_num;
								else
									menu_item<=voicemail;
							end
							def_sys: menu_item<=def_sys;
							def_init:menu_item<=def_init;
							def_welcome:menu_item<=def_welcome;
							set_dt:menu_item<=set_dt;
							default: menu_item<=menu_item+1;		
						endcase
					end
					
					else if (((right&&!right_latch)||(enter&&!enter_latch))&&override) begin //menu item selected
						case (menu_item) 
							def_welcome: menu_item<=call_number;
							def_sys: begin
								temp_display_control<=UI;
								menu_item<=call_number; 
							end
							call_number: menu_item<=dialing;
							volume: menu_item<=change_vol;
							voicemail: menu_item<=toggle_v;
//							get_num: menu_item<=set_time;
//							set_time: menu_item<=call_number;
							def_init:menu_item<=def_welcome;
							
							//call number
							dialing: begin
								temp_addr<={s7,s6,s5,s4,s3,s2,s1,s0};
								temp_command<=make_call;
								menu_item<=def_outgoing;
								state<=outgoing;
							end
							
							//voicemail menu
							toggle_v: begin
								case (voicemail_state)
									1:voicemail_state<=0;
									0:voicemail_state<=1;
								endcase
							end
							
							//Change Volume Menu (save changes)
							change_vol:begin
								temp_headphone_volume<=temp_headphone_volume + headphone_change;
								menu_item<=volume;
							end
							
							//Unread Voicemail
							unread:begin	
								if (voicemail_status==STS_CMD_RDY) begin 
									   override<=0; //disable up/down buttons for UI
										temp_voicemail_command<=CMD_VIEW_UNRD;
										temp_display_control<=voicemail_disp; //voicemail now controls display
										menu_item<=play_unread;	
								end
								
								else 
									menu_item<=unread;
							end
							
							//Saved Voicemail
							saved:begin		
								if (voicemail_status==STS_CMD_RDY) begin
									override<=0;
									temp_voicemail_command<=CMD_VIEW_SAVED;
									temp_display_control<=voicemail_disp;//voicemail now controls display
									menu_item<=play_saved;
								end
								
								else
									menu_item<=saved;
							end
							
							set_time:begin
								temp_set_date<=1;
								temp_display_control<=date_time;
								override<=0;
								menu_item<=set_dt;
							end
						endcase
					end
					
					
					else if (left&&!left_latch) begin //move to higher level menu	 
							//go back to system date and time from main menu
							if (menu_item>=0 && menu_item<=4) begin
							    temp_display_control<=date_time;
								 menu_item<=def_sys; 
							end
									 
							//back to call number
							else if (menu_item==7)
								menu_item<=call_number;
								
							//back to set headphone volume
							else if (menu_item==8)
								menu_item<=volume;
								 
							//back to voicemail	 
							else if (menu_item>=9 && menu_item<=11)
								menu_item<=voicemail;
						
							//back to unread voicemail
							else if (menu_item>=12 && menu_item<=14) begin
								menu_item<=unread;
								override<=1; //up/down buttons enabled for UI
								temp_display_control<=UI; //UI now controls display
							 end

							//back to saved voicemail
							else if (menu_item>=15 && menu_item<=17) begin
								menu_item<=saved;
								override<=1; //up/down buttons enabled for UI
								temp_display_control<=UI;//UI now controls display
							end
						
							//escape to display number
							else if (menu_item==30)
								menu_item<=get_num;
							
//							//escape to set time/date
//							else if (menu_item==31) begin
//								menu_item<=set_time;
//								temp_display_control<=UI;
//							end
					
					end	
					
					else if (b0&&!b0_latch&&(menu_item==15||menu_item==12)) begin	//voicemail delete button
						case (menu_item) 
							play_unread: temp_voicemail_command<=CMD_DEL;								
							play_saved:  temp_voicemail_command<=CMD_DEL;
						endcase
					end
					
					else if (b1&&!b1_latch&&(menu_item==15||menu_item==12)) begin //voicemail save button
							temp_voicemail_command<=CMD_SAVE;
					end
					
					else if (b2&&b2_latch&&(menu_item==15||menu_item==12)) begin //voicemail stop button
						case (menu_item)
							play_unread: temp_voicemail_command<=CMD_END_RD;
							play_saved: temp_voicemail_command<=CMD_END_RD;
						endcase
					end
					
					else if (b3&&b3_latch&&(menu_item==play_saved||menu_item==play_unread)) begin //voicemail play button
						case (menu_item)
							play_unread: temp_voicemail_command<=CMD_START_RD;
							play_saved: temp_voicemail_command<=CMD_START_RD;
						endcase	
					end
					
					else if (b0&&!b1_latch&&menu_item==set_dt) begin
						override<=1;
						temp_set_date<=0;
						temp_display_control<=UI;
						menu_item<=set_time; //escape from setting time
					end
					
					//no button presses
					case (menu_item)									
							//display Number
							get_num: begin				
							end
					endcase
					
					
				end
				
				
				
				
				//incoming state logic
				incoming: begin
					start_t<=0;
				
					if (expired==0) begin
						if (up&&!up_latch) begin
							case (menu_item) 
								def_incoming: begin
									if (voicemail_status==STS_NO_CF_DEVICE||voicemail_state==0)
										menu_item<=reject;
									else 
										menu_item<=send_to_v;
								end
								default: menu_item<=menu_item-1;
							endcase
						end
						
						else if (down&&!down_latch) begin
							case (menu_item) 
								send_to_v: menu_item<=def_incoming;
								reject:begin
									if (voicemail_status==STS_NO_CF_DEVICE||voicemail_state==0)
										menu_item<=def_incoming;
									else 
										menu_item<=send_to_v;
								end
								default: menu_item<=menu_item+1;
							endcase
						end
						
						else if ((right&&!right_latch)||(enter&&!enter_latch)) begin
							case (menu_item) 
								def_incoming:temp_command<=disconnect;
								accept: temp_command<=answer_call;
								reject: begin
									if (voicemail_status==1)
										temp_command<=go_to_voicemail;
									else
										temp_command<=disconnect;
								end
								send_to_v:temp_command<=go_to_voicemail;
							endcase
						end
				end
				
				//timer expired w/o call being answered
				else begin 
						if (voicemail_state==1) 
							temp_command<=go_to_voicemail;
						else
							temp_command<=disconnect;
				end
		
				
	
					case (menu_item)	//waiting on application layer
						def_incoming: begin
								if (inc_command==connected) begin
									menu_item<=def_busy;
									state<=busy;
								end		
						end
						accept: begin
							if (inc_command==connected) begin
									menu_item<=def_busy;
									state<=busy;
							end		
						end
						reject:begin
							if (inc_command==disconnected) begin
								menu_item<=def_sys;
								state<=idle;
							end						
						end
						send_to_v:begin
							if (inc_command==disconnected)begin	
								menu_item<=def_sys;
								state<=idle;
							end
						end
					endcase
				
				end
				
				
				
				//outgoing state logic
				outgoing: begin
					if (up&&override&&!up_latch) begin
						case (menu_item)
							def_outgoing: menu_item<=end_call;
							default: menu_item<=menu_item-1;
						endcase
					end
					
					else if (down&&override&&!down_latch) begin
						case (menu_item) 
							end_call: menu_item<=def_outgoing;
							default: menu_item<=menu_item+1;
						endcase
					end
					
					else if (((enter&&!enter_latch)||(right&&!right_latch)) && override) begin
						case(menu_item)
							end_call: begin
								temp_command<=disconnect;
								if (inc_command==disconnected) begin
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
					
					else if (inc_command==no_answer||inc_command==disconnected) begin //call disconnected or voicemail
						menu_item<=def_sys;
						state<=idle;
					end
					
					else if (inc_command==connected_to_v) begin //call sent to voicemail
						override<=0;
						temp_display_control<=voicemail_disp;
						if (voicemail_status==STS_ERR_VM_FULL) begin
							override<=1;
							temp_display_control<=UI;
							temp_command<=disconnect;
						end
						
						else if (voicemail_status==STS_CMD_RDY)
							if (b0&&!b0_latch) //begin recording
								temp_voicemail_command<=CMD_START_WR;
							else if (b1&&b1_latch) begin //end recording
								temp_voicemail_command<=CMD_END_WR;
								override<=1;
								temp_command<=disconnect;		
							end
							
							else if  (voicemail_status==STS_ERR_VM_FULL) begin //voicemail becomes full while recording
								override<=1;
								temp_display_control<=UI;
								temp_command<=disconnect;
							end
						end
				end
				
				
				
				
				//busy state
				busy: begin
					if (up&&!up_latch) begin
						case (menu_item)
							def_busy: menu_item<=set_volume;
							change_vol: begin
								if (headphone_volume<31)
									headphone_change<=headphone_change+1;
							end
							default: menu_item<=menu_item-1;
						endcase
					end
					else if (down&&!down_latch) begin
						case (menu_item) 
							set_volume: menu_item<=def_busy;
							change_vol: begin 
								if (headphone_volume>0)
									headphone_change<=headphone_change-1;
							end
							default: menu_item<=menu_item+1;
						endcase
					end
					else if ((right&&!right_latch)||(enter&&!enter_latch)) begin
						case (menu_item) 
							end_call_b:	temp_command<=disconnect;
							set_volume: menu_item<=change_vol;
							change_vol:begin
								if (headphone_volume<31) begin
										temp_headphone_volume<=temp_headphone_volume + headphone_change;
										menu_item<=change_vol;
									end
							end
						endcase
					end
					else if (left&&!left_latch) begin
						case (menu_item) 
							change_vol: menu_item<=set_volume;
						endcase
					end
					
					case (menu_item) //no button presses currently
						end_call_b: begin
							if (inc_command==disconnected) begin
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
	assign headphone_volume=temp_headphone_volume;
	assign voicemail_command=temp_voicemail_command;
	assign disp_control=temp_display_control;
	assign start_timer=start_t;
	assign txt_addr=addr;
	assign txt_length=length;
	assign txt_start=start;
	assign set_date=temp_set_date;
	

	


endmodule

				
