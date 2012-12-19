`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Sachin Shinde
// 
// Create Date:    07:03:26 11/21/2012 
// Design Name: 
// Module Name:    PHY_Pair 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Instantiate a pair of PHY modules, which share an encoder and 
//                 decoder.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PHY_Pair(
	// PHY I/O
	input clk_40mhz,      // 40Mhz Clock
	input clk_160mhz,     // Sampling Clock
	input reset,          // Active-High Reset
	// PHY_1 I/O
   input TCV_RX_1,                // Transceiver RX
   output TCV_TX_1,               // Transceiver TX
	output TCV_TX_en_1,            // Transceiver TX enable
   input [7:0] D_TX_1,            // DLC Data TX
	output [7:0] D_RX_1,         // DLC Data RX
	input D_TX_ready_1,            // DLC Data TX Ready
   output D_RX_ready_1,           // DLC Data RX Ready
   output CD_1,                   // Collision Detect (while Sending)
	output TX_success_1,           // Successful transmission
   output IB_1,                   // Idle Bus
	// PHY_2 I/O
   input TCV_RX_2,                // Transceiver RX
   output TCV_TX_2,               // Transceiver TX
	output TCV_TX_en_2,            // Transceiver TX enable
   input [7:0] D_TX_2,            // DLC Data TX
	output [7:0] D_RX_2,         // DLC Data RX
	input D_TX_ready_2,            // DLC Data TX Ready
   output D_RX_ready_2,           // DLC Data RX Ready
   output CD_2,                   // Collision Detect (while Sending)
	output TX_success_2,           // Successful transmission
   output IB_2                   // Idle Bus
	,// DEBUG
	output [2:0] rcv_state_DEBUG,
	output [2:0] state_DEBUG,
	output [7:0] encoder_din_1_DEBUG,
	output [9:0] encoder_dout_1_DEBUG,
	output encoder_nd_1_DEBUG,
	output in_rd_en_DEBUG,
	output [9:0] in_dout_DEBUG,
	output in_rst_DEBUG,
	output in_empty_DEBUG,
	output [3:0] data_to_send_DEBUG,
	output [9:0] TX_shift_reg_DEBUG,
	output clk_20mhz_DEBUG,
	output TX_started_DEBUG,
	output [23:0] shift_reg_DEBUG,
	output RX_sampled_ready_DEBUG,
	output cnsy_zero_DEBUG,
	output cnsy_one_DEBUG,
	output check_cnsy_DEBUG,
	output [2:0] trans_reg_DEBUG,
	output init_trans_detected_DEBUG,
	output trans_zero_DEBUG,
	output trans_late_DEBUG,
	output trans_not_exist_DEBUG,
	output init_trans_detect_DEBUG,
	output demux_nd_DEBUG,
	output [9:0] demux_dout_DEBUG,
	output CD_comp_1_DEBUG,
	output CD_signal_1_DEBUG,
	output CD_decoder_1_DEBUG,
	output CD_comp_2_DEBUG,
	output CD_signal_2_DEBUG,
	output CD_decoder_2_DEBUG,
	output [9:0] comp_dout_DEBUG,
	output encoder_ce_1_DEBUG,
	output [9:0] demux_out_2_DEBUG,     // Demultiplexer Output
	output demux_out_ready_2_DEBUG,      // Demultiplexer Output Ready
	output decoder_init_2_DEBUG,         // Decoder Initialization
	output [7:0] decoder_dout_2_DEBUG,  // Decoder Data Output
	output decoder_kout_2_DEBUG,         // Decoder Special Char Output
	output decoder_dout_ready_2_DEBUG    // Decoder Output Ready
	// END DEBUG
	);

	// Instantiate first PHY
	// Decoder I/O
	wire [9:0] demux_out_1;    // Demultiplexer Output
	wire demux_out_ready_1;    // Demultiplexer Output Ready
	wire decoder_init_1;       // Decoder Initialization
	wire [7:0] decoder_dout_1; // Decoder Data Output
	wire decoder_kout_1;       // Decoder Special Char Output
	wire decoder_dout_ready_1; // Decoder Output Ready
	wire CD_decoder_1;         // Collision Detect
	// Encoder I/O
	wire encoder_force_code_1;  // Encoder reset
	wire encoder_ce_1;          // Encoder chip reset
	wire [7:0] encoder_din_1;   // Encoder data wire
	wire encoder_kin_1;         // Encoder special character wire
	wire [9:0] encoder_dout_1;  // Encoder character dout
	wire encoder_nd_1;          // Encoder new data signal
	PHY PHY_1(
		// PHY_1 I/O
		.clk_40mhz(clk_40mhz),             // System Clock
		.clk_160mhz(clk_160mhz),           // Sampling Clock
		.reset(reset),                     // Active-High Reset
		.TCV_RX(TCV_RX_1),                   // Transceiver RX
		.TCV_TX(TCV_TX_1),                   // Transceiver TX
		.TCV_TX_en(TCV_TX_en_1),             // Transceiver TX enable
		.D_TX(D_TX_1),                       // DLC Data TX
		.D_RX(D_RX_1),                       // DLC Data RX
		.D_TX_ready(D_TX_ready_1),           // DLC Data TX Ready
		.D_RX_ready(D_RX_ready_1),           // DLC Data RX Ready
		.CD(CD_1),                           // Collision Detect (while Sending_1)
		.TX_success(TX_success_1),           // Successful transmission
		.IB(IB_1),                           // Idle Bus
		// Decoder I/O
		.demux_out(demux_out_1),                  // Demultiplexer Output
		.demux_out_ready(demux_out_ready_1),      // Demultiplexer Output Ready
		.decoder_init(decoder_init_1),            // Decoder Initialization
		.decoder_dout(decoder_dout_1),            // Decoder Data Output
		.decoder_kout(decoder_kout_1),            // Decoder Special Char Output
		.decoder_dout_ready(decoder_dout_ready_1),  // Decoder Output Ready
		.CD_decoder(CD_decoder_1),                // Collision Detect
		// Encoder I/O
		.encoder_force_code(encoder_force_code_1),
		.encoder_ce(encoder_ce_1),
		.encoder_din(encoder_din_1),
		.encoder_kin(encoder_kin_1),
		.encoder_dout(encoder_dout_1),
		.encoder_nd(encoder_nd_1)
		,// DEBUG
		.rcv_state_DEBUG(rcv_state_DEBUG),
		.state_DEBUG(state_DEBUG),
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
		.CD_comp_DEBUG(CD_comp_1_DEBUG),
		.CD_signal_DEBUG(CD_signal_1_DEBUG),
		.CD_decoder_DEBUG(CD_decoder_1_DEBUG),
		.comp_dout_DEBUG(comp_dout_DEBUG)
		// END DEBUG
	);

	// Instantiate second PHY
	// Decoder I/O
	wire [9:0] demux_out_2;    // Demultiplexer Output
	wire demux_out_ready_2;    // Demultiplexer Output Ready
	wire decoder_init_2;       // Decoder Initialization
	wire [7:0] decoder_dout_2; // Decoder Data Output
	wire decoder_kout_2;       // Decoder Special Char Output
	wire decoder_dout_ready_2; // Decoder Output Ready
	wire CD_decoder_2;         // Collision Detect
	// Encoder I/O
	wire encoder_force_code_2;  // Encoder reset
	wire encoder_ce_2;          // Encoder chip reset
	wire [7:0] encoder_din_2;   // Encoder data wire
	wire encoder_kin_2;         // Encoder special character wire
	wire [9:0] encoder_dout_2;  // Encoder character dout
	wire encoder_nd_2;          // Encoder new data signal
	PHY PHY_2(
		// PHY_2 I/O
		.clk_40mhz(clk_40mhz),      // System Clock
		.clk_160mhz(clk_160mhz),    // Sampling Clock
		.reset(reset),              // Active-High Reset
		.TCV_RX(TCV_RX_2),                   // Transceiver RX
		.TCV_TX(TCV_TX_2),                   // Transceiver TX
		.TCV_TX_en(TCV_TX_en_2),             // Transceiver TX enable
		.D_TX(D_TX_2),                       // DLC Data TX
		.D_RX(D_RX_2),                       // DLC Data RX
		.D_TX_ready(D_TX_ready_2),           // DLC Data TX Ready
		.D_RX_ready(D_RX_ready_2),           // DLC Data RX Ready
		.CD(CD_2),                           // Collision Detect (while Sending_2)
		.TX_success(TX_success_2),           // Successful transmission
		.IB(IB_2),                           // Idle Bus
		// Decoder I/O
		.demux_out(demux_out_2),                  // Demultiplexer Output
		.demux_out_ready(demux_out_ready_2),      // Demultiplexer Output Ready
		.decoder_init(decoder_init_2),            // Decoder Initialization
		.decoder_dout(decoder_dout_2),            // Decoder Data Output
		.decoder_kout(decoder_kout_2),            // Decoder Special Char Output
		.decoder_dout_ready(decoder_dout_ready_2),  // Decoder Output Ready
		.CD_decoder(CD_decoder_2),                // Collision Detect
		// Encoder I/O
		.encoder_force_code(encoder_force_code_2),
		.encoder_ce(encoder_ce_2),
		.encoder_din(encoder_din_2),
		.encoder_kin(encoder_kin_2),
		.encoder_dout(encoder_dout_2),
		.encoder_nd(encoder_nd_2)
		,// DEBUG
		.CD_comp_DEBUG(CD_comp_2_DEBUG),
		.CD_signal_DEBUG(CD_signal_2_DEBUG),
		.CD_decoder_DEBUG(CD_decoder_2_DEBUG)
		// END DEBUG
	);
	
	// Instantiate Decoder
	wire decoder_code_err_1;
	wire decoder_disp_err_1;
	wire decoder_ce_1;
	assign decoder_ce_1 = demux_out_ready_1 | decoder_init_1;
	wire decoder_code_err_2;
	wire decoder_disp_err_2;
	wire decoder_ce_2;
	assign decoder_ce_2 = demux_out_ready_2 | decoder_init_2;
	PHY_Decoder PHY_DEC_1(
		// First Decoder I/O
		.clk(clk_40mhz),
		.ce(decoder_ce_1),
		.sinit(decoder_init_1),
		.din(demux_out_1),
		.dout(decoder_dout_1),
		.kout(decoder_kout_1),
		.code_err(decoder_code_err_1),
		.disp_err(decoder_disp_err_1),
		.nd(decoder_dout_ready_1),
		// Second Decoder I/O
		.clk_b(clk_40mhz),
		.ce_b(decoder_ce_2),
		.sinit_b(decoder_init_2),
		.din_b(demux_out_2),
		.dout_b(decoder_dout_2),
		.kout_b(decoder_kout_2),
		.code_err_b(decoder_code_err_2),
		.disp_err_b(decoder_disp_err_2),
		.nd_b(decoder_dout_ready_2)
	);
	
	// Assign outputs
	assign CD_decoder_1 = decoder_code_err_1 | decoder_disp_err_1;
	assign CD_decoder_2 = decoder_code_err_2 | decoder_disp_err_2;
	
	// Instantiate Encoder
	wire encoder_real_ce_1; 
	wire encoder_real_ce_2;
	assign encoder_real_ce_1 = encoder_ce_1 | encoder_force_code_1;
	assign encoder_real_ce_2 = encoder_ce_2 | encoder_force_code_2;
	PHY_Encoder PHY_ENC_1(
		// First Encoder I/O
		.clk(clk_40mhz),
		.force_code(encoder_force_code_1),
		.din(encoder_din_1),
		.kin(encoder_kin_1),
		.ce(encoder_real_ce_1),
		.dout(encoder_dout_1),
		.nd(encoder_nd_1),
		// Second Encoder I/O
		.clk_b(clk_40mhz),
		.force_code_b(encoder_force_code_2),
		.din_b(encoder_din_2),
		.kin_b(encoder_kin_2),
		.ce_b(encoder_real_ce_2),
		.dout_b(encoder_dout_2),
		.nd_b(encoder_nd_2)
		);
		
	// DEBUG
	assign encoder_din_2_DEBUG = encoder_din_2;
	assign encoder_dout_2_DEBUG= encoder_dout_2;
	assign encoder_nd_2_DEBUG = encoder_nd_2;
	assign encoder_ce_2_DEBUG = encoder_ce_2;
	assign demux_out_2_DEBUG = demux_out_2;
	assign demux_out_ready_2_DEBUG = demux_out_ready_2;
	assign decoder_init_2_DEBUG = decoder_init_2;
	assign decoder_dout_2_DEBUG = decoder_dout_2;
	assign decoder_kout_2_DEBUG = decoder_kout_2;
	assign decoder_dout_ready_2_DEBUG = decoder_dout_ready_2;
endmodule
