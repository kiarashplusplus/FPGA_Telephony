// set rcvSignal to high to send data from network to here.

module transportRcv #(parameter packetSize=16)  //in bytes
	(input clk, input reset, input rcvSignal, input [7:0] packetIn, input sessionBusy, output [1:0] reg sendingToSession,
	 output [15:0] data);
		
	
	//initializing recieved packets' fifo
	reg [7:0] rcvIn;
	reg rcv_rd_en;
	reg rcv_wr_en;
	reg [10:0] rcv_data_count;
	reg [7:0] rcvOut;
	reg rcvEmpty;
	reg rcvFull;
	rcvPackets rcvPackets (.clk(clk), .din(rcvIn), .rd_en(rcv_rd_en), .srst(reset), .wr_en(rcv_wr_en),
		.data_count(rcv_data_count), .dout(rcvOut), .empty(rcvEmpty), .full(rcvFull));
	

	reg rcvFlag=0;
	reg [packetSize:0] packetSizeCounter;
	
	reg [7:0] buffer;
	reg sessionFlag=0;
	reg [2:0] state;
	reg [15:0] data;
	
	always @(posedge clk) begin
		if (reset) begin
			rcvFlag<=0;
			rcv_wr_en<=0;
			rcv_rd_en<=0;
		end else if (rcvSignal==1) begin
			rcv_wr_en<=1;
			rcvIn<=packetIn;
			rcvFlag<=1;
		end else if (rcvFlag==1) begin
			rcv_wr_en<=0;
			rcvFlag<=0;
		end
		
		if ((rcvEmpty==0) && (sessionBusy==0) ) begin
			if (state==0) begin
				rcv_rd_en<=1;
				state<=1;
			end else if (state==1 && buffer==8'b0100_0000) begin 
				state<=2; //control command
				buffer<=rcvIn;
			end else if (state==1 && buffer==8'b1000_0000) begin
				state<=6; //audio
				buffer<=rcvIn;			
			end else if (state==2) begin
				data [15:8]<=buffer;
				buffer2<=rcvIn;
				state=3;
			end else if (state==3) begin
				data[7:0]=buffer2;
				sendingToSession=2'b01;
				state=4;
			end else if (state==4) begin
				sendingToSession=0;
				state=5;
				packetSizeCounter=packetSize-3;
			end else if (state==5) begin
				if (packetSizeCounter==0) begin
					state=0;
				end else packetSizeCounter=packetSizeCounter-1;
			end else if (state==6) begin 
				data[15:8]=buffer;
				state=7;
				buffer2<=rcvIn;
				packetSizeCounter=packetSize-2;
			end else if (state==7) begin
				data[7:0]=buffer2;
				sendingToSession=2'b10;
				state=8;
				if (packetSizeCounter==0) state=9
				else packetSizeCounter=packetSizeCounter-1;
				
			end else if (state==8) begin
				sendingToSession=2'b00;
				data[15:8]=buffer;
				state=7;
				packetSizeCounter=packetSizeCounter-1;
			end else if (state==9) begin
				sendingToSession=2'b00;
				rcv_rd_en=0;
				state=0;
			end
		end 


	end
	
endmodule
