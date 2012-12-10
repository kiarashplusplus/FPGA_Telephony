`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:57:52 12/09/2012
// Design Name:   session
// Module Name:   /afs/athena.mit.edu/user/k/i/kiarash/Documents/6.111/FPGA_Telephony/my jizz/transport/session_tb.v
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
	reg [15:0] audioIn;
	reg [1:0] cmdIn;
	reg [15:0] packetIn;
	reg transportBusy;

	// Outputs
	wire audioInFlag;
	wire audioOutFlag;
	wire [15:0] audioOut;
	wire [1:0] cmd;
	wire [15:0] dataOut;
	wire sessionBusy;
	wire [7:0] phoneOut;
	wire [3:0] current_state;

	// Instantiate the Unit Under Test (UUT)
	session uut (
		.clk(clk), 
		.reset(reset), 
		.phoneNum(phoneNum), 
		.userInp(userInp), 
		.audioIn(audioIn), 
		.cmdIn(cmdIn), 
		.packetIn(packetIn), 
		.transportBusy(transportBusy), 
		.audioInFlag(audioInFlag), 
		.audioOutFlag(audioOutFlag), 
		.audioOut(audioOut), 
		.cmd(cmd), 
		.dataOut(dataOut), 
		.sessionBusy(sessionBusy), 
		.phoneOut(phoneOut), 
		.current_state(current_state)
	);
	
	always #5 clk= !clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		phoneNum = 0;
		userInp = 0;
		audioIn = 0;
		cmdIn = 0;
		packetIn = 0;
		transportBusy = 0;

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
		packetIn[7:0]=8'h1;
		packetIn[15:8]=8'h30;
		#100;
		
	end
      
endmodule

