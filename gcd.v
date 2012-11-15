module gcd(
  input clk,start,
  input [15:0] Ain,Bin,
  output reg [15:0] answer,
  output reg done
);

  reg [15:0] a,b;
  always @ (posedge clk) begin
    if (start) begin a <= Ain; b <= Bin; done <= 0; end
    else if (b == 0) begin answer <= a; done <= 1; end
    else if (a > b) a <= a - b;
    else b <= b - a;
  end
endmodule
