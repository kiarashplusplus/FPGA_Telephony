`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Sachin Shinde
// 
// Create Date:    12:07:55 12/07/2012 
// Design Name: 
// Module Name:    DLC 
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
module DLC #(
	parameter P_INIT_SEND_MAX = 15,
	parameter P_INIT_NO_ACK_TIMEOUT = 100000,
	parameter P_INIT_TIMEOUT = 1000000,
	parameter P_ACK_TIMEOUT = 100000
	)(
	input clk_40mhz,             // 40MHz Clock
	input reset,                 // Active-High Reset
	// PHY I/O
   output [7:0] PHY_TX,          // PHY Data TX
	output PHY_TX_ready,            // PHY Data TX Ready
	input [7:0] PHY_RX,           // PHY Data RX
   input PHY_RX_ready,             // PHY Data RX Ready
   input PHY_CD,                   // Collision Detect (while Sending)
	input PHY_TX_success,           // Successful transmission
   input PHY_IB,                   // Idle Bus
	// Network I/O
	input [1:0] cmd,              // DLC command from status
	output link_sts,                // Active High for Up
	output [1:0] sts,              // DLC status
	input [7:0] self_phn_num,      // Self Phone Number
	input [7:0] D_TX,              // outgoing data port
	input D_TX_ready,                // outgoing ready
	input [7:0] D_TX_addr,       // phone number for transmission
	output [7:0] D_RX,             // incoming data port
	output D_RX_ready,               // incoming ready
	output [7:0] D_RX_addr,         // phone number for reception
	// PRNG I/O
	input [63:0] rand_num           // 64-bit random number
	,// DEBUG
	output [5:0] init_state_DEBUG,
	output [5:0] pckt_size_DEBUG,
	output CRC_E_we_DEBUG,
	output [10:0] CRC_E_addr_DEBUG,
	output [7:0] CRC_E_data_DEBUG,
	output [7:0] MAC_data_DEBUG,
	output [10:0] MAC_addr_DEBUG,
	output [2:0] MAC_state_DEBUG,
	output [4:0] b_state_DEBUG,
	output [4:0] f_state_DEBUG,
	output [2:0] s_state_DEBUG,
	output [3:0] c_state_DEBUG,
	output b_f_lock_DEBUG,
	output b_b_lock_DEBUG,
	output b_c_lock_DEBUG,
	output f1w_s_lock_DEBUG,
	output f1w_b_lock_DEBUG,
	output f1w_c_lock_DEBUG,
	output f1r_f_lock_DEBUG,
	output f1r_b_lock_DEBUG,
	output f2w_f_lock_DEBUG,
	output f2w_b_lock_DEBUG,
	output f2w_c_lock_DEBUG	,
	output [4:0] MAC_pckt_num_DEBUG,
	output MAC_sts_DEBUG,
	output MAC_cmd_DEBUG,
	output CRC_sts_DEBUG,
	output [7:0] CRC_D_TX_DEBUG,
	output CRC_D_TX_ready_DEBUG,
	output [4:0] CRC_pckt_num_DEBUG,
	output CRC_D_RX_ready_DEBUG,
	output [7:0] CRC_D_RX_DEBUG,
	output p_DEBUG,
	output [15:0] dina_DEBUG, 
	output wea_DEBUG,
	output [7:0] addra_DEBUG,
	output [15:0] douta_DEBUG,
	output [4:0] rd_pointer_DEBUG,
	output [4:0] wr_pointer_DEBUG,
	output [2:0] CRC_state_DEBUG
	); 
	
	
	// Define link status
	reg link_up;
	assign link_sts = link_up;
	
	// Generate serial random number signal
	wire rand_num_serial;
	assign rand_num_serial = rand_num[0];
	
	// Instantiate Media Access Controller Module
	wire MAC_sts;
	wire MAC_cmd, MAC_cmd_ARQ;
	reg MAC_cmd_INIT_reg;
	assign MAC_cmd = (link_up) ? MAC_cmd_ARQ: MAC_cmd_INIT_reg;
	wire [4:0] MAC_pckt_num, MAC_pckt_num_ARQ;
	reg [4:0] MAC_pckt_num_INIT_reg;
	assign MAC_pckt_num = (link_up) ? MAC_pckt_num_ARQ: MAC_pckt_num_INIT_reg;
	wire [7:0] MAC_data;
	wire [10:0] MAC_addr;
	MAC MAC_1(
		.clk_40mhz(clk_40mhz),
		.reset(reset),
		// Main I/O
		.cmd(MAC_cmd),
		.sts(MAC_sts),
		.pckt_num(MAC_pckt_num),
		// PHY I/O
		.PHY_TX(PHY_TX),
		.PHY_TX_ready(PHY_TX_ready),
		.PHY_CD(PHY_CD),
		.PHY_TX_success(PHY_TX_success),
		.PHY_IB(PHY_IB),
		// Packet Storage I/O
		.data(MAC_data),
		.addr(MAC_addr),
		// PRNG I/O
		.rand_num_serial(rand_num_serial)
		,// DEBUG
		.pckt_size_DEBUG(pckt_size_DEBUG),
		.MAC_state_DEBUG(MAC_state_DEBUG)
		);
	
	// Instantiate Block RAM for outgoing packets
	wire CRC_E_we;
	wire [10:0] CRC_E_addr;
	wire [7:0] CRC_E_data;
	DLC_BRAM_TX DLC_BRAM_TX_1(
		.clka(clk_40mhz),
		.clkb(clk_40mhz),
		.addra(CRC_E_addr),
		.dina(CRC_E_data),
		.wea(CRC_E_we),
		.addrb(MAC_addr),
		.doutb(MAC_data)
		);
		
	// Instantiate CRC16-ANSI to write to Outgoing BRAM
	wire CRC_sts;
	wire [7:0] CRC_D_TX, CRC_D_TX_ARQ;
	wire CRC_D_TX_ready, CRC_D_TX_ready_ARQ;
	wire [4:0] CRC_pckt_num, CRC_pckt_num_ARQ;
	CRC_Enc CRC_ENC_1(
		.clk_40mhz(clk_40mhz),
		.reset(reset),
		// Data I/O
		.sts(CRC_sts),
		.D_TX(CRC_D_TX),
		.D_TX_ready(CRC_D_TX_ready),
		.pckt_num(CRC_pckt_num),
		// BRAM I/O
		.we(CRC_E_we),
		.addr(CRC_E_addr),
		.data(CRC_E_data)
		);
		
	reg [7:0] CRC_D_TX_INIT_reg;
	reg CRC_D_TX_ready_INIT_reg;
	reg [4:0] CRC_pckt_num_INIT_reg;
	assign CRC_D_TX = (link_up) ? CRC_D_TX_ARQ: CRC_D_TX_INIT_reg;
	assign CRC_D_TX_ready = (link_up) ? CRC_D_TX_ready_ARQ: CRC_D_TX_ready_INIT_reg;
	assign CRC_pckt_num = (link_up) ? CRC_pckt_num_ARQ: CRC_pckt_num_INIT_reg;
	
	// Instantiate CRC16-ANSI for incoming packets
	wire [7:0] CRC_D_RX;
	wire CRC_D_RX_ready;
	CRC_Dec CRC_DEC_1(	
		.clk_40mhz(clk_40mhz),
		.reset(reset),
		// PHY I/O
		.PHY_RX(PHY_RX),
		.PHY_RX_ready(PHY_RX_ready),
		// Data I/O
		.D_RX(CRC_D_RX),
		.D_RX_ready(CRC_D_RX_ready)
		,// DEBUG
		.rd_pointer_DEBUG(rd_pointer_DEBUG),
		.wr_pointer_DEBUG(wr_pointer_DEBUG),
		.CRC_state_DEBUG(CRC_state_DEBUG)
		);
		
	// Instantiate request buffer
	wire [7:0] req;
	wire [7:0] req_param;
	reg req_rd;
	wire [3:0] ignore;
	reg [3:0] ignore_reg;
	assign ignore = ignore_reg;
	Request_Buffer REQUEST_BUFFER_1(
	.clk_40mhz(clk_40mhz),
	.reset(reset),
	// DLC Control I/O
	.req(req),                    // request type
	.req_param(req_param),        // request paramter
	.req_rd(req_rd),              // clear current request, load next
	.self_phn_num(self_phn_num),
	.ignore(ignore),
	// CRC Checker I/O
	.D_RX(CRC_D_RX),                 // incoming data port
	.D_RX_ready(CRC_D_RX_ready)      // incoming ready
	);	
	
	// Instantiate init state
	reg [5:0] init_state;
	
	// Declare init state parameters
	parameter SI_WAIT_PHN_NUM         = 6'h00;
	parameter SI_WAIT_INIT            = 6'h01;
	parameter SI_MASTER_INIT          = 6'h02;
	parameter SI_MASTER_INIT_1        = 6'h03;
	parameter SI_MASTER_INIT_2        = 6'h04;
	parameter SI_MASTER_INIT_3        = 6'h05;
	parameter SI_MASTER_INIT_4        = 6'h06;
	parameter SI_MASTER_INIT_5        = 6'h07;
	parameter SI_MASTER_INIT_6        = 6'h08;
	parameter SI_MASTER_INIT_7        = 6'h09;
	parameter SI_MASTER_INIT_8        = 6'h0A;
	parameter SI_MASTER_INIT_9        = 6'h0B;
	parameter SI_MASTER_INIT_10       = 6'h0C;
	parameter SI_MASTER_INIT_11       = 6'h0D;
	parameter SI_MASTER_INIT_12       = 6'h0E;
	parameter SI_MASTER_FINISH_INIT	 = 6'h0F;	
	parameter SI_MASTER_FINISH_INIT_1 = 6'h10;
	parameter SI_MASTER_FINISH_INIT_2 = 6'h11;
	parameter SI_MASTER_FINISH_INIT_3 = 6'h12;
	parameter SI_MASTER_FINISH_INIT_4 = 6'h13;
	parameter SI_MASTER_FINISH_INIT_5 = 6'h14;
	parameter SI_MASTER_FINISH_INIT_6 = 6'h15;
	parameter SI_SLAVE_INIT           = 6'h16;
	parameter SI_SLAVE_INIT_1         = 6'h17;
	parameter SI_SLAVE_INIT_2         = 6'h18;
	parameter SI_SLAVE_INIT_3         = 6'h19;
	parameter SI_SLAVE_INIT_4         = 6'h1A;
	parameter SI_SLAVE_INIT_5         = 6'h1B;
	parameter SI_SLAVE_FINISH_INIT    = 6'h1C;
	parameter SI_SLAVE_FINISH_INIT_1  = 6'h1D;
	parameter SI_SLAVE_FINISH_INIT_2  = 6'h1E;	
	parameter SI_SLAVE_FINISH_INIT_3  = 6'h1F;
	parameter SI_SLAVE_FINISH_INIT_4  = 6'h20;
	parameter SI_SLAVE_FINISH_INIT_5  = 6'h21;
	parameter SI_SLAVE_FINISH_INIT_6  = 6'h22;
	parameter SI_INIT_SUCCESS         = 6'h23;
	parameter SI_INIT_FAIL            = 6'h24;
	
	// Define command parameters
	parameter CMD_IDLE        = 2'd0;
	parameter CMD_SET_PHN_NUM = 2'd1;
	parameter CMD_INIT        = 2'd2;
	parameter CMD_TX          = 2'd3;
	
	// Define request parameters
	parameter REQ_NONE            = 8'h00;
	parameter REQ_INIT            = 8'h01;
	parameter REQ_INIT_ACK        = 8'h02;
	parameter REQ_INIT_ACK_ACK    = 8'h03;
	parameter REQ_INIT_FINISH     = 8'h04;
	parameter REQ_INIT_FINISH_ACK = 8'h05;
	parameter REQ_DATA            = 8'h06;
	parameter REQ_DATA_ACK        = 8'h07;
	
	// Define status parameters
	parameter STS_IDLE      = 2'd0;
	parameter STS_BUSY      = 2'd1;
	parameter STS_TX_ACCEPT = 2'd2;
	parameter STS_TX_REJECT = 2'd3;
	
	// Manage initialization state transitions
	reg [19:0] cntr;
	reg [3:0] init_cnt;
	reg ACK_received;
	reg [7:0] temp_phn_num;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			init_state <= SI_WAIT_PHN_NUM;
			ignore_reg <= 5'b00000;
			link_up <= 0;
			cntr <= 0;
			init_cnt <= 0;
			ACK_received <= 0;
		end
		else begin
			case (init_state)
				SI_WAIT_PHN_NUM: begin
					if (cmd == CMD_SET_PHN_NUM) begin
						init_state <= init_state + 1;
					end
				end
				SI_WAIT_INIT: begin
					if (req != REQ_NONE) begin // if remote init started
						req_rd <= 1;
						init_state <= SI_SLAVE_INIT;
						ignore_reg <= 5'b11010;  // Ignore ACK requests
					end
					else if (cmd == CMD_INIT) begin
						init_state <= SI_MASTER_INIT;
						init_cnt <= P_INIT_SEND_MAX;
					end
				end
				
				////////////////////////////////////////////////////////////////////////////
				// MASTER INITIALIZATION PROTOCOL
				////////////////////////////////////////////////////////////////////////////
				
				SI_MASTER_INIT: begin
					if ((req == REQ_INIT) && (req_param[7:0] < self_phn_num)) begin
						req_rd <= 1;
						init_state <= SI_SLAVE_INIT;
						ignore_reg <= 5'b11010;  // Ignore ACK requests
						cntr <= 0;
					end
					else begin
						req_rd <= 0;
						if (init_cnt) begin
							if (CRC_sts == 0) begin  // If encoder idle, write to buffer
								CRC_D_TX_ready_INIT_reg <= 1'b1;
								CRC_D_TX_INIT_reg <= REQ_INIT;
								CRC_pckt_num_INIT_reg <= 5'd0;
								init_state <= init_state + 1;
							end
						end
						else begin
							init_state <= SI_INIT_FAIL;
						end
					end
				end
				SI_MASTER_INIT_1: begin
					CRC_D_TX_INIT_reg <= self_phn_num;
					init_state <= init_state + 1;
				end
				SI_MASTER_INIT_2: begin
					CRC_D_TX_ready_INIT_reg <= 1'b0;
					if (CRC_sts == 0) init_state <= init_state + 1;
				end
				SI_MASTER_INIT_3: begin
					if (MAC_sts == 0) begin  // If MAC idle, send packet to it
						MAC_cmd_INIT_reg <= 1'b1;
						MAC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end
				end
				SI_MASTER_INIT_4: begin
					MAC_cmd_INIT_reg <= 1'b0;
					init_state <= init_state + 1;
				end
				SI_MASTER_INIT_5: begin
					if (MAC_sts == 0) begin // If MAC done sending
						init_state <= init_state + 1;
						cntr <= P_INIT_NO_ACK_TIMEOUT;
						ACK_received <= 1'b0;
					end
				end
				SI_MASTER_INIT_6: begin
					if ((req == REQ_INIT) && (req_param[7:0] < self_phn_num)) begin
						req_rd <= 1;
						init_state <= SI_SLAVE_INIT;
						ignore_reg <= 5'b11010;  // Ignore ACK requests
						cntr <= 0;
					end
					else if (req == REQ_INIT_ACK) begin // If INIT_ACK comes, send back INIT_ACK_ACK 
						req_rd <= 1;
						temp_phn_num <= req_param[7:0];
						ACK_received <= 1'b1;
						init_state <= init_state + 1;
					end
					else if (req != REQ_NONE) begin
						req_rd <= 1;
					end
					else if (cntr) begin
						req_rd <= 0;
						cntr <= cntr - 1;
					end
					else begin // (!cntr)
						req_rd <= 0;
						if (ACK_received) begin // assume all FPGAs have ACKed, complete init
							init_state <= SI_MASTER_FINISH_INIT;
							ignore_reg <= 5'b01111;
							cntr <= 0;
						end
						else begin  // no FPGAs have ACKed, try sending INIT again until init count exhausted
							init_state <= SI_MASTER_INIT;
							init_cnt <= init_cnt - 1;
						end
					end
				end
				SI_MASTER_INIT_7: begin
					req_rd <= 0;
					if (CRC_sts == 0) begin // If CRC idle, send packet
						CRC_D_TX_ready_INIT_reg <= 1'b1;
						CRC_D_TX_INIT_reg <= REQ_INIT_ACK_ACK;
						CRC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end
				end
				SI_MASTER_INIT_8: begin
					CRC_D_TX_INIT_reg <= temp_phn_num;
					init_state <= init_state + 1;
				end
				SI_MASTER_INIT_9: begin
					CRC_D_TX_ready_INIT_reg <= 0;
					if (CRC_sts == 0) init_state <= init_state + 1;
				end
				SI_MASTER_INIT_10: begin
					if (MAC_sts == 0) begin  // If MAC idle, send packet to it
						MAC_cmd_INIT_reg <= 1'b1;
						MAC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end
				end
				SI_MASTER_INIT_11: begin
					MAC_cmd_INIT_reg <= 1'b0;
					init_state <= init_state + 1;
				end
				SI_MASTER_INIT_12: begin
					if (MAC_sts == 0) begin // If MAC done sending
						init_state <= SI_MASTER_INIT_6;
						cntr <= P_INIT_TIMEOUT;
					end
				end
				
				////////////////////////////////////////////////////////////////////////////
				// MASTER INITIALIZATION FINISH PROTOCOL
				////////////////////////////////////////////////////////////////////////////
				
				SI_MASTER_FINISH_INIT: begin
					if (req == REQ_INIT_FINISH_ACK) begin  // Received Finish ACK, success
						req_rd <= 1;
						init_state <= SI_INIT_SUCCESS;
						ignore_reg <= 5'b10111;
					end
					else if (req != REQ_NONE) begin
						req_rd <= 1;
					end
					else if (cntr) begin
						req_rd <= 0;
						cntr <= cntr - 1;
					end
					else begin  // Send init finish ACK
						req_rd <= 0;
						init_state <= init_state + 1;
					end
				end
				SI_MASTER_FINISH_INIT_1: begin
					req_rd <= 0;
					if (CRC_sts == 0) begin
						CRC_D_TX_ready_INIT_reg <= 1'b1;
						CRC_D_TX_INIT_reg <= REQ_INIT_FINISH;
						CRC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end
				end
				SI_MASTER_FINISH_INIT_2: begin
					CRC_D_TX_ready_INIT_reg <= 0;
					init_state <= init_state + 1;					
				end
				SI_MASTER_FINISH_INIT_3: begin
					if (CRC_sts == 0) init_state <= init_state + 1;				
				end
				SI_MASTER_FINISH_INIT_4: begin
					if (MAC_sts == 0) begin  // If MAC idle, send packet to it
						MAC_cmd_INIT_reg <= 1'b1;
						MAC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end					
				end
				SI_MASTER_FINISH_INIT_5: begin
					MAC_cmd_INIT_reg <= 1'b0;
					init_state <= init_state + 1;
				end
				SI_MASTER_FINISH_INIT_6: begin
					if (MAC_sts == 0) begin // If MAC done sending
						init_state <= SI_MASTER_FINISH_INIT;
						cntr <= P_ACK_TIMEOUT;
					end
				end
				
				////////////////////////////////////////////////////////////////////////////
				// SLAVE INITIALIZATION PROTOCOL
				////////////////////////////////////////////////////////////////////////////
				
				SI_SLAVE_INIT: begin
					if (req == REQ_INIT_ACK_ACK) begin
						req_rd <= 1;
						init_state <= SI_SLAVE_FINISH_INIT;
						ignore_reg <= 5'b10110;
					end
					else if (req != REQ_NONE) begin  // ignore other request types
						req_rd <= 1;
					end
					else if (cntr) begin
						req_rd <= 0;
						cntr <= cntr - 1;
					end
					else begin // (!cntr), start sending INIT_ACK
						req_rd <= 0;
						if (CRC_sts == 0) begin
							CRC_D_TX_ready_INIT_reg <= 1'b1;
							CRC_D_TX_INIT_reg <= REQ_INIT_ACK;
							CRC_pckt_num_INIT_reg <= 5'd0;
							init_state <= init_state + 1;
						end
					end
				end
				SI_SLAVE_INIT_1: begin
					CRC_D_TX_INIT_reg <= self_phn_num;
					init_state <= init_state + 1;
				end
				SI_SLAVE_INIT_2: begin
					CRC_D_TX_ready_INIT_reg <= 0;
					if (CRC_sts == 0) init_state <= init_state + 1;
				end
				SI_SLAVE_INIT_3: begin
					if (MAC_sts == 0) begin  // If MAC idle, send packet to it
						MAC_cmd_INIT_reg <= 1'b1;
						MAC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end
				end
				SI_SLAVE_INIT_4: begin
					MAC_cmd_INIT_reg <= 1'b0;
					init_state <= init_state + 1;
				end
				SI_SLAVE_INIT_5: begin
					if (MAC_sts == 0) begin // If MAC done sending
						init_state <= SI_SLAVE_INIT;
						cntr <= P_ACK_TIMEOUT;
					end
				end
				
				////////////////////////////////////////////////////////////////////////////
				// SLAVE INITIALIZATION FINISH PROTOCOL
				////////////////////////////////////////////////////////////////////////////
				
				SI_SLAVE_FINISH_INIT: begin
					if (req == REQ_INIT) begin
						req_rd <= 1;
						init_state <= SI_SLAVE_INIT;
						ignore_reg <= 5'b11010;  // Ignore ACK requests
						cntr <= 0;
					end
					else if (req == REQ_INIT_FINISH) begin // Send FINISH_ACK
						req_rd <= 1;
						init_state <= init_state + 1;
					end
					else if (req != REQ_NONE) begin
						req_rd <= 1;
					end
					else begin
						req_rd <= 0;
					end
				end
				SI_SLAVE_FINISH_INIT_1: begin
					req_rd <= 0;
					if (CRC_sts == 0) begin
						CRC_D_TX_ready_INIT_reg <= 1'b1;
						CRC_D_TX_INIT_reg <= REQ_INIT_FINISH_ACK;
						CRC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end					
				end
				SI_SLAVE_FINISH_INIT_2: begin
					CRC_D_TX_ready_INIT_reg <= 1'b0;
					init_state <= init_state + 1;
				end
				SI_SLAVE_FINISH_INIT_3: begin
					if (CRC_sts == 0) init_state <= init_state + 1;
				end
				SI_SLAVE_FINISH_INIT_4: begin
					if (MAC_sts == 0) begin  // If MAC idle, send packet to it
						MAC_cmd_INIT_reg <= 1'b1;
						MAC_pckt_num_INIT_reg <= 5'd0;
						init_state <= init_state + 1;
					end
				end
				SI_SLAVE_FINISH_INIT_5: begin
					MAC_cmd_INIT_reg <= 1'b0;
					init_state <= init_state + 1;
				end
				SI_SLAVE_FINISH_INIT_6: begin
					if (MAC_sts == 0) begin // If MAC done sending
						init_state <= SI_INIT_SUCCESS;
						ignore_reg <= 5'b10111;
					end
				end
				
				////////////////////////////////////////////////////////////////////////////
				// INITIALIZATION END STATES
				////////////////////////////////////////////////////////////////////////////				
				
				SI_INIT_SUCCESS: begin
					if (req == REQ_INIT_FINISH) begin  // resend INIT_FINISH_ACK
						req_rd <= 1;
						init_state <= SI_SLAVE_FINISH_INIT_1;
					end
					else if (req != REQ_NONE) begin
						req_rd <= 1;
					end
					else begin
						req_rd <= 0;
					end
					link_up <= 1;
				end
				SI_INIT_FAIL: begin
					link_up <= 0;
				end
			endcase
		end
	end
	
	// Instantiate ARQ manager for post-initialization
	ARQ_Manager ARQ_MANAGER_1(
		.clk_40mhz(clk_40mhz),
		.reset(reset),
		// General signals
		.start(link_up),
		.self_phn_num(self_phn_num),
		// Network I/O
		.NW_cmd(cmd), 
		.NW_sts(sts),
		.NW_D_TX_addr(D_TX_addr),
		.NW_D_TX(D_TX),
		.NW_D_TX_ready(D_TX_ready),
		.NW_D_RX_addr(D_RX_addr),
		.NW_D_RX(D_RX), 
		.NW_D_RX_ready(D_RX_ready),
		// CRC Encoder I/O
		.CRC_sts(CRC_sts),
		.D_TX(CRC_D_TX_ARQ),
		.D_TX_ready(CRC_D_TX_ready_ARQ),
		.pckt_num(CRC_pckt_num_ARQ),
		// MAC I/O
		.MAC_cmd(MAC_cmd_ARQ),
		.MAC_sts(MAC_sts),
		.MAC_pckt_num(MAC_pckt_num_ARQ),
		// CRC Decoder I/O
		.D_RX(CRC_D_RX),
		.D_RX_ready(CRC_D_RX_ready)
		,// DEBUG	
		.b_state_DEBUG(b_state_DEBUG),
		.f_state_DEBUG(f_state_DEBUG),
		.s_state_DEBUG(s_state_DEBUG),
		.c_state_DEBUG(c_state_DEBUG),
		.b_f_lock_DEBUG(b_f_lock_DEBUG),
		.b_b_lock_DEBUG(b_b_lock_DEBUG),
		.b_c_lock_DEBUG(b_c_lock_DEBUG),
		.f1w_s_lock_DEBUG(f1w_s_lock_DEBUG),
		.f1w_b_lock_DEBUG(f1w_b_lock_DEBUG),
		.f1w_c_lock_DEBUG(f1w_c_lock_DEBUG),
		.f1r_f_lock_DEBUG(f1r_f_lock_DEBUG),
		.f1r_b_lock_DEBUG(f1r_b_lock_DEBUG),
		.f2w_f_lock_DEBUG(f2w_f_lock_DEBUG),
		.f2w_b_lock_DEBUG(f2w_b_lock_DEBUG),
		.f2w_c_lock_DEBUG	(f2w_c_lock_DEBUG),
		.p_DEBUG(p_DEBUG),
		.dina_DEBUG(dina_DEBUG), 
		.wea_DEBUG(wea_DEBUG),
		.addra_DEBUG(addra_DEBUG),
		.douta_DEBUG(douta_DEBUG)
		);
	
	// DEBUG
	assign init_state_DEBUG = init_state;
	assign CRC_E_we_DEBUG = CRC_E_we;
	assign CRC_E_addr_DEBUG = CRC_E_addr;
	assign CRC_E_data_DEBUG = CRC_E_data;
	assign MAC_data_DEBUG = MAC_data;
	assign MAC_addr_DEBUG = MAC_addr;
	assign MAC_pckt_num_DEBUG = MAC_pckt_num;
	assign MAC_sts_DEBUG = MAC_sts;
	assign MAC_cmd_DEBUG = MAC_cmd;
	assign CRC_sts_DEBUG = CRC_sts;
	assign CRC_D_TX_DEBUG = CRC_D_TX;
	assign CRC_D_TX_ready_DEBUG = CRC_D_TX_ready;
	assign CRC_pckt_num_DEBUG = CRC_pckt_num;
	assign CRC_D_RX_ready_DEBUG = CRC_D_RX_ready;
	assign CRC_D_RX_DEBUG = CRC_D_RX;
	
endmodule

// Media Access Control
//  o Truncated binary exponential backoff sending
//  o Reads from BRAM using packet number
module MAC #(
	parameter P_CW_MIN = 4,
	parameter P_CW_MAX = 19,
	parameter P_LOG_CW_MAX = 5,
	parameter P_TIMEOUT_PERIOD = 6'd63
	)(
	input clk_40mhz,
	input reset,
	// Main I/O
	input cmd,
	output sts,
	input [4:0] pckt_num,
	// PHY I/O
	output [7:0] PHY_TX,
	output PHY_TX_ready,
	input PHY_CD,
	input PHY_TX_success,
	input PHY_IB,
	// Packet Storage I/O
	input [7:0] data,
	output [10:0] addr,
	// PRNG I/O
	input rand_num_serial
	,// DEBUG
	output [5:0] pckt_size_DEBUG,
	output [2:0] MAC_state_DEBUG
	);

	// Assign TCV TX data
	assign PHY_TX = data;
	
	// Instantiate TCV TX ready signal register
	reg PHY_TX_ready_reg;
	assign PHY_TX_ready = PHY_TX_ready_reg;

	// Instantiate status register
	reg sts_reg;
	assign sts = sts_reg;

	// Declare command parameters
	parameter CMD_IDLE = 0;
	parameter CMD_SEND = 1;
	
	// Declare status parameters
	parameter STS_CMD_RDY = 0;
	parameter STS_BUSY    = 1;
	
	// Instantiate state
	reg [2:0] state;
	
	// Declare state parameters
	parameter S_IDLE      = 3'h0;
	parameter S_TX_WAIT   = 3'h1;
	parameter S_TX_WAIT_1 = 3'h2;
	parameter S_TX_WAIT_2 = 3'h3;
	parameter S_TX        = 3'h4;
	parameter S_TX_1      = 3'h5;
	parameter S_TO        = 3'h6;
	
	// Instantiate counter state
	reg [1:0] cnt_state;
	
	// Declare counter state parameters
	parameter SC_IDLE     = 2'h0;
	parameter SC_INIT_CNT = 2'h1;
	parameter SC_CNT      = 2'h2;
	
	// Set & Run CW Counter as needed
	reg start_cnt;
	reg [(P_LOG_CW_MAX-1):0] CW, CW_l;
	reg [(P_CW_MAX-1):0] cnt;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			cnt <= 0;
			CW_l <= 0;
			cnt_state <= SC_IDLE;
		end
		else begin
			case (cnt_state)
				SC_IDLE: begin
					if (start_cnt) begin
						cnt_state <= cnt_state + 1;
						CW_l <= CW;
						cnt <= 0;
					end
				end
				SC_INIT_CNT: begin
					if (CW_l) begin
						cnt <= {cnt[(P_CW_MAX-2):0], rand_num_serial};
						CW_l <= CW_l - 1;
					end
					else begin
						cnt_state <= cnt_state + 1;
					end
				end
				SC_CNT: begin
					if (cnt) begin
						cnt <= cnt - 1;
					end
					else begin
						cnt_state <= SC_IDLE;
					end
				end
			endcase
		end
	end
	
	// Instantiate packet storage output registers
	reg [10:0] addr_reg;
	assign addr = addr_reg;
	
	// Instantiate next byte wire
	wire [5:0] next_byte;
	assign next_byte = addr_reg[5:0] + 1;
	
	// Manage main state transitions
	reg [5:0] cntr;
	reg [5:0] pckt_size;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			state <= S_IDLE;
			CW <= P_CW_MIN;
			sts_reg <= STS_BUSY;
			addr_reg <= 0;
			PHY_TX_ready_reg <= 1'b0;
		end
		else begin
			case (state)
				S_IDLE: begin
					PHY_TX_ready_reg <= 1'b0;
					if (cmd == CMD_SEND) begin
						sts_reg <= STS_BUSY;
						addr_reg <= {pckt_num, 6'd63};
						state <= S_TX_WAIT;
						start_cnt <= 1'b1;
					end
					else begin
						sts_reg <= STS_CMD_RDY;
					end
				end
				S_TX_WAIT: begin  // Wait two cycles for counter to start
					addr_reg <= {addr_reg[10:6], next_byte};
					start_cnt <= 1'b0;
					state <= state + 1;
				end
				S_TX_WAIT_1: begin // Store packet size
					pckt_size <= data[5:0];
					state <= state + 1;
				end
				S_TX_WAIT_2: begin  // Wait until counter finished to start transmission
					if ((cnt_state == SC_IDLE) && (PHY_IB)) begin
						PHY_TX_ready_reg <= 1'b1;
						addr_reg <= {addr_reg[10:6], next_byte};
						pckt_size <= pckt_size - 1;
						state <= state + 1;
					end
				end
				S_TX: begin
					if (PHY_CD) begin  // if collision detected, go back to wait with higher CW
						PHY_TX_ready_reg <= 0;
						CW <= (CW == P_CW_MAX) ? P_CW_MAX: (CW+1);
						addr_reg <= {addr_reg[10:6], 6'd63};
						state <= S_TX_WAIT;
						start_cnt <= 1'b1;
					end
					else if (pckt_size) begin
						pckt_size <= pckt_size - 1;
						addr_reg <= {addr_reg[10:6], next_byte};
					end
					else begin // if nothing left to transfer
						PHY_TX_ready_reg <= 1'b0;
						state <= state + 1;
					end
				end
				S_TX_1: begin
					if (PHY_CD) begin  // If collision detected, go back to wait with higher CW
						CW <= (CW == P_CW_MAX) ? P_CW_MAX: (CW+1);
						addr_reg <= {addr_reg[10:6], 6'd63};
						state <= S_TX_WAIT;
						start_cnt <= 1'b1;
					end
					else if (PHY_TX_success) begin // If transmission successful, decrease CW
						CW <= (CW == P_CW_MIN) ? P_CW_MIN: (CW-1);
						cntr <= P_TIMEOUT_PERIOD;
						state <= state + 1;
					end
					else if (PHY_IB) begin
						CW <= (CW == P_CW_MAX) ? P_CW_MAX: (CW+1);
						addr_reg <= {addr_reg[10:6], 6'd63};
						state <= S_TX_WAIT;
						start_cnt <= 1'b1;						
					end
				end
				S_TO: begin
					if (cntr) begin
						cntr <= cntr - 1;
					end
					else begin
						state <= S_IDLE;
						sts_reg <= STS_CMD_RDY;
					end
				end
			endcase
		end
	end
	
	// DEBUG
	assign pckt_size_DEBUG = pckt_size;
	assign MAC_state_DEBUG = state;
endmodule

// CRC16-ANSI generator
// o 8-bit data in w/ ready
// o writes payload and packet length to BRAM

module CRC_Enc(
	input clk_40mhz,
	input reset,
	// Data I/O
	output sts,
	input [7:0] D_TX,
	input D_TX_ready,
	input [4:0] pckt_num,
	// BRAM I/O
	output we,
	output [10:0] addr,
	output [7:0] data
	);
	
	// Instantiate status register
	reg sts_reg;
	assign sts = sts_reg;
	
	// Instantiate output registers
	reg we_reg;
	assign we = we_reg;
	reg [7:0] data_reg;
	assign data = data_reg;
	reg [10:0] addr_reg;
	assign addr = addr_reg;
	
	// Declare command parameters
	parameter CMD_IDLE = 0;
	parameter CMD_WRITE = 1;
	
	// Declare status parameters
	parameter STS_CMD_RDY = 0;
	parameter STS_BUSY    = 1;
	
	// Instantiate state
	reg [1:0] state;
	
	// Declare state parameters
	parameter S_IDLE = 2'h0;
	parameter S_WR   = 2'h1;
	parameter S_WR_1 = 2'h2;
	parameter S_WR_2 = 2'h3;
	
	// Instantiate CRC register
	reg [15:0] CRC_reg;
	
	// Assign wire for next CRC
	wire [15:0] CRC_new;
	assign CRC_new = {(^data_reg) ^ (^CRC_reg[15:7]),
							CRC_reg[6],
							CRC_reg[5],
							CRC_reg[4],
							CRC_reg[3],
							CRC_reg[2],
							CRC_reg[1] ^ CRC_reg[15] ^ data_reg[7],
							CRC_reg[0] ^ CRC_reg[15] ^ data_reg[7] ^ CRC_reg[14] ^ data_reg[6],
							CRC_reg[14] ^ data_reg[6] ^ CRC_reg[13] ^ data_reg[5],
							CRC_reg[13] ^ data_reg[5] ^ CRC_reg[12] ^ data_reg[4],
							CRC_reg[12] ^ data_reg[4] ^ CRC_reg[11] ^ data_reg[3],
							CRC_reg[11] ^ data_reg[3] ^ CRC_reg[10] ^ data_reg[2],
							CRC_reg[10] ^ data_reg[2] ^ CRC_reg[9] ^ data_reg[1],
							CRC_reg[9] ^ data_reg[1] ^ CRC_reg[8] ^ data_reg[0],
							(^data_reg[7:1]) ^ (^CRC_reg[15:9]),
							(^data_reg) ^ (^CRC_reg[15:8])
							};
	
	// Manage state transitions
	wire [5:0] next_byte;
	assign next_byte = addr_reg[5:0] + 1;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			state <= S_IDLE;
			CRC_reg <= 0;
			we_reg <= 1'b0;
			addr_reg <= 11'd0;
			data_reg <= 8'd0;
			sts_reg <= STS_BUSY;
		end
		else begin
			case (state)
				S_IDLE: begin
					if (D_TX_ready) begin
						state <= state + 1;
						addr_reg <= {pckt_num, 6'd0};
						data_reg <= D_TX;
						we_reg <= 1'b1;
						sts_reg <= STS_BUSY;
					end
					else begin 
						CRC_reg <= 0;
						we_reg <= 0;
						sts_reg <= STS_CMD_RDY;
					end
				end
				S_WR: begin  // write payload
					addr_reg <= {addr_reg[10:6], next_byte};
					if (D_TX_ready) begin
						data_reg <= D_TX;
						CRC_reg <= CRC_new;
					end
					else begin // write MSByte of CRC
						data_reg <= CRC_new[15:8];
						CRC_reg <= CRC_new;
						state <= state + 1;
					end
				end
				S_WR_1: begin // write LSByte of CRC
					addr_reg <= {addr_reg[10:6], next_byte};
					data_reg <= CRC_reg[7:0];
					CRC_reg <= 0;
					state <= state + 1;
				end
				S_WR_2: begin  // write packet count
					addr_reg <= {addr_reg[10:6], 6'd63};
					data_reg <= {2'b00, next_byte};
					state <= S_IDLE;
					sts_reg <= STS_CMD_RDY;
				end
			endcase
		end
	end
endmodule

// CRC16-ANSI checker
// o Interfaces with PHY RCV signals
// Two sets of output ports, one for I/O, one for 
module CRC_Dec(	
	input clk_40mhz,
	input reset,
	// PHY I/O
	input [7:0] PHY_RX,         	// PHY Data RX
   input PHY_RX_ready,           	// PHY Data RX Ready	
	// Data I/O
	output [7:0] D_RX,             // incoming data port
	output D_RX_ready               // incoming ready
	,// DEBUG
	output [4:0] rd_pointer_DEBUG,
	output [4:0] wr_pointer_DEBUG,
	output [2:0] CRC_state_DEBUG
	);
	
	// Instantiate Incoming BRAM pointers
	reg [4:0] rd_pointer, wr_pointer;
	
	// Instantiate Block RAM for incoming packets
	wire [10:0] rd_addr, wr_addr;
	wire [7:0] wr_data, rd_data;
	wire we;
	DLC_BRAM_RX DLC_BRAM_RX_1(
		.clka(clk_40mhz),
		.clkb(clk_40mhz),
		.addra(wr_addr),
		.dina(wr_data),
		.wea(we),
		.addrb(rd_addr),
		.doutb(rd_data)
		);
		
	// Assign data outputs
	reg D_RX_ready_reg;
	assign D_RX_ready = D_RX_ready_reg;
	assign D_RX = rd_data;
	
	///////////////////////////////////////////////////////////////////////////////
	// Incoming BRAM Write Logic
	///////////////////////////////////////////////////////////////////////////////
	
	// Latch RX_ready
	reg PHY_RX_ready_l;
	always @(posedge clk_40mhz) PHY_RX_ready_l <= (reset) ? 1'b0: PHY_RX_ready;	
	
	// Track fall of latched RX_ready
	reg PHY_RX_ready_ll;
	wire PHY_RX_ready_l_fall;
	always @(posedge clk_40mhz) PHY_RX_ready_ll <= (reset) ? 1'b0: PHY_RX_ready_l;
	assign PHY_RX_ready_l_fall = ~PHY_RX_ready_l & PHY_RX_ready_ll;

	// Instantiate Block RAM input registers
	reg we_override;
	reg [5:0] wr_addr_reg;
	wire [5:0] wr_addr_low;
	assign we = (PHY_RX_ready | PHY_RX_ready_l) & we_override;
	assign wr_addr_low = (PHY_RX_ready) ? wr_addr_reg: 6'd63;
	assign wr_addr = {wr_pointer, wr_addr_low};
	assign wr_data = (PHY_RX_ready) ? PHY_RX: {2'b00, wr_addr_reg};
	
	// Set addr_reg
	always @(posedge clk_40mhz) begin
		if (reset)
			wr_addr_reg <= 6'd0;
		else if (PHY_RX_ready)
			wr_addr_reg <= wr_addr_reg + 1;
		else
			wr_addr_reg <= 6'd0;
	end	

	// Set we override, write pointer
	always @(posedge clk_40mhz) begin
		if (reset) begin
			we_override <= 1'b0;
			wr_pointer <= 5'd1;
		end
		else if (wr_pointer != rd_pointer) begin
			we_override <= 1'b1;
			if (PHY_RX_ready_l_fall) wr_pointer <= wr_pointer + 1;
		end
		else begin
			we_override <= 1'b0;
		end
	end
	
	///////////////////////////////////////////////////////////////////////////////
	// Incoming BRAM Read Logic
	///////////////////////////////////////////////////////////////////////////////
	
	// Instantiate BRAM input registers
	reg [5:0] rd_addr_reg;
	assign rd_addr = {rd_pointer, rd_addr_reg};
	
	// Instantiate state
	reg [2:0] state;
	
	// Declare state parameters
	parameter S_IDLE          = 3'h0;
	parameter S_RD_BYTE_CNT   = 3'h1;
	parameter S_RD_BYTE_CNT_1 = 3'h2;
	parameter S_CRC           = 3'h3;
	parameter S_CRC_1         = 3'h4;
	parameter S_RD            = 3'h5;
	parameter S_RD_1          = 3'h6;
	
	// Instantiate/Assign CRC regs/wires
	reg [7:0] data_reg;
	reg [15:0] CRC_reg;
	wire [15:0] CRC_new;
	assign CRC_new = {(^data_reg) ^ (^CRC_reg[15:7]),
							CRC_reg[6],
							CRC_reg[5],
							CRC_reg[4],
							CRC_reg[3],
							CRC_reg[2],
							CRC_reg[1] ^ CRC_reg[15] ^ data_reg[7],
							CRC_reg[0] ^ CRC_reg[15] ^ data_reg[7] ^ CRC_reg[14] ^ data_reg[6],
							CRC_reg[14] ^ data_reg[6] ^ CRC_reg[13] ^ data_reg[5],
							CRC_reg[13] ^ data_reg[5] ^ CRC_reg[12] ^ data_reg[4],
							CRC_reg[12] ^ data_reg[4] ^ CRC_reg[11] ^ data_reg[3],
							CRC_reg[11] ^ data_reg[3] ^ CRC_reg[10] ^ data_reg[2],
							CRC_reg[10] ^ data_reg[2] ^ CRC_reg[9] ^ data_reg[1],
							CRC_reg[9] ^ data_reg[1] ^ CRC_reg[8] ^ data_reg[0],
							(^data_reg[7:1]) ^ (^CRC_reg[15:9]),
							(^data_reg) ^ (^CRC_reg[15:8])
							};

	// Manage state transitions
	reg [5:0] byte_cnt, out_byte_cnt;
	wire [4:0] wr_pointer_minus_one;
	assign wr_pointer_minus_one = wr_pointer - 1;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			rd_pointer <= 5'd0;
			rd_addr_reg <= 6'd0;
			state <= S_IDLE;
			CRC_reg <= 0;
			data_reg <= 0;
			state <= S_IDLE;
			D_RX_ready_reg <= 1'b0;
		end
		else begin
			case (state)
				S_IDLE: begin
					D_RX_ready_reg <= 1'b0;
					if (rd_pointer != wr_pointer_minus_one) begin
						rd_pointer <= rd_pointer + 1;
						state <= state + 1;
						rd_addr_reg <= 6'd63;
						state <= state + 1;
					end
				end
				S_RD_BYTE_CNT: begin
					rd_addr_reg <= 6'd0;
					state <= state + 1;
				end
				S_RD_BYTE_CNT_1: begin
					byte_cnt <= rd_data;
					out_byte_cnt <= rd_data - 2;
					rd_addr_reg <= 6'd1;
					state <= state + 1;
				end
				S_CRC: begin
					byte_cnt <= byte_cnt - 1;
					data_reg <= rd_data;
					CRC_reg <= 0;
					rd_addr_reg <= 6'd2;
					state <= state + 1;
				end
				S_CRC_1: begin
					if (byte_cnt) begin
						rd_addr_reg <= rd_addr_reg + 1;
						byte_cnt <= byte_cnt - 1;
						CRC_reg <= CRC_new;
						data_reg <= rd_data;
					end
					else begin
						rd_addr_reg <= 0;
						if (CRC_new) begin // CRC failed
							state <= S_IDLE;
						end
						else begin // CRC success, readout again for sending
							state <= state + 1;
						end
					end
				end
				S_RD: begin
					out_byte_cnt <= out_byte_cnt - 1;
					rd_addr_reg <= 1;
					D_RX_ready_reg <= 1;
					state <= state + 1;
				end
				S_RD_1: begin
					if (out_byte_cnt) begin
						out_byte_cnt <= out_byte_cnt - 1;
						rd_addr_reg <= rd_addr_reg + 1;
					end
					else begin
						D_RX_ready_reg <= 0;
						state <= S_IDLE;
						rd_addr_reg <= 0;
					end
				end
			endcase
		end
	end
	
	assign rd_pointer_DEBUG = rd_pointer;
	assign wr_pointer_DEBUG = wr_pointer;
	assign CRC_state_DEBUG = state;
endmodule

// Module for pushing requests to a queue
module Request_Buffer(
	input clk_40mhz,
	input reset,
	// DLC Control I/O
	output [7:0] req,        // request type
	output [7:0] req_param,  // request paramter
	input req_rd,             // clear current request, load next
	input [7:0] self_phn_num,
	input [4:0] ignore,
	// CRC Decoder I/O
	input [7:0] D_RX,        // incoming data port
	input D_RX_ready           // incoming ready
	);
	
	// Declare request parameters
	// Define request parameters
	parameter REQ_NONE            = 8'h00;
	parameter REQ_INIT            = 8'h01;
	parameter REQ_INIT_ACK        = 8'h02;
	parameter REQ_INIT_ACK_ACK    = 8'h03;
	parameter REQ_INIT_FINISH     = 8'h04;
	parameter REQ_INIT_FINISH_ACK = 8'h05;
	
	// Instantiate FIFO
	wire wr_en, rd_en, empty, full;
	wire [15:0] din, dout;
	DLC_Request_FIFO DLC_REQUEST_FIFO_1(
		.clk(clk_40mhz),
		.rst(reset),
		.din(din),
		.wr_en(wr_en),
		.dout(dout),
		.rd_en(rd_en),
		.empty(empty),
		.full(full)
		);
		
	// Instantiate FIFO inputs
	reg [15:0] din_reg;
	reg wr_en_reg;
	assign din = din_reg;
	assign rd_en = req_rd;
	assign wr_en = wr_en_reg;
	
	// Assign outputs
	assign req = (empty) ? (REQ_NONE): dout[7:0];
	assign req_param = dout[15:8];
	
	// Instantiate state
	reg [2:0] state;
	
	// Define state parameters
	parameter S_IDLE            = 3'h0;
	parameter S_INIT            = 3'h1;
	parameter S_INIT_ACK        = 3'h2;
	parameter S_INIT_ACK_ACK    = 3'h3;
	parameter S_INIT_FINISH     = 3'h4;
	parameter S_INIT_FINISH_ACK = 3'h5;
	
	// Detect ready rise
	reg D_RX_ready_l;
	wire D_RX_ready_rise;
	always @(posedge clk_40mhz) D_RX_ready_l = (reset) ? 1'b0: D_RX_ready;
	assign D_RX_ready_rise = D_RX_ready & ~D_RX_ready_l;
	
	// Manage state transitions
	always @(posedge clk_40mhz) begin
		if (reset) begin
			wr_en_reg <= 0;
			din_reg <= 0;
			state <= S_IDLE;
		end
		else begin
			case (state)
				S_IDLE: begin
					wr_en_reg <= 0;
					din_reg <= {8'h00, D_RX};
					if (D_RX_ready_rise) begin
						case (D_RX)
							REQ_INIT: begin
								if (~ignore[0]) state <= S_INIT;
							end
							REQ_INIT_ACK: begin
								if (~ignore[1]) state <= S_INIT_ACK;
							end
							REQ_INIT_ACK_ACK: begin
								if (~ignore[2]) state <= S_INIT_ACK_ACK;
							end
							REQ_INIT_FINISH: begin
								if (~ignore[3]) state <= S_INIT_FINISH;
							end
							REQ_INIT_FINISH_ACK: begin
								if (~ignore[4]) state <= S_INIT_FINISH_ACK;
							end
						endcase
					end
				end
				S_INIT: begin
					wr_en_reg <= 1;
					din_reg <= {D_RX, din_reg[7:0]};
					state <= S_IDLE;
				end
				S_INIT_ACK: begin
					wr_en_reg <= 1;
					din_reg <= {D_RX, din_reg[7:0]};
					state <= S_IDLE;
				end
				S_INIT_ACK_ACK: begin
					if (D_RX == self_phn_num) begin
						wr_en_reg <= 1;
						din_reg <= {D_RX, din_reg[7:0]};
						state <= S_IDLE;
					end
				end
				S_INIT_FINISH: begin
					wr_en_reg <= 1;
					din_reg <= {8'h00, REQ_INIT_FINISH};
					state <= S_IDLE;
				end
				S_INIT_FINISH_ACK: begin
					wr_en_reg <= 1;
					din_reg <= {8'h00, REQ_INIT_FINISH_ACK};
					state <= S_IDLE;
				end
			endcase
		end
	end
endmodule

// Module for managing Parallel Stop-and-Wait ARQ

module ARQ_Manager #(
	parameter P_DELETE_TIMEOUT = 10'd1023,       // Approximately 2048 cycles per count
	parameter P_LOG_SIZE_ARQ_TIMEOUT = 6 // Approximately 2048 cycles per count
	)(
	input clk_40mhz,
	input reset,
	// General signals
	input start,
	input [7:0] self_phn_num,
	// Network I/O
	input [1:0] NW_cmd, 
	output [1:0] NW_sts,
	input [7:0] NW_D_TX_addr,
	input [7:0] NW_D_TX,
	input NW_D_TX_ready,
	output [7:0] NW_D_RX_addr,
	output [7:0] NW_D_RX, 
	output NW_D_RX_ready,
	// CRC Encoder I/O
	input CRC_sts,
	output [7:0] D_TX,
	output D_TX_ready,
	output [4:0] pckt_num,
	// MAC I/O
	output MAC_cmd,
	input MAC_sts,
	output [4:0] MAC_pckt_num,
	// CRC Decoder I/O
	input [7:0] D_RX,        // incoming data port
	input D_RX_ready           // incoming ready
	,// DEBUG
	output [4:0] b_state_DEBUG,
	output [4:0] f_state_DEBUG,
	output [2:0] s_state_DEBUG,
	output [3:0] c_state_DEBUG,
	output b_f_lock_DEBUG,
	output b_b_lock_DEBUG,
	output b_c_lock_DEBUG,
	output f1w_s_lock_DEBUG,
	output f1w_b_lock_DEBUG,
	output f1w_c_lock_DEBUG,
	output f1r_f_lock_DEBUG,
	output f1r_b_lock_DEBUG,
	output f2w_f_lock_DEBUG,
	output f2w_b_lock_DEBUG,
	output f2w_c_lock_DEBUG	,
	output p_DEBUG,
	output [15:0] dina_DEBUG, 
	output wea_DEBUG,
	output [7:0] addra_DEBUG,
	output [15:0] douta_DEBUG
	);
	
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
	
	// Define request parameters
	parameter REQ_NONE            = 8'h00;
	parameter REQ_INIT            = 8'h01;
	parameter REQ_INIT_ACK        = 8'h02;
	parameter REQ_INIT_ACK_ACK    = 8'h03;
	parameter REQ_INIT_FINISH     = 8'h04;
	parameter REQ_INIT_FINISH_ACK = 8'h05;
	parameter REQ_DATA            = 8'h06;
	parameter REQ_DATA_ACK        = 8'h07;

	// Instantiate output registers
	reg [1:0] NW_sts_reg;
	reg [7:0] NW_D_RX_reg;
	reg NW_D_RX_ready_reg;
	reg MAC_cmd_reg;
	reg [4:0] MAC_pckt_num_reg;
	reg [7:0] NW_D_RX_addr_reg;
	
	// Assign outputs
	assign NW_sts = NW_sts_reg;
	assign NW_D_RX = NW_D_RX_reg;
	assign NW_D_RX_ready = NW_D_RX_ready_reg;
	assign MAC_cmd = MAC_cmd_reg;
	assign MAC_pckt_num = MAC_pckt_num_reg;
	assign NW_D_RX_addr = NW_D_RX_addr_reg;
	
	// Instantiate FIFO for open spots in outgoing packet queue (latency is one)
	wire [4:0] f1_din, f1_dout;
	wire f1_re, f1_we;
	wire [4:0] f1_dc_low;
	wire [5:0] f1_dc;
	wire f1_empty, f1_full;
	assign f1_dc = {f1_full, f1_dc_low};
	DLC_ARQ_FIFO1 DLC_ARQ_FIFO1_1(
		.clk(clk_40mhz),
		.rst(reset),
		.din(f1_din),
		.rd_en(f1_re),
		.dout(f1_dout),
		.wr_en(f1_we),
		.empty(f1_empty),
		.full(f1_full),
		.data_count(f1_dc_low)
		);

	// Instantiate r/w locks
	reg f1w_s_lock;
	reg f1w_b_lock;
	reg f1w_c_lock;
	reg f1r_f_lock;
	reg f1r_b_lock;

	// Instantiate input regs
	reg [4:0] f1_c_din_reg;
	reg f1_c_we_reg;	
	
	reg [4:0] f1_s_din_reg;
	reg f1_s_we_reg;

	reg f1_f_re_reg;
	reg [7:0] D_TX_f_reg;
	reg D_TX_ready_f_reg;
	reg [4:0] pckt_num_f_reg;
	
	reg [4:0] f1_b_din_reg;
	reg f1_b_we_reg, f1_b_re_reg;
	reg [7:0] D_TX_b_reg;
	reg D_TX_ready_b_reg;
	reg [4:0] pckt_num_b_reg;
	
	// Mux inputs according to locks
	assign f1_din = (f1w_b_lock) ? f1_b_din_reg: (f1w_s_lock) ? f1_s_din_reg: f1_c_din_reg;
	assign f1_we = (f1w_b_lock) ? f1_b_we_reg: (f1w_s_lock) ? f1_s_we_reg: (f1w_c_lock) ? f1_c_we_reg: 0;
	
	assign f1_re = (f1r_b_lock) ? f1_b_re_reg: (f1r_f_lock) ? f1_f_re_reg: 0;
	assign D_TX = (f1r_b_lock) ? D_TX_b_reg: (f1r_f_lock) ? D_TX_f_reg: 0;
	assign D_TX_ready = (f1r_b_lock) ? D_TX_ready_b_reg: (f1r_f_lock) ? D_TX_ready_f_reg: 0;
	assign pckt_num = (f1r_b_lock) ? pckt_num_b_reg: (f1r_f_lock) ? pckt_num_f_reg: 0;
	
	// Instantiate FIFO for outgoing send commands to MAC (latency is one)
	wire [5:0] f2_din, f2_dout;
	wire f2_re, f2_we;
	wire f2_empty, f2_full;
	DLC_ARQ_FIFO2 DLC_ARQ_FIFO2_1(
		.clk(clk_40mhz),
		.rst(reset),
		.din(f2_din),
		.rd_en(f2_re),
		.dout(f2_dout),
		.wr_en(f2_we),
		.empty(f2_empty),
		.full(f2_full)
		);
	
	// Instantiate write locks
	reg f2w_f_lock;
	reg f2w_b_lock;
	reg f2w_c_lock;

	// Instantiate input regs
	reg [5:0] f2_f_din_reg;
	reg f2_f_we_reg;
	reg [5:0] f2_b_din_reg;
	reg f2_b_we_reg;
	reg [5:0] f2_c_din_reg;
	reg f2_c_we_reg;
	reg f2_s_re_reg;
	
	// Mux inputs according to locks
	assign f2_din = (f2w_b_lock) ? f2_b_din_reg: (f2w_f_lock) ? f2_f_din_reg: f2_c_din_reg;
	assign f2_we = (f2w_b_lock) ? f2_b_we_reg: (f2w_f_lock) ? f2_f_we_reg: (f2w_c_lock) ? f2_c_we_reg: 0;
	assign f2_re = f2_s_re_reg;
	
	// Instantiate BRAM for counter timeouts, and outstanding message bits (simple dual port)
	wire [7:0] addra;
	wire [15:0] dina, douta;
	wire [15:0] doutb;
	wire wea;
	DLC_ARQ_BRAM1 DLC_ARQ_BRAM1_1(
		.clka(clk_40mhz),
		.clkb(clk_40mhz),
		.addra(addra),
		.dina(dina),
		.douta(douta),
		.wea(wea),
		.addrb(NW_D_TX_addr),
		.dinb(8'h00),
		.doutb(doutb),
		.web(1'b0)
		);
		
	// Instantiate r/w locks
	reg b_f_lock;
	reg b_b_lock;
	reg b_c_lock;
	
	// Instantiate input regs
	reg [7:0] b_f_addr_reg;
	reg [15:0] b_f_din_reg;
	reg b_f_we_reg;
	reg [7:0] b_b_addr_reg;
	reg [15:0] b_b_din_reg;
	reg b_b_we_reg;
	reg [7:0] b_c_addr_reg;
	reg [15:0] b_c_din_reg;
	reg b_c_we_reg;
	
	// Mux inputs according to locks
	assign addra = (b_c_lock) ? b_c_addr_reg: (b_b_lock) ? b_b_addr_reg: b_f_addr_reg;
	assign dina = (b_c_lock) ? b_c_din_reg: (b_b_lock) ? b_b_din_reg: b_f_din_reg;
	assign wea = (b_c_lock) ? b_c_we_reg: (b_b_lock) ? b_b_we_reg: (b_f_lock) ? b_f_we_reg: 0;
	
	// Instantiate Memory Array for TX/RX parity bits
	reg parity_tx [0:255];
	reg parity_rx [0:255];
	
	// Track rise of CRC_D_RX_ready
	reg D_RX_ready_l;
	wire D_RX_ready_rise;
	always @(posedge clk_40mhz) D_RX_ready_l <= (reset) ? 1'b0 :D_RX_ready;
	assign D_RX_ready_rise = D_RX_ready & ~D_RX_ready_l;
	
	///////////////////////////////////////////////////////////////////////////////
	/// STATE MACHINES
	///////////////////////////////////////////////////////////////////////////////
	
	// Handle back end state machine
	reg [4:0] b_state;
	
	// Declare back end state parameters
	parameter SB_START      = 5'h00;
	parameter SB_START_1    = 5'h01;
	parameter SB_IDLE       = 5'h02;
	parameter SB_DATA       = 5'h03;
	parameter SB_DATA_1     = 5'h04;
	parameter SB_DATA_2     = 5'h05;
	parameter SB_DATA_3     = 5'h06;
	parameter SB_DATA_4     = 5'h07;
	parameter SB_DATA_5     = 5'h08;
	parameter SB_DATA_6     = 5'h09;
	parameter SB_DATA_7     = 5'h0A;
	parameter SB_DATA_8     = 5'h0B;
	parameter SB_DATA_9     = 5'h0C;
	parameter SB_DATA_10    = 5'h0D;
	parameter SB_DATA_11    = 5'h0E;
	parameter SB_DATA_12    = 5'h0F;
	parameter SB_DATA_ACK   = 5'h10;
	parameter SB_DATA_ACK_1 = 5'h11;
	parameter SB_DATA_ACK_2 = 5'h12;
	parameter SB_DATA_ACK_3 = 5'h13;
	parameter SB_DATA_ACK_4 = 5'h14;
	parameter SB_DATA_ACK_5 = 5'h15;
	parameter SB_DATA_ACK_6 = 5'h16;
	parameter SB_DATA_ACK_7 = 5'h17;
	
	genvar i;
	reg global_start;
	reg RX_start;
	reg [4:0] ACK_pckt_num;
	reg [7:0] sender;
	always @(posedge clk_40mhz) begin
		if (reset) begin
			f1w_b_lock <= 0;
			f1r_b_lock <= 0;
			f2w_b_lock <= 0;
			b_b_lock <= 0;
			global_start <= 0;
			b_state <= SB_START;
//			generate
//				for (i=0; i<256; i=i+1)
//					begin: INIT_LOOP
//						parity_rx[i] <= 1'd0;
//						parity_tx[i] <= 1'd0;
//					end
//			endgenerate
		end
		else begin
			case (b_state)
				SB_START: begin // Fill outgoing FIFO with 1-32
					if (start) begin
						f1w_b_lock <= 1;
						f1_b_we_reg <= 1;
						f1_b_din_reg <= 5'd0;
						b_state <= b_state + 1;
					end
				end
				SB_START_1: begin
					if (f1_b_din_reg == 5'd31) begin
						f1w_b_lock <= 0;
						f1_b_we_reg <= 0;
						b_state <= b_state + 1;
						global_start <= 1;
					end
					else begin
						f1_b_din_reg <= f1_b_din_reg + 1;
					end
				end
				SB_IDLE: begin
					f1w_b_lock <= 0;
					f1r_b_lock <= 0;
					f2w_b_lock <= 0;
					b_b_lock <= 0;
					if (D_RX_ready_rise) begin
						case (D_RX)
							REQ_DATA: begin
								b_state <= SB_DATA;
							end
							REQ_DATA_ACK: begin
								b_state <= SB_DATA_ACK;
							end
							default:;  // do nothing otherwise
						endcase
					end
				end
				
				////////////////////////////////////////////////////////////////////////////
				// DATA PROTOCOL
				////////////////////////////////////////////////////////////////////////////				
				
				SB_DATA: begin // next byte is Receiver ID
					if (D_RX == self_phn_num) begin  // data for us
						b_state <= b_state + 1;
					end
					else begin  // data for different node
						b_state <= SB_IDLE;
					end
				end
				SB_DATA_1: begin  // next byte is Sender ID
					sender <= D_RX;
					b_state <= b_state + 1;
				end
				SB_DATA_2: begin  // next byte is parity + packet number
					if (parity_rx[sender] == D_RX[7]) begin  // right data parity, output data and update parity
						ACK_pckt_num <= D_RX[4:0];
						parity_rx[sender] <= ~D_RX[7];
						RX_start <= 1;
					end
					else begin  // wrong data parity
						ACK_pckt_num <= D_RX[4:0];
					end
					b_state <= b_state + 1;
				end
				SB_DATA_3: begin  // Send back an ACK
					RX_start <= 0;
					if (~f1r_f_lock) begin
						if (f1_empty) begin  // no spaces available to send, go back to idle
							b_state <= SB_IDLE;
						end
						else begin
							f1r_b_lock <= 1;
							f1_b_re_reg <= 1;
							b_state <= b_state + 1;
						end
					end
				end
				SB_DATA_4: begin  // spaces available to send, read from queue
					f1_b_re_reg <= 0;
					b_state <= b_state + 1;
				end
				SB_DATA_5: begin  // set request
					pckt_num_b_reg <= f1_dout;
					b_state <= b_state + 1;
				end
				SB_DATA_6: begin
					if (CRC_sts == 0) begin
						D_TX_b_reg <= REQ_DATA_ACK;
						D_TX_ready_b_reg <= 1;
						b_state <= b_state + 1;
					end
				end
				SB_DATA_7: begin  // set Receiver ID
					D_TX_b_reg <= sender;
					b_state <= b_state + 1;
				end
				SB_DATA_8: begin  // set Sender ID
					D_TX_b_reg <= self_phn_num;
					b_state <= b_state + 1;
				end
				SB_DATA_9: begin  // set parity + packet number
					D_TX_b_reg <= {parity_rx[sender], 2'b00, ACK_pckt_num};
					b_state <= b_state + 1;
				end
				SB_DATA_10: begin  // release current lock, acquire lock on sending FIFO
					f1r_b_lock <= 0;
					D_TX_ready_b_reg <= 0;
					if (~f2w_f_lock) begin
						f2w_b_lock <= 1;
						f2_b_we_reg <= 0;
						b_state <= b_state + 1;
					end
				end
				SB_DATA_11: begin  // write to sending FIFO when not full
					if (~f2_full) begin
						f2_b_we_reg <= 1;
						f2_b_din_reg <= {1'b1, pckt_num_b_reg};
						b_state <= b_state + 1;
					end
				end
				SB_DATA_12: begin
					f2w_b_lock <= 0;
					f2_b_we_reg <= 0;
					b_state <= SB_IDLE;
				end
				
				////////////////////////////////////////////////////////////////////////////
				// DATA ACK PROTOCOL
				////////////////////////////////////////////////////////////////////////////				
				
				SB_DATA_ACK: begin  // next byte is Receiver ID
					if (D_RX == self_phn_num) begin  // data for us
						b_state <= b_state + 1;
					end
					else begin  // data for different node
						b_state <= SB_IDLE;
					end					
				end
				SB_DATA_ACK_1: begin  // next byte is Sender ID
					sender <= D_RX;
					b_state <= b_state + 1;					
				end
				SB_DATA_ACK_2: begin  // next byte is parity + packet number
					if (parity_tx[sender] != D_RX[7]) begin  // right data parity, output data
						ACK_pckt_num <= D_RX[4:0];
						parity_tx[sender] <= D_RX[7];
					end
					else begin  // wrong data parity
						ACK_pckt_num <= D_RX[4:0];
					end
					b_state <= b_state + 1;					
				end
				SB_DATA_ACK_3: begin  // acquire write lock on empty spots in queue
					if (~f1w_s_lock) begin
						f1w_b_lock <= 1;
						f1_b_we_reg <= 0;
						b_state <= b_state + 1;
					end
				end
				SB_DATA_ACK_4: begin  // This lock has low priority, manage appropriately
					if (f1w_s_lock) begin
						f1w_b_lock <= 0;
						b_state <= b_state - 1;
					end
					else begin
						f1_b_we_reg <= 1;
						f1_b_din_reg <= ACK_pckt_num;
						b_state <= b_state + 1;
					end
				end
				SB_DATA_ACK_5: begin // Write finished, release lock. Acquire lock on BRAM
					f1w_b_lock <= 0;
					f1_b_we_reg <= 0;
					if (~b_c_lock & ~b_f_lock) begin
						b_b_lock <= 1;
						b_b_we_reg <= 0;
						b_state <= b_state + 1;
					end
				end
				SB_DATA_ACK_6: begin  // This lock has medium priority, manage appropriately
					if (b_c_lock) begin
						b_b_lock <= 0;
						b_state <= b_state - 1;
					end
					else begin
						b_b_we_reg <= 1;
						b_b_addr_reg <= sender;
						b_b_din_reg <= 16'h00;
						b_state <= b_state + 1;
					end
				end
				SB_DATA_ACK_7: begin  // Write finished, release lock.
					b_b_lock <= 0;
					b_b_we_reg <= 0;
					b_state <= SB_IDLE;
				end
			endcase
		end
	end
	
	// Manage network data output
	reg started;
	always @(posedge clk_40mhz) begin
		if (reset | ~global_start) begin
			NW_D_RX_reg <= 8'd0;
			NW_D_RX_ready_reg <= 0;
			NW_D_RX_addr_reg <= 0;
			started <= 0;
		end
		else if (RX_start) begin
			if (D_RX_ready) begin
				started <= 1;
				NW_D_RX_reg <= D_RX;
				NW_D_RX_ready_reg <= 1;
				NW_D_RX_addr_reg <= sender;
			end
			else begin
				started <= 0;
				NW_D_RX_ready_reg <= 0;
			end
		end
		else if (started) begin
			if (D_RX_ready) begin
				NW_D_RX_reg <= D_RX;
				NW_D_RX_ready_reg <= 1;				
			end
			else begin
				NW_D_RX_ready_reg <= 0;
				started <= 0;
			end
		end
		else begin
			NW_D_RX_ready_reg <= 0;
			started <= 0;
		end
	end
	
	// Handle front end state machine
	reg [4:0] f_state;
	
	// Declare front end state parameters
	parameter SF_IDLE    = 5'h00;
	parameter SF_CHECK   = 5'h01;
	parameter SF_CHECK_1 = 5'h02;
	parameter SF_CHECK_2 = 5'h03;
	parameter SF_SEND    = 5'h04;
	parameter SF_SEND_1  = 5'h05;
	parameter SF_SEND_2  = 5'h06;
	parameter SF_SEND_3  = 5'h07;
	parameter SF_SEND_4  = 5'h08;
	parameter SF_SEND_5  = 5'h09;
	parameter SF_SEND_6  = 5'h0A;
	parameter SF_SEND_7  = 5'h0B;
	parameter SF_SEND_8  = 5'h0C;
	parameter SF_SEND_9  = 5'h0D;
	parameter SF_SEND_10 = 5'h0E;
	parameter SF_SEND_11 = 5'h0F;
	parameter SF_SEND_12 = 5'h10;
	
	reg [7:0] NW_D_TX_addr_l;
	always @(posedge clk_40mhz) begin
		if (reset | ~global_start) begin
			f1r_f_lock <= 0;
			f2w_f_lock <= 0;
			b_f_lock <= 0;
			f_state <= SF_IDLE;
			NW_sts_reg <= STS_BUSY;
		end
		else begin
			case (f_state)
				SF_IDLE: begin
					f1r_f_lock <= 0;
					f2w_f_lock <= 0;
					b_f_lock <= 0;
					if (NW_cmd == CMD_TX) begin
						NW_sts_reg <= STS_BUSY;
						NW_D_TX_addr_l <= NW_D_TX_addr;
						f_state <= f_state + 1;
					end
					else begin
						NW_sts_reg <= STS_IDLE;
					end
				end
				SF_CHECK: begin
					if (doutb[15]) begin  // outgoing packet already exists
						NW_sts_reg <= STS_TX_REJECT;
						f_state <= SF_IDLE;
					end
					else begin
						f_state <= f_state + 1;
					end
				end
				SF_CHECK_1: begin // acquire lock on open buffer spots FIFO
					if (~f1r_b_lock) begin
						f1r_f_lock <= 1;
						f1_f_re_reg <= 0;
						f_state <= f_state + 1;
					end
				end
				SF_CHECK_2: begin // This lock has low priority, manage appropriately
					if (f1r_b_lock) begin
						f1r_f_lock <= 0;
						f_state <= f_state - 1;
					end
					else if (f1_empty) begin  // no more available spots in buffer
						f1r_f_lock <= 0;
						f_state <= SF_IDLE;
						NW_sts_reg <= STS_TX_REJECT;
					end
					else begin
						f1_f_re_reg <= 1;
						f_state <= f_state + 1;
					end
				end
				SF_SEND: begin
					f1_f_re_reg <= 0;
					f_state <= f_state + 1;
				end
				SF_SEND_1: begin
					pckt_num_f_reg <= f1_dout;
					f_state <= f_state + 1;
				end
				SF_SEND_2: begin  // First byte is request type
					if (CRC_sts == 0) begin
						D_TX_ready_f_reg <= 1;
						D_TX_f_reg <= REQ_DATA; 
						f_state <= f_state + 1;
					end
				end
				SF_SEND_3: begin  // Next byte is Receiver ID
					D_TX_f_reg <= NW_D_TX_addr_l; 
					f_state <= f_state + 1;
				end
				SF_SEND_4: begin  // Next byte is Sender ID
					D_TX_f_reg <= self_phn_num;
					f_state <= f_state + 1;
					NW_sts_reg <= STS_TX_ACCEPT;
				end
				SF_SEND_5: begin  // Next byte is parity + packet number
					D_TX_f_reg <=	{parity_tx[NW_D_TX_addr_l], 2'b00, pckt_num_f_reg};
					f_state <= f_state + 1;
				end
				SF_SEND_6: begin  // Rest is data
					if (NW_D_TX_ready) begin
						D_TX_f_reg <= NW_D_TX;
					end
					else begin
						f1r_f_lock <= 0;
						D_TX_ready_f_reg <= 0;
						f_state <= f_state + 1;
					end
				end
				SF_SEND_7: begin  // Acquire write lock on send FIFO
					if (~f2w_b_lock) begin
						f2w_f_lock <= 1;
						f2_f_we_reg <= 0;
						f_state <= f_state + 1;
					end
				end
				SF_SEND_8: begin  // This lock has low priority, manage appropriately
					if (f2w_b_lock) begin
						f2w_f_lock <= 0;
						f_state <= f_state - 1;
					end
					else begin
						f_state <= f_state + 1;
					end
				end
				SF_SEND_9: begin
					if (~f2_full) begin
						f2_f_we_reg <= 1;
						f2_f_din_reg <= {1'b0, pckt_num_f_reg};
						f_state <= f_state + 1;						
					end
				end
				SF_SEND_10: begin // Release lock on sending FIFO, acquire lock on BRAM
					f2w_f_lock <= 0;
					f2_f_we_reg <= 0;
					if (~b_b_lock & ~b_c_lock) begin
						b_f_lock <= 1;
						b_f_we_reg <= 0;
						f_state <= f_state + 1;
					end
				end
				SF_SEND_11: begin // This lock has low priority, manage appropriately
					if (b_b_lock | b_c_lock) begin
						b_f_lock <= 0;
						f_state <= f_state - 1;
					end
					else begin
						b_f_we_reg <= 1;
						b_f_addr_reg <= NW_D_TX_addr_l;
						b_f_din_reg <= {1'b1, pckt_num_f_reg, P_DELETE_TIMEOUT[9:0]};
						f_state <= f_state + 1;
					end
				end
				SF_SEND_12: begin
					b_f_lock <= 0;
					b_f_we_reg <= 0;
					f_state <= SF_IDLE;
				end
			endcase
		end
	end
	
	// Handle MAC send commands state machine
	reg [3:0] s_state;
	
	// Declare send state machine parameters
	parameter SS_IDLE   = 4'h0;
	parameter SS_SEND   = 4'h1;
	parameter SS_SEND_1 = 4'h2;
	parameter SS_SEND_2 = 4'h3;
	parameter SS_SEND_3 = 4'h4;
	parameter SS_SEND_4 = 4'h5;
	parameter SS_DEL    = 4'h6;
	parameter SS_DEL_1  = 4'h7;
	parameter SS_DEL_2  = 4'h8;
	
	reg del_packet;
	always @(posedge clk_40mhz) begin
		if (reset | ~global_start) begin
			s_state <= SS_IDLE;
			f2_s_re_reg <= 0;
			MAC_cmd_reg <= 0;
			MAC_pckt_num_reg <= 5'd0; 
		end
		else begin
			case (s_state)
				SS_IDLE: begin
					if (~f2_empty) begin
						f2_s_re_reg <= 1;
						s_state <= s_state + 1;
					end
					else begin
						f2_s_re_reg <= 0;
					end
				end
				SS_SEND: begin  // Send write command to MAC
					f2_s_re_reg <= 0;
					s_state <= s_state + 1;
				end
				SS_SEND_1: begin
					del_packet <= f2_dout[5];
					MAC_pckt_num_reg <= f2_dout[4:0];
					s_state <= s_state + 1;
				end
				SS_SEND_2: begin  // Wait until MAC is idle
					if (MAC_sts == 0) begin
						MAC_cmd_reg <= 1;
						s_state <= s_state + 1;
					end
				end
				SS_SEND_3: begin
					MAC_cmd_reg <= 0;
					if (del_packet) begin
						s_state <= s_state + 1;
					end
					else begin
						s_state <= SS_IDLE;
					end
				end
				SS_SEND_4: begin  // wait for MAC to finish sending before deletion
					if (MAC_sts == 0) begin
						s_state <= s_state + 1;
					end
				end
				SS_DEL: begin  // Delete packet if it was an ACK. Acquire write lock.
					if (~f1w_b_lock) begin
						f1w_s_lock <= 1;
						f1_s_we_reg <= 0;
						s_state <= s_state + 1;
					end
				end
				SS_DEL_1: begin  // This lock has low priority, manage appropriately
					if (f1w_b_lock) begin
						f1w_s_lock <= 0;
						s_state <= s_state - 1;
					end
					else begin
						f1_s_we_reg <= 1;
						f1_s_din_reg <= MAC_pckt_num_reg;
						s_state <= s_state + 1;
					end
				end
				SS_DEL_2: begin  // Release lock
					f1w_s_lock <= 0;
					f1_s_we_reg <= 0;
					s_state <= SS_IDLE;
				end
			endcase
		end
	end
	
	// Handle ARQ timeout state machine
	reg [3:0] c_state;
	
	// Define ARQ timeout state parameters
	parameter SC_IDLE   = 4'h0;
	parameter SC_DEC    = 4'h1;
	parameter SC_DEC_1  = 4'h2;
	parameter SC_DEC_2  = 4'h3;
	parameter SC_DEC_3  = 4'h4;	
	parameter SC_DEL    = 4'h5;
	parameter SC_DEL_1  = 4'h6;
	parameter SC_DEL_2  = 4'h7;
	parameter SC_SEND   = 4'h8;
	parameter SC_SEND_1 = 4'h9;
	parameter SC_SEND_2 = 4'hA;
	parameter SC_SEND_3 = 4'hB;
	
	reg [2:0] cntr;
	reg [4:0] c_pckt_num;
	wire [9:0] timeout_minus_one;
	assign timeout_minus_one = douta[9:0] - 1;
	always @(posedge clk_40mhz) begin
		if (reset | ~global_start) begin
			f2w_c_lock <= 0;
			f1w_c_lock <= 0;
			b_c_lock <= 0;
			c_state <= SC_IDLE;
			cntr <= 3'd0;
			b_c_addr_reg <= 0;
		end
		else begin
			case (c_state)
				SC_IDLE: begin  // acquire lock on BRAM 
					if (~b_f_lock & ~b_b_lock & !cntr) begin
						b_c_lock <= 1;
						c_state <= c_state + 1;
					end
					else if (cntr) begin
						cntr <= cntr - 1;
						b_c_lock <= 0;
					end
					else begin
						b_c_lock <= 0;
					end
					b_c_we_reg <= 0;
					f2w_c_lock <= 0;
					f1w_c_lock <= 0;
				end
				SC_DEC: begin  // guaranteed to get lock
					c_state <= c_state + 1;
				end
				SC_DEC_1: begin  // wait a state for the address to be set for the read
					c_state <= c_state + 1;
				end
				SC_DEC_2: begin
					if (douta[15]) begin
						b_c_we_reg <= 1;
						b_c_din_reg <= {(|douta[9:0]), douta[14:10], timeout_minus_one};
						c_pckt_num <= douta[14:10];
						if (!douta[9:0]) begin // delete the packet
							c_state <= SC_DEL;
						end
						else if (!douta[P_LOG_SIZE_ARQ_TIMEOUT-1:0]) begin // resend the packet
							c_state <= SC_SEND;
						end
						else begin // decrement ARQ timeout
							c_state <= c_state + 1;
						end
					end
					else begin  // no outstanding message, release the lock
						b_c_lock <= 0;
						b_c_we_reg <= 0;
						b_c_addr_reg <= b_c_addr_reg + 1;
						cntr <= 3'd7;
						c_state <= SC_IDLE;
					end
				end
				SC_DEC_3: begin
						b_c_lock <= 0;
						b_c_we_reg <= 0;
						b_c_addr_reg <= b_c_addr_reg + 1;
						cntr <= 3'd7;
						c_state <= SC_IDLE;					
				end
				SC_DEL: begin // get lock on open spots FIFO
					b_c_lock <= 0;
					b_c_we_reg <= 0;
					if (~f1w_b_lock & ~f1w_s_lock) begin
						f1w_c_lock <= 1;
						f1_c_we_reg <= 0;
						c_state <= c_state + 1;
					end
				end
				SC_DEL_1: begin
					if (f1w_b_lock | f1w_s_lock) begin
						f1w_c_lock <= 0;
						c_state <= c_state - 1;
					end
					else begin
						f1_c_we_reg <= 1;
						f1_c_din_reg <= c_pckt_num;
						c_state <= c_state + 1;
					end
				end
				SC_DEL_2: begin  // release lock
					f1_c_we_reg <= 0;
					f1w_c_lock <= 0;
					b_c_addr_reg <= b_c_addr_reg + 1;
					cntr <= 3'd7;
					c_state <= SC_IDLE;
				end
				SC_SEND: begin  // get lock on sending FIFO
					b_c_lock <= 0;
					b_c_we_reg <= 0;
					if (~f2w_b_lock & ~f2w_f_lock) begin
						f2w_c_lock <= 1;
						f2_c_we_reg <= 0;
						c_state <= c_state + 1;
					end
				end
				SC_SEND_1: begin
					if (f2w_b_lock | f2w_f_lock) begin
						f2w_c_lock <= 0;
						c_state <= c_state - 1;
					end
					else begin						
						c_state <= c_state + 1;
					end
				end
				SC_SEND_2: begin
					if (~f2_full) begin
						f2_c_we_reg <= 1;
						f2_c_din_reg <= c_pckt_num;
						c_state <= c_state + 1;
					end
				end
				SC_SEND_3: begin
					f2_c_we_reg <= 0;
					f2w_c_lock <= 0;
					b_c_addr_reg <= b_c_addr_reg + 1;
					cntr <= 3'd7;
					c_state <= SC_IDLE;
				end
			endcase
		end
	end
	
	// DEBUG
	assign b_state_DEBUG = b_state;
	assign f_state_DEBUG = f_state;
	assign s_state_DEBUG = s_state;
	assign c_state_DEBUG = c_state;
	assign b_f_lock_DEBUG = b_f_lock;
	assign b_b_lock_DEBUG = b_b_lock;
	assign b_c_lock_DEBUG = b_c_lock;
	assign f1w_s_lock_DEBUG = f1w_s_lock;
	assign f1w_b_lock_DEBUG = f1w_b_lock;
	assign f1w_c_lock_DEBUG = f1w_c_lock;
	assign f1r_f_lock_DEBUG = f1r_f_lock;
	assign f1r_b_lock_DEBUG = f1r_b_lock;
	assign f2w_f_lock_DEBUG = f2w_f_lock;
	assign f2w_b_lock_DEBUG = f2w_b_lock;
	assign f2w_c_lock_DEBUG	 = f2w_c_lock;
	assign p_DEBUG = parity_tx[8'hAD];
	assign dina_DEBUG = dina;
	assign wea_DEBUG = wea;
	assign addra_DEBUG = addra;
	assign douta_DEBUG = douta;
endmodule