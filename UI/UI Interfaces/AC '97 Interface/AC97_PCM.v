`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:07:52 10/31/2012 
// Design Name:    AC97-PCM Interface
// Module Name:    AC97_PCM 
// Project Name:   6.111 Final Project
// Target Devices: Xilinx XC2V6000
// Tool versions:  
// Description:    An interface between the LM4550 AC '97 Audio Codec and the 
//                 48kHz PCM data stream that: 
//                 1) Assembles PCM audio output into LM4550 sdata_out frames
//                 2) Disassembles LM4550 sdata_in frames into PCM audio input
//                 3) Manages all LM4550 control signals (including headphone 
//                    volume)
//
//                 Ready (a one-clock pulse) times I/O of the PCM stream. On the 
//                 rising edge of ready, audio input is avaiable. On the falling
//                 edge of ready, audio output is latched.
//
//                 The PCM stream bit depth is 16 and sampling rate is 8kHz.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//                 Audio input will be held for at least 128 AC97 bit clocks
//                 (around 280 27MHz clocks w/ AC97 bit clock @ 12.288MHz).
//
//////////////////////////////////////////////////////////////////////////////////
module AC97_PCM(
	input wire clock_27mhz,
	input wire reset,
	input wire [4:0] volume,
	// PCM interface signals
	output wire [15:0] audio_in_data,
	input wire [15:0] audio_out_data,
	output wire ready,
	// LM4550 interface signals
	output reg audio_reset_b,
	output wire ac97_sdata_out,
	input wire ac97_sdata_in,
	output wire ac97_synch,
	input wire ac97_bit_clock
	);

	wire [7:0] command_address;
	wire [15:0] command_data;
	wire command_valid;
	wire [19:0] left_in_data, right_in_data;
	wire [19:0] left_out_data, right_out_data;

   // Wait 1024 clock cycles before enabling the LM4550
	reg [9:0] reset_count;
	always @(posedge clock_27mhz) begin
		if (reset) begin
			audio_reset_b = 1'b0;
			reset_count = 0;
		end 
		else if (reset_count == 1023)
			audio_reset_b = 1'b1;
		else
			reset_count = reset_count+1;
	end

	// Assemble/Disassemble serial frames for LM4550
	wire ac97_ready;
	wire slot_req;    // slot request for Variable Rate Audio (VRA)
	ac97 ac97(.ready(ac97_ready),
             .command_address(command_address),
             .command_data(command_data),
             .command_valid(command_valid),
             .left_data(left_out_data), .left_valid(1'b1),
             .right_data(right_out_data), .right_valid(1'b1),
             .left_in_data(left_in_data), .right_in_data(right_in_data),
				 .slot_req(slot_req),
             .ac97_sdata_out(ac97_sdata_out),
             .ac97_sdata_in(ac97_sdata_in),
             .ac97_synch(ac97_synch),
             .ac97_bit_clock(ac97_bit_clock));

	// Generate int_ready (one-clock pulse, synchronous with clock_27mhz)
	// from ac97_ready (long pulse, synchronouse with ac97_bit_clock)
	reg [2:0] ready_sync;
	wire int_ready;
	always @ (posedge clock_27mhz) 
		ready_sync <= {ready_sync[1:0], ac97_ready};
	assign int_ready = ready_sync[1] & ~ready_sync[2];
	
	// Generate ready signal taking into account LM4550 slot requests
	assign ready = int_ready & slot_req;

	// Latch audio output on falling edge of ready
	reg [15:0] out_data;
	always @ (posedge clock_27mhz)
		if (ready) out_data <= audio_out_data;
	
	// Assign audio input (16 bits)
	assign audio_in_data = left_in_data[19:4];
	
	// Assign LM4550 L/R output data signals
	assign left_out_data = {out_data, 4'h0};
	assign right_out_data = left_out_data;

   // Generate R/W control signals for LM4550
	ac97commands cmds(.clock(clock_27mhz), .ready(int_ready),
                     .command_address(command_address),
                     .command_data(command_data),
                     .command_valid(command_valid),
                     .volume(volume),
                     .source(3'b000));     // mic
endmodule

// Assemble/Disassemble serial frames for LM4550
module ac97 (
	output reg ready,
	// Commmand signals
	input wire [7:0] command_address,
	input wire [15:0] command_data,
	input wire command_valid,
	// L/R data output signals
	input wire [19:0] left_data, right_data,
	input wire left_valid, right_valid,
	// L/R data input signals
	output reg [19:0] left_in_data, right_in_data,
	output reg slot_req,
	// LM4550 Serial Interface signals
	output reg ac97_sdata_out,
	input wire ac97_sdata_in,
	output reg ac97_synch,
	input wire ac97_bit_clock
	);
	
	// Counter for bit position in frame
	reg [7:0] bit_count;

	// Latched output signals
	reg [19:0] l_cmd_addr;
	reg [19:0] l_cmd_data;
	reg [19:0] l_left_data, l_right_data;
	reg l_cmd_v, l_left_v, l_right_v;

	initial begin
		ready <= 1'b0;
		// synthesis attribute init of ready is "0";
		ac97_sdata_out <= 1'b0;
		// synthesis attribute init of ac97_sdata_out is "0";
		ac97_synch <= 1'b0;
		// synthesis attribute init of ac97_synch is "0";

		bit_count <= 8'h00;
		// synthesis attribute init of bit_count is "0000";
		l_cmd_v <= 1'b0;
		// synthesis attribute init of l_cmd_v is "0";
		l_left_v <= 1'b0;
		// synthesis attribute init of l_left_v is "0";
		l_right_v <= 1'b0;
		// synthesis attribute init of l_right_v is "0";

		left_in_data <= 20'h00000;
		// synthesis attribute init of left_in_data is "00000";
		right_in_data <= 20'h00000;
		// synthesis attribute init of right_in_data is "00000";
		
		slot_req <= 1'b0;
		// synthesis attribute init of right_in_data is "0";
	end

	// Generate basic signals
	always @(posedge ac97_bit_clock) begin
		// Generate the sync signal
		if (bit_count == 255)
			ac97_synch <= 1'b1;
		if (bit_count == 15)
			ac97_synch <= 1'b0;

		// Generate the ready signal (synchronous with ac97_bit_clock)
		if (bit_count == 128)
			ready <= 1'b1;
		if (bit_count == 2)
			ready <= 1'b0;

		// Latch output signals at the end of each frame. This ensures that 
		// the first frame after reset will be empty.
		if (bit_count == 255) begin
			l_cmd_addr <= {command_address, 12'h000};
			l_cmd_data <= {command_data, 4'h0};
			l_cmd_v <= command_valid;
			l_left_data <= left_data;
			l_left_v <= left_valid;
			l_right_data <= right_data;
			l_right_v <= right_valid;
		end
		
		// Update bit_count
		bit_count <= bit_count+1;
	end
	
	// Generate ac97_sdata_out from latched audio output
	always @(posedge ac97_bit_clock) begin
		if ((bit_count >= 0) && (bit_count <= 15)) begin
			// Slot 0: Tags
			case (bit_count[3:0])
				4'h0: ac97_sdata_out <= 1'b1;      // Frame valid
				4'h1: ac97_sdata_out <= l_cmd_v;   // Command address valid
				4'h2: ac97_sdata_out <= l_cmd_v;   // Command data valid
				4'h3: ac97_sdata_out <= l_left_v;  // Left data valid
				4'h4: ac97_sdata_out <= l_right_v; // Right data valid
				default: ac97_sdata_out <= 1'b0;
			endcase
		end
		else if ((bit_count >= 16) && (bit_count <= 35))
			// Slot 1: Command address (8-bits, left justified)
			ac97_sdata_out <= l_cmd_v ? l_cmd_addr[35-bit_count] : 1'b0;
		else if ((bit_count >= 36) && (bit_count <= 55))
			// Slot 2: Command data (16-bits, left justified)
			ac97_sdata_out <= l_cmd_v ? l_cmd_data[55-bit_count] : 1'b0;
		else if ((bit_count >= 56) && (bit_count <= 75)) begin
			// Slot 3: Left channel
			ac97_sdata_out <= l_left_v ? l_left_data[19] : 1'b0;
			l_left_data <= { l_left_data[18:0], l_left_data[19] };
		end
		else if ((bit_count >= 76) && (bit_count <= 95))
			// Slot 4: Right channel
			ac97_sdata_out <= l_right_v ? l_right_data[95-bit_count] : 1'b0;
		else
			ac97_sdata_out <= 1'b0;
	end

	// Extract audio input from ac97_sdata_in
	always @(negedge ac97_bit_clock) begin
		if ((bit_count >= 57) && (bit_count <= 76))
			// Slot 3: Left channel
			left_in_data <= { left_in_data[18:0], ac97_sdata_in };
		else if ((bit_count >= 77) && (bit_count <= 96))
			// Slot 4: Right channel
			right_in_data <= { right_in_data[18:0], ac97_sdata_in };
	end
	
	// Extract slot request bit for Variable Rate Audio (VRA)
	always @(negedge ac97_bit_clock) begin
		if (bit_count == 25)
			slot_req <= ~ac97_sdata_in;
	end
endmodule

// Generate R/W control signals for LM4550
module ac97commands (
	input wire clock,
	input wire ready,
	// Command signals
	output wire [7:0] command_address,
	output wire [15:0] command_data,
	output reg command_valid,
	// Other signals
	input wire [4:0] volume,
	input wire [2:0] source
	);
	
	// Create command register & state
	reg [23:0] command;
	reg [3:0] state;

	// Assign command signal outputs
	assign command_address = command[23:16];
	assign command_data = command[15:0];
	
	initial begin
		command <= 24'h00_0000;
		// synthesis attribute init of command is "00_0000";
		command_valid <= 1'b0;
		// synthesis attribute init of command_valid is "0";
		state <= 4'h0;
		// synthesis attribute init of state is "0";
	end

	// Convert volume to attentuation
	wire [4:0] vol;
	assign vol = 5'd31 - volume;

	// Update state and command vars
	always @(posedge clock) begin
		// Increment state
		if (ready) state <= state+1;
		
		// Set command
		case (state)
			4'h0: begin // Read reset register (7'h00)
				command <= 24'h80_0000;
				command_valid <= 1'b1;
			end
			4'h1: // Read reset register (7'h00)
				command <= 24'h80_0000;
			4'h2: // Set Variable Rate Audio (7'h2A) LSB to 1
				command <= 24'h2A_0001;
			4'h3: // Set PCM DAC Sampling rate (7'h2C) to 8kHz
				command <= 24'h2C_1F40;
			4'h4: // Set PCM ADC Sampling rate (7'h32) to 8kHz
				command <= 24'h32_1F40;
			4'h5: // Set headphone volume (7'h04) on both L/R to vol
				command <= { 8'h04, 3'b000, vol, 3'b000, vol };
			4'h6: // Set PCM output volume (7'h18) on both L/R to 6dB gain
				command <= 24'h18_0808;
			4'h7: // Set record select (7'h1A) to source (mic)
				command <= { 8'h1A, 5'b00000, source, 5'b00000, source};
			4'h8: // Set record gain (7'h1C) to max (22.5dB gain)
				command <= 24'h1C_0F0F;
			4'h9: // Set mic volume (7'h0E) bit 6 for 20dB boost amplifier
				command <= 24'h0E_8048;
			4'hA: // Set PC beep volume (7'h0A) to 0dB attentuation
				command <= 24'h0A_0000;
			4'hB: // Set general purpose register (7'h20) so that:
			      //  * PCM output bypasses 3D circuitry
					//  * National 3D Sound is off
					//  * mic1 is selected
					//  * No ADC/DAC loopback
				command <= 24'h20_8000;
			default:
				command <= 24'h80_0000;
		endcase
	end
endmodule
