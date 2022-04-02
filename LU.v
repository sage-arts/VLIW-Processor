module logicUnit(a,b,select,out);
input [63:0] a,b;
input [5:0]select;
output reg[63:0] out;

parameter[5:0] AND =100000,OR =100001,XOR =100110,NAND=6'b100010,NOR =6'b100011,XNOR=6'b100111,NOT =6'b100100,TCM =6'b100101;
always@(a,b,select)
    begin
        case(select)
            AND: 
            begin
                out=a&b;
            end
            XOR:
            begin
                out=a^b;
            end
            NAND:
            begin
                out=~(a&b);
            end
            OR:
            begin
                out=a|b;
            end
            NOT:
            begin
                out=~a;
            end
            NOR:
            begin
                out=~(a|b);
            end
            XNOR:
            begin
                out=~(a^b);
            end
            TCM:
            begin
                out=(~a)+1;
            end//add default case
        endcase
    end
endmodule

/*
module tb_alu;
input clk;  
reg[63:0] a,b;
reg[5:0] select;
wire[63:0] out;

logicUnit test(a,b,select,out);
    initial begin
        #0 a=64'd1232;  b=64'd89454;  select=6'b001010;
        #1 a=64'd1232;  b=64'd89454;  select=6'b001011;
        #2 a=64'd1232;  b=64'd89454;  select=6'b001100;
        #3 a=64'd1232;  b=64'd89454;  select=6'b001101;
        #4 a=64'd1232;  b=64'd89454;  select=6'b001110;
        #5 a=64'd1232;  b=64'd89454;  select=6'b001111;    
        #6 a=64'd1232;  b=64'd89454;  select=6'b010000;
        #7 a=64'd1232;  b=64'd89454;  select=6'b010001;
    end
    initial begin
        $monitor("a=%d b=%d out=%d",a,b,out);
    end
endmodule
*/