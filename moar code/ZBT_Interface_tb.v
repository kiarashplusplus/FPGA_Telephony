`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Sachin Shinde
//
// Create Date:   23:53:00 11/25/2012
// Design Name:   ZBT_Interface
// Module Name:   C:/Users/Sachin Shinde/Desktop/6.111/Final Project/Verilog/Final_Project/ZBT_Interface_tb.v
// Project Name:  Final_Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ZBT_Interface
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ZBT_Interface_tb;

	// Inputs
	reg clk_27mhz;
	reg reset;
	reg [18:0] addr;
	reg [35:0] din;
	reg [1:0] op;
	reg [3:0] bwe;

	// Outputs
	wire [35:0] dout;
	wire nd;
	wire [18:0] ram_address;
	wire ram_we_b;
	wire [3:0] ram_bwe_b;
	wire ready;

	// Bidirs
	wire [35:0] ram_data;

	// Define Operation parameters (OPCODE)
	parameter OP_IDLE = 2'b00;
	parameter OP_READ = 2'b01;
	parameter OP_WRITE = 2'b10;
	
	// Create Tri-state Buffer
	reg [35:0] ram_data_reg;
	
	// Assign Tri-state Buffer
	assign ram_data = ram_data_reg;
	
	// Instantiate the Unit Under Test (UUT)
	ZBT_Interface uut (
		.clk_27mhz(clk_27mhz), 
		.reset(reset), 
		.addr(addr), 
		.din(din), 
		.op(op), 
		.bwe(bwe), 
		.dout(dout), 
		.nd(nd), 
		.ram_data(ram_data), 
		.ram_address(ram_address), 
		.ram_we_b(ram_we_b), 
		.ram_bwe_b(ram_bwe_b),
		.ready(ready)
	);
	
	// Set 100 MHz clock
	always #5 clk_27mhz = ~clk_27mhz;
	
	initial begin
		// Initialize Inputs
		clk_27mhz = 0;
		reset = 1;
		addr = 0;
		din = 0;
		op = 0;
		bwe = 0;
		ram_data_reg <= 36'bZ;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		@(negedge clk_27mhz)
			reset = 0;
			op = OP_IDLE;
		@(negedge clk_27mhz)
			op = OP_READ;
			addr = 0;
			din = 36'hDEADACEDA;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 1;
			din = 36'hDEADACEDA;
		@(negedge clk_27mhz)
			op = OP_WRITE;
			bwe = 4'b0101;
			addr = 2;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_READ;
			addr = 4;
			din = 36'hACAFEBABE;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_READ;
			addr = 5;
			din = 36'hABABECAFE;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_WRITE;
			bwe = 0000;
			addr = 6;
			din = 36'hACAFEBABE;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_WRITE;
			addr = 7;
			din = 36'hABABECAFE;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_READ;
			addr = 8;
			din = 36'hFADEEDAFC;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_WRITE;
			addr = 9;
			din = 36'hBABAFAFAD;
		@(negedge clk_27mhz)
			op = OP_IDLE;
			addr = 3;
			din = 36'hACADEDEAD;
		@(negedge clk_27mhz)
			op = OP_READ;
			addr = 10;
			din = 36'hDECADEACE;
		@(negedge clk_27mhz)
			op = OP_IDLE;
		@(negedge clk_27mhz)
			ram_data_reg = 36'hFFFFAAAA;
	end
endmodule

