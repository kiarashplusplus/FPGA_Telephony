module tranToNet #(parameter packetSize=16)
    (input clk, input reset, input [7:0] data, input sending, input dummyBufferRd,
	 output reg sendData, output [7:0] packetOut, 
	 output [7:0] phoneNum, output [10:0] dummyBufferCount, output dummyBufferEmpty);


    reg [2:0] state=0;

    reg [7:0] phone=0;

    assign phoneNum=phone;
    
    parameter s_idle=0;
    parameter s_receive=1;
    parameter s_phone=2;
    parameter s_continue=3;
	 
	 wire dummyBufferFull;

	 dummyBuffer dummyBuffer( .clk(clk),	.din(data), .rd_en(dummyBufferRd), 
	   .srst(reset), .wr_en(sending),.data_count(dummyBufferCount),
		.dout(packetOut),.empty(dummyBufferEmpty),.full(dummyBufferFull));

    always @(posedge clk) begin
        if (reset) begin
            state<=s_idle;
        end
        
        case(state) 

            s_idle: begin
                if (dummyBufferEmpty) begin
                    state<=s_receive;
                end else
                    state<=s_idle;
            end
            
            s_receive: begin
					  sendDate<=1;
					  dummyBufferIn<=data;
					  if (sending) 
							dummyBufferIn<=data;							
							state<=s_phone;
					  else state<=s_receive;			
            end
            
            s_phone: begin
                dummyBufferIn<=data;
                phone<=data;
                state<=s_continue;                
            end
				
				s_continue: begin
                if (dummyBufferCount==packetSize) begin
                    sendData<=0;
                    state<=s_idle;
                end else begin
                    dummyBufferIn<=data;
						  if (!sending) 
								state<=s_idle;
                end				
				end
        
        endcase


    end




endmodule
