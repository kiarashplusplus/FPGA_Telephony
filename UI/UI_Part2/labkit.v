///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2006-Mar-08: Corrected default assignments to "vga_out_red", "vga_out_green"
//              and "vga_out_blue". (Was 10'h0, now 8'h0.)
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module labkit (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, ac97_synch, ac97_sdata_out,audio_reset_b;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
//   assign audio_reset_b = 1'b0;
//   assign ac97_synch = 1'b0;
//   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // VGA Output
   assign vga_out_red = 8'h0;
   assign vga_out_green = 8'h0;
   assign vga_out_blue = 8'h0;
   assign vga_out_sync_b = 1'b1;
   assign vga_out_blank_b = 1'b1;
   assign vga_out_pixel_clock = 1'b0;
   assign vga_out_hsync = 1'b0;
   assign vga_out_vsync = 1'b0;

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
//   assign ram0_data = 36'hZ;
//   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
//   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
//   assign ram0_we_b = 1'b1;
//   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
//   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
//   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
//   assign disp_blank = 1'b1;
//   assign disp_clock = 1'b0;
//   assign disp_rs = 1'b0;
//   assign disp_ce_b = 1'b1;
//   assign disp_reset_b = 1'b0;
//   assign disp_data_out = 1'b0;
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
//   assign systemace_data = 16'hZ;
//   assign systemace_address = 7'h0;
//   assign systemace_ce_b = 1'b1;
//   assign systemace_we_b = 1'b1;
//   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
//   assign analyzer1_data[15:9] = 0;
//   assign analyzer1_clock = 1'b1;
   assign analyzer2_data[15:7]= 9'h0;
//   assign analyzer2_clock = clock_27mhz;
//   assign analyzer3_data = 16'h0;
//   assign analyzer3_clock = clock_27mhz;
   assign analyzer4_data = 16'h0;
//   assign analyzer4_clock = clock_27mhz;
	
	
	///////////////////////////////////////////////////
	//Project Code Starts Here
	//////////////////////////////////////////////////////
	//Declarations for Buttons
	wire reset,debb0,debb1,debb2,debb3,
	debup,debdown,debleft,debright,debenter,
	b0,b1,b2,b3,up,down,left,right,enter;
	
	//Declarations for Switches
	wire s0,s1,s2,s3,s4,s5,s6,s7;
	
	//UI inputs
	wire [3:0] inc_command;
	wire init, ready;
	wire [7:0] inc_address;
	wire [15:0] audio_in_data, dout,session_audio_data;
	wire [3:0] voicemail_status;
	
	
	
	//UI outputs
	wire [3:0] voicemail_command;
	wire [7:0] phn_num,address,ui_ascii_out,ascii_out;
	wire [15:0] din,audio_out_data;
	wire [1:0] disp_control;
	wire [2:0] current_state;
	wire [5:0] current_menu_item;
	wire [4:0] headphone_volume, command;
	wire ui_ascii_out_ready, start,ascii_out_ready;
	wire [10:0] addr,length;
	wire done, over;
	
	reg [7:0] a_out;
	reg a_out_ready;
	
	//RAM clock I/O
	wire clk_27mhz,locked;
	
	
	//RAM clock
	ramclock RAMCLOCK_1(
		.ref_clock(clock_27mhz), 
		.fpga_clock(clk_27mhz), 
		.ram0_clock(ram0_clk), 
		.ram1_clock(ram1_clk),		
	   .clock_feedback_in(clock_feedback_in),
		.clock_feedback_out(clock_feedback_out), 
		.locked(locked)
	);
	

	
	//Debounce buttons
	debounce db0(.reset(reset),.clock(clk_27mhz),.noisy(~button0),
	.clean(debb0));
	debounce db1(.reset(reset),.clock(clk_27mhz),.noisy(~button1),
	.clean(debb1));
	debounce db2(.reset(reset),.clock(clk_27mhz),.noisy(~button2),
	.clean(debb2));
	debounce db3(.reset(reset),.clock(clk_27mhz),.noisy(~button3),
	.clean(debb3));
	
	debounce dup(.reset(reset),.clock(clk_27mhz),.noisy(~button_up),
	.clean(debup));
	debounce ddown(.reset(reset),.clock(clk_27mhz),.noisy(~button_down),
	.clean(debdown));
	debounce dleft(.reset(reset),.clock(clk_27mhz),.noisy(~button_left),
	.clean(debleft));
	debounce dright(.reset(reset),.clock(clk_27mhz),.noisy(~button_right),
	.clean(debright));
	debounce denter(.reset(reset),.clock(clk_27mhz),.noisy(~button_enter),
	.clean(debenter));
	
	//Contention Resolver
	Button_Contention_Resolver bcr(.clk(clk_27mhz),.reset(reset),
	.button0_in(debb0),.button1_in(debb1),.button2_in(debb2),
	.button3_in(debb3),.button_enter_in(debenter),
	.button_left_in(debleft),.button_right_in(debright),
	.button_up_in(debup),.button_down_in(debdown),
	.button0_out(b0),.button1_out(b1),.button2_out(b2),
	.button3_out(b3),.button_enter_out(enter),
	.button_left_out(left),.button_right_out(right),
	.button_up_out(up),.button_down_out(down));
	
	
	//Synchronize Switches 
	synchronize #(.NSYNC(2)) synch6(.clk(clk_27mhz),.in(switch[7]),.out(s7));
   synchronize #(.NSYNC(2)) synch7(.clk(clk_27mhz),.in(switch[5]),.out(s5));
   synchronize #(.NSYNC(2)) synch8(.clk(clk_27mhz),.in(switch[4]),.out(s4));
   synchronize #(.NSYNC(2)) synch9(.clk(clk_27mhz),.in(switch[3]),.out(s3));
   synchronize #(.NSYNC(2)) synch10(.clk(clk_27mhz),.in(switch[2]),.out(s2));
   synchronize #(.NSYNC(2)) synch11(.clk(clk_27mhz),.in(switch[1]),.out(s1));
   synchronize #(.NSYNC(2)) synch12(.clk(clk_27mhz),.in(switch[0]),.out(s0));
	
	
	//AC97
	AC97_PCM ac(.clock_27mhz(clk_27mhz),.reset(reset),.volume(headphone_volume),
	.audio_in_data(audio_in_data),.audio_out_data(audio_out_data),
	.ready(ready),
	.audio_reset_b(audio_reset_b),.ac97_sdata_out(ac97_sdata_out),
	.ac97_sdata_in(ac97_sdata_in),
	.ac97_synch(ac97_synch),.ac97_bit_clock(ac97_bit_clock));

	wire ui_ready;
	
	//Instantiate User Interface module
	user_interface ui(.clk(clk_27mhz),.s7(s7),.s6(s6),.s5(s5),.s4(s4), 
	.s3(s3),.s2(s2),.s1(s1),.s0(s0),.b3(b3),.b2(b2), 
	.b1(b1),.b0(b0),.reset(reset),.enter(enter), 
	.up(up),.down(down),.left(left),.right(right), 
	.inc_command(inc_command),.init(init), 
	.audio_in_data(audio_in_data),.ready(ui_ready),
	.voicemail_status(voicemail_status),.voicemail_command(voicemail_command),
	.phn_num(phn_num),.dout(dout),
	.din(din),.disp_control(disp_control),
	.inc_address(inc_address),.address(address),
	.command(command),.current_state(current_state),
	.current_menu_item(current_menu_item),
	.headphone_volume(headphone_volume),
	.audio_out_data(audio_out_data),.txt_addr(addr),
	.txt_length(length),.txt_start(start),.done(done),.set_date(set));
	
	/////////////////////////////////////////////
	//Text Interfaces
	///////////////////////////////////////////////
	wire [127:0] string_data;
	wire wr_en_DEBUG;
	wire [7:0] wr_data_DEBUG;
	wire [10:0] wr_addr_DEBUG;
	wire cntr_DEBUG;
	wire set_disp_DEBUG;
	wire [3:0] rel_pos_DEBUG;
	wire [10:0] rd_addr_DEBUG;
	wire [7:0] rd_data_DEBUG;
	
	Text_Scroller_Interface tsi(.clk(clk_27mhz),.reset(reset),
	.addr(addr),.length(length),.start(start),
	.ascii_out(ui_ascii_out),.ascii_out_ready(ui_ascii_out_ready),.done(done));
	
	Text_Scroller ts (.clk(clk_27mhz),.reset(reset),.ascii_data(ascii_out),
	.ascii_data_ready(ascii_out_ready),.string_data(string_data),.wr_en_DEBUG(wr_en_DEBUG)
	,.wr_data_DEBUG(wr_data_DEBUG),.wr_addr_DEBUG(wr_addr_DEBUG)
	,.cntr_DEBUG(cntr_DEBUG),.set_disp_DEBUG(set_disp_DEBUG),
	.rel_pos_DEBUG(rel_pos_DEBUG),.rd_addr_DEBUG(rd_addr_DEBUG),
	.rd_data_DEBUG(rd_data_DEBUG));
	
	//display here
	display_string ds(.reset(reset),.clock_27mhz(clk_27mhz),
	.string_data(string_data),.disp_blank(disp_blank),
	.disp_clock(disp_clock),.disp_rs(disp_rs),
	.disp_ce_b(disp_ce_b),.disp_reset_b(disp_reset_b)
	,.disp_data_out(disp_data_out));
	
	//Voicemail I/Os
	reg vmail_disp_en;
	wire [6:0] vm_addr;
	wire [7:0] vm_data;
	wire v_disp_en;
	wire [7:0] v_ascii_out;
	wire v_ascii_out_ready;
	
	//Date and Time I/Os
	wire date_disp_en;
	reg d_disp_en;
	wire [6:0] year;
	wire [3:0] month;
	wire [4:0] day, hour;
	wire [5:0] minute, second;
	wire [7:0] date_ascii_out;
	wire date_ascii_out_ready;
	wire [6:0] DT_addr;
	wire [7:0] DT_data;
	
	//Binary to Decimal
	Binary_to_Decimal BtD1(
		.clka(clk_27mhz),
		.clkb(clk_27mhz),
		.addra(DT_addr),
		.addrb(vm_addr),
		.douta(DT_data),
		.doutb(vm_data)
	);
	
	
	//System Date and Time
	Date_Time dt(.clk_27mhz(clk_27mhz),.reset(reset),
	.set(set),.disp_en(date_disp_en),.button_up(up),
	.button_down(down),.button_left(left),
	.button_right(right),.year(year),.month(month),
	.day(day),.hour(hour),.minute(minute),.second(second),
	.ascii_out(date_ascii_out),.ascii_out_ready(date_ascii_out_ready)
	,.addr(DT_addr),.data(DT_data));
	
	
	//Voicemail
	 Voicemail_Interface vmail(.clk_27mhz(clk_27mhz),
	.reset(reset),.sts(voicemail_status),.cmd(voicemail_command),
	.phn_num(phn_num),.din(audio_out_data),.dout(dout),.d_ready(ready),
	.disp_en(v_disp_en),.button_up(up),.button_down(down),
	.ascii_out(v_ascii_out),.ascii_out_ready(v_ascii_out_ready),
	.ram_data(ram0_data),.ram_address(ram0_address),.ram_we_b(ram0_we_b),.ram_bwe_b(ram0_bwe_b),
	.year(year),.month(month),.day(day),.hour(hour),.minute(minute),.addr(vm_addr),
	.data(vm_data),.systemace_data(systemace_data),.systemace_address(systemace_address),
	.systemace_ce_b(systemace_ce_b),.systemace_we_b(systemace_we_b),
	.systemace_oe_b(systemace_oe_b),.systemace_mpbrdy(systemace_mpbrdy));
	
	//Display Control Mux
	always @(posedge clk_27mhz) begin
		case(disp_control)
			0: begin //UI case
				vmail_disp_en<=0;
				d_disp_en<=0;
				a_out<=ui_ascii_out;
				a_out_ready<=ui_ascii_out_ready;
			end
			1: begin //Date&Time		
				vmail_disp_en<=0;
				a_out<=date_ascii_out;
				a_out_ready<=date_ascii_out_ready;
				d_disp_en<=1;
			end
			2:	begin //Voicemail	
				d_disp_en<=0;
				a_out<=v_ascii_out;
				a_out_ready<=v_ascii_out_ready;
				vmail_disp_en<=1;
			end
		endcase
	end
	
	assign v_disp_en=vmail_disp_en;
	assign date_disp_en=d_disp_en;
	assign ascii_out_ready=a_out_ready;
	assign ascii_out=a_out;
	
	//Logic Analyzer
	assign analyzer1_data[7:0] = ascii_out;
	assign analyzer1_data[8]=ascii_out_ready;
	assign analyzer1_clock=clk_27mhz;
	assign analyzer1_data[9]=start;
	assign analyzer1_data[15:10]=addr[10:5];
	assign analyzer3_data[3:0]=voicemail_status;
	assign analyzer3_data[5:4]=disp_control;
	assign analyzer3_data[15:6]=0;
	assign analyzer2_data[0]=a_out;
	assign analyzer2_data[6:1]=current_menu_item;
	assign analyzer2_clock=clk_27mhz;
	assign analyzer3_clock=clk_27mhz;
	assign analyzer4_clock=clk_27mhz;



	//////////////////////////////////////////////////
			    
endmodule
