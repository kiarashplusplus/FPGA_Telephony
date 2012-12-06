
module transport #(parameter packetSize=127, parameter inpSize= 48, parameter outSize=8)
	(input clk, input reset, input [7:0] phoneNum, input [1:0] cmd, input [15:0] data, input sendData, output [7:0] packet, output busy);
	
	//cmd == 2'b00 idle ; 2'b01  command control data; 2'b10  audio
	
	reg [packetSize:0] packetBuffer; 
	reg [5:0] packetTop;
	
	//initializing ready packets' fifo
	reg [7:0] readyIn;
	reg rd_en;
	reg wr_en;
	reg [9:0] data_count;
	reg [7:0] readyOut;
	reg readyEmpty;
	reg readyFull;
	readyPackets readyPackets (.clk(clk), .din(readyIn), .rd_en(rd_en), .rst(reset), .wr_en(wr_en),
		.data_count(data_count), .dout(readyOut), .empty(readyEmpty), .full(readyFull));
	

	//reg [7:0] addrBook;   
	//reg [1:0] addrBookTop; //number of phone numbers in the addressbook
	reg [15:0] buffer;
	
	reg cdFlag=0;
	reg [1:0] cdCounter=0;
	reg [packetSize:0] cdZeroCounter;
	
	reg auFlag=0;
	
	always @(posedge clk) begin
		if (reset) begin
			packetBuffer [packetSize:0] =0;	
			packetTop=0;
			
		end else if(cmd==2'b01 && cdFlag==0) begin  //recieving contol data    //assuming the control data is 16 bits
			busy=1;
			cdFlag=1;
			buffer=data[15:0];
			readyIn=8'b0100_0000;
			wr_en=1;
			cdCounter=0;
		end else if (cdFlag==1) begin
			
			if (cdCounter==2'b00) begin
				readyIn=buffer[15:8];
				cdCounter=2'b01;
			end else if (cdCounter==2'b01) begin
				readyIn=buffer[7:0];
				cdCounter=2'b10;
				cdZeroCounter=packetSize-24+1;
			end else if (cdCounter==2'b10) begin
				if (cdZeroCounter==0) begin
					busy=0;
					cdFlag=0;
					wr_en=0;
				end else begin
					cdZeroCounter=cdZeroCounter-8;
					readyIn=0;
				end
			end
			
		end else if (cmd==2'b10 && auFlag==0) begin  // recieving audio
			busy=1;
			auFlag=1;
			wr_en=1;
			buffer=data[15:0];
			readyIn=8'b1000_0000;
			
			
		
		end
		
		


	end
	
	
	
endmodule