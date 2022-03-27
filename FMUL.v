`include "MUL.v"

module Split(input [63:0]A, output sign, output [10:0]exp, output [51:0]man);
    assign sign = A[63];
    assign exp  = A[62:52];
    assign man  = A[51:0];
endmodule

module FLM(Exp1,Exp2,Final_exp);
    input [63:0] Exp1,Exp2;   //inputs
    output reg [63:0] Final_exp;
    wire S1,S2,S3;          //Signs
    wire [10:0] E1,E2;       //Exponents
    wire [51:0] M1,M2;      //Mantissa

    reg [51:0]M3;       //Final Mantissa
    reg [10:0]E3;        //Final Exponent

    //SPLIT phase
    Split SP1(Exp1,S1,E1,M1);
    Split SP2(Exp2,S2,E2,M2);

    //MULTIPLICATION
    wire [63:0] N1,N2;   //TEMPORARY VAR
	wire [127:0] N3;
    wire [10:0] temp_E3;

    assign N1 = {{11'b0},|E1,M1};   //Reduction xor for handle zeroes
    assign N2 = {{11'b0},|E2,M2};   //and denormal numbers
   
    assign temp_E3=E1+E2-1023; //adding the exponents and subtracting the bias to obtaim final exponent
    assign S3=S1^S2; //xor of sign bits to determine the final sign 
    
    Multiplier w(N2,N1,N3);

   //NORMALISING
	always@(*)	
	begin
		if(N3[105]==1)
		begin
            M3=N3[104:53]; //rounding off
            E3=temp_E3+1; //incrementing exponent by 1
        end
        else
        begin
            M3=N3[103:52]; //rounding off phase
            E3=temp_E3;
        end
        if(temp_E3>=2047)
            E3=11'b11111111111;
	end

    //Checking various cases
    always@(*)
    begin
        if(&E1 == 1'b1 && |M1 == 1'b0)              //INFINITY
            Final_exp={1'b0,11'b11111111111,52'b0};
        else if(&E2 == 1'b1 && |M2 == 1'b0)         //INFINITY
            Final_exp={1'b0,11'b11111111111,52'b0};
        else if(|E1 == 1'b0 && |M1 == 1'b0)         //ZERO
            Final_exp={64'b0};
        else if(|E2 == 1'b0 && |M2 == 1'b0)         //ZERO
            Final_exp={64'b0};
        else                                        //NORMAL CASE
            Final_exp={S3,E3,M3};
    end

endmodule


module tb;
    reg [63:0] Exp1,Exp2;   //inputs
    wire [63:0] Final_exp;
	//TESTBENCHING
    FLM test(Exp1,Exp2,Final_exp);
    initial
    begin
        #0  Exp1=64'b0000000000000000000000000000000000000000000000000000000000110111;//100.25
	        Exp2=64'b0000000000000000000000000000000000000000000000000000000000110111;//6.088
			
		#10 Exp1=64'b1100000001011001000100000000000000000000000000000000000000000000;//-100.25
	        Exp2=64'b1100000000011000010110100001110010101100000010000011000100100111;//-6.088
			
		#10 Exp1=64'b0100000001011001000100000000000000000000000000000000000000000000;//100.25
	        Exp2=64'b1100000000011000010110100001110010101100000010000011000100100111;//-6.088
			
		#10 Exp1=64'b1100000001011001000100000000000000000000000000000000000000000000;//-100.25
	        Exp2=64'b0100000000011000010110100001110010101100000010000011000100100111;//6.088
				
		#10 Exp1=64'b0000000000000000000000000000000000000000000000000000000000000000;//0
	        Exp2=64'b0100000001011001000100000000000000000000000000000000000000000000;//100.25
			
		#10 Exp1=64'b0100000000011000010110100001110010101100000010000011000100100111;//6.088
	        Exp2=64'b0111111111110000000000000000000000000000000000000000000000000000;//infinity
    end
    initial
    begin
        $monitor("\nExp1: %b\nExp2: %b\nPROD: %b\n",Exp1,Exp2,Final_exp);
    end
endmodule

