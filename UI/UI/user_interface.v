`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:49:56 11/15/2012 
// Design Name: 
// Module Name:    user_interface 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module user_interface(
    input clk,
    input s7,
    input s6,
    input s5,
    input s4,
    input s3,
    input s2,
    input s1,
    input b3,
    input b2,
    input b1,
    input b0,
    input reset,
    input enter,
    input up,
    input down,
    input left,
    input right,
    output address,
    output command,
	output text,
    output state
    );
	
	//states
	parameter [2:0] idle=0; //no current calls
	parameter [2:0] incoming=3'b1; //user is being called
	parameter [2:0] initiate=3'b2; //user calls another party
	parameter [2:0] busy=3'b3; //call in progress
	parameter [2:0] call_while_busy=3'b4; //user in call, receiving incoming call
	parameter [2:0] initialize=3'b5;
	
	//menu parameters
	parameter [4:0] welcome=0; //initial welcome message
	parameter [4:0] sys_time=5'b1; //system date and time
	parameter [4:0] main_menu=5'b2;
	parameter [4:0] call_number=5'b3; //for initiating calls
	parameter [4:0] set_volume=5'b4; //headphone volume
	parameter [4:0] voicemail=5'b5; 
	parameter [4:0] configure_voicemail=5'b6; //toggle feature on/off
	parameter [4:0] new_voicemail=5'b7; 
	parameter [4:0] saved_voicemail=5'b8; 
	parameter [4:0] call_block=5'b9; 
	parameter [4:0] configure_block=5'b10; //toggle feature on/off
	parameter [4:0] view_block=5'b11;
	parameter [4:0] add_block=5'b12;
	parameter [4:0] delete_block=5'b13;
	parameter [4:0] delete_all_block=5'b14;
	parameter [4:0] call_fwd=5'b15;
	parameter [4:0] configure_fwd=5'b16;
	parameter [4:0] configure_fwd=5'b16;
	
	
	
	
	
	
	reg [2:0] state=idle;
	
	always @(posedge clk) begin
	end
	
	


endmodule
