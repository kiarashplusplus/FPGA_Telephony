`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:07:49 11/24/2012 
// Design Name: 
// Module Name:    Date_Time 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Keeps track of date and time, allows for setting it, and 
//                 generates ASCII bit-stream of data when D&T needed by asserting
//                 a display enable bit.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Date_Time #(
	parameter SEC_COUNT = 27_000_000  // number of clock cycles in a second 
	)(
	input clk_27mhz,           // 27 MHz clock
	input reset,               // Asynchronous reset
	// Control signals
	input set,                 // High for setting clock, low otherwise
	input disp_en,             // Assert to generate ASCII stream when D&T changes
	input button_up,     
	input button_down,   
	input button_left,   
	input button_right,  
	// Date & Time binary outputs
	output [6:0] year,
	output [3:0] month,
	output [4:0] day,
	output [4:0] hour,
	output [5:0] minute,
	output [5:0] second,
	// ASCII output
	output [7:0] ascii_out,
	output ascii_out_ready,
	// BRAM Binary-to-Decimal Lookup-Table I/O
	output [6:0] addr,
	input [7:0] data
	);
	
	// Define counter parameters
	parameter SEC_CNTR_LMT = SEC_COUNT - 1;
	
	// Generate one-cycle-high signals for button rises
	reg button_up_reg, button_down_reg, button_left_reg, button_right_reg;
	reg bu, bd, bl, br;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			button_up_reg <= 0;
			button_down_reg <= 0;
			button_left_reg <= 0;
			button_right_reg <= 0;
			bu <= 0;
			bd <= 0;
			bl <= 0;
			br <= 0;
		end
		else begin
			button_up_reg <= button_up;
			button_down_reg <= button_down;
			button_left_reg <= button_left;
			button_right_reg <= button_right;
			bu <= button_up & ~button_up_reg;
			bd <= button_down & ~button_down_reg;
			bl <= button_left & ~button_left_reg;
			br <= button_right & ~button_right_reg;
		end
	end
	
	// Keep track of previous disp_en to detect rise
	reg disp_en_reg;
	always @(posedge clk_27mhz) disp_en_reg <= (reset) ? 0: disp_en;
	
	// Instantiate DT output registers
	reg [6:0] year_reg;
	reg [3:0] month_reg;
	reg [4:0] day_reg;
	reg [4:0] hour_reg;
	reg [5:0] minute_reg;
	reg [5:0] second_reg;

	// Assign DT output
	assign year = year_reg;
	assign month = month_reg;
	assign day = day_reg;
	assign hour = hour_reg;
	assign minute = minute_reg;
	assign second = second_reg;
	
	// Instantiate ASCII output registers
	reg [7:0] ascii_out_reg;
	reg ascii_out_ready_reg;
	
	// Assign ASCII output
	assign ascii_out = ascii_out_reg;
	assign ascii_out_ready = ascii_out_ready_reg;
	
	// Instantiate BRAM I/O regisers
	reg [6:0] addr_reg;
	
	// Assign output
	assign addr = addr_reg;
	
	// Instantiate display request register
	reg disp_req;
	
	// Create second counter
	reg [24:0] sec_cnt;
	reg sec_rdy;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			sec_cnt <= 0;
			sec_rdy <= 0;
		end
		else if (sec_cnt == SEC_CNTR_LMT) begin
			sec_cnt <= 0;
			sec_rdy <= 1;
		end
		else begin
			sec_cnt <= sec_cnt + 1;
			sec_rdy <= 0;
		end
	end
	
	// Instantiate cursor registers
	reg [2:0] cursor_pos; 
	reg cursor_blink;
	
	// Declare position parameters
	parameter POS_SECOND = 0;
	parameter POS_MINUTE = 1;
	parameter POS_HOUR   = 2;
	parameter POS_DAY    = 3;
	parameter POS_MONTH  = 4;
	parameter POS_YEAR   = 5;
	
	// Assign number of days in month signal
	wire [4:0] num_days_cur_month;
	assign num_days_cur_month = (month_reg == 2) ? ((year_reg[1:0]) ? 28: 29): ((month_reg[3]^month_reg[0]) ? 31: 30);
	
	// Manage Date & Time
	reg start;
	always @(posedge clk_27mhz) begin
		if (reset) begin
			year_reg <= 0;
			month_reg <= 1;
			day_reg <= 1;
			hour_reg <= 0;
			minute_reg <= 0;
			second_reg <= 0;
			disp_req <= 0;
			start <= 0;
		end
		else if (set & (bu|bd)) begin  // Manage button presses when setting
			disp_req <= 0;
			start <= 1;
			if (bu) begin
				case (cursor_pos)
					POS_SECOND: second_reg <= 0;
					POS_MINUTE: minute_reg <= (minute_reg == 59) ? 0: minute_reg + 1;
					POS_HOUR: hour_reg <= (hour_reg == 23) ? 0: hour_reg + 1;
					POS_DAY: day_reg <= (day_reg == num_days_cur_month) ? 1: day_reg + 1;
					POS_MONTH: month_reg <= (month_reg == 12) ? 1: month_reg + 1;
					POS_YEAR: year_reg <= (year_reg == 99) ? 0: year_reg + 1;
				endcase
			end
			else begin
				case (cursor_pos)
					POS_SECOND: second_reg <= 0;
					POS_MINUTE: minute_reg <= (minute_reg == 0) ? 59: minute_reg - 1; 
					POS_HOUR: hour_reg <= (hour_reg == 0) ? 23: hour_reg - 1; 
					POS_DAY: day_reg <= (day_reg == 1) ? num_days_cur_month: day_reg - 1; 
					POS_MONTH: month_reg <= (month_reg == 1) ? 12: month_reg - 1; 
					POS_YEAR: year_reg <= (year_reg == 0) ? 99: year_reg - 1; 
				endcase
			end
		end
		else if (start) begin  // Correct days in month if it exceeds max
			start <= 0;
			disp_req <= 1;
			if (day_reg > num_days_cur_month) day_reg <= num_days_cur_month;
		end
		else if (sec_rdy) begin
			disp_req <= 1;
			if (second_reg == 59) begin
				second_reg <= 0;
				if (minute_reg == 59) begin
					minute_reg <= 0;
					if (hour_reg == 23) begin
						hour_reg <= 0;
						if (day_reg == num_days_cur_month) begin
							day_reg <= 1;
							if (month_reg == 12) begin
								month_reg <= 1;
								if (year_reg == 99) begin
									year_reg <= 0;
								end
								else
									year_reg <= year_reg + 1;
							end
							else
								month_reg <= month_reg + 1;
						end
						else
							day_reg <= day_reg + 1;
					end
					else
						hour_reg <= hour_reg + 1;
				end
				else
					minute_reg <= minute_reg + 1;					
			end
			else
				second_reg <= second_reg + 1;
		end
		else begin
			disp_req <= 0;
		end
	end
	
	// Manage cursor blinking
	always @(posedge clk_27mhz) begin
		if (reset | ~set)
			cursor_blink <= 0;
		else if (sec_rdy)
			cursor_blink <= ~cursor_blink;
	end
	
	// Manage cursor position
	always @(posedge clk_27mhz) begin
		if (reset | ~set)
			cursor_pos <= 0;
		else if (bl)
			cursor_pos <= (cursor_pos == POS_YEAR) ? POS_YEAR: cursor_pos + 1;
		else if (br)
			cursor_pos <= (cursor_pos == POS_SECOND) ? POS_SECOND: cursor_pos - 1;
	end
	
	// Instantiate state for ASCII display requests
	reg [4:0] state;
	
	// Declare state parameters
	parameter S_IDLE    = 5'h00;
	parameter S_DISP    = 5'h01;
	parameter S_DISP_1  = 5'h02;
	parameter S_DISP_2  = 5'h03;
	parameter S_DISP_3  = 5'h04;
	parameter S_DISP_4  = 5'h05;
	parameter S_DISP_5  = 5'h06;
	parameter S_DISP_6  = 5'h07;
	parameter S_DISP_7  = 5'h08;
	parameter S_DISP_8  = 5'h09;
	parameter S_DISP_9  = 5'h0A;
	parameter S_DISP_10 = 5'h0B;
	parameter S_DISP_11 = 5'h0C;
	parameter S_DISP_12 = 5'h0D;
	parameter S_DISP_13 = 5'h0E;
	parameter S_DISP_14 = 5'h0F;
	parameter S_DISP_15 = 5'h10;
	parameter S_DISP_16 = 5'h11;
	
	// Instantiate capture registers
	reg [25:0] DT_capture;
	reg [2:0] cursor_pos_capture;
	reg cursor_blink_capture;
	reg temp;
	
	// Manage display requests
	always @(posedge clk_27mhz) begin
		if (reset) begin
			state <= 0;  // S_IDLE
			ascii_out_reg <= 0;
			ascii_out_ready_reg <= 0;
			addr_reg <= 0;
		end
		else begin
			case (state)
				S_IDLE: begin
					ascii_out_reg <= 0;
					ascii_out_ready_reg <= 0;
					addr_reg <= year_reg;
					if (disp_en & (disp_req | ~disp_en_reg)) begin
						state <= state + 1;  // S_DISP
						DT_capture <= {month_reg, day_reg, hour_reg, minute_reg, second_reg};
						cursor_pos_capture <= cursor_pos;
						cursor_blink_capture <= cursor_blink;
					end
				end
				S_DISP: begin
					temp <= ~(cursor_blink_capture & (cursor_pos_capture == 5));
					state <= state + 1;  // S_DISP_1
				end
				S_DISP_1: begin
					addr_reg <= {3'b000, DT_capture[25:22]};
					ascii_out_reg <= {2'b00, temp, 1'b1, data[7:4]};  // year, first digit
					ascii_out_ready_reg <= 1;
					state <= state + 1;  // S_DISP_2
				end
				S_DISP_2: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[3:0]};  // year, second digit
					state <= state + 1;  // S_DISP_3
				end
				S_DISP_3: begin
					ascii_out_reg <= 8'h2F;  // forward slash
					temp <= ~(cursor_blink_capture & (cursor_pos_capture == 4));
					state <= state + 1;  // S_DISP_4
				end
				S_DISP_4: begin
					addr_reg <= {2'b00, DT_capture[21:17]};
					ascii_out_reg <= {2'b00, temp, 1'b1, data[7:4]};  // month, first digit
					state <= state + 1;  // S_DISP_5
				end
				S_DISP_5: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[3:0]};  // month, second digit
					state <= state + 1;  // S_DISP_6
				end
				S_DISP_6: begin
					ascii_out_reg <= 8'h2F;  // forward slash
					temp <= ~(cursor_blink_capture & (cursor_pos_capture == 3));
					state <= state + 1;  // S_DISP_7
				end
				S_DISP_7: begin
					addr_reg <= {2'b00, DT_capture[16:12]};
					ascii_out_reg <= {2'b00, temp, 1'b1, data[7:4]};  // day, first digit
					state <= state + 1;  // S_DISP_8
				end
				S_DISP_8: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[3:0]};  // day, second digit
					state <= state + 1;  // S_DISP_9
					temp <= ~(cursor_blink_capture & (cursor_pos_capture == 2));
				end
				S_DISP_9: begin
					addr_reg <= {1'b0, DT_capture[11:6]};
					ascii_out_reg <= {2'b00, temp, 1'b1, data[7:4]};  // hour, first digit
					state <= state + 1;  // S_DISP_10
				end
				S_DISP_10: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[3:0]};  // hour, second digit
					state <= state + 1;  // S_DISP_11
				end
				S_DISP_11: begin
					ascii_out_reg <= 8'h3A;  // colon
					temp <= ~(cursor_blink_capture & (cursor_pos_capture == 1));
					state <= state + 1;  // S_DISP_12
				end
				S_DISP_12: begin
					addr_reg <= {1'b0, DT_capture[5:0]};
					ascii_out_reg <= {2'b00, temp, 1'b1, data[7:4]};  // minute, first digit
					state <= state + 1;  // S_DISP_13
				end
				S_DISP_13: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[3:0]};  // minute, second digit
					state <= state + 1;  // S_DISP_14
				end
				S_DISP_14: begin
					ascii_out_reg <= 8'h3A;  // colon
					temp <= ~(cursor_blink_capture & (cursor_pos_capture == 0));
					state <= state + 1;  // S_DISP_15					
				end
				S_DISP_15: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[7:4]};  // second, first digit
					state <= state + 1;  // S_DISP_16
				end
				S_DISP_16: begin
					ascii_out_reg <= {2'b00, temp, 1'b1, data[3:0]};  // second, second digit
					state <= S_IDLE;
				end				
			endcase
		end
	end
endmodule
