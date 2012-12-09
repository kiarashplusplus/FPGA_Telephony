/*
 call phone number
 disconnect phone number
 
 add phone number to the call
 disconnect from group call
 
 put call on hold
 
 phone busy
 voicmail

*/

module session (input clk, input reset, input [7:0] phoneNum, input [4:0] userInp, input [15:0] audioIn,   
	  input [1:0] cmdIn, input [15:0] packetIn, input transportBusy,
	  output reg audioInFlag, output reg audioOutFlag, output [15:0] audioOut;
	  output [1:0] cmd, output [15:0] dataOut, output , output reg sessionBusy, 
	  output [7:0] phoneNumOut, output [3:0] current_state);
	
	assign phoneNumOut= phoneNum;
	
	reg [3:0] state, next_state;
	
	assign current_state = state;

	parameter s_idle=0;   
    parameter s_calling=1;
    parameter s_connected=2;
    parameter s_noAnswer=3;
    parameter s_voicemail=4;
   // parameter s_isBusy=5;
    parameter s_ringing=6;	
	
	
	
	parameter timeOutConstant=1000;
	reg [5:0] timeOut; //???????????????
	
	
    always @(*) begin
 
        if (reset) begin 
            next_state<=s_idle;
         
        end else case (state)
			
			s_idle:  begin

				timeOut<=timeOutConstant;
				audioInFlag<=0;
				audioOutFlag<=0;
				sessionBusy<=0;
				
				
				
				if (userInp==5'h1) begin  //call a phone number
					cmd<=2'b10;      //sending a control packet
					dataOut<=16'h1;  
					next_state<=s_calling;
				end else if (cmdIn==2'b01 && packetIn==16'h1) begin
					next_state<=s_ringing;
					cmd<=0;
				end else begin
					next_state<=s_idle;	
					cmd<=0;
				end
			
			end
			
			
			s_calling: begin
				cmd<=0;			
				if (timeOut==0) begin
					next_state<=s_noAnswer;
				end else if (cmdIn==2'b01) begin  //incoming control message
				
					if (packetIn==16'h2) begin 
						next_state<=s_connected;
						
				//	end else if (packetIn==16'h3) begin
				//		next_state<=s_connectedToVoice;
					end		
				end	else begin
					timeOut<=timeOut-1;
					next_state<=s_calling;
					
				end
				
			end
			
			s_ringing: begin

				if (timeOut==0) begin
					next_state<=s_idle;
					//next_state<=s_voicemail;
				end else if (usetInp==5'h2) begin   //user answered
					cmd<=2'b10;      //sending a control packet
					dataOut<=16'h2;  
					next_state<=s_connected;
				end	else begin
					timeOut<=timeOut-1;		
					next_state<=s_ringing;
				end
				
			
			end
			
			s_connected: begin
				
				if (userInp==5'h5) begin  //user disconnects the call
					cmd<=2'b01; //sending control
					dataOut<=16'h5;
					next_state<=s_idle;
				end else if (cmdIn==2'b01) begin
					if (packetIn==16'h5) begin
						next_state<=s_idle;
						cmd<=0;
					//end else if (packetIn==16'h6) begin
					//	next_state<=s_hold;
					end 
				end else begin   
					if (!transportBusy) begin
						audioInFlag<=1;
						cmd<=2'b10; //sending audio
						dataOut<=audioIn;
					end 
					if (cmdIn==2'b10) begin  //incoming audio
						audioOutFlag<=1;
						audioOut<=packetIn;
					end	else audioOutFlag<=0;
					
					next_state<=state;
				end
				
			end

			s_noAnswer: begin ///????? probably some time out
				
				next_state<=s_idle;
			
			end
			
			
		endcase
			
	end
	
    always @(posedge clk) state<=next_state;

endmodule
	 

 
 
 
 