`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        6.111
// Engineer:       Sachin Shinde 
// 
// Create Date:    19:21:10 11/23/2012 
// Design Name: 
// Module Name:    Voicemail_Interface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:   Allows for reading and writing of voicemails to CompactFlash.
//                Voicemail max time is around 4 minutes (8192 sectors)
//                Max number of voicemails is 1024.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
//// High-Level Interface Module
//////////////////////////////////////////////////////////////////////////////////

module Voicemail_Interface(
	input clk_27mhz,      // 27MHz clock
	input reset,          // Synchronous reset
	// Main Interface ports
	output [3:0] sts,         // Status port
	input [3:0] cmd,          // Port for issuing commands
	input [7:0] phn_num,      // Port for phone number (on writes)
	input [15:0] din,         // Sample Data in
	output [15:0] dout,       // Sample Data out
	input d_ready,            // Sample Data Ready Signal
	input disp_en,            // Display Enable
	// Button inputs
	input button_up,
	input button_down,
	// ASCII output
	output [7:0] ascii_out,   // Port for ASCII data
	output ascii_out_ready,   // Ready signal for ASCII data
	// ZBT RAM I/Os
   inout  [35:0] ram_data,
   output [18:0] ram_address,
   output ram_we_b,
   output [3:0] ram_bwe_b,
	// Date & Time inputs	
	input [6:0] year,
	input [3:0] month,
	input [4:0] day,
	input [4:0] hour,
	input [5:0] minute,
	input [5:0] second,
	// Binary-to-Decimal Lookup-Table I/O
	output [6:0] addr,
	input [7:0] data,
	// SystemACE ports
	inout [15:0] systemace_data,     // SystemACE R/W data
	output [6:0] systemace_address,  // SystemACE R/W address
	output systemace_ce_b,           // SystemACE chip enable (Active Low)
	output systemace_we_b,           // SystemACE write enable (Active Low)
	output systemace_oe_b,           // SystemACE output enable (Active Low)
	input systemace_mpbrdy           // SystemACE buffer ready
	);

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
	
	// Instantiate status register
	reg [3:0] sts_reg;
	
	// Assign status signal
	assign sts = sts_reg;
	
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
	
	// Declare CF Interface command parameters
	parameter CF_CMD_IDLE   = 2'b00;
	parameter CF_CMD_DETECT = 2'b01;
	parameter CF_CMD_READ   = 2'b10;
	parameter CF_CMD_WRITE  = 2'b11;

	// Define ZBT Operation parameters (OPCODE)
	parameter OP_IDLE  = 2'b00;
	parameter OP_READ  = 2'b01;
	parameter OP_WRITE = 2'b10;
	
	// Instantiate state
	reg [5:0] state;
	
	// Define state parameters
	parameter S_INIT                 = 6'h00;
	parameter S_IDLE                 = 6'h01;
	parameter S_START_RW_INIT        = 6'h02;
	parameter S_START_RW_INIT_1      = 6'h03;
	parameter S_START_WR             = 6'h04;
	parameter S_START_WR_1           = 6'h05;
	parameter S_START_WR_2           = 6'h06;
	parameter S_START_WR_3           = 6'h07;
	parameter S_START_WR_4           = 6'h08;
	parameter S_WRING                = 6'h09;
	parameter S_END_WR               = 6'h0A;
	parameter S_END_WR_2             = 6'h0B;
	parameter S_END_WR_3             = 6'h0C;
	parameter S_START_RD             = 6'h0D;
	parameter S_START_RD_1           = 6'h0E;
	parameter S_START_RD_2           = 6'h0F;
	parameter S_RDING                = 6'h10;
	parameter S_END_RD               = 6'h11;
	parameter S_DEL_MSG              = 6'h12;
	parameter S_DEL_MSG_1            = 6'h13;
	parameter S_DEL_MSG_2            = 6'h14;
	parameter S_DEL_MSG_3            = 6'h15;
	parameter S_DEL_MSG_4            = 6'h16;
	parameter S_DEL_MSG_5            = 6'h17;
	parameter S_ADD_MSG              = 6'h18;
	parameter S_ADD_MSG_1            = 6'h19;
	parameter S_ADD_MSG_2            = 6'h1A;
	parameter S_ADD_MSG_3            = 6'h1B;
	parameter S_ADD_MSG_4            = 6'h1C;
	parameter S_ADD_MSG_5            = 6'h1D;
	parameter S_UPDT_MSG_POS_DATA    = 6'h1E;
	parameter S_UPDT_MSG_POS_DATA_1  = 6'h1F;
	parameter S_UPDT_MSG_POS_DATA_2  = 6'h20;
	parameter S_UPDT_MSG_POS_DATA_3  = 6'h21;
	parameter S_UPDT_MSG_POS_DATA_4  = 6'h22;
	parameter S_UPDT_MSG_POS_DATA_5  = 6'h23;
	parameter S_UPDT_MSG_POS_DATA_6  = 6'h24;
	parameter S_UPDT_MSG_POS_DATA_7  = 6'h25;
	parameter S_UPDT_MSG_POS_DATA_8  = 6'h26;
	parameter S_UPDT_MSG_POS_DATA_9  = 6'h27;
	parameter S_UPDT_MSG_POS_DATA_10 = 6'h28;
	
	// Generate button rise signals
	reg bl_up, bl_down;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			bl_up <= 0;
			bl_down <= 0;
		end
		else begin
			bl_up <= button_up;
			bl_down <= button_down;		
		end
	end
	assign b_up_rise = button_up & ~bl_up;
	assign b_down_rise = button_down & ~bl_down;
	
	// Instantiate CF_Interface
	wire [1:0] CF_cmd;
	wire [27:0] CF_LBA;
	wire [7:0] CF_SC;
	wire [15:0] CF_din;
	wire CF_we_req;
	wire [15:0] CF_dout;
	wire CF_nd;
	wire CF_CF_detect;
	wire [27:0] CF_LBA_max;
	wire CF_ready;
	CF_Interface CF_INTERFACE_1(
		.clk_27mhz(clk_27mhz),                  // 27 MHz clock
		.reset(reset),                          // Synchronous reset
		// Mid-level I/O
		.cmd(CF_cmd),                           // Command to be performed
		.LBA(CF_LBA),                           // Logical Block Address for r/w
		.SC(CF_SC),                             // Sector Count
		.din(CF_din),                           // Data input for writes
		.we_req(CF_we_req),                     // Request for write data
		.dout(CF_dout),                         // Data output for reads
		.nd(CF_nd),                             // New Data available at output
		.CF_detect(CF_CF_detect),               // Detect if CF d evice is connected
		.LBA_max(CF_LBA_max),                   // Maximum number of LBAs if CF detected
		.ready(CF_ready),                       // Command ready signal
		// SystemACE ports
		.systemace_data(systemace_data),        // SystemACE R/W data
		.systemace_address(systemace_address),  // SystemACE R/W address
		.systemace_ce_b(systemace_ce_b),        // SystemACE chip enable (Active Low)
		.systemace_we_b(systemace_we_b),        // SystemACE write enable (Active Low)
		.systemace_oe_b(systemace_oe_b),        // SystemACE output enable (Active Low)
		.systemace_mpbrdy(systemace_mpbrdy)     // SystemACE MPU buffer ready
		);
	
	// Instantiate CF Interface input registers
	reg [1:0] CF_cmd_reg;
	reg [27:0] CF_LBA_reg;
	reg [7:0] CF_SC_reg;
	
	// Assign CF Interface inputs
	assign CF_cmd = CF_cmd_reg;
	assign CF_LBA = CF_LBA_reg;
	assign CF_SC = CF_SC_reg;
	
	// Instantiate 4-Sector FIFO for Incoming Voicemail
	reg wr_en_override, rst_in_FIFO;
	wire [10:0] in_data_cnt;
	wire in_wr_en;
	assign in_wr_en = wr_en_override & d_ready;
	wire in_full, in_empty;
	Voicemail_FIFO VM_FIFO_IN(
		.clk(clk_27mhz),
		.rst(rst_in_FIFO),
		.din(din),
		.dout(CF_din),
		.wr_en(in_wr_en),
		.rd_en(CF_we_req),
		.data_count(in_data_cnt),
		.empty(in_empty),
		.full(in_full)
		);
	
	// Instantiate 4-Sector FIFOs for Outgoing Voicemail
	reg rd_en_override, rst_out_FIFO;
	wire [10:0] out_data_cnt;
	wire out_rd_en;
	assign out_rd_en = rd_en_override & d_ready;
	wire out_empty, out_full;
	Voicemail_FIFO VM_FIFO_OUT(
		.clk(clk_27mhz),
		.rst(rst_out_FIFO),
		.din(CF_dout),
		.dout(dout),
		.wr_en(CF_nd),
		.rd_en(out_rd_en),
		.data_count(out_data_cnt),
		.empty(out_empty),
		.full(out_full)
		);
	
	// Instantiate ZBT Interface
	wire [35:0] ZBT_din, ZBT_dout;
	wire [18:0] ZBT_addr;
	wire [1:0] ZBT_op;
	wire [3:0] ZBT_bwe;
	wire ZBT_nd, ZBT_ready;
	ZBT_Interface ZBT_INTERFACE_1(
		.clk_27mhz(clk_27mhz),    // 27MHz clock
		.reset(reset),            // Synchronous reset
		// Low-Level I/O
		.addr(ZBT_addr),          // Address signal for r/w
		.din(ZBT_din),            // Data input for writes
		.op(ZBT_op),              // Operation Code
		.bwe(ZBT_bwe),            // Partial (byte) writes
		.dout(ZBT_dout),          // Data output for reads
		.nd(ZBT_nd),              // New data available at output
		.ready(ZBT_ready),        // Command Ready signal
		// ZBT ports
		.ram_data(ram_data),
		.ram_address(ram_address),
		.ram_we_b(ram_we_b),
		.ram_bwe_b(ram_bwe_b)
		);

	// Instantiate ZBT Interface registers
	reg [18:0] ZBT_addr_reg;
	reg [35:0] ZBT_din_reg;
	reg [1:0] ZBT_op_reg;
	reg [3:0] ZBT_bwe_reg;
	
	// Assign ZBT Interface registers
	assign ZBT_addr = ZBT_addr_reg;
	assign ZBT_din = ZBT_din_reg;
	assign ZBT_op = ZBT_op_reg;
	assign ZBT_bwe = ZBT_bwe_reg;
	
	// Instantiate ZBT doubly-linked list (DLL) pointers
	reg [14:0] unread_start;
	reg [14:0] unread_end;
	reg [14:0] saved_start;
	reg [14:0] saved_end;
	
	// Instantiate ZBT DLL message empty regs
	reg unread_exist;  // High if at least one unread message
	reg saved_exist;   // High if at least one saved message
	
	// Instantiate ZBT FIFO pointers
	reg [14:0] FIFO_start; 
	reg [14:0] FIFO_end;
	
	// Instantiate CF Interface operation (internal) registers
	reg [2:0] CF_Interface_op;
	
	// Declare CF Interface operation parameters
	parameter CF_OP_IDLE     = 3'h0;
	parameter CF_OP_WR_EN    = 3'h1;
	parameter CF_OP_RD_EN    = 3'h2;
	parameter CF_OP_WR_FORCE = 3'h3;
	parameter CF_OP_DETECT   = 3'h4;
	
	// Latch input parameters
	reg [7:0] latch_phn_num;
	reg [32:0] latch_DT;
	
	// Instantiate other internal registers
	reg [14:0] msg_max;                               // Maximum number of messages
	reg [14:0] msg_chkout_cnt;                        // Allocates message IDs initially
	reg [21:0] sample_cnt;                            // Counts samples on R/W (0 to 8192*256 inclusive)
	reg [14:0] msg_pos, msg_pos_prev, msg_pos_next;  // Current message position and data
	reg [7:0] msg_pos_phn_num;                        // Message position data
	reg [32:0] msg_pos_DT;                            // Message position data
	reg [21:0] msg_pos_sample_cnt;                    // Message position data
	reg disp_req;                                       // Set high for display request
	reg S_DEL_save;                                     // Parameter for delete procedure
	reg S_ADD_MSG_unread;                               // Parameter for add message procedure
	reg wr_op;                                          // Used to control whether RD or WR op after Initial CF Detect
	reg cur_view;                                       // Currently viewed list (either 0 for unread, or 1 for saved)
	
	// Manage main state transitions
	always @(posedge clk_27mhz) begin
		if (reset | ~CF_CF_detect) begin
			// Set High-Level output registers
			sts_reg <= STS_NO_CF_DEVICE;		
			// Set ZBT Interface output registers
			ZBT_addr_reg <= 0;
			ZBT_din_reg <= 0;
			ZBT_op_reg <= OP_IDLE;
			ZBT_bwe_reg <= 0;
			// Set ZBT DLL pointers
			unread_start <= 0;
			unread_end <= 0;
			saved_start <= 0;
			saved_end <= 0;
			unread_exist <= 0;
			saved_exist <= 0;
			// Set ZBT FIFO pointers
			FIFO_start <= 0;
			FIFO_end <= 0;
			// Set override registers
			rd_en_override <= 0;
			wr_en_override <= 0;
			// Set FIFO registers
			rst_in_FIFO <= 0;
			rst_out_FIFO <= 0;
			// Set CF Interface op register
			CF_Interface_op <= CF_OP_IDLE;
			// Set Internal registers
			msg_max <= 0;
			msg_chkout_cnt <= 0;
			sample_cnt <= 0;
			msg_pos <= 0;
			msg_pos_prev <= 0;
			msg_pos_next <= 0;
			msg_pos_phn_num <= 0;
			msg_pos_DT <= 0;
			msg_pos_sample_cnt <= 0;
			disp_req <= 0;
			wr_op <= 0;
			cur_view <= 0;
			// Set State
			state <= S_INIT;
		end
		else begin
			case (state)
				S_INIT: begin
					if (CF_ready) begin
						// Set parent and child to itself
						if (ZBT_ready) begin
							msg_max <= CF_LBA_max[27:13];
							sts_reg <= STS_CMD_RDY;
							ZBT_addr_reg <= {2'b00, 15'd0, 2'b00};
							ZBT_din_reg <= 36'd0;
							ZBT_op_reg <= OP_WRITE;
							ZBT_bwe_reg <= 4'b1111;
							state <= state + 1;  // S_IDLE
							disp_req <= 1;
						end
					end
				end
				S_IDLE: begin
					disp_req <= 0;
					ZBT_op_reg <= OP_IDLE;
					CF_Interface_op <= CF_OP_IDLE;
					if ((b_up_rise | b_down_rise)&(unread_exist | cur_view)&(saved_exist | ~cur_view)) begin
						sts_reg <= STS_BUSY;
						case (b_up_rise)
							1'b0: begin  // Down
								state <= S_UPDT_MSG_POS_DATA;
								msg_pos <= msg_pos_next;
							end
							1'b1: begin  // Up
								state <= S_UPDT_MSG_POS_DATA;
								msg_pos <= msg_pos_prev;
							end
						endcase
					end
					else begin
						case (cmd)
							CMD_START_RD: begin
								state <= S_START_RW_INIT;
								sts_reg <= STS_BUSY;
								wr_op <= 0;
							end
							CMD_START_WR: begin
								state <= S_START_RW_INIT;
								latch_phn_num <= phn_num;
								latch_DT <= {year, month, day, hour, minute, second};
								sts_reg <= STS_BUSY;
								wr_op <= 1;
							end
							CMD_VIEW_UNRD: begin
								state <= S_UPDT_MSG_POS_DATA;
								msg_pos <= unread_start;
								sts_reg <= STS_BUSY;
								cur_view <= 0;
							end
							CMD_VIEW_SAVED: begin
								state <= S_UPDT_MSG_POS_DATA;
								msg_pos <= saved_start;
								sts_reg <= STS_BUSY;
								cur_view <= 1;
							end
							CMD_DEL: begin
								state <= S_DEL_MSG;
								S_DEL_save <= 0;
								sts_reg <= STS_BUSY;
							end
							CMD_SAVE: begin
								if (~cur_view) begin  // Make sure current view is unread
									state <= S_DEL_MSG;
									S_DEL_save <= 1;
									sts_reg <= STS_BUSY;
								end
								else
									sts_reg <= STS_CMD_RDY;
							end
							default: sts_reg <= STS_CMD_RDY;
						endcase
					end
				end

				/////////////////////////////////////////////////////////
				////  Detect CF Device before RW operations
				/////////////////////////////////////////////////////////

				S_START_RW_INIT: begin  // Detect CF device first
					if (CF_cmd_reg == CF_CMD_DETECT) begin
						CF_Interface_op <= CF_OP_IDLE;  // S_START_WR_INIT_2
						state <= state + 1;  // S_START_RW_INIT_1
					end
					else
						CF_Interface_op <= CF_OP_DETECT;
				end
				S_START_RW_INIT_1: begin  // Wait for CF Interface to be ready before proceeding
					if (CF_ready) begin
						if (wr_op)
							state <= state + 1;  // S_START_WR
						else
							state <= S_START_RD;
					end
				end

				/////////////////////////////////////////////////////////
				////  Write Voicemail
				/////////////////////////////////////////////////////////
				
				S_START_WR: begin  // Checkout message ID
					sample_cnt <= 0;
					rst_in_FIFO <= 1;
					if (ZBT_ready) begin
						if (msg_chkout_cnt != msg_max) begin
							msg_chkout_cnt <= msg_chkout_cnt + 1;
							msg_pos <= msg_chkout_cnt;
							ZBT_addr_reg <= {2'b00, msg_chkout_cnt, 2'b01};
							ZBT_din_reg <= {27'h0000000, latch_phn_num, 1'b0};
							ZBT_op_reg <= OP_WRITE;
							ZBT_bwe_reg <= 4'b0001;
							state <= state + 2;  // S_START_WR_2
						end
						else if (FIFO_start != FIFO_end) begin
							ZBT_addr_reg <= {4'b0010, FIFO_start};
							ZBT_op_reg <= OP_READ;
							FIFO_start <= FIFO_start + 1;
							state <= state + 1;  // S_START_WR_1
						end
						else begin
							state <= S_IDLE;
							sts_reg <= STS_ERR_VM_FULL;
						end
					end
				end
				S_START_WR_1: begin
					if (ZBT_nd) begin
						ZBT_addr_reg <= {2'b00, ZBT_dout[35:21], 2'b01};
						ZBT_din_reg <= {27'h0000000, latch_phn_num, 1'b0};
						ZBT_op_reg <= OP_WRITE;
						ZBT_bwe_reg <= 4'b0001;
						msg_pos <= ZBT_dout[35:21];
						state <= state + 2;  // S_START_WR_3
					end
					else
						ZBT_op_reg <= OP_IDLE;
				end
				S_START_WR_2: begin  // Wait constraint on consective ZBT ops
					ZBT_op_reg <= OP_IDLE;
					state <= state + 1;
				end
				S_START_WR_3: begin  // Store Date & Time
					rst_in_FIFO <= 0;
					if (ZBT_ready) begin
						ZBT_addr_reg <= {2'b00, msg_pos, 2'b10};
						ZBT_din_reg <= {latch_DT, 3'b000};
						ZBT_op_reg <= OP_WRITE;
						ZBT_bwe_reg <= 4'b1111;
						state <= state + 1;
					end
				end
				S_START_WR_4: begin // Wait constraint on consective ZBT ops
					state <= S_ADD_MSG;
					S_ADD_MSG_unread <= 1;
					ZBT_op_reg <= OP_IDLE;
				end
				S_WRING: begin
					ZBT_op_reg <= OP_IDLE;
					if (cmd == CMD_END_WR) begin
						sts_reg <= STS_WR_FIN;
						wr_en_override <= 0;
						state <= state + 1;  // S_END_WR
					end
					else if (d_ready) begin
						if (in_full) begin  // if write buffer full
							sts_reg <= STS_ERR_WR_FAIL;
							wr_en_override <= 0;
							state <= state + 1; // S_END_WR
						end
						else if (&sample_cnt[20:0]) begin  // if next sample will be last
							sts_reg <= STS_WR_FIN;
							wr_en_override <= 0;
							state <= state + 1;  // S_END_WR
							sample_cnt <= sample_cnt + 1;
						end
						else
							sample_cnt <= sample_cnt + 1;
					end
				end
				S_END_WR: begin
					if (!in_data_cnt[10:8] & CF_ready) begin
						state <= state + 1;  // S_END_WR_2
						if (in_data_cnt[7:0]) begin //  if there are samples left in the incoming FIFO
							CF_Interface_op <= CF_OP_WR_FORCE; // force remainder of FIFO to be written
						end
						else begin
							CF_Interface_op <= CF_OP_IDLE;
						end
					end
				end
				S_END_WR_2: begin
					if (!in_data_cnt && CF_ready) begin  // wait until incoming FIFO is empty and CF Interface is ready before moving forward
						state <= state + 1;
						CF_Interface_op <= CF_OP_IDLE;
					end
				end
				S_END_WR_3: begin  // Store sample count (ZBT should be ready, no need to check)
					ZBT_addr_reg <= {2'b00, msg_pos, 2'b01};
					ZBT_din_reg <= {sample_cnt, 14'd0};
					ZBT_op_reg <= OP_WRITE;
					ZBT_bwe_reg <= 4'b1110;
					state <= S_IDLE;
					sts_reg <= STS_CMD_RDY;
				end

				/////////////////////////////////////////////////////////
				////  Read Voicemail
				/////////////////////////////////////////////////////////
				
				S_START_RD: begin  // check if message exists before reading
					if ((~unread_exist & ~cur_view)|(~saved_exist & cur_view)) begin
						state <= S_IDLE;
						sts_reg <= STS_CMD_RDY;
					end
					else
						state <= state + 1;  // S_START_RD_1
				end
				S_START_RD_1: begin
					sample_cnt <= msg_pos_sample_cnt;
					rst_out_FIFO <= 1;
					state <= state + 1;  // S_START_RD_2
				end
				S_START_RD_2: begin
					rst_out_FIFO <= 0;
					CF_Interface_op <= CF_OP_RD_EN;
					if (out_data_cnt[10:8]) begin  // Preload 256 samples into output FIFO before proceeding
						state <= state + 1;  // S_RDING
						sts_reg <= STS_RDING;
						rd_en_override <= 1;
					end
				end
				S_RDING: begin
					if (cmd == CMD_END_RD) begin
						sts_reg <= STS_RD_FIN;
						rd_en_override <= 0;
						CF_Interface_op <= CF_OP_IDLE;
						state <= state + 1;  // S_END_RD
					end
					else if (d_ready) begin
						if (out_empty) begin  // if read buffer empty
							sts_reg <= STS_ERR_RD_FAIL;
							rd_en_override <= 0;
							CF_Interface_op <= CF_OP_IDLE;
							state <= state + 1; // S_END_RD
						end
						else if (sample_cnt == 1) begin  // if next sample will be last
							sts_reg <= STS_RD_FIN;
							rd_en_override <= 0;
							CF_Interface_op <= CF_OP_IDLE;
							state <= state + 1;  // S_END_RD
						end
						else
							sample_cnt <= sample_cnt - 1;
					end
				end
				S_END_RD: begin  // Wait until CF Interface is ready before moving forward
					if (CF_ready) begin
						state <= S_IDLE;
						sts_reg <= STS_CMD_RDY;
					end
				end

				/////////////////////////////////////////////////////////
				////  Delete Message from List
				/////////////////////////////////////////////////////////
				
				S_DEL_MSG: begin
					if ((~unread_exist & ~cur_view)|(~saved_exist & cur_view)) begin  // Check if del/sve cmd issued when lists are empty
						state <= S_IDLE;
						sts_reg <= STS_CMD_RDY;						
					end
					else
						state <= state + 1;  // S_DEL_MSG_1
				end
				S_DEL_MSG_1: begin
					if (ZBT_ready) begin
						ZBT_addr_reg <= {2'b00, msg_pos_prev, 2'b00};  // Set previous msg's child to next msg
						ZBT_din_reg <= {18'h00000, msg_pos_next, 3'b000};
						ZBT_op_reg <= OP_WRITE;
						ZBT_bwe_reg <= 4'b0011;
						state <= state + 1;  // S_DEL_MSG_2
						// Update if msg to delete is start or end of a list;
						if (cur_view) begin
							if (msg_pos == saved_end) saved_end <= msg_pos_prev;
							if (msg_pos == saved_start) saved_start <= msg_pos_next;
						end
						else begin
							if (msg_pos == unread_end) unread_end <= msg_pos_prev;
							if (msg_pos == unread_start) unread_start <= msg_pos_next;
						end
					end
				end
				S_DEL_MSG_2: begin  // Wait constraint on consective ZBT ops
					state <= state + 1;  // S_DEL_MSG_3
					ZBT_op_reg <= OP_IDLE;
				end
				S_DEL_MSG_3: begin
					if (ZBT_ready) begin
						ZBT_addr_reg <= {2'b00, msg_pos_next, 2'b00};  // Set next msg's parent to previous msg
						ZBT_din_reg <= {msg_pos_prev, 21'h000000};
						ZBT_op_reg <= OP_WRITE;
						ZBT_bwe_reg <= 4'b1100;
						state <= state + 1;  // S_DEL_MSG_4
					end
				end
				S_DEL_MSG_4: begin  // Wait constraint on consective ZBT ops
					state <= state + 1;  // S_DEL_MSG_5
					ZBT_op_reg <= OP_IDLE;
				end
				S_DEL_MSG_5: begin
					if (ZBT_ready) begin
						if (msg_pos_prev == msg_pos) begin  // Check if only one message left
							if (cur_view)
								saved_exist <= 0;
							else 
								unread_exist <= 0;
						end
						if (S_DEL_save) begin
							ZBT_op_reg <= OP_IDLE;
							state <= S_ADD_MSG;
							S_ADD_MSG_unread <= 0;
						end
						else begin  // Add deleted msg ID to end of FIFO
							ZBT_addr_reg <= {4'b0100, FIFO_end};
							ZBT_din_reg <= {msg_pos, 21'h000000};
							ZBT_op_reg <= OP_WRITE;
							ZBT_bwe_reg <= 4'b1111;
							FIFO_end <= FIFO_end + 1;
							msg_pos <= msg_pos_prev;
							state <= S_UPDT_MSG_POS_DATA;
						end
					end
				end
				
				/////////////////////////////////////////////////////////
				////  Add Message to End of List
				/////////////////////////////////////////////////////////

				S_ADD_MSG: begin  // Wait constraint on consective ZBT ops
					state <= state + 1;  // S_ADD_MSG_1
					ZBT_op_reg <= OP_IDLE;
				end
				S_ADD_MSG_1: begin
					if (ZBT_ready) begin
						ZBT_op_reg <= OP_WRITE;
						ZBT_addr_reg <= {2'b00, msg_pos, 2'b00};
						ZBT_bwe_reg <= 4'b1111;
						if (S_ADD_MSG_unread) begin  // writing
							if (unread_exist) begin  
								ZBT_din_reg <= {unread_end, 3'b000, unread_start, 3'b000};
								state <= state + 1;  // S_ADD_MSG_2
							end
							else begin
								ZBT_din_reg <= {msg_pos, 3'b000, msg_pos, 3'b000};
								unread_start <= msg_pos;
								unread_end <= msg_pos;
								unread_exist <= 1;
								state <= S_WRING;
								sts_reg <= STS_WRING;
								wr_en_override <= 1;
								CF_Interface_op <= CF_OP_WR_EN;
							end
						end
						else begin  // saving
							if (saved_exist) begin
								ZBT_din_reg <= {saved_end, 3'b000, saved_start, 3'b000};
								state <= state + 1;  // S_ADD_MSG_2
							end
							else begin
								ZBT_din_reg <= {msg_pos, 3'b000, msg_pos, 3'b000};
								saved_start <= msg_pos;
								saved_end <= msg_pos;
								saved_exist <= 1;
								state <= S_UPDT_MSG_POS_DATA;
								msg_pos <= msg_pos_prev;
							end
						end
					end
				end
				S_ADD_MSG_2: begin  // Wait constraint on consective ZBT ops
					state <= state + 1;  // S_ADD_MSG_3
					ZBT_op_reg <= OP_IDLE;
				end
				S_ADD_MSG_3: begin  // Set start's parent to message
					if (ZBT_ready) begin
						ZBT_op_reg <= OP_WRITE;
						ZBT_bwe_reg <= 4'b1100;
						ZBT_din_reg <= {msg_pos, 21'h000000};
						state <= state + 1;  // S_ADD_MSG_4
						if (S_ADD_MSG_unread)
							ZBT_addr_reg <= {2'b00, unread_start, 2'b00};
						else
							ZBT_addr_reg <= {2'b00, saved_start, 2'b00};
					end
				end
				S_ADD_MSG_4: begin  // Wait constraint on consective ZBT ops
					state <= state + 1;  // S_ADD_MSG_5
					ZBT_op_reg <= OP_IDLE;
				end
				S_ADD_MSG_5: begin  // Set end's child to message
					if (ZBT_ready) begin
						ZBT_op_reg <= OP_WRITE;
						ZBT_bwe_reg <= 4'b0011;
						ZBT_din_reg <= {18'h00000, msg_pos, 3'b000}; 
						if (S_ADD_MSG_unread) begin
							ZBT_addr_reg <= {2'b00, unread_end, 2'b00};
							unread_end <= msg_pos;
							state <= S_WRING;
							sts_reg <= STS_WRING;
							wr_en_override <= 1;
							CF_Interface_op <= CF_OP_WR_EN;
						end
						else begin
							ZBT_addr_reg <= {2'b00, saved_end, 2'b00};
							saved_end <= msg_pos;
							state <= S_UPDT_MSG_POS_DATA;
							msg_pos <= msg_pos_prev;
						end
					end
				end
				
				/////////////////////////////////////////////////////////
				////  Update Message Position Data
				/////////////////////////////////////////////////////////

				S_UPDT_MSG_POS_DATA: begin // Wait constraint on consective ZBT ops
					state <= state + 1; // S_UPDT_MSG_POS_DATA_1
					ZBT_op_reg <= OP_IDLE;
				end
				S_UPDT_MSG_POS_DATA_1: begin
					if (ZBT_ready) begin
						ZBT_addr_reg <= {2'b00, msg_pos, 2'b00};  // Read Parent (Prev) & Child (Next)
						ZBT_op_reg <= OP_READ;
						state <= state + 1;  // S_UPDT_MSG_POS_DATA_2
					end
				end
				S_UPDT_MSG_POS_DATA_2: begin // Wait constraint on consective ZBT ops
					state <= state + 1; // S_UPDT_MSG_POS_DATA_3
					ZBT_op_reg <= OP_IDLE;
				end
				S_UPDT_MSG_POS_DATA_3: begin
					ZBT_addr_reg <= {2'b00, msg_pos, 2'b01};  // Read Sample Count & Phone number
					ZBT_op_reg <= OP_READ;
					state <= state + 1;  // S_UPDT_MSG_POS_DATA_4
				end
				S_UPDT_MSG_POS_DATA_4: begin // Wait constraint on consective ZBT ops
					state <= state + 1; // S_UPDT_MSG_POS_DATA_5
					ZBT_op_reg <= OP_IDLE;
				end
				S_UPDT_MSG_POS_DATA_5: begin
					ZBT_addr_reg <= {2'b00, msg_pos, 2'b10};  // Read Date & Time
					ZBT_op_reg <= OP_READ;
					state <= state + 1;  // S_UPDT_MSG_POS_DATA_6
				end				
				S_UPDT_MSG_POS_DATA_6: begin
					ZBT_op_reg <= OP_IDLE;
					msg_pos_prev <= ZBT_dout[35:21];
					msg_pos_next <= ZBT_dout[17:3];
					state <= state + 1;  // S_UPDT_MSG_POS_DATA_7
				end
				S_UPDT_MSG_POS_DATA_7: begin
					state <= state + 1;  // S_UPDT_MSG_POS_DATA_8
				end
				S_UPDT_MSG_POS_DATA_8: begin
					msg_pos_sample_cnt <= ZBT_dout[35:14];
					msg_pos_phn_num <= ZBT_dout[8:1];
					state <= state + 1;  // S_UPDT_MSG_POS_DATA_9
				end
				S_UPDT_MSG_POS_DATA_9: begin
					state <= state + 1;  // S_UPDT_MSG_POS_DATA_10
				end
				S_UPDT_MSG_POS_DATA_10: begin
					msg_pos_DT <= ZBT_dout[35:3];
					sts_reg <= STS_CMD_RDY;
					state <= S_IDLE;
					disp_req <= 1;
				end
			endcase
		end
	end

	// Manage commands to CF Interface as needed
	reg [12:0] cur_LBA;
	wire [7:0] in_SC, out_SC;
	wire [1:0] out_SC_low;
	assign in_SC = (in_data_cnt[10]) ? 8'd4: {6'd0, in_data_cnt[9:8]};
	assign out_SC_low = 2'd3 - out_data_cnt[9:8];
	assign out_SC = (out_data_cnt[10]) ? 8'd0: {6'd0, out_SC_low};
	always @(posedge clk_27mhz) begin
		if (reset) begin
			CF_cmd_reg <= CF_CMD_IDLE;
			CF_LBA_reg <= 0;
			CF_SC_reg <= 0;
			cur_LBA <= 0;
		end
		else begin
			case (CF_Interface_op)
				CF_OP_WR_EN: begin
					if (CF_ready && in_SC) begin
						CF_cmd_reg <= CF_CMD_WRITE;
						CF_LBA_reg <= {msg_pos, cur_LBA};
						CF_SC_reg <= in_SC;
						cur_LBA <= (cur_LBA + CF_SC_reg); 
					end
					else
						CF_cmd_reg <= CF_CMD_IDLE;
				end
				CF_OP_RD_EN: begin
					if (CF_ready && out_SC) begin
						CF_cmd_reg <= CF_CMD_READ;
						CF_LBA_reg <= {msg_pos, cur_LBA};
						CF_SC_reg <= out_SC;
						cur_LBA <= (cur_LBA + CF_SC_reg);
					end
					else
						CF_cmd_reg <= CF_CMD_IDLE;
				end
				CF_OP_WR_FORCE: begin
					if (CF_ready  && in_data_cnt) begin
						CF_cmd_reg <= CF_CMD_WRITE;
						CF_LBA_reg <= {msg_pos, cur_LBA};
						CF_SC_reg <= 1;
					end
					else
						CF_cmd_reg <= CF_CMD_IDLE;
				end
				CF_OP_DETECT: begin
					if (CF_ready)
						CF_cmd_reg <= CF_CMD_DETECT;
				end
				default: begin // CD_OP_IDLE
					CF_cmd_reg <= CF_CMD_IDLE;
					cur_LBA <= 0;
					CF_SC_reg <= 0;
				end
				
			endcase
		end
	end
	
	// Instantiate ASCII state
	reg [4:0] ascii_state;
	
	// Declare ASCII state parameters
	parameter S_ASCII_IDLE         = 5'h00;
	parameter S_ASCII_DISP         = 5'h01;
	parameter S_ASCII_DISP_1       = 5'h02;
	parameter S_ASCII_DISP_2       = 5'h03;
	parameter S_ASCII_DISP_3       = 5'h04;
	parameter S_ASCII_DISP_4       = 5'h05;
	parameter S_ASCII_DISP_5       = 5'h06;
	parameter S_ASCII_DISP_6       = 5'h07;
	parameter S_ASCII_DISP_7       = 5'h08;
	parameter S_ASCII_DISP_8       = 5'h09;
	parameter S_ASCII_DISP_9       = 5'h0A;
	parameter S_ASCII_DISP_10      = 5'h0B;
	parameter S_ASCII_DISP_11      = 5'h0C;
	parameter S_ASCII_DISP_12      = 5'h0D;
	parameter S_ASCII_DISP_13      = 5'h0E;
	parameter S_ASCII_DISP_14      = 5'h0F;
	parameter S_ASCII_DISP_15      = 5'h10;
	parameter S_ASCII_DISP_16      = 5'h11;
	parameter S_ASCII_DISP_17      = 5'h12;
	parameter S_ASCII_DISP_18      = 5'h13;
	parameter S_ASCII_DISP_19      = 5'h14;
	parameter S_ASCII_DISP_20      = 5'h15;
	parameter S_ASCII_DISP_EMPTY   = 5'h16;
	parameter S_ASCII_DISP_EMPTY_1 = 5'h17;
	parameter S_ASCII_DISP_EMPTY_2 = 5'h18;
	parameter S_ASCII_DISP_EMPTY_3 = 5'h19;
	

	// Instantiate ASCII registers
	reg [7:0] ascii_out_reg;
	reg ascii_out_ready_reg;
	reg [6:0] addr_reg;
	
	// Assign ASCII registers
	assign ascii_out = ascii_out_reg;
	assign ascii_out_ready = ascii_out_ready_reg;
	assign addr = addr_reg;
	
	// Instantiate capture registers
	reg [25:0] DT_capture;
	reg [7:0] phn_num_capture;
	reg [3:0] phn_num_minus_nine;
	reg empty_capture;
	
	// Queue display requests as needed
	reg q_disp_req, l_disp_req;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			l_disp_req <= 0;
		end
		else if (disp_req) begin  // latch if high
			l_disp_req <= 1;
		end
		else if (ascii_state == S_ASCII_IDLE) begin
			l_disp_req <= 0;
		end
	end
	always @(posedge clk_27mhz) begin
		if (reset) begin
			q_disp_req <= 0;
		end
		else if (l_disp_req & (ascii_state == S_ASCII_IDLE)) begin
			q_disp_req <= 1;
		end
		else begin
			q_disp_req <= 0;
		end
	end
	
	// Manage ASCII output when display requested or enabled
	always @(posedge clk_27mhz) begin
		if (reset) begin
			ascii_state <= 0;  // S_ASCII_IDLE
			ascii_out_reg <= 0;
			ascii_out_ready_reg <= 0;
			addr_reg <= 0;
			DT_capture <= 0;
			phn_num_capture <= 0;
			empty_capture <= 0;
		end
		else begin
			case (ascii_state)
				S_ASCII_IDLE: begin
					ascii_out_reg <= 0;
					ascii_out_ready_reg <= 0;
					addr_reg <= msg_pos_DT[32:26];
					if (disp_en & q_disp_req) begin
						ascii_state <= ascii_state + 1;  // S_ASCII_DISP
						DT_capture <= msg_pos_DT[25:0];
						phn_num_capture <= msg_pos_phn_num;
						empty_capture <= ((~unread_exist & ~cur_view)|(~saved_exist & cur_view));
					end
				end
				S_ASCII_DISP: begin
					if (empty_capture)  // Test if empty
						ascii_state <= S_ASCII_DISP_EMPTY;  
					else
						ascii_state <= ascii_state + 1;  // S_ASCII_DISP_1
				end
				S_ASCII_DISP_1: begin
					addr_reg <= {3'b000, DT_capture[25:22]};
					ascii_out_reg <= {4'b0011, data[7:4]};  // year, first digit
					ascii_out_ready_reg <= 1;
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_2
				end
				S_ASCII_DISP_2: begin
					ascii_out_reg <= {4'b0011, data[3:0]};  // year, second digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_3
				end
				S_ASCII_DISP_3: begin
					ascii_out_reg <= 8'h2F;  // forward slash
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_4
				end
				S_ASCII_DISP_4: begin
					addr_reg <= {2'b00, DT_capture[21:17]};
					ascii_out_reg <= {4'b0011, data[7:4]};  // month, first digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_5
				end
				S_ASCII_DISP_5: begin
					ascii_out_reg <= {4'b0011, data[3:0]};  // month, second digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_6
				end
				S_ASCII_DISP_6: begin
					ascii_out_reg <= 8'h2F;  // forward slash
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_7
				end
				S_ASCII_DISP_7: begin
					addr_reg <= {2'b00, DT_capture[16:12]};
					ascii_out_reg <= {4'b0011, data[7:4]};  // day, first digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_8
				end
				S_ASCII_DISP_8: begin
					ascii_out_reg <= {4'b0011, data[3:0]};  // day, second digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_9
				end
				S_ASCII_DISP_9: begin
					ascii_out_reg <= 8'h20;  // space
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_10					
				end
				S_ASCII_DISP_10: begin
					addr_reg <= {1'b0, DT_capture[11:6]};
					ascii_out_reg <= {4'b0011, data[7:4]};  // hour, first digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_11
				end
				S_ASCII_DISP_11: begin
					ascii_out_reg <= {4'b0011, data[3:0]};  // hour, second digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_12
				end
				S_ASCII_DISP_12: begin
					ascii_out_reg <= 8'h3A;  // colon
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_13
				end
				S_ASCII_DISP_13: begin
					addr_reg <= {1'b0, DT_capture[5:0]};
					ascii_out_reg <= {4'b0011, data[7:4]};  // minute, first digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_14
				end
				S_ASCII_DISP_14: begin
					ascii_out_reg <= {4'b0011, data[3:0]};  // minute, second digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_15
				end
				S_ASCII_DISP_15: begin
					ascii_out_reg <= 8'h3A;  // colon
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_16					
				end
				S_ASCII_DISP_16: begin
					ascii_out_reg <= {4'b0011, data[7:4]};  // second, first digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_17
				end
				S_ASCII_DISP_17: begin
					ascii_out_reg <= {4'b0011, data[3:0]};  // second, second digit
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_18
				end
				S_ASCII_DISP_18: begin
					ascii_out_reg <= 8'h20;  // space
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_19
					phn_num_minus_nine <= phn_num_capture[7:4] - 4'd9;
				end
				S_ASCII_DISP_19: begin
					ascii_out_reg <= (phn_num_capture[7:4] < 4'd10) ? {4'b0011, phn_num_capture[7:4]}: {4'b0100, phn_num_minus_nine};
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_20
					phn_num_minus_nine <= phn_num_capture[3:0] - 4'd9;
				end
				S_ASCII_DISP_20: begin
					ascii_out_reg <= (phn_num_capture[3:0] < 4'd10) ? {4'b0011, phn_num_capture[3:0]}: {4'b0100, phn_num_minus_nine};
					ascii_state <= S_ASCII_IDLE;
				end
				S_ASCII_DISP_EMPTY: begin  // Display "None" since empty
					ascii_out_reg <= 8'h4E; // N
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_EMPTY_1
					ascii_out_ready_reg <= 1;
				end
				S_ASCII_DISP_EMPTY_1: begin
					ascii_out_reg <= 8'h6F; // o
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_EMPTY_2
				end
				S_ASCII_DISP_EMPTY_2: begin
					ascii_out_reg <= 8'h6E; // n
					ascii_state <= ascii_state + 1;  // S_ASCII_DISP_EMPTY_3
				end
				S_ASCII_DISP_EMPTY_3: begin
					ascii_out_reg <= 8'h65; // e
					ascii_state <= S_ASCII_IDLE;
				end				
			endcase
		end
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////
//// Mid-Level Interface Module
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Provide a mid-level interface for making reads and writes to Compact Flash.
// READING:
//     o On read request, provide read command, LBA, and sector count (SC).
//     o Sends back data in 16-bit words as it arrives with nd (new data) signal.
// WRITING:
//     o On write request, provide write command, LBA, and sector count (SC).
//     o Sends back we_req for requesting write data to be sent.
//     o Write data must be sent during the SAME clock cycle we_req is asserted.
//     o Use FWFT on any external FIFOs for 0 latency reads from the FIFOs.
// STATUS:
//     o Tells if Compact Flash device is present. Manual CF Detect commands
//        needed in idle state. Done automatically when needed for R/W.
//     o If CF device is present, gives number of LBAs on device.
//     o Provides signal indicating whether system is ready for command.
// COMMANDS:
//     o CMD_IDLE:   2'b00
//     o CMD_DETECT: 2'b01
//     o CMD_READ:   2'b10
//     o CMD_WRITE:  2'b11
// SPECIAL NOTES:
//     o SC value of 0 corresponds to 256.
//     o Ready signal is asserted cycle BEFORE data can be issued.
//     o Ensure successive commands have at least one cycle between them.
//////////////////////////////////////////////////////////////////////////////////

module CF_Interface #(
	parameter CMD_RDY_TO_PD = 1620000,  // SystemACE Command Ready Timeout Period
	parameter BFR_RDY_TO_PD = 1620000   // SystemACE Buffer Ready Timeout Period
	)(
	input clk_27mhz,        // 27 MHz clock
	input reset,            // Synchronous reset
	// Mid-level I/O
	input [1:0] cmd,        // Command to be performed
	input [27:0] LBA,       // Logical Block Address for r/w
	input [7:0] SC,         // Sector Count
	input [15:0] din,       // Data input for writes
	output we_req,          // Request for write data
	output [15:0] dout,     // Data output for reads
	output nd,              // New Data available at output
	output CF_detect,       // Detect if CF device is connected
	output [27:0] LBA_max,  // Maximum number of LBAs if CF detected
	output ready,           // Command ready signal
	// SystemACE ports
	inout [15:0] systemace_data,     // SystemACE R/W data
	output [6:0] systemace_address,  // SystemACE R/W address
	output systemace_ce_b,           // SystemACE chip enable (Active Low)
	output systemace_we_b,           // SystemACE write enable (Active Low)
	output systemace_oe_b,           // SystemACE output enable (Active Low)
	input systemace_mpbrdy           // SystemACE MPU buffer ready
	);
	
	// Instantiate Low-Level I/O for basic R/W to SystemACE MPU
	wire [15:0] rw_din, rw_dout;
	wire [5:0] addr;
	wire [6:0] addr_large;
	wire re, we, rw_nd, rw_ready;
	assign addr_large = {addr, 1'b0};
	RW_Interface RW_INTERFACE_1(
		.clk_27mhz(clk_27mhz),
		.reset(reset),
		// RW ports
		.addr(addr_large),
		.din(rw_din),
		.we(we),
		.re(re),
		.dout(rw_dout),
		.nd(rw_nd),
		.ready(rw_ready),
		// SystemACE ports
		.systemace_data(systemace_data),
		.systemace_address(systemace_address),
		.systemace_ce_b(systemace_ce_b),
		.systemace_we_b(systemace_we_b),
		.systemace_oe_b(systemace_oe_b)
	);
	
	// Declare command parameters
	parameter CMD_IDLE   = 2'b00;
	parameter CMD_DETECT = 2'b01;
	parameter CMD_READ   = 2'b10;
	parameter CMD_WRITE  = 2'b11;
	
	// Instantiate state
	reg [5:0] state;
	
	// Declare state parameters
	parameter S_SET_WORD_MODE    = 6'h00;
	parameter S_SET_WORD_MODE_1  = 6'h01;
	parameter S_FORCE_LOCK       = 6'h02;
	parameter S_FORCE_LOCK_1     = 6'h03;
	parameter S_CHK_LOCK         = 6'h04;
	parameter S_CHK_LOCK_1       = 6'h05;
	parameter S_IDLE             = 6'h06;
	parameter S_CHK_RDY          = 6'h07;
	parameter S_CHK_RDY_1        = 6'h08;
	parameter S_CHK_RDY_2        = 6'h09;
	parameter S_SET_LBA          = 6'h0A;
	parameter S_SET_LBA_1        = 6'h0B;
	parameter S_SET_LBA_2        = 6'h0C;
	parameter S_SET_LBA_3        = 6'h0D;
	parameter S_SET_SC_CMD       = 6'h0E;
	parameter S_SET_SC_CMD_1     = 6'h0F;
	parameter S_RESET_CFG        = 6'h10;
	parameter S_RESET_CFG_1      = 6'h11;
	parameter S_INIT_BFR_CNT     = 6'h12;
	parameter S_CHK_BFR_RDY      = 6'h13;
	parameter S_CHK_BFR_RDY_1    = 6'h14;
	parameter S_CHK_BFR_RDY_2    = 6'h15;
	parameter S_CHK_BFR_RDY_3    = 6'h16;
	parameter S_INIT_DATA_CNT    = 6'h17;
	parameter S_WR_BFR           = 6'h18;
	parameter S_WR_BFR_1         = 6'h19;
	parameter S_RD_BFR           = 6'h1A;
	parameter S_RD_BFR_1         = 6'h1B;
	parameter S_RD_BFR_2         = 6'h1C;
	parameter S_CLR_RESET_CFG    = 6'h1D;
	parameter S_CLR_RESET_CFG_1  = 6'h1E;
	parameter S_ABORT_CMD        = 6'h1F;
	parameter S_ABORT_CMD_1      = 6'h20;
	parameter S_ABORT_CMD_2      = 6'h21;
	parameter S_ABORT_CMD_3      = 6'h22;
	parameter S_CF_DETECT        = 6'h23;
	parameter S_CF_DETECT_1      = 6'h24;
	parameter S_CF_DETECT_FAIL   = 6'h25;
	parameter S_CF_DETECT_FAIL_1 = 6'h26;
	
	// Instantiate RW Interface input registers
	reg [5:0] addr_reg;
	reg [15:0] rw_din_reg;
	reg re_reg, we_reg;
	
	// Assign RW Interface inputs
	assign addr = addr_reg;
	assign rw_din = rw_din_reg;
	assign we = we_reg;
	assign re = re_reg;
	
	// Instantiate Mid-Level output registers
	reg we_req_reg;
	reg nd_reg;
	reg CF_detect_reg;
	reg [27:0] LBA_max_reg;
	reg ready_reg;

	// Assign Mid-Level outputs
	assign we_req = we_req_reg;
	assign dout = rw_dout;
	assign nd = nd_reg;
	assign CF_detect = CF_detect_reg;
	assign LBA_max = LBA_max_reg;
	assign ready = ready_reg;
	
	// Instantiate return states for function calls
	reg [5:0] rtn_state_CF_detect;
	
	// Instantiate op register for passing function parameters
	reg [1:0] op_reg;
	
	// Declare op parameters
	parameter OP_IDENTIFY = 2'h0;
	parameter OP_READ     = 2'h1;
	parameter OP_WRITE    = 2'h2;
	
	// Instantiate registers for storing Mid-Level input
	reg [27:0] LBA_reg;
	reg [7:0] SC_reg;
	
	// Instantiate internal registers
	reg nd_raw_reg;
	reg [3:0] data_cnt;
	reg [11:0] bfr_cnt;
	reg [20:0] timeout_cntr;  // Ensure enough bits for TO_PD parameters
	
	// Manage state transitions
	always @(posedge clk_27mhz) begin
		if (reset) begin
			// RW Interface Inputs
			addr_reg <= 0;
			rw_din_reg <= 0;
			we_reg <= 0;
			re_reg <= 0;
			// Mid-Level outputs
			we_req_reg <= 0;
			nd_reg <= 0;
			CF_detect_reg <= 0;
			LBA_max_reg <= 0;
			ready_reg <= 0;
			// Mid-Level inputs
			LBA_reg <= 0;
			SC_reg <= 0;
			// Internal regsiters
			nd_raw_reg <= 0;
			data_cnt <= 0;
			bfr_cnt <= 0;
			timeout_cntr <= 0;
			// Set state to enter after reset
			state <= 0; // S_SET_WORD_MODE
			rtn_state_CF_detect <= S_CF_DETECT_FAIL;
		end
		else
			case (state)
				S_SET_WORD_MODE: begin  // Set Bus Mode to WORD MODE
					if (rw_ready) begin
						addr_reg <= 6'h00;  // Write BUSMODEREG[7:0]
						rw_din_reg <= 16'h0001;
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_SET_WORD_MODE_1
					end
				end
				S_SET_WORD_MODE_1: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_FORCE_LOCK
				end
				S_FORCE_LOCK: begin  // Force lock on CompactFlash resource
					if (rw_ready) begin
						addr_reg <= 6'h0C;  // Write CONTROLREG[15:0]
						rw_din_reg <= 16'h0003;
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_FORCE_LOCK_1
					end
				end
				S_FORCE_LOCK_1: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_CHK_LOCK				
				end
				S_CHK_LOCK: begin  // Check if lock has been acquired
					if (rw_ready) begin
						addr_reg <= 6'h02;  // Read STATUSREG[15:0]
						re_reg <= 1;
						we_reg <= 0;
						state <= state + 1;  // S_CHK_LOCK_1
					end
				end
				S_CHK_LOCK_1: begin
					re_reg <= 0;
					we_reg <= 0;					
					if (rw_nd) begin
						if (rw_dout[1]) begin
							state <= S_CF_DETECT_FAIL;
						end
						else
							state <= state - 1; // S_CHK_LOCK
					end
				end
				S_IDLE: begin
					case (cmd)
						CMD_IDLE: ready_reg <= 1;
						CMD_DETECT: begin
							ready_reg <= 0;
							rtn_state_CF_detect <= state;  // S_IDLE
							state <= S_CF_DETECT;
						end
						CMD_READ: begin
							ready_reg <= 0;
							LBA_reg <= LBA;
							SC_reg <= SC;
							op_reg <= OP_READ;
							state <= state + 1;  // S_CHK_RDY
						end
						CMD_WRITE: begin
							ready_reg <= 0;
							LBA_reg <= LBA;
							SC_reg <= SC;
							op_reg <= OP_WRITE;
							state <= state + 1;  // S_CHK_RDY
						end
						// No default needed
					endcase
				end
				
				/////////////////////////////////////////////////////////
				////  R/W & Identify 
				/////////////////////////////////////////////////////////
				
				S_CHK_RDY: begin  // Check if the SystemACE controller is ready
					timeout_cntr <= CMD_RDY_TO_PD;
					state <= state + 1;  // S_CHK_RDY_1
				end
				S_CHK_RDY_1: begin
					if (rw_ready) begin
						addr_reg <= 6'h02;  // Read STATUSREG[15:0]
						re_reg <= 1;
						we_reg <= 0;
						state <= state + 1;  // S_CHK_RDY_2
					end				
				end
				S_CHK_RDY_2: begin
					re_reg <= 0;
					we_reg <= 0;
					timeout_cntr <= timeout_cntr - 1;
					if (!timeout_cntr) begin
						rtn_state_CF_detect <= state - 2;  // S_CHK_RDY
						state <= S_ABORT_CMD;
					end
					else if (rw_nd) begin
						if (rw_dout[8]) begin
							state <= state + 1;  // S_SET_LBA
						end
						else begin
							state <= state - 1;  // S_CHK_RDY_1
						end
					end
				end
				S_SET_LBA: begin  // Set Logical Block Address
					if (rw_ready) begin
						addr_reg <= 6'h08;  // Write MPULBAREG[15:0]
						rw_din_reg <= (op_reg == OP_IDENTIFY) ? 16'h0000: LBA_reg[15:0];
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_SET_LBA_1
					end					
				end
				S_SET_LBA_1: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_SET_LBA_2					
				end
				S_SET_LBA_2: begin
					if (rw_ready) begin
						addr_reg <= 6'h09;  // Write MPULBAREG[31:16]
						rw_din_reg <= (op_reg == OP_IDENTIFY) ? 16'h0000: {4'h0, LBA_reg[27:16]};
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_SET_LBA_3
					end					
				end
				S_SET_LBA_3: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_SET_SC_CMD					
				end
				S_SET_SC_CMD: begin  // Set sector count & command
					if (rw_ready) begin
						addr_reg <= 6'h0A;  // Write SECCNTCMDREG[15:0]
						case (op_reg)
							OP_IDENTIFY: rw_din_reg <= 16'h0201;
							OP_READ: rw_din_reg <= {8'h03, SC_reg};
							OP_WRITE: rw_din_reg <= {8'h04, SC_reg};
							default: rw_din_reg <= 16'h0001;  // if unused, do nothing
						endcase
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_SET_SC_CMD_1
					end						
				end
				S_SET_SC_CMD_1: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_RESET_CFG	
				end				
				S_RESET_CFG: begin  // Reset the Configuration/CompactFlash Controllers
					if (rw_ready) begin
						addr_reg <= 6'h0C;  // Write CONTROLREG[31:16]
						rw_din_reg <= 16'h0083;
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_RESET_CFG_1
					end						
				end
				S_RESET_CFG_1: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;	// S_INIT_BFR_CNT				
				end
				S_INIT_BFR_CNT: begin  // Initialize the buffer count
					bfr_cnt <= (op_reg == OP_IDENTIFY) ? 12'h010: {SC_reg, 4'h0};
					state <= state + 1;  // S_CHK_BFR_RDY
				end
				S_CHK_BFR_RDY: begin
					timeout_cntr <= BFR_RDY_TO_PD;
					state <= state + 1;  // S_CHK_BFR_RDY_1
				end
				S_CHK_BFR_RDY_1: begin  // takes times for buffer ready signal to set
					state <= state + 1;  // S_CHK_BFR_RDY_2
				end
				S_CHK_BFR_RDY_2: begin
					state <= state + 1;  // S_CHK_BFR_RDY_3
				end
				S_CHK_BFR_RDY_3: begin
					timeout_cntr <= timeout_cntr - 21'd1;
					if (systemace_mpbrdy)
						state <= state + 1;  // S_INIT_DATA_CNT;
					else if (!timeout_cntr) begin
						rtn_state_CF_detect <= state - 3;  // S_CHK_BFR_RDY 
						state <= S_ABORT_CMD;
					end
				end
				S_INIT_DATA_CNT: begin  // Initialize data count
					data_cnt <= 4'hF;  // one less than real data count
					if (op_reg == OP_WRITE) begin
						state <= S_WR_BFR;
						we_req_reg <= 1;
					end
					else begin
						addr_reg <= 6'h20;  // Read DATABUFREG[15:0]
						re_reg <= 1;
						we_reg <= 0;
						state <= S_RD_BFR;
						nd_raw_reg <= 0;
						nd_reg <= 0;
					end
				end
				S_WR_BFR: begin  // Write data word to buffer
					// Assume rw_ready
					addr_reg <= 6'h20;  // Write DATABUFREG[15:0]
					rw_din_reg <= din;
					re_reg <= 0;
					we_reg <= 1;
					state <= state + 1;  // S_WR_BFR_1	
					we_req_reg <= 0;
				end
				S_WR_BFR_1: begin  
					data_cnt <= data_cnt - 1;
					re_reg <= 0;
					we_reg <= 0;
					if (!data_cnt) begin
						bfr_cnt <= bfr_cnt - 1;
						if (bfr_cnt == 1)
							state <= S_CLR_RESET_CFG;
						else
							state <= S_CHK_BFR_RDY;
					end
					else begin
						state <= state - 1;  // S_WR_BFR
						we_req_reg <= 1;
					end
				end
				S_RD_BFR: begin  // Read data word from buffer, set LBA_max if identifying
					re_reg <= 0;
					we_reg <= 0;
					nd_raw_reg <= 0;
					nd_reg <= 0;
					if (nd_raw_reg) data_cnt <= data_cnt - 1;
					if ((op_reg == OP_IDENTIFY) & nd_raw_reg & (bfr_cnt == 13)) begin
						if (data_cnt == 3) // Word 60
							LBA_max_reg <= {12'h000, rw_dout};
						if (data_cnt == 2) // Word 61
							LBA_max_reg <= {rw_dout[11:0], LBA_max_reg[15:0]};
					end
					if (nd_raw_reg & !data_cnt) begin
						bfr_cnt <= bfr_cnt - 1;
						if (bfr_cnt == 1)
							state <= S_CLR_RESET_CFG;
						else
							state <= S_CHK_BFR_RDY;
					end
					else
						state <= state + 1;  // S_RD_BFR_1
				end
				S_RD_BFR_1: begin
					state <= state + 1;  // S_RD_BFR_2				
				end
				S_RD_BFR_2: begin
					// Assume rw_ready
					addr_reg <= 6'h20;  // Read DATABUFREG[15:0]
					re_reg <= 1;
					we_reg <= 0;
					state <= state - 2; // S_RD_BFR_1
					nd_raw_reg <= 1;
					nd_reg <= (op_reg == OP_READ);
				end
				S_CLR_RESET_CFG: begin  // Clear Configuration/CompactFlash controller reset
					if (rw_ready) begin
						addr_reg <= 6'h0C;  // Write CONTROLREG[31:16]
						rw_din_reg <= 16'h0003;
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_RESET_CFG_1
					end
				end
				S_CLR_RESET_CFG_1: begin  // Exit subroutine, return to S_IDLE
					re_reg <= 0;
					we_reg <= 0;
					state <= S_IDLE;
					ready_reg <= 1;
					CF_detect_reg <= 1;
				end				
				
				/////////////////////////////////////////////////////////
				////  Error Handling 
				/////////////////////////////////////////////////////////
				
				S_ABORT_CMD: begin  // Abort current command
					if (rw_ready) begin
						addr_reg <= 6'h0A;  // Write SECCNTCMDREG[15:0]
						rw_din_reg <= 16'h0601;
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_ABORT_CMD_1
					end					
				end
				S_ABORT_CMD_1: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_ABORT_CMD_2				
				end
				S_ABORT_CMD_2: begin  // Clear command bits
					if (rw_ready) begin
						addr_reg <= 6'h0A;  // Write SECCNTCMDREG[15:0]
						rw_din_reg <= 16'h0001;
						re_reg <= 0;
						we_reg <= 1;
						state <= state + 1;  // S_ABORT_CMD_3
					end					
				end
				S_ABORT_CMD_3: begin
					re_reg <= 0;
					we_reg <= 0;
					state <= state + 1;  // S_CF_DETECT
				end
				S_CF_DETECT: begin  // Detect the presence of CF Device
					if (rw_ready) begin
						addr_reg <= 6'h02;  // Read STATUSREG[15:0]
						re_reg <= 1;
						we_reg <= 0;
						state <= state + 1;  // S_CF_DETECT_1
					end
				end
				S_CF_DETECT_1: begin
					re_reg <= 0;
					we_reg <= 0;					
					if (rw_nd) begin
						if (rw_dout[4])
							state <= rtn_state_CF_detect;
						else begin
							state <= state + 1;  // S_CF_DETECT_FAIL
							CF_detect_reg <= 0;
							LBA_max_reg <= 0;
							ready_reg <= 0;
						end
					end
				end
				S_CF_DETECT_FAIL: begin  // CF Device not detected, wait until then		
					if (rw_ready) begin
						addr_reg <= 6'h02;  // Read STATUSREG[15:0]
						re_reg <= 1;
						we_reg <= 0;
						state <= state + 1;  // S_CF_DETECT_FAIL_1
					end
				end
				S_CF_DETECT_FAIL_1: begin
					re_reg <= 0;
					we_reg <= 0;					
					if (rw_nd) begin
						if (rw_dout[4]) begin
							op_reg <= OP_IDENTIFY;
							state <= S_CHK_RDY;
						end
						else begin
							state <= S_FORCE_LOCK;  // S_FORCE_LOCK;
							CF_detect_reg <= 0;
							LBA_max_reg <= 0;
							ready_reg <= 0;
						end
					end					
				end
			endcase
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////
////  Low-Level Interface Modules
//////////////////////////////////////////////////////////////////////////////////

// Provides low-level interface for making reads and writes to MPU Interface.
// Ensures signal timing constraints are met.
// Ready signal is asserted one cycle BEFORE r/w request can be sent.
// MUST have at least one clock of no r/w requests between successive r/w requests.
module RW_Interface(
	input clk_27mhz,      // 27MHz clock
	input reset,          // Synchronous reset
	// Low-Level I/O
	input [6:0] addr,     // Address signal for r/w
	input [15:0] din,     // Data input for writes
	input we,             // Write enable
	input re,             // Read enable
	output [15:0] dout,   // Data output for reads
	output nd,            // New data available at output
	output ready,         // Command ready signal
	// SystemACE ports
	inout [15:0] systemace_data,     // SystemACE R/W data
	output [6:0] systemace_address,  // SystemACE R/W address
	output systemace_ce_b,           // SystemACE chip enable (Active Low)
	output systemace_we_b,           // SystemACE write enable (Active Low)
	output systemace_oe_b            // SystemACE output enable (Active Low)
	);
	
	// Instantiate state
	reg [1:0] state;

	// Define state parameters
	parameter S_IDLE    = 2'd0;
	parameter S_READ_1  = 2'd1;
	parameter S_READ_2  = 2'd2;
	parameter S_WRITE_1 = 2'd3; 

	
	// Instantiate SystemACE output registers
	reg [15:0] systemace_din_reg;
	reg [6:0] systemace_address_reg;
	reg systemace_ce_b_reg;
	reg systemace_we_b_reg;
	reg systemace_oe_b_reg;
	
	// Instantiate RW Interface input register
	reg [15:0] din_reg;
	
	// Instantiate RW Interface output registers
	reg ready_reg;
	
	// Assign SystemACE outputs
	assign systemace_data = systemace_din_reg;
	assign systemace_address = systemace_address_reg;
	assign systemace_ce_b = systemace_ce_b_reg;
	assign systemace_we_b = systemace_we_b_reg;
	assign systemace_oe_b = systemace_oe_b_reg;
	
	// Assign RW Interface outputs
	assign dout = systemace_data;
	assign nd = ~systemace_oe_b_reg;
	assign ready = ready_reg;
	
	// Manage state transitions
	always @(posedge clk_27mhz) begin
		if (reset) begin
			state <= S_IDLE;
			// Reset RW Interface signals
			din_reg <= 0;
			ready_reg <= 0;
			// Reset SystemACE signals
			systemace_din_reg <= 16'hZZZZ;
			systemace_address_reg <= 0;
			systemace_ce_b_reg <= 1;
			systemace_we_b_reg <= 1;
			systemace_oe_b_reg <= 1;
		end
		else begin
			case (state)
				S_IDLE: begin
					// Set definite RW Interface signals
					din_reg <= din;
					// Set definite SystemACE signals
					systemace_address_reg <= addr;
					systemace_din_reg <= 16'hZZZZ;
					systemace_we_b_reg <= 1;
					systemace_oe_b_reg <= 1;
					// Manage R/W
					if (re) begin
						state <= S_READ_1;
						ready_reg <= 0;
						systemace_ce_b_reg <= 0;
					end
					else if (we) begin
						state <= S_WRITE_1;
						ready_reg <= 1;
						systemace_ce_b_reg <= 0;
					end
					else begin
						state <= S_IDLE;
						ready_reg <= 1;
						systemace_ce_b_reg <= 1;
					end
				end
				S_READ_1: begin
					state <= S_READ_2;
					// Set changed RW Interface signals
					ready_reg <= 1;
				end
				S_READ_2: begin
					state <= S_IDLE;
					// Set changed SystemACE signals
					systemace_oe_b_reg <= 0;
				end
				S_WRITE_1: begin
					state <= S_IDLE;
					// Set changed SystemAce signals
					systemace_din_reg <= din_reg;
					systemace_we_b_reg <= 0;
				end
				// Since all state encodings used, no need for default.
			endcase
		end
	end
endmodule

// Provides low-level interface for reading to and writing from ZBT.
// Ensures timing constraints are met.
// Command ready set BEFORE a command can be sent.
// At least one clock cycle between consecutive commands.
// OPCODES:
//    o OP_IDLE:   2'b00
//    o OP_READ:   2'b01
//    o OP_WRITE:  2'b10
// SPECIAL NOTES:
//    o Partial (byte) write enable (bwe) is Active High

module ZBT_Interface(
	input clk_27mhz,      // 27MHz clock
	input reset,          // Synchronous reset
	// Low-Level I/O
	input [18:0] addr,     // Address signal for r/w
	input [35:0] din,     // Data input for writes
	input [1:0] op,       // Operation Code
	input [3:0] bwe,      // Partial (byte) writes
	output [35:0] dout,   // Data output for reads
	output nd,            // New data available at output	
	output ready,           // Command ready signal
	// ZBT ports
   inout  [35:0] ram_data,
   output [18:0] ram_address,
   output ram_we_b,
   output [3:0] ram_bwe_b	
	);
	
	// Define Operation parameters (OPCODE)
	parameter OP_IDLE = 2'b00;
	parameter OP_READ = 2'b01;
	parameter OP_WRITE = 2'b10;
	
	// Instantiate ZBT output registers
	reg [35:0] ram_data_reg;  // Tri-state Buffer
	reg [18:0] ram_address_reg;
	reg ram_we_b_reg;
	reg [3:0] ram_bwe_b_reg;
	
	// Assign ZBT outputs
	assign ram_data = ram_data_reg;
	assign ram_address = ram_address_reg;
	assign ram_we_b = ram_we_b_reg;
	assign ram_bwe_b = ram_bwe_b_reg;
	
	// Instantiate Low-Level Interface output registers
	reg [35:0] dout_reg; 
	reg nd_reg, ready_reg;
	
	// Assign Low-Level Interface output registers
	assign nd = nd_reg;
	assign dout = dout_reg;
	assign ready = ready_reg;
	
	// Instantiate internal registers
	reg nd_reg_delay, nd_reg_double_delay, nd_reg_triple_delay;
	reg [35:0] ram_data_reg_delay;
	reg ram_we_b_reg_delay;
	
	// Instantiate state
	reg [1:0] state;
	
	// Define state paramters
	parameter S_IDLE = 2'b00;
	parameter S_WR   = 2'b01;
	parameter S_WR_1 = 2'b10;
	parameter S_RD   = 2'b11;
	
	// Manage state transitions
	always @(posedge clk_27mhz) begin
		if (reset) begin
			// Set ZBT signals
			ram_data_reg <= 36'hZZZZZZZZZ;
			ram_address_reg <= 0;
			ram_we_b_reg <= 1'b1;
			ram_bwe_b_reg <= 4'hF;
			// Set Low-Level signals
			nd_reg <= 0;
			ready_reg <= 0;
			dout_reg <= 0;
			// Set internal signals
			nd_reg_delay <= 0;
			nd_reg_double_delay <= 0;
			nd_reg_triple_delay <= 0;
			ram_data_reg_delay <= 0;
			ram_we_b_reg_delay <= 1;
			// Set initial state
			state <= S_IDLE;
		end
		else begin
			ram_we_b_reg_delay <= ram_we_b_reg;
			ram_data_reg <= (ram_we_b_reg_delay) ? 36'hZZZZZZZZZ: ram_data_reg_delay;
			nd_reg_double_delay <= nd_reg_delay;
			nd_reg_triple_delay <= nd_reg_double_delay;
			nd_reg <= nd_reg_triple_delay;
			if (nd_reg_triple_delay) dout_reg <= ram_data;
			case (state)
				S_IDLE: begin
					ram_address_reg <= addr;
					ram_data_reg_delay <= din;
					case (op)
						OP_READ: begin
							ready_reg <= 1;
							state <= S_RD;
							nd_reg_delay <= 1;
						end
						OP_WRITE: begin
							ready_reg <= 0;
							state <= S_WR;
							ram_we_b_reg <= 0;
							ram_bwe_b_reg <= ~bwe;
							nd_reg_delay <= 0;
						end
						default: begin
							ready_reg <= 1;  // OP_IDLE
							nd_reg_delay <= 0;
						end
					endcase
				end
				S_WR: begin
					state <= state + 1;  // S_WR_1
					ready_reg <= 1;
				end
				S_WR_1: begin
					state <= S_IDLE;
					ram_we_b_reg <= 1;
					ram_bwe_b_reg <= 4'hF;
				end
				S_RD: begin
					state <= S_IDLE;
					nd_reg_delay <= 0;
				end
			endcase
		end
	end
endmodule
