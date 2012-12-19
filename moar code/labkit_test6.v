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
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
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
		
	assign data = 64'd0;

	// Instantiate PRNG
	wire [63:0] rand_num;
	LSFR_64 RAND_GEN_1(
		.clk(clk_40mhz),
		.ainit(reset),
		.pd_out(rand_num)
		);
	
	wire rand_num_1, rand_num_2;
	assign rand_num_1 = rand_num;
	assign rand_num_2 = {rand_num[31:0],rand_num[63:32]};

	// Instantiate PHY Pair

	// Inputs
	wire TCV_RX_1;
	wire TCV_RX_2;
	
	wire [7:0] D_TX_1;
	wire D_TX_ready_1;
	wire [7:0] D_TX_2;
	wire D_TX_ready_2;

	// Outputs
	wire TCV_TX_1;
	wire TCV_TX_en_1;
	wire TCV_TX_2;
	wire TCV_TX_en_2;
	
	wire [7:0] D_RX_1;
	wire D_RX_ready_1;
	wire CD_1;
	wire TX_success_1;
	wire IB_1;
	
	wire [7:0] D_RX_2;
	wire D_RX_ready_2;
	wire CD_2;
	wire TX_success_2;
	wire IB_2;

	PHY_Pair PHY_PAIR_1( 
		.clk_40mhz(clk_40mhz), 
		.clk_160mhz(clk_160mhz), 
		.reset(reset),
		
		.TCV_RX_1(TCV_RX_1), 
		.TCV_TX_1(TCV_TX_1), 
		.TCV_TX_en_1(TCV_TX_en_1), 
		
		.D_TX_1(D_TX_1), 
		.D_RX_1(D_RX_1), 
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
		.D_TX_ready_2(D_TX_ready_2), 
		.D_RX_ready_2(D_RX_ready_2), 
		.CD_2(CD_2), 
		.TX_success_2(TX_success_2), 
		.IB_2(IB_2)
		);
	
	// Instantiate DLCs
	
	wire [1:0] cmd_1;
	wire link_sts_1;
	wire [1:0] sts_1;
	wire [7:0] DLC_RX_1;
	wire DLC_RX_ready_1;
	reg [7:0] DLC_TX_1;
	reg DLC_TX_ready_1;
	wire DLC_RX_addr_1;
	
	DLC DLC_1(
	.clk_40mhz(clk_40mhz),         // 40MHz Clock
	.reset(reset),                 // Active-High Reset
	// PHY I/O
	.PHY_TX(D_TX_1), 
	.PHY_RX(D_RX_1), 
	.PHY_TX_ready(D_TX_ready_1), 
	.PHY_RX_ready(D_RX_ready_1), 
	.PHY_CD(CD_1), 
	.PHY_TX_success(TX_success_1), 
	.PHY_IB(IB_1), 
	// Network I/O 
	.cmd(cmd_1),                           // DLC command from status
	.sts(sts_1),                           // DLC status
	.link_sts(link_sts_1),                 // Link status
	.self_phn_num(8'hDE),                  // Self Phone Number
	.D_TX(DLC_TX_1),                         // outgoing data port
	.D_TX_ready(DLC_TX_ready_1),             // outgoing ready
	.D_TX_addr(8'hAD),
	.D_RX(DLC_RX_1),                         // incoming data port
	.D_RX_ready(DLC_RX_ready_1),             // incoming ready
	.D_RX_addr(D_RX_addr_1),
	// PRNG I/O
	.rand_num(rand_num_1)                    // 64-bit random number
	);
	
	wire [1:0] cmd_2;
	wire link_sts_2;
	wire [1:0] sts_2;
	wire [7:0] DLC_RX_2;
	wire DLC_RX_ready_2;
	wire [7:0] DLC_TX_2;
	wire DLC_TX_ready_2;
	wire DLC_RX_addr_2;
	
	DLC DLC_2(
	.clk_40mhz(clk_40mhz),         // 40MHz Clock
	.reset(reset),                 // Active-High Reset
	// PHY I/O
	.PHY_TX(D_TX_2), 
	.PHY_RX(D_RX_2), 
	.PHY_TX_ready(D_TX_ready_2), 
	.PHY_RX_ready(D_RX_ready_2), 
	.PHY_CD(CD_2), 
	.PHY_TX_success(TX_success_2), 
	.PHY_IB(IB_2),
	// Network I/O 
	.cmd(cmd_2),                           // DLC command from status
	.link_sts(link_sts_2),                 // Link status
	.sts(sts_2),                           // DLC status
	.self_phn_num(8'hAD),                  // Self Phone Number
	.D_TX(DLC_TX_2),                         // outgoing data port
	.D_TX_ready(DLC_TX_ready_2),             // outgoing ready
	.D_TX_addr(8'hDE),
	.D_RX(DLC_RX_2),                         // incoming data port
	.D_RX_ready(DLC_RX_ready_2),           	// incoming ready
	.D_RX_addr(D_RX_addr_2),
	// PRNG I/O
	.rand_num(rand_num_2)                    // 64-bit random number
	);
	
//	// Latch states
//	reg [5:0] init_state_1_l, init_state_2_l;
//	wire init_state_1_change, init_state_2_change;
//	always @(posedge clk_40mhz) init_state_1_l <= init_state_1_DEBUG;
//	always @(posedge clk_40mhz) init_state_2_l <= init_state_2_DEBUG;
//	assign init_state_1_change = (reset) ? 0: (init_state_1_DEBUG != init_state_1_l);
//	assign init_state_2_change = (reset) ? 0: (init_state_2_DEBUG != init_state_2_l);
	
//	wire [5:0] FIFO_out_1;
//	wire F1_empty;
//	DEBUG_FIFO DF_1(
//		.clk(clk_40mhz),
//		.rst(reset),
//		.wr_en(init_state_1_change),
//		.din(init_state_1_DEBUG),
//		.rd_en(b0_rise),
//		.dout(FIFO_out_1),
//		.empty(F1_empty)
//		);
//
//	wire [5:0] FIFO_out_2;
//	wire F2_empty;
//	DEBUG_FIFO DF_2(
//		.clk(clk_40mhz),
//		.rst(reset),
//		.wr_en(init_state_2_change),
//		.din(init_state_2_DEBUG),
//		.rd_en(b1_rise),
//		.dout(FIFO_out_2),
//		.empty(F2_empty)
//		);

	// Define command parameters
	parameter CMD_IDLE        = 2'd0;
	parameter CMD_SET_PHN_NUM = 2'd1;
	parameter CMD_INIT        = 2'd2;
	parameter CMD_TX          = 2'd3;
	
	// Define status parameters
	parameter STS_IDLE      = 2'd0;
	parameter STS_BUSY      = 2'd1;
	parameter STS_TX_ACCEPT = 2'd2;
	parameter STS_TX_REJECT = 2'd3;
	
	reg DLC_RX_ready_2_l;
	always @(posedge clk_40mhz) DLC_RX_ready_2_l <= DLC_RX_ready_2;
	
	reg [2:0] state;
	reg [1:0] cmd_1_reg, cmd_2_reg;
	assign cmd_1 = cmd_1_reg;
	assign cmd_2 = cmd_2_reg;
	reg [5:0] cntr;
	reg tests_failed;
	reg data_arrived;
	reg [15:0] rt_delay;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			state <= 0;
			cmd_1_reg <= 0;
			cmd_2_reg <= 0;
			tests_failed <= 0;
			data_arrived <= 0;
			rt_delay <= 0;
		end
		else begin
			case (state)
				0: begin
					if (sw_rise[0]) begin
						cmd_1_reg <= 1;
						cmd_2_reg <= 1;
						state <= 1;
					end
					else if (sw_rise[1]) begin
						cmd_1_reg <= 1;
						cmd_2_reg <= 1;
						state <= 2;
					end
					else if (sw_rise[2]) begin
						cmd_1_reg <= 1;
						cmd_2_reg <= 1;
						state <= 3;
					end
				end
				1:begin
					cmd_1_reg <= 2;
					state <= 4;
				end
				2:begin
					cmd_2_reg <= 2;
					state <= 4;
				end
				3: begin
					cmd_1_reg <= 2;
					cmd_2_reg <= 2;
					state <= 4;
				end
				4: begin
					if ((sts_1 == STS_IDLE) & sw[3]) begin
						rt_delay <= 0;
						cmd_1_reg <= 3;
						state <= state + 1;
					end
					else begin
						cmd_1_reg <= 0;
					end
				end
				5: begin
					cmd_1_reg <= 0;
					rt_delay <= rt_delay + 1;
					if (sts_1 == STS_TX_REJECT) begin
						tests_failed <= 1;
					end
					else if (sts_1 == STS_TX_ACCEPT) begin
						DLC_TX_ready_1 <= 1;
						DLC_TX_1 <= 0;
						state <= state + 1;
						cntr <= 40;
					end
				end
				6: begin
					rt_delay <= rt_delay + 1;
					if (cntr) begin
						DLC_TX_1 <= DLC_TX_1 + 1;
						cntr <= cntr - 1;
					end
					else begin
						DLC_TX_ready_1 <= 0;
						state <= state + 1;
					end
				end
				7: begin
					if (DLC_RX_ready_2) begin
						data_arrived <= 1;
						if (cntr == DLC_RX_2[5:0]) begin
							cntr <= cntr + 1;
						end
						else
							tests_failed <= 1;
					end
					else if (~DLC_RX_ready_2 & DLC_RX_ready_2_l) begin
						state <= state + 1;
					end
					else begin
						rt_delay <= rt_delay + 1;
					end
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
	assign led[2] = ~data_arrived;
	assign led[3] = ~1'b1;
	assign led[4] = ~1'b1;
	assign led[5] = ~link_sts_1;
	assign led[6] = ~link_sts_2;
	assign led[7] = ~tests_failed;
	
	// Assign hex display data
//	assign data = {rt_delay, 2'd0, init_state_2_DEBUG,2'd0,FIFO_out_2,18'd0,init_state_1_DEBUG,2'd0,FIFO_out_1};
	
   // Logic Analyzer
//	assign analyzer1_clock = clk_40mhz;
//	assign analyzer2_clock = clk_40mhz;
//	assign analyzer3_clock = clk_40mhz;
//	assign analyzer4_clock = clk_40mhz;
//	assign analyzer1_data = {D_TX_1,D_RX_1};
	// assign analyzer2_data = {D_TX_2,D_RX_2};
//	assign analyzer2_data = {s_state_DEBUG, 2'b0,
//									 b_f_lock_DEBUG,
//									 b_b_lock_DEBUG,
//									 b_c_lock_DEBUG,
//									 f1w_s_lock_DEBUG,
//									 f1w_b_lock_DEBUG,
//									 f1w_c_lock_DEBUG,
//									 f1r_f_lock_DEBUG,
//									 f1r_b_lock_DEBUG,
//									 f2w_f_lock_DEBUG,
//									 f2w_b_lock_DEBUG,
//									 f2w_c_lock_DEBUG
//									 };

//	assign analyzer3_data = {TCV_TX_1, TCV_TX_en_1, TCV_RX_1, TCV_TX_2, TCV_TX_en_2, TCV_RX_2, 
//									  IB_2, TX_success_2, CD_2, IB_1, TX_success_1, CD_1, 
//									  D_TX_ready_2, D_RX_ready_2, D_TX_ready_1, D_RX_ready_1};	  
	// assign analyzer4_data = {1'b0, MAC_state_DEBUG, init_state_2_DEBUG, init_state_1_DEBUG};
//	assign analyzer1_data = {CRC_D_TX_DEBUG, CRC_D_RX_DEBUG};
//	assign analyzer2_data = {p_DEBUG, CRC_sts_DEBUG, state, MAC_state_DEBUG, 8'h00};
//	assign analyzer2_data = {p_DEBUG, CRC_sts_DEBUG, state,
//									 b_f_lock_DEBUG,
//									 b_b_lock_DEBUG,
//									 b_c_lock_DEBUG,
//									 f1w_s_lock_DEBUG,
//									 f1w_b_lock_DEBUG,
//									 f1w_c_lock_DEBUG,
//									 f1r_f_lock_DEBUG,
//									 f1r_b_lock_DEBUG,
//									 f2w_f_lock_DEBUG,
//									 f2w_b_lock_DEBUG,
//									 f2w_c_lock_DEBUG
//									 };
//	assign analyzer3_data = {MAC_sts_DEBUG, MAC_cmd_DEBUG, s_state_DEBUG ,MAC_pckt_num_DEBUG, CRC_pckt_num_DEBUG};
//	assign analyzer4_data = {CRC_D_TX_ready_DEBUG, CRC_D_RX_ready_DEBUG, c_state_DEBUG, f_state_DEBUG, b_state_DEBUG};
//
//   assign analyzer1_data = {D_TX_1,D_TX_ready_1,CD_1,rcv_state_DEBUG, state_DEBUG};
//   assign analyzer2_data = {CD_signal_1_DEBUG, CD_comp_1_DEBUG, TX_shift_reg_DEBUG, TCV_TX_en_1,TCV_TX_1,TCV_RX_1,TX_success_1};
//   assign analyzer3_data = {CD_decoder_1_DEBUG, trans_reg_DEBUG, init_state_1_DEBUG, comp_dout_DEBUG[9:4]};
//   assign analyzer4_data = {comp_dout_DEBUG[3:0],demux_dout_DEBUG,demux_nd_DEBUG,in_rd_en_DEBUG};

endmodule
