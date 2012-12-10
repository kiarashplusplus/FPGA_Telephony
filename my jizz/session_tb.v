`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:24:28 12/10/2012
// Design Name:   session
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz//session_tb.v
// Project Name:  transport
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: session
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module session_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] phoneNum;
	reg [4:0] userInp;
	reg [1:0] cmdIn;
	reg [15:0] packetIn;
	reg transportBusy;
	reg ac97_clk;
	reg micBuffer_wr_en;
	reg [15:0] micBufferIn;
	reg spkBuffer_rd_en;

	// Outputs
	wire micFlag;
	wire [1:0] cmd;
	wire [15:0] dataOut;
	wire sessionBusy;
	wire [7:0] phoneOut;
	wire [3:0] current_state;
	wire [15:0] spkBufferOut;
	wire micBufferFull;
	wire micBufferEmpty;
	wire spkBufferFull;
	wire spkBufferEmpty;

	// Instantiate the Unit Under Test (UUT)
	session uut (
		.clk(clk), 
		.reset(reset), 
		.phoneNum(phoneNum), 
		.userInp(userInp), 
		.cmdIn(cmdIn), 
		.packetIn(packetIn), 
		.transportBusy(transportBusy), 
		.micFlag(micFlag), 
		.cmd(cmd), 
		.dataOut(dataOut), 
		.sessionBusy(sessionBusy), 
		.phoneOut(phoneOut), 
		.current_state(current_state), 
		.ac97_clk(ac97_clk), 
		.micBuffer_wr_en(micBuffer_wr_en), 
		.micBufferIn(micBufferIn), 
		.spkBuffer_rd_en(spkBuffer_rd_en), 
		.spkBufferOut(spkBufferOut), 
		.micBufferFull(micBufferFull), 
		.micBufferEmpty(micBufferEmpty), 
		.spkBufferFull(spkBufferFull), 
		.spkBufferEmpty(spkBufferEmpty)
	);

	always #5 clk=!clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		phoneNum = 0;
		userInp = 0;
		cmdIn = 0;
		packetIn = 0;
		transportBusy = 0;
		ac97_clk = 0;
		micBuffer_wr_en = 0;
		micBufferIn = 0;
		spkBuffer_rd_en = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		phoneNum=8'h20;
		userInp=5'h01;
		#100;
		phoneNum=0;
		userInp=0;
		#100;
		cmdIn=2'b01;
		packetIn[7:0]=8'h5;
		packetIn[15:8]=8'h30;
		#100;
		cmdIn=2'b01;
		packetIn[7:0]=8'h1;
		packetIn[15:8]=8'h30;
		#100;		
		
	end
      
endmodule

