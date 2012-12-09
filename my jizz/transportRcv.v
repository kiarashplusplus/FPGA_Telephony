// set rcvSignal to high to send data from network to here.

module transportRcv #(parameter packetSize=16)  //in bytes
	(input clk, input reset, input rcvSignal, input [7:0] packetIn, input sessionBusy, 
	output reg [1:0]  sendingToSession,	 output reg [15:0] data, output reg [7:0] dafuq);
		
	
	//initializing recieved packets' fifo
	wire [7:0] rcvIn;
	reg rcv_rd_en=0;
	wire rcv_wr_en	;
	wire [10:0] rcv_data_count;
	wire [7:0] rcvOut;
	wire rcvEmpty;
	wire rcvFull;
	readyPackets rcvPackets (.clk(clk), .din(rcvIn), .rd_en(rcv_rd_en), .srst(reset), .wr_en(rcv_wr_en),
		.data_count(rcv_data_count), .dout(rcvOut), .empty(rcvEmpty), .full(rcvFull));
		
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
	
	reg [4:0] state=s_idle;
	reg [4:0]  next_state=s_idle;
	
	
	initial begin
		dafuq=0;
		sendingToSession=0;
		rcvState=0;
	end
	
			
    always @(*) begin
			if (reset) begin
				next_state=s_idle;
 				
			end else case (state)
		
				s_idle:  begin
					if ((rcv_data_count>=packetSize) && (sessionBusy==0) ) begin
						rcv_rd_en=1;
						next_state=s_sending;
					end else begin 
						rcv_rd_en=0;
							next_state=s_idle;
					end
				end
				
				/*s_before_sending: begin
					next_state=s_sending;
				end*/
				
				s_sending: begin
					if (rcvOut==8'b0100_0000) begin
						dafuq=0;
						next_state=s_control;
					end else if (rcvOut==8'b1000_0000) begin
						dafuq=0;
						next_state=s_audio;
						packetSizeCounter=packetSize-1;
					end else dafuq=1;
				end
				
				s_control: begin
					data[15:8]=rcvOut;
					next_state=s_controlTwo;
				end
				
				s_controlTwo: begin
					data[7:0]=rcvOut;
					sendingToSession=2'b01;
					next_state=s_zeros;
				
				end
				
				s_zeros: begin
					sendingToSession=0;
					counter=packetSize-4; ///?????????
					next_state=s_countDown;
				end
				
				s_countDown: begin
				
					if (counter==1) begin
						next_state=s_idle;
					end else begin
						next_state=s_countDown;
						counter=counter-1;						
					end
				
				end
				

				s_audio: begin
					sendingToSession=0;
					if (packetSizeCounter==0) begin
						next_state=s_idle;
						rcv_rd_en=0;
					end else begin										
						data[15:8]=rcvOut;
						next_state=s_audioTwo;
						packetSizeCounter=packetSizeCounter-1;
					end
					
				end
				
				s_audioTwo: begin
					data[7:0]=rcvOut;
					sendingToSession=2'b10;
					next_state=s_audio;
					packetSizeCounter=packetSizeCounter-1;					
				end
			endcase
    end
	
	
    always @(posedge clk) state<=next_state;

	
endmodule
