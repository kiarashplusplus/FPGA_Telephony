
module transportSend #(parameter packetSize=16) //in bytes
	(input clk, input reset, input [1:0] cmd, input [15:0] data, 
	 input sendData, output reg sending, output [7:0] packetOut, 
	 output reg busy, output [10:0] ready_data_count);
	
	//cmd == 2'b00 idle ; 2'b01  command control data; 2'b10  audio
	reg goingToSend=0;

	initial begin
		sending=0;
		busy=0;
	end
		
	//initializing buffer packets' fifo
	reg [7:0] bufferIn=0;
	reg buffer_rd_en=0;
	reg buffer_wr_en=0;
	wire [10:0] buffer_data_count;
	wire [7:0] bufferOut;
	wire bufferEmpty;
	wire bufferFull;
	packetBuffer packetBuffer (.clk(clk), .din(bufferIn), .rd_en(buffer_rd_en), .srst(reset), .wr_en(buffer_wr_en),
		.data_count(buffer_data_count), .dout(bufferOut), .empty(bufferEmpty), .full(bufferFull));
		
	
	//initializing ready packets' fifo
	reg [7:0] readyIn=0;
	reg ready_rd_en=0;
	reg ready_wr_en=0;
	wire [7:0] readyOut;
	wire readyEmpty;
	wire readyFull;
	readyPackets readyPackets (.clk(clk), .din(readyIn), .rd_en(ready_rd_en), .srst(reset), .wr_en(ready_wr_en),
		.data_count(ready_data_count), .dout(readyOut), .empty(readyEmpty), .full(readyFull));
	

	assign packetOut=readyOut;

	//reg [7:0] addrBook;   
	//reg [1:0] addrBookTop; //number of phone numbers in the addressbook
	
	reg [15:0] buffer;
	reg [packetSize:0] packetSizeCounter=0;
	reg [packetSize:0] packetSizeCounter2=0;
	
	reg [1:0] twoCounter=0;
	
	reg cdFlag=0;	
	reg auFlag=0; 

	always @(posedge clk) begin
		if (reset) begin
			cdFlag<=0;
			auFlag<=0;
			twoCounter<=0;
			sending<=0;
			goingToSend<=0;
			busy<=0;
			buffer_wr_en<=0;
			buffer_rd_en<=0;
			ready_wr_en<=0;
			ready_wr_en<=0;
		end else if(cmd==2'b01 && cdFlag==0) begin  //recieving contol data    //assuming the control data is 16 bits
			busy<=1;
			cdFlag<=1;
			buffer<=data[15:0];
			readyIn<=8'b0100_0000;
			ready_wr_en<=1;
			twoCounter<=0;
		end else if (cdFlag==1) begin
			
			if (twoCounter==2'b00) begin
				readyIn<=buffer[15:8];
				twoCounter<=2'b01;
			end else if (twoCounter==2'b01) begin
				readyIn<=buffer[7:0];
				twoCounter<=2'b10;
				packetSizeCounter<=packetSize-3;
			end else if (twoCounter==2'b10) begin
				if (packetSizeCounter==0) begin
					busy<=0;
					cdFlag<=0;
					ready_wr_en<=0;
				end else begin
					packetSizeCounter<=packetSizeCounter-1;
					readyIn<=0;
				end
			end
			
		end else if (cmd==2'b10 && auFlag==0) begin  // recieving audio
				busy<=1;
				auFlag<=1;
				buffer<=data[15:0];
				twoCounter<=0;

		end else if (auFlag==1) begin
			if (bufferEmpty && twoCounter==0) begin
				if (buffer_wr_en==0) begin
					buffer_wr_en<=1;		
					bufferIn<=8'b1000_0000;
				end else buffer_wr_en<=0;
				
			end else if (twoCounter==0) begin
				buffer_wr_en<=1;		
				bufferIn<=buffer[15:8];
				twoCounter<=2'b01;
				
			end else if (twoCounter==2'b01) begin
				bufferIn<=buffer[7:0];
				twoCounter<=2'b10;

				
			end else if (!bufferEmpty && twoCounter==2'b11) begin
				if (buffer_wr_en==1) 
					buffer_wr_en<=0;
				else begin
					readyIn<=bufferOut;
					ready_wr_en<=1;
				end
			end else if (bufferEmpty && twoCounter==2'b11) begin
				twoCounter<=2'b10;
				readyIn<=bufferOut;
			
			end else if (buffer_data_count==packetSize-2) begin  
				bufferIn<=8'b1111_1111;
				twoCounter<=2'b11;					
				buffer_rd_en<=1;
				readyIn<=bufferOut;

			end else begin
				twoCounter<=0;
				busy<=0;
				auFlag<=0;
				buffer_wr_en<=0;
				buffer_rd_en<=0;
				ready_wr_en<=0;
			end
		end	
		
		
		if (goingToSend==1) begin
			if (packetSizeCounter2==1) begin
				ready_rd_en<=0;	
				packetSizeCounter2<=packetSizeCounter2-1;	 
			end else if (packetSizeCounter2==0) begin
				sending<=0;	
				goingToSend<=0;				
			end else begin
				sending<=1;
				packetSizeCounter2<=packetSizeCounter2-1;
			end
		end else if (sendData && (!readyEmpty) ) begin
			ready_rd_en<=1;
			packetSizeCounter2<=packetSize;
			goingToSend<=1;	
		end

	end
	
endmodule