//asumming if got a 

module transport #(parameter packetSize=100, parameter inpSize= 48, parameter outSize=8)
	(input clk, input reset, input addrBookSignal, input [7:0] phoneNum, input cmd, input [15:0] data, input sendData, output [7:0] packet, output sent);
	
	reg [packetSize:0] packetBuffer; 
	reg [5:0] packetTop;
	
	reg [packetSize:0] readyPackets [0:20] ; //up to 20 packets in the queue
	reg [4:0] readyBegin;
	reg [4:0] readyEnd;
	
	reg [7:0] addrBook [0:10];   //max 10 numbers
	reg [1:0] addrBookTop; //number of phone numbers in the addressbook
	
	always @(posedge clk) begin
		if (reset) begin
			packetBuffer [packetSize:0] =0;	
			addressBookTop =0;
		end else if (addrBookSignal) begin		
			addrBook[addrBookTop] = phoneNume;
			addrBookTop=addrBookTop+1;
		end else if ((sendData==1) && (readyEnd>0)) begin
			
			for (i=packetSize-1; i>=0; i=i-8) begin
				packet = packet
			
			end
		
		
		
		end else if(cmd==0) begin  //recieving contol data 
			
			readyPackets[readyEnd][1:0]=2b'00;	
			readyPackets[readyEnd][17:2]=data;
			readyPackets[readyEnd][packetSize:17]=0;
			readyEnd=readyEnd+1;
			
		end else if (cmd==1) begin  // recieving audio
		
		
		
		end
		
		


	end
	
	
	
endmodule