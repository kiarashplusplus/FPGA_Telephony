////////////////////////////////////////////////////////////////////////////////
// Engineer: Kiarash Adl
// Module Name:  TransportSend Test Bench
////////////////////////////////////////////////////////////////////////////////

module tSend_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [1:0] cmd;
	reg [15:0] data;
	reg sendData;

	// Outputs
	wire sending;
	wire [7:0] packetOut;
	wire busy;
	wire ready_data_count;

	// Instantiate the Unit Under Test (UUT)
	transportSend uut (
		.clk(clk), 
		.reset(reset), 
		.cmd(cmd), 
		.data(data), 
		.sendData(sendData), 
		.sending(sending), 
		.packetOut(packetOut), 
		.busy(busy),
      .ready_data_count(ready_data_count)

	);
	
	always #5 clk= !clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		cmd = 0;
		data = 0;
		sendData = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
	/*	cmd=2'b01;
		#20;
		cmd=0;
		#200;
		cmd=2'b10;
		#400;
		cmd=0;
		#400;
		sendData=1;
		#20;
		sendData=0;
		#200;
		cmd=2'b10;
		#200;
		sendData=1;
		#20;
		sendData=0;
		#500;		
	*/
		cmd=2'b01;
		data=16'h44;
		#100;
		sendData=1;
		

	end
      
endmodule

