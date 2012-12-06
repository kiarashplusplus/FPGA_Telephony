
module transportRcv #(parameter packetSize=127)
	(input clk, input reset, input rcvSignal, input [7:0] packetIn, input sessionBusy, output reg sendingToSession, output [7:0] phoneNum,
	output reg [1:0] cmd, output [15:0] data, output reg busy);
		
	
	//initializing recieved packets' fifo
	reg [7:0] rcvIn;
	reg rcv_rd_en;
	reg rcv_wr_en;
	reg [9:0] rcv_data_count;
	reg [7:0] rcvOut;
	reg rcvEmpty;
	reg rcvFull;
	rcvPackets rcvPackets (.clk(clk), .din(rcvIn), .rd_en(rcv_rd_en), .rst(reset), .wr_en(rcv_wr_en),
		.data_count(rcv_data_count), .dout(rcvOut), .empty(rcvEmpty), .full(rcvFull));
	

	reg rcvFlag=0;
	reg [packetSize:0] packetSizeCounter;
	
	reg [7:0] buffer;
	reg sessionFlag=0;
	reg [2:0] state;
	reg [15:0] data;
	
	always @(posedge clk) begin
		if (reset) begin
			rcvFlag=0;
			sessionFlag=0;
			
		end else if (rcvSignal==1) begin
			busy=1;
			rcv_wr_en=1;
			rcvIn=packetIn;
			rcvFlag=1;
			packetSizeCounter=packetSize+1;
		end else if (rcvFlag==1) begin
			if (packetSizeCouneter==0) begin
				busy=0;
				rcv_wr_en=0;
				rcvFlag=0;
				state=0;
			end else packetSizeCounter=packetSizeCounter-8;
		end
		
		if ((rcvEmpty==0) && (sessionBusy==0) ) begin
			rcv_rd_en=1;
			sendingToSession=1;		
			buffer=rcvIn;
			sessionFlag=1;
			state=0;
		end else if (sessionFlag==1) begin
			if (state==0 && buffer==8'b0100_0000) begin 
				state=1; //control command
			end else if (state==0 && buffer==8'b1000_0000) begin
				state=3; //audio
			end else if (state==1) begin
				data [15:8]=buffer;
				state=2;
			end else if (state==2) begin
				data[7:0]=buffer;

			end
		end 


	end
	
	
	
endmodule