////////////////////////////////////////////////////////////////////////////////
// Engineer: Kiarash Adl
// Module Name:  CompleteTest  test bench
////////////////////////////////////////////////////////////////////////////////

module complete_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [3:0] oneInp;
	reg [3:0] twoInp;

	// Outputs
	wire [3:0] onecurrent_state;
	wire [3:0] twocurrent_state;

	// Instantiate the Unit Under Test (UUT)
	complete uut (
		.clk(clk), 
		.reset(reset), 
		.oneInp(oneInp), 
		.twoInp(twoInp), 
		.onecurrent_state(onecurrent_state), 
		.twocurrent_state(twocurrent_state)
	);

	always #5 clk=!clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		oneInp = 0;
		twoInp = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		oneInp=4'h1;
		#500;
		twoInp=4'h5;
		
		

	end
      
endmodule

