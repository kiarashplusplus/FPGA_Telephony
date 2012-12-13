////////////////////////////////////////////////////////////////////////////////
// Engineer: Kiarash Adl
// Module Name:  TransportReceive Module
////////////////////////////////////////////////////////////////////////////////

// set rcvSignal to high and send data from network to here.

module transportRcv #(parameter packetSize=16)  //in bytes
	(input clk, input reset, input rcvSignal, input [7:0] packetIn, input sessionBusy, 
	output reg [1:0]  sendingToSession,	 output reg [15:0] data, 
	output [10:0] rcv_data_count, output [7:0] dafuq);
		
	
	
	//initializing recieved packets' FIFO
	wire [7:0] rcvIn;
	reg rcv_rd_en=0;
	wire rcv_wr_en	;
	wire [7:0] rcvOut;
	wire rcvEmpty;
	wire rcvFull;
	readyPackets rcvPackets (.clk(clk), .din(rcvIn), .rd_en(rcv_rd_en), .srst(reset), .wr_en(rcv_wr_en),
		.data_count(rcv_data_count), .dout(rcvOut), .empty(rcvEmpty), .full(rcvFull));

	//This module buffers data as they are available. 
	assign rcv_wr_en=rcvSignal;
	assign rcvIn=packetIn;

	reg [1:0] rcvState=0;
	reg [packetSize:0] packetSizeCounter;
	reg [packetSize:0] counter;
	
	reg [7:0] buffer;


	parameter s_idle=0;   
	parameter s_before_sending=1;

    parameter s_sending=2;
    parameter s_control=3;
    parameter s_controlTwo=4;	
	parameter s_zeros=5;   
    parameter s_countDown=6;
    parameter s_audio=7;
    parameter s_audioTwo=8;	
	parameter s_audioThree=9;
	 
	 
	reg [4:0] state=s_idle;
	
	
	//for debugging purposes
	assign dafuq=rcvOut;
	
	
	initial begin
		sendingToSession=0;
		rcvState=0;
	end
	
			
    always @(posedge clk) begin
			if (reset) begin
				state<=s_idle;
 				
			end else case (state)
		
				s_idle:  begin   //Idle mode  
					if ((rcv_data_count>=packetSize) && (sessionBusy==0) ) begin
						rcv_rd_en<=1;
						state<=s_sending;
					end else begin 
						rcv_rd_en<=0;
						state<=s_idle;
					end
				end
				
				s_sending: begin   //checking whether the recieved packet has a "control message" or audio data.
					if (rcvOut==8'b0100_0000) begin
						
						state<=s_control;
					end else if (rcvOut==8'b1000_0000) begin
						
						state<=s_audio;
						packetSizeCounter<=packetSize-2;
					end
					
				end
				
				//we need two clock cycles two receive 16 bits of data
				
				s_control: begin
					data[15:8]<=rcvOut;
					state<=s_controlTwo;
				end
				
				s_controlTwo: begin
					data[7:0]<=rcvOut;
					sendingToSession<=2'b01;
					state<=s_zeros;
				
				end
				
				//After the 3rd byte of "control" packets are just zeros; just discarding.
				s_zeros: begin
					sendingToSession<=0;
					counter<=packetSize-4;
					state<=s_countDown;
				end
				
				s_countDown: begin
				
					if (counter==1) begin
						state<=s_idle;
					end else begin
						state<=s_countDown;
						counter<=counter-1;						
					end
				
				end
				

				// every two continous bytes go together. 
				s_audio: begin
					sendingToSession<=0;
					if (packetSizeCounter==2) begin
						state<=s_audioThree;
					end else begin										
						data[15:8]<=rcvOut;
						state<=s_audioTwo;
						packetSizeCounter<=packetSizeCounter-1;
					end
					
				end
				
				s_audioTwo: begin
					data[7:0]<=rcvOut;
					sendingToSession<=2'b10;
					state<=s_audio;
					packetSizeCounter<=packetSizeCounter-1;					
				end
				
				s_audioThree: begin
					rcv_rd_en<=0;
					state<=s_idle;				
				end
			endcase
			
			
    end
	
endmodule
