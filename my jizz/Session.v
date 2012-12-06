/*
 call phone number
 disconnect phone number
 
 add phone number to the call
 disconnect from group call
 
 put call on hold
 
 phone busy
 voicmail

*/

module session (input clk, input reset, input [7:0] phoneNum, inp	ut [1:0] cmd, input [15:0] data, 
	 input transportBusy, output [15:0] out, output [3:0] current_state);
	
	
	reg [3:0] state, next_state;
	
	assign current_state = state;

	parameter s_idle=0;   
    parameter s_wait=1;
    parameter s_connected=2;
    parameter s_=3;
	
	
    always @(*) begin
 
        if (reset) begin 
            next_state=s_idle;
         
        end else case (state)
		
			s_idle:  begin
			
			
			end
			
			s_wait:
			
	end
	
    always @(posedge clk) state<=next_state;

endmodule
	 

 
 
 
 