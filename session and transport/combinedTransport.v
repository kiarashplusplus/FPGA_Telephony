//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kiarash Adl
// Module: combinedTransport
//////////////////////////////////////////////////////////////////////////////////

module combinedTransport #(parameter packetSize=16) //in bytes
	(input clk, input reset, input [1:0] cmd, input [15:0] data, 
	  output [7:0] packetOut, input dummyBufferRd,output busy,
	 output [7:0] phoneNum, output [9:0] dummyBufferCount, output dummyBufferEmpty);
	
	wire sending;
	wire [7:0] sendPacketOut;
	wire [10:0] ready_data_count;
	wire sendData;
	
	transportSend sender (
		.clk(clk), 
		.reset(reset), 
		.cmd(cmd), 
		.data(data), 
		.sendData(sendData), 
		.sending(sending), 
		.packetOut(sendPacketOut), 
		.busy(busy),
		.ready_data_count(ready_data_count)
	);
	
	wire [2:0] debug;
	
	tranToNet oneTran
    (.clk(clk), .reset(reset), .data(sendPacketOut), .sending(sending), .dummyBufferRd(dummyBufferRd),
	  .sendData(sendData), .phoneNum(phoneNum), .packetOut(packetOut),
	  .dummyBufferCount(dummyBufferCount), .dummyBufferEmpty(dummyBufferEmpty), 
	  .debug(debug));


endmodule
