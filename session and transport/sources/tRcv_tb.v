////////////////////////////////////////////////////////////////////////////////
// Engineer: Kiarash Adl
// Module Name:  TransportReceive Test Bench
////////////////////////////////////////////////////////////////////////////////


module tRcv_tb;

	// Inputs
	reg clk;
	reg reset;
	reg rcvSignal;
	reg [7:0] packetIn;
	reg sessionBusy;

	// Outputs
	wire [1:0] sendingToSession;
	wire [15:0] data;
	wire dafuq;

	// Instantiate the Unit Under Test (UUT)
	transportRcv uut (
		.clk(clk), 
		.reset(reset), 
		.rcvSignal(rcvSignal), 
		.packetIn(packetIn), 
		.sessionBusy(sessionBusy), 
		.sendingToSession(sendingToSession), 
		.data(data), 
		.dafuq(dafuq)
	);


	always #5 clk= !clk;
//	always #20 packetIn=packetIn+2;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		rcvSignal = 0;
		packetIn = 0;
		sessionBusy = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rcvSignal=1;
		packetIn=8'b1000_0000;
		#10;
		packetIn=8'h4;
		#10;
		packetIn=8'h5;
		#10;
		packetIn=8'h6;
		#10;
		packetIn=8'h7;
		#10;
		packetIn=8'h8;
		#10;
		packetIn=8'h9;
		#10;
		packetIn=8'h10;
		#10;
		packetIn=8'h11;
		#10;
		packetIn=8'h12;
		#10;
		packetIn=8'h13;
		#10;
		packetIn=8'h14;		
		#10;
		packetIn=8'h15;
		#10;
		packetIn=8'h16;		
		#10;
		packetIn=8'h17;
		#10;
		packetIn=8'b1111_1111;
		#10;
		rcvSignal=0;
		#200;
		rcvSignal=1;
		
		
		packetIn=8'b0100_0000;
		#10;
		packetIn=8'h2;
		#20;
		packetIn=2;
		#130;		
		rcvSignal=0;
		#100;
		sessionBusy=0;
		#500;
		reset=1;
		#50;
		reset=0;

	end
      
endmodule

