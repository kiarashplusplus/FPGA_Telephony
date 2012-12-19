///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Sachin Shinde
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

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
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
   assign ram0_cen_b = 1'b0;
   assign ram0_ce_b = 1'b0;
   assign ram0_oe_b = 1'b0;
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
//   assign led = 8'hFF;
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
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;

//////////////////////////////////////////////////////////////////////////////
	//
	// Reset Generation
	//
	// A shift register primitive is used to generate an active-high reset
	// signal that remains high for 16 clock cycles after configuration finishes
	// and the FPGA's internal clocks begin toggling.
	//
   ///////////////////////////////////////////////////////////////////////////
   wire clk_27mhz, locked;
	ramclock RAMCLOCK_1(
		.ref_clock(clock_27mhz), 
		.fpga_clock(clk_27mhz), 
		.ram0_clock(ram0_clk), 
		.ram1_clock(ram1_clk),		
	   .clock_feedback_in(clock_feedback_in),
		.clock_feedback_out(clock_feedback_out), 
		.locked(locked)
		);
		
   wire pre_reset, reset;
   SRL16 reset_sr(.D(1'b0), .CLK(clk_27mhz), .Q(pre_reset),
	         .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;
	
	assign reset = pre_reset | ~locked;

	////////////////////////////////////////////////////////////////////////////
	//
	// Main Modules
	//
	////////////////////////////////////////////////////////////////////////////
	
	
	wire b_up, b_down, b_left, b_right, b_enter, b0, b1, b2, b3;
	wire br_up, br_down, br_left, br_right, br_enter, br0, br1, br2, br3;
	wire [7:0] sw;
	// Instantiate Button and Switch Debouncers
	debounce DB1(.clock(clk_27mhz),.reset(reset),.noisy(~button_up),.clean(br_up));
	debounce DB2(.clock(clk_27mhz),.reset(reset),.noisy(~button_down),.clean(br_down));
	debounce DB3(.clock(clk_27mhz),.reset(reset),.noisy(~button_left),.clean(br_left));
	debounce DB4(.clock(clk_27mhz),.reset(reset),.noisy(~button_right),.clean(br_right));
	debounce DB5(.clock(clk_27mhz),.reset(reset),.noisy(~button_enter),.clean(br_enter));
	debounce DB6(.clock(clk_27mhz),.reset(reset),.noisy(~button0),.clean(br0));
	debounce DB7(.clock(clk_27mhz),.reset(reset),.noisy(~button1),.clean(br1));
	debounce DB8(.clock(clk_27mhz),.reset(reset),.noisy(~button2),.clean(br2));
	debounce DB9(.clock(clk_27mhz),.reset(reset),.noisy(~button3),.clean(br3));
	debounce DB10(.clock(clk_27mhz),.reset(reset),.noisy(switch[0]),.clean(sw[0]));
	debounce DB11(.clock(clk_27mhz),.reset(reset),.noisy(switch[1]),.clean(sw[1]));
	debounce DB12(.clock(clk_27mhz),.reset(reset),.noisy(switch[2]),.clean(sw[2]));
	debounce DB13(.clock(clk_27mhz),.reset(reset),.noisy(switch[3]),.clean(sw[3]));
	debounce DB14(.clock(clk_27mhz),.reset(reset),.noisy(switch[4]),.clean(sw[4]));
	debounce DB15(.clock(clk_27mhz),.reset(reset),.noisy(switch[5]),.clean(sw[5]));
	debounce DB16(.clock(clk_27mhz),.reset(reset),.noisy(switch[6]),.clean(sw[6]));
	debounce DB17(.clock(clk_27mhz),.reset(reset),.noisy(switch[7]),.clean(sw[7]));
	
	// Instante Button Contention Resolver
	Button_Contention_Resolver BCR1(
		.clk(clk_27mhz),
		.reset(reset),
		// Button Inputs
		.button0_in(br0),
		.button1_in(br1),
		.button2_in(br2),
		.button3_in(br3),
		.button_enter_in(br_enter),
		.button_left_in(br_left),
		.button_right_in(br_right),
		.button_up_in(br_up),
		.button_down_in(br_down),
		// Button Outputs
		.button0_out(b0),
		.button1_out(b1),
		.button2_out(b2),
		.button3_out(b3),
		.button_enter_out(b_enter),
		.button_left_out(b_left),
		.button_right_out(b_right),
		.button_up_out(b_up),
		.button_down_out(b_down)
	);
	
	// Latch switches to detect transitions
	reg [7:0] sw_l;
	always @(posedge clk_27mhz) sw_l <= (reset) ? 0: sw;
	wire [7:0] sw_rise, sw_fall;
	assign sw_rise = sw & ~sw_l;
	assign sw_fall = ~sw & sw_l;

	
	// Latch buttons to detect transitions
	reg bl_up, bl_down, bl_left, bl_right, bl_enter, bl0, bl1, bl2, bl3;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			bl_up <= 0;
			bl_down <= 0;
			bl_left <= 0;
			bl_right <= 0;
			bl_enter <= 0;
			bl0 <= 0;
			bl1 <= 0;
			bl2 <= 0;
			bl3 <= 0;
		end
		else begin
			bl_up <= b_up;
			bl_down <= b_down;
			bl_left <= b_left;
			bl_right <= b_right;
			bl_enter <= b_enter;
			bl0 <= b0;
			bl1 <= b1;
			bl2 <= b2;
			bl3 <= b3;			
		end
	end
	assign b_up_rise = b_up & ~bl_up;
	assign b_up_fall = ~b_up & bl_up;
	assign b_down_rise = b_down & ~bl_down;
	assign b_down_fall = ~b_down & bl_down;
	assign b_left_rise = b_left & ~bl_left;
	assign b_left_fall = ~b_left & bl_left;
	assign b_right_rise = b_right & ~bl_right;
	assign b_right_fall = ~b_right & bl_right;
	assign b_enter_rise = b_enter & ~bl_enter;
	assign b_enter_fall = ~b_enter & bl_enter;
	assign b0_rise = b0 & ~bl0;
	assign b0_fall = ~b0 & bl0;
	assign b1_rise = b1 & ~bl1;
	assign b1_fall = ~b1 & bl1;
	assign b2_rise = b2 & ~bl2;
	assign b2_fall = ~b2 & bl2;
	assign b3_rise = b3 & ~bl3;
	assign b3_fall = ~b3 & bl3;
	
	
	// Initiate DT module
	wire [6:0] year;
	wire [3:0] month;
	wire [4:0] day;
	wire [4:0] hour;
	wire [5:0] minute;
	wire [5:0] second;
	wire [7:0] DT_ascii_out;
	wire DT_ascii_out_ready;
	wire [6:0] DT_addr;
	wire [7:0] DT_data;
	wire DT_disp_en;
	reg DT_set;
	Date_Time DT1(
		.clk_27mhz(clk_27mhz),           
		.reset(reset),               
		// Control signals
		.set(DT_set),           
		.disp_en(DT_disp_en),      
		.button_up(b_up),     
		.button_down(b_down),   
		.button_left(b_left),   
		.button_right(b_right),  
		// Date & Time binary outputs
		.year(year),
		.month(month),
		.day(day),
		.hour(hour),
		.minute(minute),
		.second(second),
		// ASCII output
		.ascii_out(DT_ascii_out),
		.ascii_out_ready(DT_ascii_out_ready),
		// BRAM Binary-to-Decimal Lookup-Table I/O
		.addr(DT_addr),
		.data(DT_data)
		);
	
	// Instantiate text scroller
	wire [127:0] string_data;
	wire [7:0] ascii_in;
	wire ascii_in_ready;
	Text_Scroller TS1(	
		.clk(clk_27mhz),
		.reset(reset),
		// Data In
		.ascii_data(ascii_in),
		.ascii_data_ready(ascii_in_ready),
		// Data Out
		.string_data(string_data)
		);
	
	// Instantiate string and hex displays
	display_string DS1(
		.clock_27mhz(clk_27mhz),
		.reset(reset), 
		.string_data(string_data), 
		.disp_blank(disp_blank_0), 
		.disp_clock(disp_clock_0), 
		.disp_rs(disp_rs_0), 
		.disp_ce_b(disp_ce_b_0),
		.disp_reset_b(disp_reset_b_0), 
		.disp_data_out(disp_data_out_0)
		);

	wire [63:0] data;
	display_16hex DISP_HEX_1(
		.clock_27mhz(clk_27mhz),
		.reset(reset),
		.data(data), 
		.disp_blank(disp_blank_1),
		.disp_clock(disp_clock_1), 
		.disp_rs(disp_rs_1), 
		.disp_ce_b(disp_ce_b_1),
		.disp_reset_b(disp_reset_b_1), 
		.disp_data_out(disp_data_out_1)
		);
	
	// Mux displays as needed
	reg disp_blank_reg, disp_clock_reg, disp_rs_reg, disp_ce_b_reg, disp_reset_b_reg, disp_data_out_reg;
	assign disp_blank = disp_blank_reg;
	assign disp_clock = disp_clock_reg;
	assign disp_rs = disp_rs_reg;
	assign disp_ce_b = disp_ce_b_reg;
	assign disp_reset_b = disp_reset_b_reg;
	assign disp_data_out = disp_data_out_reg;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			disp_blank_reg <= 1'b1;
			disp_clock_reg <= 1'b0;
			disp_rs_reg <= 1'b0;
			disp_ce_b_reg <= 1'b1;
			disp_reset_b_reg <= 1'b0;
			disp_data_out_reg <= 1'b0;
		end
		else if (sw[0]) begin
			disp_blank_reg <= disp_blank_0;
			disp_clock_reg <= disp_clock_0;
			disp_rs_reg <= disp_rs_0;
			disp_ce_b_reg <= disp_ce_b_0;
			disp_reset_b_reg <= disp_reset_b_0;
			disp_data_out_reg <= disp_data_out_0;
		end
		else begin
			disp_blank_reg <= disp_blank_1;
			disp_clock_reg <= disp_clock_1;
			disp_rs_reg <= disp_rs_1;
			disp_ce_b_reg <= disp_ce_b_1;
			disp_reset_b_reg <= disp_reset_b_1;
			disp_data_out_reg <= disp_data_out_1;		
		end
	end

	
	// Instantiate AC '97 PCM
	wire [15:0] audio_in_data,audio_out_data;
	wire audio_ready;
	AC97_PCM AC97_PCM_1(
		.clock_27mhz(clk_27mhz),
		.reset(reset),
		.volume(4'b1111),
		// PCM interface signals
		.audio_in_data(audio_in_data),
		.audio_out_data(audio_out_data),
		.ready(audio_ready),
		// LM4550 interface signals
		.audio_reset_b(audio_reset_b),
		.ac97_sdata_out(ac97_sdata_out),
		.ac97_sdata_in(ac97_sdata_in),
		.ac97_synch(ac97_synch),
		.ac97_bit_clock(ac97_bit_clock)
		);

	// Instantiate Voicemail Interface
	wire [3:0] sts;
	wire [3:0] cmd;
	wire [7:0] phn_num;
	wire [7:0] vm_ascii_out;
	wire vm_ascii_out_ready;
	wire [6:0] vm_addr;
	wire [7:0] vm_data;
	wire vm_disp_en;
	Voicemail_Interface VM_INTERFACE_1(
		.clk_27mhz(clk_27mhz),      // 27MHz clock
		.reset(reset),              // Synchronous reset
		// Main Interface ports
		.sts(sts),                  // Status port
		.cmd(cmd),                  // Port for issuing commands
		.phn_num(phn_num),          // Port for phone number (on writes)
		.din(audio_in_data),        // Sample Data in
		.dout(audio_out_data),      // Sample Data out
		.d_ready(audio_ready),      // Sample Data Ready Signal
		.disp_en(vm_disp_en),       // Display Enable
		// Button inputs
		.button_up(b_up),
		.button_down(b_down),
		// ASCII output
		.ascii_out(vm_ascii_out),               // Port for ASCII data
		.ascii_out_ready(vm_ascii_out_ready),   // Ready signal for ASCII data
		// ZBT RAM I/Os
		.ram_data(ram0_data),
		.ram_address(ram0_address),
		.ram_we_b(ram0_we_b),
		.ram_bwe_b(ram0_bwe_b),
		// Date & Time inputs	
		.year(year),
		.month(month),
		.day(day),
		.hour(hour),
		.minute(minute),
		.second(second),
		// Binary-to-Decimal Lookup-Table I/O
		.addr(vm_addr),
		.data(vm_data),
		// SystemACE ports
		.systemace_data(systemace_data),         // SystemACE R/W data
		.systemace_address(systemace_address),   // SystemACE R/W address
		.systemace_ce_b(systemace_ce_b),      // SystemACE chip enable (Active Low)
		.systemace_we_b(systemace_we_b),         // SystemACE write enable (Active Low)
		.systemace_oe_b(systemace_oe_b),         // SystemACE output enable (Active Low)
		.systemace_mpbrdy(systemace_mpbrdy)        // SystemACE buffer ready
		);
	
	reg [3:0] cmd_reg;
	reg [7:0] phn_num_reg;
	
	assign cmd = cmd_reg;
	assign phn_num = phn_num_reg;
	
	// Define command parameters
	parameter CMD_IDLE       = 4'd0;
	parameter CMD_START_RD   = 4'd1;
	parameter CMD_END_RD     = 4'd2;
	parameter CMD_START_WR   = 4'd3;
	parameter CMD_END_WR     = 4'd4;
	parameter CMD_VIEW_UNRD  = 4'd5;
	parameter CMD_VIEW_SAVED = 4'd6;
	parameter CMD_DEL        = 4'd7;
	parameter CMD_SAVE       = 4'd8;
	
	// Define Status parameters
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
	
	// Binary_to_Decimal Instantiation
	Binary_to_Decimal BtD1(
		.clka(clk_27mhz),
		.clkb(clk_27mhz),
		.addra(DT_addr),
		.addrb(vm_addr),
		.douta(DT_data),
		.doutb(vm_data)
		);
	
	// Set output to Text Scroller
	assign ascii_in = vm_ascii_out;
	assign ascii_in_ready = vm_ascii_out_ready;
	assign vm_disp_en = 1'b1;
	assign DT_disp_en = 1'b0;

	// Instantiate state
	reg [3:0] state;
	
	// Define state paramters
	parameter S_IDLE       = 4'h0;
	parameter S_VIEW_UNRD  = 4'h1;
	parameter S_VIEW_SAVED = 4'h2;
	parameter S_START_RD   = 4'h3;
	parameter S_START_RD_1 = 4'h4;
	parameter S_START_RD_2 = 4'h5;
	parameter S_START_WR   = 4'h6;
	parameter S_START_WR_1 = 4'h7;
	parameter S_DEL        = 4'h8;
	parameter S_SAVE       = 4'h9;
	
	// Set commands with buttons
	always @(posedge clk_27mhz) begin
		if (reset) begin
			cmd_reg <= CMD_IDLE;
			phn_num_reg <= 8'hFF;
			state <= S_IDLE;
		end
		else begin
			case (state)
				S_IDLE: begin
					cmd_reg <= CMD_IDLE;
					if (sts == STS_CMD_RDY) begin
						if (b_left_rise)
							state <= S_VIEW_UNRD;
						else if (b_right_rise)
							state <= S_VIEW_SAVED;
						else if (b_enter_rise)
							state <= S_START_RD;
						else if (b3_rise)
							state <= S_START_WR;
						else if (b0_rise)
							state <= S_DEL;
						else if (b1_rise)
							state <= S_SAVE;
					end
				end
				S_VIEW_UNRD: begin
					if (sts == STS_CMD_RDY) begin
						cmd_reg <= CMD_VIEW_UNRD;
						state <= S_IDLE;
					end
				end
				S_VIEW_SAVED: begin
					if (sts == STS_CMD_RDY) begin
						cmd_reg <= CMD_VIEW_SAVED;
						state <= S_IDLE;
					end
				end
				S_START_RD: begin
					if (sts == STS_CMD_RDY) begin
						cmd_reg <= CMD_START_RD;
						state <= state + 1;
					end
				end
				S_START_RD_1: begin
					cmd_reg <= CMD_IDLE;
					state <= state + 1;
				end
				S_START_RD_2: begin
					if (sts == STS_RDING) begin
						if (~b_enter) begin
							cmd_reg <= CMD_END_RD;
							state <= S_IDLE;
						end
					end
					else if ((sts == STS_RD_FIN)|(sts == STS_CMD_RDY))
						state <= S_IDLE;
				end
				S_START_WR: begin
					if (sts == STS_CMD_RDY) begin
						cmd_reg <= CMD_START_WR;
						phn_num_reg <= sw[7:1];
						state <= state + 1;
					end
				end
				S_START_WR_1: begin
					if (sts == STS_WRING) begin
						if (~b3) begin
							cmd_reg <= CMD_END_WR;
							state <= S_IDLE;
						end
					end
					else if (sts == STS_WR_FIN) begin
						state <= S_IDLE;
					end
				end
				S_DEL: begin
					if (sts == STS_CMD_RDY) begin
						cmd_reg <= CMD_DEL;
						state <= S_IDLE;
					end
				end
				S_SAVE: begin
					if (sts == STS_CMD_RDY) begin
						cmd_reg <= CMD_SAVE;
						state <= S_IDLE;
					end
				end
			endcase
		end
	end
	
	// Latch LEDs to temporary statuses, with reset button b2
	reg led3, led4, led5, led6, led7;
	assign led[7] = ~led7;
	assign led[6] = ~led6;
	assign led[5] = ~led5;
	assign led[4] = ~led4;
	assign led[3] = ~led3;
	assign led[2] = ~(sts == STS_RDING);
	assign led[1] = ~(sts == STS_WRING);
	assign led[0] = ~(sts == STS_NO_CF_DEVICE);

	always @(posedge clk_27mhz) begin
		if (reset | b2) begin
			led3 <= 0;
			led4 <= 0;
			led5 <= 0;
			led6 <= 0;
			led7 <= 0;
		end
		else begin
			if (sts == STS_RD_FIN)      led3 <= 1;
			if (sts == STS_WR_FIN)      led4 <= 1;
			if (sts == STS_ERR_RD_FAIL) led5 <= 1;
			if (sts == STS_ERR_WR_FAIL) led6 <= 1;
			if (sts == STS_ERR_VM_FULL) led7 <= 1;
		end
	end

endmodule
