`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:03:25 11/12/2012 
// Design Name: 
// Module Name:    PHY 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Physical Layer in OSI Model.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PHY(
	// PHY I/O
	input clk_40mhz,             // 40MHz Clock
	input clk_160mhz,            // Sampling 160 MHz Clock
	input reset,                 // Active-High Reset
   input TCV_RX,                // Transceiver RX
   output TCV_TX,               // Transceiver TX
	output TCV_TX_en,            // Transceiver TX enable
   input [7:0] D_TX,            // DLC Data TX
	output [7:0] D_RX,         // DLC Data RX
	input D_TX_ready,            // DLC Data TX Ready
   output D_RX_ready,           // DLC Data RX Ready
   output CD,                   // Collision Detect (while Sending)
	output TX_success,           // Successful transmission
   output IB,                   // Idle Bus
	// Decoder I/O
	output [9:0] demux_out,    // Demultiplexer Output
	output demux_out_ready,    // Demultiplexer Output Ready
	output decoder_init,       // Decoder Initialization
	input [7:0] decoder_dout,  // Decoder Data Output
	input decoder_kout,        // Decoder Special Char Output
	input decoder_dout_ready,  // Decoder Output Ready
	input CD_decoder,          // Decoder Collision Detect
	// Encoder I/O
	output encoder_force_code, // Encoder reset
	output encoder_ce,         // Encoder chip reset
	output [7:0] encoder_din,  // Encoder data input
	output encoder_kin,        // Encoder special character input
	input [9:0] encoder_dout,  // Encoder character dout
	input encoder_nd           // Encoder new data signal
	,// DEBUG
	output [2:0] rcv_state_DEBUG,
	output [2:0] state_DEBUG,
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
	output CD_comp_DEBUG,
	output CD_signal_DEBUG,
	output CD_decoder_DEBUG,
	output [9:0] comp_dout_DEBUG
	// END DEBUG
   );

	// Instantiate main ready & enable output registers
	reg TCV_TX_reg;
	reg TCV_TX_en_reg;
	reg D_RX_ready_reg;
	reg CD_reg;
	reg IB_reg;
	reg TX_success_reg;
	
	// Assign outputs
	assign TCV_TX = TCV_TX_reg;
	assign TCV_TX_en = TCV_TX_en_reg;
	assign D_RX_ready = D_RX_ready_reg;
	assign CD = CD_reg;
	assign IB = IB_reg;
	assign TX_success = TX_success_reg;
	
	///////////////////////////////////////////////////////////////////////////////
	// RX LOGIC
	///////////////////////////////////////////////////////////////////////////////
	
	// Instantiate RX Sampler for demultiplexing
	wire [7:0] RX_sampled;
	wire RX_sampled_ready;
	PHY_RX_Sample PHY_RX_SAMPLE_1(
		.clk_40mhz(clk_40mhz),
		.clk_160mhz(clk_160mhz),
		.reset(reset),
		.RX(TCV_RX),
		.out_ready(RX_sampled_ready),
		.RX_sampled(RX_sampled)
	);
	
	// Instantiate shift registers for clock recovery
	reg [23:0] shift_reg;
	always @(posedge clk_40mhz) begin
		if (RX_sampled_ready) begin
			shift_reg <= {shift_reg[15:0], RX_sampled};
		end
	end
	
	// Instantiate transition address registers
	reg [2:0] trans_reg, init_trans_reg;
	wire [3:0] trans_reg_early, trans_reg_zero, trans_reg_late;
	wire [4:0] trans_reg_cnsy1 [0:4];
	
	// Instantiate transition check registers
	reg trans_zero, trans_late, trans_not_exist;
	
	// Instantiate signal consistency check registers
	reg check_cnsy, cnsy_one, cnsy_zero;
	
	// Assign shift register addresses
	assign trans_reg_early = trans_reg + 5;
	assign trans_reg_zero = trans_reg + 4;
	assign trans_reg_late = trans_reg + 3;
	assign trans_reg_cnsy1[0] = trans_reg + 12;
	assign trans_reg_cnsy1[1] = trans_reg + 13;
	assign trans_reg_cnsy1[2] = trans_reg + 14;
	assign trans_reg_cnsy1[3] = trans_reg + 15;
	assign trans_reg_cnsy1[4] = trans_reg + 16;
	
	// Recover clock from transitions, sample as needed
	reg skip_frame;
	reg init_trans_detect;
	reg init_trans_detected;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			trans_reg <= 0;
			init_trans_detected <= 0;
			check_cnsy <= 0;
			skip_frame <= 0;
		end
		// Determine transition edge, store next transition measure points
		// Handle edge cases where frame pointer moves out of frame (both too early and too late)
		else if (RX_sampled_ready) begin
			cnsy_one <= shift_reg[12] & shift_reg[13] & shift_reg[14] & shift_reg[15] & shift_reg[16];
			cnsy_zero <= ~shift_reg[12] & ~shift_reg[13] & ~shift_reg[14] & ~shift_reg[15] & ~shift_reg[16];
			if (init_trans_detect) begin  // if detecting initial edge
				trans_reg <= (|init_trans_reg) ? init_trans_reg: (~shift_reg[5]) ? 3'd2: (~shift_reg[4]) ? 3'd1: (~shift_reg[3]) ? 3'd0: trans_reg;
				init_trans_detected <= (init_trans_reg) || (|(~shift_reg[5:3]));
				check_cnsy <= 1'b0;
				skip_frame <= 1'b0;
			end
			else if (trans_not_exist) begin  // if transition doesn't exist
				init_trans_detected <= 0;
				trans_reg <= trans_reg;
				check_cnsy <= 1'b0;
				skip_frame <= 1'b0;
			end
			else if (trans_late) begin
				init_trans_detected <= 0;
				trans_reg <= trans_reg - 1;
				check_cnsy <= 1'b0;
				skip_frame <= (trans_reg == 0); // EDGE CASE: Frame pointer moves too late (no transition in frame), so skip frame.
			end
			else if (trans_zero) begin
				init_trans_detected <= 0;
				trans_reg <= trans_reg;
				check_cnsy <= 1'b0;
				skip_frame <= 1'b0;
			end
			else begin // if (trans_early)
				init_trans_detected <= 0;
				trans_reg <= trans_reg + 1;
				check_cnsy <= (trans_reg == 7); // EDGE CASE: Frame pointer moves too early (two transitions in frame), so assume next transition is at 0.
				skip_frame <= 1'b0;
			end
		end
		// Assign transition checks. Determine from previously found transitions whether the signal is consistent.
		else begin // if (~RX_sampled_ready)
			trans_zero <= (shift_reg[trans_reg_early] == shift_reg[trans_reg_zero]);
			trans_late <= (shift_reg[trans_reg_early] == shift_reg[trans_reg_zero]) & (shift_reg[trans_reg_early] == shift_reg[trans_reg_late]);
			trans_not_exist <= (shift_reg[trans_reg_early] == shift_reg[trans_reg]);
			cnsy_one <= shift_reg[trans_reg_cnsy1[0]] & shift_reg[trans_reg_cnsy1[1]] & shift_reg[trans_reg_cnsy1[2]] & shift_reg[trans_reg_cnsy1[3]] & shift_reg[trans_reg_cnsy1[4]];
			cnsy_zero <= (~shift_reg[trans_reg_cnsy1[0]] & ~shift_reg[trans_reg_cnsy1[1]] & ~shift_reg[trans_reg_cnsy1[2]] & ~shift_reg[trans_reg_cnsy1[3]] & ~shift_reg[trans_reg_cnsy1[4]]);
			check_cnsy <= ~skip_frame;
			skip_frame <= 1'b0;
			init_trans_reg <= (~shift_reg[10]) ? 3'd7: (~shift_reg[9]) ? 3'd6: (~shift_reg[8]) ? 3'd5: (~shift_reg[7]) ? 3'd4:(~shift_reg[6]) ? 3'd3: 3'd0;
		end
	end
	
	// Instantiate sample value registers
	reg recov_wr_en;
	reg recovered_signal;
	
	// Recover bit stream, check for signal consistency
	reg CD_signal;
	reg recov_wr_en_override;
	always @(posedge clk_40mhz) begin
		recovered_signal <= cnsy_one;
		recov_wr_en <= (cnsy_one | cnsy_zero) & check_cnsy & recov_wr_en_override;
		CD_signal <= (~(cnsy_one | cnsy_zero)) & check_cnsy;
	end
	
	// Demultiplex recovered bit stream into 10 bit words for 8b/10b Decoder
	wire demux_reset, demux_nd;
	reg manual_demux_reset;
	assign demux_reset = reset | manual_demux_reset;
	wire [9:0] demux_dout;
	assign demux_out = demux_dout;
	PHY_Demux PHY_DEMUX_1(
		.clk_40mhz(clk_40mhz),
		.demux_reset(demux_reset),
		.demux_din(recovered_signal),
		.demux_wr_en(recov_wr_en),
		.demux_dout(demux_dout),
		.demux_nd(demux_nd)
		);
	
	// Count runs of ones
	reg [2:0] runs_of_ones;
	wire ro_reset;
	reg manual_ro_reset;
	always @(posedge clk_40mhz) begin
		if (ro_reset)
			runs_of_ones <= 3'd0;
		else if (~RX_sampled_ready)
			runs_of_ones <= (~(&shift_reg[7:0])) ? 3'd0: (runs_of_ones == 7) ? 3'd7: (runs_of_ones + 3'd1);
	end
	
	// Assign runs of ones reset
	assign ro_reset = reset | manual_ro_reset;
	
	// Count runs of zeros
	reg [2:0] runs_of_zeros;
	wire rz_reset;
	reg manual_rz_reset;
	always @(posedge clk_40mhz) begin
		if (rz_reset)
			runs_of_zeros <= 3'd0;
		else if (~RX_sampled_ready)
			runs_of_zeros <= (|shift_reg[7:0]) ? 3'd0: (runs_of_zeros == 7) ? 3'd7: (runs_of_zeros + 3'd1);
	end
	
	// Assign runs of ones reset
	assign rz_reset = reset | manual_rz_reset;
	
	///////////////////////////////////////////////////////////////////////////////
	// I/O BUFFERS & ENC/DEC
	///////////////////////////////////////////////////////////////////////////////	
	
	// Instantiate asymmetric aspect ratio output FIFO
	wire out_rst;
	wire out_wr_en;
	wire out_almost_empty;
	wire out_rd_en;
	PHY_OUT_FIFO PHY_OUT_FIFO_1(
		.clk(clk_40mhz),
		.rst(out_rst),
		.din(decoder_dout),
		.wr_en(out_wr_en),
		.dout(D_RX),
		.rd_en(out_rd_en),
		.almost_empty(out_almost_empty)
		);
	
	// Assign output FIFO inputs
	reg out_rst_reg;
	reg out_rd_en_reg;
	assign out_rst = out_rst_reg;
	assign out_rd_en = out_rd_en_reg;
	
	// Instantiate FWFT input FIFO
	wire in_rd_en;
	wire in_rst;
	wire [9:0] in_dout;
	wire in_empty;
	PHY_IN_FIFO PHY_IN_FIFO_1(
		.clk(clk_40mhz),
		.rst(in_rst),
		.din(encoder_dout),
		.dout(in_dout),
		.rd_en(in_rd_en),
		.wr_en(encoder_nd),
		.empty(in_empty)
		);
	
	// Assign input FIFO inputs
	reg in_rd_en_reg;
	reg in_rst_reg;
	assign in_rd_en = in_rd_en_reg;
	assign in_rst = reset | in_rst_reg;
	
	// Instantiate secondary input FIFO for comparision
	wire [9:0] comp_dout;
	wire comp_overflow, comp_empty;
	PHY_small_FIFO PHY_SMALL_FIFO_1(
		.clk_40mhz(clk_40mhz),
		.reset(in_rst),
		.din(in_dout),
		.dout(comp_dout),
		.wr_en(in_rd_en_reg),
		.rd_en(demux_out_ready),
		.overflow_err(comp_overflow),
		.empty(comp_empty)
		);
	
	// Instantiate 8b/10b Decoder I/O registers
	reg demux_out_ready_override;
	reg decoder_init_reg;
	reg out_wr_en_override;
	assign demux_out_ready = demux_nd & demux_out_ready_override;
	assign out_wr_en = (decoder_dout_ready & (~decoder_kout) & out_wr_en_override);
	assign decoder_init = decoder_init_reg;
	
	// Instantiate 8b/10b Encoder I/O registers
	reg encoder_ce_reg;
	reg encoder_force_code_reg;
	reg encoder_kin_reg;
	reg [7:0] encoder_din_reg;
	assign encoder_ce = encoder_ce_reg;
	assign encoder_force_code = encoder_force_code_reg;
	assign encoder_kin = encoder_kin_reg;
	always @(posedge clk_40mhz) encoder_din_reg <= (D_TX_ready) ? D_TX: 8'b00011100;
	assign encoder_din = encoder_din_reg;
	
	///////////////////////////////////////////////////////////////////////////////
	// TX LOGIC
	///////////////////////////////////////////////////////////////////////////////
	
	// Generate 20Mhz clock
	reg clk_20mhz;
	always @(posedge clk_40mhz) clk_20mhz <= (reset) ? 1'b0: ~clk_20mhz;
	
	// Drive TCV TX as needed
	reg [3:0] data_to_send;
	reg [9:0] TX_shift_reg;
	reg TX_started;
	reg TX_drive_low;
	always @(posedge clk_40mhz) begin
		if (reset | in_rst) begin
			TCV_TX_en_reg <= (TX_drive_low) ? 1'b1: 1'b0;
			TCV_TX_reg <= (TX_drive_low) ? 1'b0: 1'b1;
			data_to_send <= 4'd9;
			TX_started <= 1'b0;
			TX_shift_reg <= 10'b0101010101;
		end
		else if (clk_20mhz) begin
			if (~TX_started & ~in_empty) begin
				TCV_TX_en_reg <= 1'b1;
				TX_started <= 1'b1;
				data_to_send <= 4'd9;
				TCV_TX_reg <= 1'b1;
				TX_shift_reg <= 10'b0010101010;
			end
			else if (!data_to_send & in_rd_en_reg & TX_started) begin
				data_to_send <= 4'd9;
				TCV_TX_reg <= in_dout[0];
				TX_shift_reg <= {1'b0, in_dout[9:1]};
			end
			else if (data_to_send && TX_started) begin
				TX_shift_reg <= {1'b0, TX_shift_reg[9:1]};
				data_to_send <= data_to_send - 1;
				TCV_TX_reg <= TX_shift_reg[0];
			end
			else begin
				TCV_TX_en_reg <= 1'b0;
				TCV_TX_reg <= 1'b1;
				data_to_send <= 4'd9;
				TX_started <= 1'b0;
				TX_shift_reg <= 10'b0101010101;
			end
		end
	end
	
	// Set read enable from FWFT input FIFO
	always @(posedge clk_40mhz) begin
		if (reset | in_rst) begin
			in_rd_en_reg <= 1'b0;
		end
		else if (~in_rd_en_reg & (~in_empty) & (data_to_send == 0) & TX_started) begin
			in_rd_en_reg <= 1'b1;
		end
		else begin
			in_rd_en_reg <= 1'b0;
		end
	end
	
	// Compare when needed to detect transmission errors
	reg CD_comp;
	always @(posedge clk_40mhz) begin
		if (reset | in_rst) begin
			CD_comp <= 1'b0;
		end
		else if ((demux_out_ready & (comp_dout != demux_out)) | comp_overflow)  begin
			CD_comp <= 1'b1;
		end
	end
	
	///////////////////////////////////////////////////////////////////////////////
	// STATE MACHINES
	///////////////////////////////////////////////////////////////////////////////
	
	// Instantiate receiver state
	reg [2:0] rcv_state;
	
	// Declare receiver state parameters
	parameter SR_RST_WAIT    = 3'h0;
	parameter SR_IB           = 3'h1;
	parameter SR_RX           = 3'h2;
	parameter SR_RX_1         = 3'h3;
	parameter SR_RX_SUCCESS   = 3'h4;
	parameter SR_RX_DRIVE_LOW = 3'h5;
	parameter SR_RX_FAIL      = 3'h6;
	
	// Instantiate main state
	reg [3:0] state;
	
	// Declare main state parameters
	parameter S_IDLE       = 4'h0;
	parameter S_TX         = 4'h1;
	parameter S_TX_1       = 4'h2;
	parameter S_TX_2       = 4'h3;
	parameter S_TX_FAIL    = 4'h4;
	parameter S_TX_SUCCESS = 4'h5;
	parameter S_RX         = 4'h6;
	parameter S_RX_1       = 4'h7;
	parameter S_WAIT       = 4'h8;
	
	// Manage receiver rcv_state transitions
	reg [5:0] out_byte_cnt;
	reg D_RX_ready_reg_l;
	wire D_RX_ready_reg_fall;
	always @(posedge clk_40mhz) D_RX_ready_reg_l <= (reset) ? 0: D_RX_ready_reg; 
	assign D_RX_ready_reg_fall = ~D_RX_ready_reg & D_RX_ready_reg_l; 
	
	always @(posedge clk_40mhz) begin
		if (reset) begin
			rcv_state <= SR_RST_WAIT;
			manual_demux_reset <= 1'b1;
			recov_wr_en_override <= 1'b0;
			init_trans_detect <= 1'b1;
			decoder_init_reg <= 1'b1;
			demux_out_ready_override <= 1'b0;
			out_rst_reg <= 1'b1;
			out_byte_cnt <= 6'd0;
			TX_drive_low <= 0;
		end
		else begin
			case (rcv_state)
				SR_RST_WAIT:	begin  // wait until sampler is ready
					if (RX_sampled_ready) begin
						rcv_state <= SR_RX_FAIL;
						manual_ro_reset <= 1'b0;
						manual_rz_reset <= 1'b0;
					end
					else begin
						rcv_state <= SR_RST_WAIT;
						manual_ro_reset <= 1'b1;
						manual_rz_reset <= 1'b1;
					end
				end  
				SR_IB: begin  // bus idle, wait for first 1->0 transition
					if (init_trans_detected) begin
						manual_demux_reset <= 1'b0;
						recov_wr_en_override <= 1'b1;
						init_trans_detect <= 1'b0;
						decoder_init_reg <= 1'b0;
						rcv_state <= SR_RX;
					end
				end
				SR_RX: begin  // test if first 10 bits are 10'b1010101010
					if (CD_signal) begin
						rcv_state <= SR_RX_DRIVE_LOW;
					end
					else if (demux_nd) begin  // on first sample
						if (demux_dout == 10'b0101010101) begin
							demux_out_ready_override <= 1'b1;
							out_wr_en_override <= 1'b1;
							out_rst_reg <= 1'b0;
							rcv_state <= SR_RX_1;
							out_byte_cnt <= 6'd0;
						end
						else
							rcv_state <= SR_RX_DRIVE_LOW;
					end
				end
				SR_RX_1: begin   // wait until either end character or decoder/signal error
					if (CD_signal | CD_comp) begin
						rcv_state <= SR_RX_DRIVE_LOW;
						out_wr_en_override <= 1'b0;
						out_rst_reg <= 1'b1;
					end
					else if (decoder_dout_ready) begin
						out_byte_cnt <= (decoder_kout) ? out_byte_cnt: (out_byte_cnt + 1);
						if (CD_decoder) begin
							rcv_state <= SR_RX_DRIVE_LOW;
							out_wr_en_override <= 1'b0;
							out_rst_reg <= 1'b1;
						end
						else if (decoder_kout & (decoder_dout == 8'b00011100)) begin
							rcv_state <= SR_RX_SUCCESS;
							out_wr_en_override <= 1'b0;
						end
					end
				end
				SR_RX_SUCCESS: begin  // go to fail rcv_state when finished, wait until idle bus. Also, manage deadlocks with other FSM.
					if (D_RX_ready_reg_fall | TX_success_reg | (state == S_TX_FAIL) | (state == S_IDLE)) begin
						rcv_state <= SR_RX_FAIL;
						out_byte_cnt <= 6'd0;
						out_rst_reg <= 1'b1;
					end
				end
				SR_RX_DRIVE_LOW: begin // drive the signal low until seven cycles of zeros
					if (runs_of_zeros == 3'd7) begin
						rcv_state <= SR_RX_FAIL;
						TX_drive_low <= 0;
					end
					else begin
						TX_drive_low <= 1;
					end
				end
				SR_RX_FAIL: begin  // wait until seven cycles of ones before declaring link idle
					manual_demux_reset <= 1'b1;
					recov_wr_en_override <= 1'b0;
					init_trans_detect <= 1'b1;
					decoder_init_reg <= 1'b1;
					demux_out_ready_override <= 1'b0;
					out_byte_cnt <= 6'd0;
					rcv_state <= ((runs_of_ones == 3'd7) & ~D_TX_ready) ? SR_IB: SR_RX_FAIL;
				end
			endcase
		end
	end
	
	// Manage main state transitions
	always @(posedge clk_40mhz) begin
		if (reset) begin
			D_RX_ready_reg <= 1'b0;
			TX_success_reg <= 1'b0;
			IB_reg <= 1'b0;
			CD_reg <= 1'b0;
			encoder_ce_reg <= 1'b0;
			encoder_force_code_reg <= 1'b1;
			encoder_kin_reg <= 1'b0;
			in_rst_reg <= 1'b1;
			out_rd_en_reg <= 1'b0;
			state <= S_WAIT;
		end
		else begin
			case (state)
				S_WAIT: begin
					if (rcv_state != SR_RST_WAIT) begin
						state <= S_IDLE;
					end
				end
				S_IDLE: begin
					D_RX_ready_reg <= 1'b0;
					encoder_kin_reg <= 1'b0;
					in_rst_reg <= 1'b1;
					out_rd_en_reg <= 1'b0;
					CD_reg <= 1'b0;
					TX_success_reg <= 1'b0;
					if ((init_trans_detected && (rcv_state == SR_IB)) || (rcv_state == SR_RX)) begin
						state <= S_RX;
						encoder_force_code_reg <= 1'b1;
						encoder_ce_reg <= 1'b0;
						IB_reg <= 1'b0;
					end
					else if (IB_reg & D_TX_ready) begin
						state <= S_TX;
						encoder_force_code_reg <= 1'b0;
						encoder_ce_reg <= 1'b1;
						IB_reg <= 1'b0;
					end
					else begin
						encoder_force_code_reg <= 1'b1;
						encoder_ce_reg <= 1'b0;
						IB_reg <= (rcv_state == SR_IB);
					end
				end
				S_TX: begin  // Take care of last character being special character (to show end)
					in_rst_reg <= 1'b0;
					if (CD_signal | CD_comp | (rcv_state == SR_RX_FAIL) | (rcv_state == SR_RX_DRIVE_LOW)) begin
						state <= S_TX_FAIL;
						in_rst_reg <= 1'b1;
						encoder_force_code_reg <= 1'b1;
						encoder_ce_reg <= 1'b0;
					end
					else if (~D_TX_ready) begin
						encoder_kin_reg <= 1'b1;
						state <= S_TX_1;
					end
				end
				S_TX_1: begin  // Waiting on last special character to be encoded
					encoder_force_code_reg <= 1'b1;
					encoder_ce_reg <= 1'b0;
					if (CD_signal | CD_comp | (rcv_state == SR_RX_FAIL) | (rcv_state == SR_RX_DRIVE_LOW)) begin
						state <= S_TX_FAIL;
						in_rst_reg <= 1'b1;	
					end
					else begin
						state <= S_TX_2;
					end
				end
				S_TX_2: begin  // Waiting on input FIFOs to become empty
					if (CD_signal | CD_comp| (rcv_state == SR_RX_FAIL) | (rcv_state == SR_RX_DRIVE_LOW)) begin
						state <= S_TX_FAIL;
						in_rst_reg <= 1'b1;
					end
					else if (in_empty & comp_empty) begin
						state <= S_TX_SUCCESS;
						in_rst_reg <= 1'b1;
					end
				end
				S_TX_FAIL: begin
					CD_reg <= 1'b1;
					if (~D_TX_ready & ((rcv_state == SR_IB) | (rcv_state == SR_RX_FAIL))) begin
						state <= S_IDLE;
					end
				end
				S_TX_SUCCESS: begin
					if (rcv_state == SR_RX_SUCCESS) begin
						TX_success_reg <= 1'b1;
						state <= S_IDLE;
					end
				end
				S_RX: begin  // Look at receiver state machine to determine behavior
					if (rcv_state == SR_RX_SUCCESS) begin
						out_rd_en_reg <= 1'b1;
						state <= state + 1;
					end
					else if ((rcv_state == SR_RX_FAIL) | (rcv_state == SR_RX_DRIVE_LOW)) begin
						state <= S_IDLE;
					end
				end
				S_RX_1: begin
					D_RX_ready_reg <= 1'b1;
					if (out_almost_empty) begin
						state <= S_IDLE;
						out_rd_en_reg <= 1'b0;
					end
				end
			endcase
		end
	end
	
	// DEBUG
	assign rcv_state_DEBUG = rcv_state;
	assign state_DEBUG = state;
	assign in_rd_en_DEBUG = in_rd_en;
	assign in_dout_DEBUG = in_dout;
	assign in_rst_DEBUG = in_rst;
	assign in_empty_DEBUG = in_empty;
	assign data_to_send_DEBUG = data_to_send;
	assign TX_shift_reg_DEBUG = TX_shift_reg;
	assign clk_20mhz_DEBUG = clk_20mhz;
	assign TX_started_DEBUG = TX_started;
	assign shift_reg_DEBUG = shift_reg;
	assign RX_sampled_ready_DEBUG = RX_sampled_ready;
	assign cnsy_zero_DEBUG = cnsy_zero;
	assign cnsy_one_DEBUG = cnsy_one;
	assign check_cnsy_DEBUG = check_cnsy;
	assign trans_reg_DEBUG = trans_reg;
	assign init_trans_detected_DEBUG = init_trans_detected;
	assign trans_zero_DEBUG = trans_zero;
	assign trans_late_DEBUG = trans_late;
	assign trans_not_exist_DEBUG = trans_not_exist;
	assign init_trans_detect_DEBUG = init_trans_detect;
	assign demux_nd_DEBUG = demux_nd;
	assign demux_dout_DEBUG = demux_dout;
	assign CD_comp_DEBUG = CD_comp;
	assign CD_signal_DEBUG = CD_signal;
	assign CD_decoder_DEBUG = CD_decoder;
	assign comp_dout_DEBUG = comp_dout;
	// END DEBUG
endmodule

//////////////////////////////////////////////////////////////////////////////////
// DEMUX MODULES
//////////////////////////////////////////////////////////////////////////////////

// General purpose demultiplexer with:
// o 1-bit wide data input
// o write enable
// o synchronous reset
// o new data signal
module PHY_Demux #(
	parameter P_DEMUX_SIZE = 10,    // Size of Demux
	parameter P_LOG_DEMUX_SIZE = 4  // Log Size of Demux
	)(
	input clk_40mhz,
	input demux_reset,                     // Demux Synchronous Reset
	input demux_din,                       // Demux Data Input
	input demux_wr_en,                     // Demux Write Enable
	output [P_DEMUX_SIZE-1:0] demux_dout,  // Demux Data Output
	output demux_nd                        // Demux New Data (at Output)
	);
	
	// Instantiate state vars
	reg [P_LOG_DEMUX_SIZE-1:0] demux_ind_reg;
	reg [P_DEMUX_SIZE-1:0] demux_data_reg;
	reg demux_nd_reg;
	reg demux_start_reg;
	
	// Assign outputs
	assign demux_dout = demux_data_reg;
	assign demux_nd = demux_nd_reg;
	
	// Manage state transitions
	always @(posedge clk_40mhz) begin
		if (demux_reset) begin
			demux_ind_reg <= 0;
			demux_data_reg <= 0;
			demux_nd_reg <= 1'b0;
			demux_start_reg <= 1'b1;
		end
		else begin
			if (demux_wr_en) begin
				demux_ind_reg <= (demux_ind_reg == (P_DEMUX_SIZE-1)) ? 0: (demux_ind_reg + 1);
				demux_data_reg[demux_ind_reg] <= demux_din;
			end
			if (demux_ind_reg == 1) demux_start_reg <= 1'b0;
			demux_nd_reg <= (demux_start_reg) ? 1'b0: (demux_wr_en & (demux_ind_reg == (P_DEMUX_SIZE-1)));
		end
	end
endmodule

// FWFT FIFO with depth 3, variable width
module PHY_small_FIFO #(
	parameter P_FIFO_WIDTH = 10,
	parameter P_LOG_FIFO_DEPTH = 1
	)(
	input clk_40mhz,
	input reset,
	input [(P_FIFO_WIDTH - 1):0] din,
	output [(P_FIFO_WIDTH - 1):0] dout,
	input wr_en,
	input rd_en,
	output overflow_err,
	output empty
	);
	
	// Instantiate state vars
	reg [1:0] data_cnt;
	reg [(P_FIFO_WIDTH-1): 0] mem [0:2];
	
	// Assign output
	assign dout = mem[0];
	assign empty = (data_cnt == 2'd0);
	assign overflow_err = (wr_en & (~rd_en) & (data_cnt == 2'd3));
	
	// Manage memory changes
	always @(posedge clk_40mhz) begin
		if (reset) begin
			data_cnt <= 2'd0;
			mem[0] <= 0;
			mem[1] <= 0;
			mem[2] <= 0;
		end
		else begin
			case ({wr_en, rd_en})
				2'b10: begin
					if (data_cnt != 2'd3) begin
						mem[data_cnt] <= din;
						data_cnt <= data_cnt + 1;
					end
				end
				2'b01: begin
					mem[0] <= mem[1];
					mem[1] <= mem[2];
					data_cnt <= (!data_cnt) ? 2'd0: (data_cnt - 1);
				end
				2'b11: begin
					if (data_cnt == 2'd1) begin
						mem[0] <= din;
					end
					else if (data_cnt == 2'd2) begin
						mem[0] <= mem[1];
						mem[1] <= din;
					end
					else if (data_cnt == 2'd3) begin
						mem[0] <= mem[1];
						mem[1] <= mem[2];
						mem[2] <= din;
					end
				end
				default:;  // Do nothing otherwise
			endcase
		end
	end
endmodule
