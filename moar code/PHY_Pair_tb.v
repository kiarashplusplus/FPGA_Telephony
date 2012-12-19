`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Sachin Shinde
//
// Create Date:   13:33:30 12/06/2012
// Design Name:   PHY_Pair
// Module Name:   C:/Users/Sachin Shinde/Desktop/6.111/Final Project/Verilog/Final_Project/PHY_Pair_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PHY_Pair
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module PHY_Pair_tb;

	// Inputs
	reg clk_40mhz;
	reg clk_160mhz;
	reg reset;
	wire TCV_RX_1;
	reg [7:0] D_TX_1;
	reg D_TX_ready_1;
	wire TCV_RX_2;
	reg [7:0] D_TX_2;
	reg D_TX_ready_2;

	// Outputs
	wire TCV_TX_1;
	wire TCV_TX_en_1;
	wire [7:0] D_RX_1;
	wire D_RX_ready_1;
	wire CD_1;
	wire TX_success_1;
	wire IB_1;
	wire TCV_TX_2;
	wire TCV_TX_en_2;
	wire [7:0] D_RX_2;
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
	wire encoder_ce_1_DEBUG;

	// Instantiate line
	wire line;
	
	// Instantiate the Unit Under Test (UUT)
	PHY_Pair uut ( 
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
		.comp_dout_DEBUG(comp_dout_DEBUG),
		.encoder_ce_1_DEBUG(encoder_ce_1_DEBUG)
		);

	// Set clocks
	always #12.5 clk_40mhz = ~clk_40mhz;
	always #3.125 clk_160mhz = ~clk_160mhz;
	// Set line	
	wire [1:0] TCV_en;
	assign TCV_en = {TCV_TX_en_1,TCV_TX_en_2};
	assign line = (TCV_en == 2'b10) ? TCV_TX_1:((TCV_en == 2'b01) ? TCV_TX_2: 1'b1);
	assign TCV_RX_1 = line;
	assign TCV_RX_2 = line;
	
	// Counter
	reg start;
	reg [7:0]count;
	always @(posedge clk_40mhz) begin
		if (start)
			D_TX_1 <= D_TX_1 + 1;
		else
			D_TX_1 <= 0;
	end
	
	
	initial begin
		// Initialize Inputs
		clk_40mhz = 0;
		clk_160mhz = 0;
		reset = 1;
		D_TX_ready_1 = 0;
		D_TX_2 = 0;
		D_TX_ready_2 = 0;
		start = 0;
		count = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(negedge clk_40mhz)
			reset = 0;
		@(posedge IB_1)
		@(negedge clk_40mhz)
			D_TX_ready_1 = 1;
			start = 1;
		@(D_TX_1 == 8'h3F)
			D_TX_ready_1 = 0;
//			D_TX_1 = count;
//		@(negedge clk_40mhz)
//			D_TX_1 = D_TX_1+1;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'h02;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hEF;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hBE;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hAD;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hDE;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hBE;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hBA;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hFE;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hCA;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hED;
//		@(negedge clk_40mhz)
//			D_TX_1 = 8'hAC;
//		@(negedge clk_40mhz)
//			D_TX_ready_1 = 0;
	end
      
endmodule

