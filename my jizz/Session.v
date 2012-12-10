/*

 user input: 

 call phone number  5'h1
 answer call  5'h2
 disconnect phone number 5'h5
 voicmail  5'h3

*/

module session (input clk, input reset, input [7:0] phoneNum, input [4:0] userInp, 
	  input [1:0] cmdIn, input [15:0] packetIn, input transportBusy,
	  output reg micFlag, 
	  output reg [1:0] cmd, output reg [15:0] dataOut, output reg sessionBusy, 
	  output reg [7:0] phoneOut, output [3:0] current_state,
	  
	  input ac97_clk, input micBuffer_wr_en, input micBufferIn,
	  input spkBuffer_rd_en, output spkBufferOut, output micBufferFull, output micBufferEmpty, 
	  output spkBufferFull, output spkBufferEmpty
	  );
	
	
	reg [3:0] state=0;
	
	 assign current_state = state;

	 parameter s_idle=0;   
    parameter s_calling=1;
    parameter s_connected=2;
    parameter s_noAnswer=3;
    parameter s_voicemail=4;
    parameter s_connectedToVoice=5;
    parameter s_ringing=6;	
	
	 reg [7:0] phone;
	
	reg spkBuffer_wr_en=0;
	wire [15:0] spkBufferIn;
	assign spkBufferIn=packetIn;
	
	reg [15:0] micBufferOut;
	reg micBuffer_rd_en;

	audioBuffer micBuffer (	.din(micBufferIn), .rd_clk(clk),.rd_en(micBuffer_rd_en), .rst(reset),
	.wr_clk(ac97_clk),	.wr_en(micBuffer_wr_en), .dout(micBufferOut), .empty(micBufferEmpty), .full(micBufferFull));


	audioBuffer spkBuffer (	.din(spkBufferIn), .rd_clk(ac97_clk),.rd_en(spkBuffer_rd_en), .rst(reset),
	.wr_clk(clk),	.wr_en(spkBuffer_wr_en), .dout(spkBufferOut), .empty(spkBufferEmpty), .full(spkBufferFull));
		
	
    always @(posedge clk) begin
 
        if (reset) begin 
            state<=s_idle;
				spkBuffer_wr_en<=0;
				micBuffer_rd_en<=0;
				
        end else case (state)
			
			s_idle:  begin
			
				sessionBusy<=0;
				
				if (userInp==5'h1) begin  //call a phone number
					cmd<=2'b01;      //sending a control packet
					dataOut[15:8]<=phoneNum;
					dataOut[7:0]<=8'h1;  
					state<=s_calling;
					phone<=phoneNum;
				end else if (cmdIn==2'b01 && packetIn[7:0]==8'h1) begin //recieving a call
					phone<=packetIn[15:8];
					state<=s_ringing;
					phoneOut<=packetIn[15:8];
					cmd<=0;
				end else begin
					state<=s_idle;	
					cmd<=0;
				end
			
			end
			
			
			s_calling: begin
				sessionBusy<=0;
				cmd<=0;			
				
				if ((cmdIn==2'b01) && (packetIn[7:0]==8'h2)) begin  //Answered
					phone<=packetIn[15:8];
					state<=s_connected;				
				end else if ((cmdIn==2'b01) && (packetIn[7:0]==8'h3)) begin //Voice-mail
					phone<=packetIn[15:8];						
					state<=s_connectedToVoice;
				end else if ((cmdIn==2'b01) && (packetIn[7:0]==8'h5)) begin //rejected
					state<=s_noAnswer;
				end else if (userInp==5'h2) begin //user disconnect
					cmd<=2'b01;      //sending a control packet
					dataOut[15:8]<=phone;
					dataOut[7:0]<=8'h2;  
					state<=s_idle;						
				end else state<=s_calling;
				
			end
			
			s_ringing: begin
				sessionBusy<=1;
				phoneOut<=phone; //outputing the caller's number
				
				if (userInp==5'h5) begin //reject call
					cmd<=2'b01; //send a control packet
					dataOut[15:8]<=phone;
					dataOut[7:0]<=8'h5;
					state<=s_idle;						
				end else if (userInp==5'h3) begin //voice-mail
					cmd<=2'b01;
					dataOut[15:8]<=phone;
					dataOut[7:0]<=8'h3;
					state<=s_voicemail;	
				end else if (userInp==5'h2) begin   //user answered			
					cmd<=2'b01;     
					dataOut[15:8]<=phone;
					dataOut[7:0]<=8'h2;
					state<=s_connected;
				end else begin
					state<=s_ringing;
				end
				
			end
			
			s_connected: begin
				sessionBusy<=0;	
				
				if (userInp==5'h5) begin  //user disconnects the call
					micFlag<=0;
					cmd<=2'b01;
					dataOut[7:0]<=8'h5;
					dataOut[15:0]<=phone;
					state<=s_idle;
				end else if ((cmdIn==2'b01) && (packetIn[7:0]==8'h5)) begin //they hung up
					micFlag<=0;
					state<=s_idle;
					cmd<=0;
				end else begin
				
					micFlag<=1;
						
					if ((!transportBusy) && (!micBufferEmpty)) begin //sending audio
						micBuffer_rd_en<=1;
						cmd<=2'b10; 
						dataOut<=micBufferOut;
					end else begin
						micBuffer_rd_en<=0;
						cmd<=0;
					end
					
					if (cmdIn==2'b10) begin  //incoming audio
						spkBuffer_wr_en<=1;
					end else begin
						spkBuffer_wr_en<=0;
					end
					
					state<=s_connected;
				end
				
			end

			s_noAnswer: begin 	
				state<=s_idle;
			end
			
			s_voicemail: begin
				sessionBusy<=0;			
				if (userInp==5'h5) begin  //user disconnects the call
					cmd<=2'b01;
					dataOut[7:0]<=8'h5;
					dataOut[15:0]<=phone;
					state<=s_idle;
				end else if ((cmdIn==2'b01) && (packetIn[7:0]==8'h5)) begin //they hung up
						state<=s_idle;
						cmd<=0;
				end else if (cmdIn==2'b10) begin  //incoming audio
						spkBuffer_wr_en<=1;
						state<=s_voicmail;
				end else begin
						spkBuffer_wr_en<=0;
						state<=s_voicmail;
				end
									
			end
			
			s_connectedToVoice: begin
				sessionBusy<=0;			
				if (userInp==5'h5) begin  //user disconnects the call
					micFlag<=0;
					cmd<=2'b01;
					dataOut[7:0]<=8'h5;
					dataOut[15:0]<=phone;
					state<=s_idle;
				end else if ((cmdIn==2'b01) && (packetIn[7:0]==8'h5)) begin //they hung up
					micFlag<=0;
					state<=s_idle;
					cmd<=0;
				end else begin			
		
					micFlag<=1;

					if ((!transportBusy) && (!micBufferEmpty)) begin //sending audio
						micBuffer_rd_en<=1;
						cmd<=2'b10; 
						dataOut<=micBufferOut;
					end else begin
						micBuffer_rd_en<=0;
						cmd<=0;
					end
					
					state<=s_connectedToVoice;
					
				end
					
			end
			
		endcase
			
	end
		
endmodule
	 

 
 
 
 