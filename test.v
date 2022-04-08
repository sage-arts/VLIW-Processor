`include "LU.v"
module test;
reg [63:0] n1;
reg [63:0] n2;
reg [5:0] opcode;
wire [63:0] out;
logicUnit k(n1, n2, opcode ,out);
initial begin
#0 n1 = 64'b0000000000000000000000000000000000000000000000000000000001111010; n2 = 64'b0000000000000000000000000000000000000000000000000000000000110101; opcode=6'b100000;
end
initial begin
$monitor("%b",out);
end
endmodule
