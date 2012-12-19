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
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
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
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
   assign ram0_we_b = 1'b1;
   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
   assign clock_feedback_out = 1'b0;
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
   assign user1[31:6] = 26'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
//   assign analyzer1_data = 16'h0;
//   assign analyzer1_clock = 1'b1;
//   assign analyzer2_data = 16'h0;
//   assign analyzer2_clock = 1'b1;
//   assign analyzer3_data = 16'h0;
//   assign analyzer3_clock = 1'b1;
//   assign analyzer4_data = 16'h0;
//   assign analyzer4_clock = 1'b1;
			    
////////////////////////////////////////////////////////////////////////////
  //
  // Reset Generation
  //
  // A shift register primitive is used to generate an active-high reset
  // signal that remains high for 16 clock cycles after configuration finishes
  // and the FPGA's internal clocks begin toggling.
  //
  ////////////////////////////////////////////////////////////////////////////
  wire pre_reset;
  SRL16 reset_sr(.D(1'b0), .CLK(clock_27mhz), .Q(pre_reset),
	         .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
  defparam reset_sr.INIT = 16'hFFFF;

	wire clk_40mhz;
	CLK_40 CLK_40_INST(
		.CLKIN_IN(clock_27mhz),
		.RST_IN(pre_reset),
		.CLKFX_OUT(clk_40mhz),
		.LOCKED_OUT(locked_40)
		);
	wire clk_160mhz;
	CLK_160 CLK_160_INST(
		.CLKIN_IN(clock_27mhz),
		.RST_IN(pre_reset),
		.CLKFX_OUT(clk_160mhz),
		.LOCKED_OUT(locked_160)
		);
	
	wire reset;
	assign reset = (pre_reset | ~locked_160 | ~locked_40);
	assign clk_27mhz = clock_27mhz;
	
	////////////////////////////////////////////////////////////////////////////
	//
	// Main Modules
	//
	////////////////////////////////////////////////////////////////////////////
	
	
	wire b_up, b_down, b_left, b_right, b_enter, b0, b1, b2, b3;
	wire br_up, br_down, br_left, br_right, br_enter, br0, br1, br2, br3;
	wire [7:0] sw;
	// Instantiate Button and Switch Debouncers
	debounce DB1(.clock(clk_40mhz),.reset(reset),.noisy(~button_up),.clean(br_up));
	debounce DB2(.clock(clk_40mhz),.reset(reset),.noisy(~button_down),.clean(br_down));
	debounce DB3(.clock(clk_40mhz),.reset(reset),.noisy(~button_left),.clean(br_left));
	debounce DB4(.clock(clk_40mhz),.reset(reset),.noisy(~button_right),.clean(br_right));
	debounce DB5(.clock(clk_40mhz),.reset(reset),.noisy(~button_enter),.clean(br_enter));
	debounce DB6(.clock(clk_40mhz),.reset(reset),.noisy(~button0),.clean(br0));
	debounce DB7(.clock(clk_40mhz),.reset(reset),.noisy(~button1),.clean(br1));
	debounce DB8(.clock(clk_40mhz),.reset(reset),.noisy(~button2),.clean(br2));
	debounce DB9(.clock(clk_40mhz),.reset(reset),.noisy(~button3),.clean(br3));
	debounce DB10(.clock(clk_40mhz),.reset(reset),.noisy(switch[0]),.clean(sw[0]));
	debounce DB11(.clock(clk_40mhz),.reset(reset),.noisy(switch[1]),.clean(sw[1]));
	debounce DB12(.clock(clk_40mhz),.reset(reset),.noisy(switch[2]),.clean(sw[2]));
	debounce DB13(.clock(clk_40mhz),.reset(reset),.noisy(switch[3]),.clean(sw[3]));
	debounce DB14(.clock(clk_40mhz),.reset(reset),.noisy(switch[4]),.clean(sw[4]));
	debounce DB15(.clock(clk_40mhz),.reset(reset),.noisy(switch[5]),.clean(sw[5]));
	debounce DB16(.clock(clk_40mhz),.reset(reset),.noisy(switch[6]),.clean(sw[6]));
	debounce DB17(.clock(clk_40mhz),.reset(reset),.noisy(switch[7]),.clean(sw[7]));
	
	// Instante Button Contention Resolver
	Button_Contention_Resolver BCR1(
		.clk(clk_40mhz),
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
	always @(posedge clk_40mhz) sw_l <= (reset) ? 0: sw;
	wire [7:0] sw_rise, sw_fall;
	assign sw_rise = sw & ~sw_l;
	assign sw_fall = ~sw & sw_l;

	
	// Latch buttons to detect transitions
	reg bl_up, bl_down, bl_left, bl_right, bl_enter, bl0, bl1, bl2, bl3;
	always @(posedge clk_40mhz) begin
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

	// Instantiate hex display
	wire [63:0] data;
	display_16hex DISP_HEX_1(
		.clock_27mhz(clk_40mhz),
		.reset(reset),
		.data(data), 
		.disp_blank(disp_blank),
		.disp_clock(disp_clock), 
		.disp_rs(disp_rs), 
		.disp_ce_b(disp_ce_b),
		.disp_reset_b(disp_reset_b), 
		.disp_data_out(disp_data_out)
		);

	// Inputs
	wire TCV_RX_1;
	wire TCV_RX_2;
	
	reg [7:0] D_TX_1;
	reg D_TX_ready_1;
	reg [7:0] D_TX_2;
	reg D_TX_ready_2;

	// Outputs
	wire TCV_TX_1;
	wire TCV_TX_en_1;
	wire TCV_TX_2;
	wire TCV_TX_en_2;
	
	wire [255:0] D_RX_1;
	wire [5:0] D_RX_byte_cnt_1;
	wire D_RX_ready_1;
	wire CD_1;
	wire TX_success_1;
	wire IB_1;
	wire [255:0] D_RX_2;
	wire [5:0] D_RX_byte_cnt_2;
	wire D_RX_ready_2;
	wire CD_2;
	wire TX_success_2;
	wire IB_2;
	// DEBUG
	wire [2:0] rcv_state_DEBUG;
	wire [2:0] state_DEBUG;
	wire [7:0] encoder_din_1_DEBUG;
	wire [9:0] encoder_dout_1_DEBUG;
	wire encoder_nd_1_DEBUG;
	wire in_rd_en_DEBUG;
	wire [9:0] in_dout_DEBUG;
	wire in_rst_DEBUG;
	wire in_empty_DEBUG;
	wire [3:0] data_to_send_DEBUG;
	wire [9:0] TX_shift_reg_DEBUG;
	wire clk_20mhz_DEBUG;
	wire TX_started_DEBUG;
	wire [23:0] shift_reg_DEBUG;
	wire RX_sampled_ready_DEBUG;
	wire cnsy_zero_DEBUG;
	wire cnsy_one_DEBUG;
	wire check_cnsy_DEBUG;
	wire [2:0] trans_reg_DEBUG;
	wire init_trans_detected_DEBUG;
	wire trans_zero_DEBUG;
	wire trans_late_DEBUG;
	wire trans_not_exist_DEBUG;
	wire init_trans_detect_DEBUG;
	wire demux_nd_DEBUG;
	wire [9:0] demux_dout_DEBUG;
	wire CD_comp_DEBUG;
	wire CD_signal_DEBUG;
	wire CD_decoder_DEBUG;
	wire [9:0] comp_dout_DEBUG;

	PHY_Pair uut( 
		.clk_40mhz(clk_40mhz), 
		.clk_160mhz(clk_160mhz), 
		.reset(reset),
		
		.TCV_RX_1(TCV_RX_1), 
		.TCV_TX_1(TCV_TX_1), 
		.TCV_TX_en_1(TCV_TX_en_1), 
		
		.D_TX_1(D_TX_1), 
		.D_RX_1(D_RX_1), 
		.D_RX_byte_cnt_1(D_RX_byte_cnt_1), 
		.D_TX_ready_1(D_TX_ready_1), 
		.D_RX_ready_1(D_RX_ready_1), 
		.CD_1(CD_1), 
		.TX_success_1(TX_success_1), 
		.IB_1(IB_1), 
		
		.TCV_RX_2(TCV_RX_2), 
		.TCV_TX_2(TCV_TX_2), 
		.TCV_TX_en_2(TCV_TX_en_2), 
		
		.D_TX_2(D_TX_2), 
		.D_RX_2(D_RX_2), 
		.D_RX_byte_cnt_2(D_RX_byte_cnt_2), 
		.D_TX_ready_2(D_TX_ready_2), 
		.D_RX_ready_2(D_RX_ready_2), 
		.CD_2(CD_2), 
		.TX_success_2(TX_success_2), 
		.IB_2(IB_2)
		,// DEBUG
		.rcv_state_DEBUG(rcv_state_DEBUG),
		.state_DEBUG(state_DEBUG),
		.encoder_din_1_DEBUG(encoder_din_1_DEBUG),
		.encoder_dout_1_DEBUG(encoder_dout_1_DEBUG),
		.encoder_nd_1_DEBUG(encoder_nd_1_DEBUG),
		.in_rd_en_DEBUG(in_rd_en_DEBUG),
		.in_dout_DEBUG(in_dout_DEBUG),
		.in_rst_DEBUG(in_rst_DEBUG),
		.in_empty_DEBUG(in_empty_DEBUG),
		.data_to_send_DEBUG(data_to_send_DEBUG),
		.TX_shift_reg_DEBUG(TX_shift_reg_DEBUG),
		.clk_20mhz_DEBUG(clk_20mhz_DEBUG),
		.TX_started_DEBUG(TX_started_DEBUG),
		.shift_reg_DEBUG(shift_reg_DEBUG),
		.RX_sampled_ready_DEBUG(RX_sampled_ready_DEBUG),
		.cnsy_zero_DEBUG(cnsy_zero_DEBUG),
		.cnsy_one_DEBUG(cnsy_one_DEBUG),
		.check_cnsy_DEBUG(check_cnsy_DEBUG),
		.trans_reg_DEBUG(trans_reg_DEBUG),
		.init_trans_detected_DEBUG(init_trans_detected_DEBUG),
		.trans_zero_DEBUG(trans_zero_DEBUG),
		.trans_late_DEBUG(trans_late_DEBUG),
		.trans_not_exist_DEBUG(trans_not_exist_DEBUG),
		.init_trans_detect_DEBUG(init_trans_detect_DEBUG),
		.demux_nd_DEBUG(demux_nd_DEBUG),
		.demux_dout_DEBUG(demux_dout_DEBUG),
		.CD_comp_DEBUG(CD_comp_DEBUG),
		.CD_signal_DEBUG(CD_signal_DEBUG),
		.CD_decoder_DEBUG(CD_decoder_DEBUG),
		.comp_dout_DEBUG(comp_dout_DEBUG)
		);
	
	reg [63:0] data_reg;
	assign data = data_reg;
	always @(posedge clk_40mhz) begin
		if (D_RX_ready_2)
			data_reg <= D_RX_2[63:0];
	end
	
	reg [3:0] state;
	reg tests_done;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			state <= 0;
			D_TX_1 <= 0;
			D_TX_ready_1 <= 0;
			D_TX_2 <= 0;
			D_TX_ready_2 <= 0;
			tests_done <= 0;
		end
		else begin
			case (state)
				0: begin
					if (IB_1 & IB_2) begin
						state <= state + 1;
					end
				end
				1:begin
					if (sw_rise[0]) begin
						state <= state + 1;
						D_TX_1 <= 8'hEF;
						D_TX_ready_1 <= 1;
					end
				end
				2:begin
					state <= state + 1;
					D_TX_1 <= 8'hBE;					
				end
				3:begin
					state <= state + 1;
					D_TX_1 <= 8'hAD;
				end
				4:begin
					state <= state + 1;
					D_TX_1 <= 8'hDE;
				end
				5:begin
					state <= state + 1;
					D_TX_1 <= 8'hFE;
				end
				6:begin
					state <= state + 1;
					D_TX_1 <= 8'hCA;
				end
				7:begin
					state <= state + 1;
					D_TX_1 <= 8'hBE;
				end
				8:begin
					state <= state + 1;
					D_TX_1 <= 8'hBA;
				end
				9:begin
					state <= state + 1;
					D_TX_ready_1 <= 0;
				end
				10: begin
					tests_done <= 1;
				end
			endcase
		end
	end
	
	// Assign outputs
	assign user1[0] = TCV_TX_1;
	assign user1[1] = TCV_TX_en_1;
	assign TCV_RX_1 = user1[2];
	assign user1[3] = TCV_TX_2;
	assign user1[4] = TCV_TX_en_2;
	assign TCV_RX_2 = user1[5];
	
	assign led[0] = ~IB_1;
	assign led[1] = ~IB_2;
	assign led[2] = ~tests_done;
	assign led[7:3] = 5'hFF;
	
   // Logic Analyzer
	assign analyzer1_clock = clk_40mhz;
	assign analyzer2_clock = clk_40mhz;
	assign analyzer3_clock = clk_40mhz;
	assign analyzer4_clock = clk_40mhz;
   assign analyzer1_data = {D_TX_1,D_TX_ready_1,CD_1,rcv_state_DEBUG, state_DEBUG};
   assign analyzer2_data = {CD_signal_DEBUG, CD_comp_DEBUG, TX_shift_reg_DEBUG, TCV_TX_en_1,TCV_TX_1,TCV_RX_1,TX_success_1};
   assign analyzer3_data = {CD_decoder_DEBUG, trans_reg_DEBUG, 6'h00, comp_dout_DEBUG[9:4]};
   assign analyzer4_data = {comp_dout_DEBUG[3:0],demux_dout_DEBUG,demux_nd_DEBUG,in_rd_en_DEBUG};

endmodule
