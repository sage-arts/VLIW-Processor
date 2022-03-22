`include "ADD.v"

module swap(input [63:0]in1, input [63:0]in2, output reg [63:0]out1, output reg [63:0]out2);
    always @(in1 or in2)
    begin
        if(in2[62:0]>in1[62:0])
        begin
            out2 = in1;
            out1 = in2;
        end
        else
        begin
            out1 = in1;
            out2 = in2;
        end
    end

endmodule

module shifter(input [63:0]A, input [10:0]shift, output [63:0]B);
    assign B = A>>shift;
endmodule

module split(input [63:0]A, output sign, output [10:0]exp, output [51:0]man);
    assign sign = A[63];//64 bits
    assign exp  = A[62:52];//11 bits
    assign man  = A[51:0];//52 bits
endmodule

module FLA(I1,I2,Final_exp);
    input[63:0] I1,I2;//-->64bits
    output reg [63:0]Final_exp;
    wire[63:0] A,B;
    swap SW(I1,I2,A,B);//First step check whether I1 > I2 and swap accordingly 
        	           // to store bigger number in A and smaller in B

    wire S1,S2;       //Sign-------->1 bit 
    wire [10:0] E1,E2;//Exponents -->11 bits
    wire [51:0] M1,M2;//mantissas -->52 bits

    split SP1(A,S1,E1,M1);//Split A into S1,E1,M1
    split SP2(B,S2,E2,M2);//Split B into S2,E2,M2

    wire [10:0]Expdiff;//Storing the Exponent difference
    assign Expdiff = E1-E2;

    wire [63:0] T1,T2,T3; //temp variables to
    assign T1= {|E1,M1};  //for handling zeores and //OR of all the bits of E1
    assign T2= {|E2,M2};

    shifter BS(T2,Expdiff,T3);//Shifting the mantissa of B by Expdiff and storing in T3
    wire [63:0]T4;
    assign T4 = {64{S1^S2}}^T3;//Caluculate the 1's complement in case of different signs

    wire [63:0]Sum;
    wire Carry;
    adder C1(T1,T4,S1^S2,Sum,Carry);//Calculate the sum of the two numbers and store in Sum

    reg [51:0] M3,tmp;//variable for final result and temp mantissa
    reg [10:0] E3;

    integer i=0;
    //normalize the final result
    always @(Sum)
    begin
        //Overflow of mantissa
        if(Sum[53]==1)
        begin 
            M3=Sum[52:1];
            E3 = E1 + 1'b1;
        end
        else if(Sum[52]==0)
        begin
        //underflow of mantissa
            i=1;
            while(Sum[52-i]==1'b0)
            begin
                i=i+1;
            end
            E3=E1-i;
            tmp=Sum[51:0];
            M3=tmp<<i;
        end
        else
        // normal case
        begin
            M3=Sum[51:0];
            E3=E1;
        end
    end

    
    always@(*) begin
        //either one of the numbers is infinity
        if(&E1 == 1'b1 || &E2 == 1'b1) begin
            Final_exp = 64'b0_11111111111_1111111111111111111111111111111111111111111111111111;	
        end
        //if first number is zero
        else if((|E1== 1'b0) && (|M1[51:0]== 1'b0)) begin
            Final_exp = {S2,E2,M2[51:0]};
        end
        //if second number is zero
        else if((|E2== 1'b0) && (|M2[51:0]== 1'b0)) begin
            Final_exp = {S1,E1,M1[51:0]};
        end
        //result is zero
        else if(Sum[63:0] == 63'b0) begin
            Final_exp=64'b0;
        end
        else begin
            Final_exp = {S1,E3,M3};
        end
    end

endmodule

/*
module tb;
    reg[63:0] I1,I2;//-->64bits
    wire[63:0] Sum;
    FLA test(I1,I2,Sum);
    initial
    begin
        #0  I1=64'b0000000000000000000000000000000000000000000000000000000001101110;
            I2=64'b0000000000000000000000000000000000000000000000000000000000110111;

                         //(6)+(8)=(14.0)
             //result = 0 10000000010 1100000000000000000000000000000000000000000000000000 
                     
        #1  I1={1'b1,{11'b10000000100},52'b0110111100011110101110000101000111101011100001010010}; 
            I2={1'b0,{11'b10000000100},52'b0001011111010111000010100011110101110000101000111101};
             //(-45.89)+(34.98)=(-10.910000000000004)
             //result = 1 10000000010 0101110100011110101110000101000111101011100001010100
                     // 1 10000000010 0101110100011110101110000101000111101011100001010100   

        #2  I1={1'b0,{11'b10000001100},52'b0011010100100111001000001100010010011011101001011110}; 
            I2={1'b1,{11'b10000001100},52'b0001011111100111111000000100110110011000001110010100};  
             //(9892.891)+(-8956.984523)=(935.9064770000005)
             //result=0100000010001101001111110100000001110111000000110110110010100000
                      
        #3  I1={1'b0,{11'b00000000000},52'b0000000000000000000000000000000000000000000000000000}; 
            I2={1'b0,{11'b10000000010},52'b1001000111101011100001010001111010111000010100011111}; 
            //(0)+(12.56)=(12.56)
            //result=0100000000101001000111101011100001010001111010111000010100011111

        #4  I2={1'b0,{11'b00000000000},52'b0000000000000000000000000000000000000000000000000000}; 
            I1={1'b0,{11'b10000000010},52'b1001000111101011100001010001111010111000010100011111}; 
            //(12.56)+(0)=(12.56)
            //result=0100000000101001000111101011100001010001111010111000010100011111

    end
    initial
    begin
        $monitor("A=%b \nB=%b \nC=%b \n",I1,I2,Sum);
        $dumpfile("DPA.vcd");
		$dumpvars;
    end
endmodule
*/
