module kpg_init (
	output reg out1, out0,
	input a, b
);//00-Kill 11-Generate 01/10-Propagate
	always @*
	case ({a, b})
		2'b00: begin
			out0 = 1'b0; out1 = 1'b0;
		end
		2'b11: begin
			out0 = 1'b1; out1 = 1'b1;
		end
		default: begin 
			out0 = 1'b0; out1 = 1'b1;
		end
	endcase

endmodule

module kpg (
	input cur_bit_1, cur_bit_0, prev_bit_1, prev_bit_0,
	output reg out_bit_1, out_bit_0
);
	always @(*)
	begin
	
		if({cur_bit_1, cur_bit_0} == 2'b00)
			{out_bit_1, out_bit_0} = 2'b00;
		
		if({cur_bit_1, cur_bit_0} == 2'b11)
			{out_bit_1, out_bit_0} = 2'b11;

		if({cur_bit_1, cur_bit_0} == 2'b10)
			{out_bit_1, out_bit_0} = {prev_bit_1, prev_bit_0};

	end

endmodule

module adder(a, b, cin ,sum, cout);
	input [63:0] a, b;
	input cin;
	output reg[63:0] sum;
	output reg cout;
	wire [64:0] carry0, carry1;
	wire [64:0] carry0_1, carry1_1, carry0_2, carry1_2, carry0_4, carry1_4, carry0_8, carry1_8, carry0_16, carry1_16, carry0_32, carry1_32;

	assign carry0[0] = cin;
	assign carry1[0] = cin;

	always @(*)
	begin
		sum = a^b;
		sum = sum[63:0]^carry0_32[63:0];
		cout = carry0_32[64];	
	end 
	
	
	kpg_init init [64:1](carry1[64:1], carry0[64:1], a[63:0], b[63:0]);

	assign carry1_1[0] = cin;
	assign carry0_1[0] = cin;

	assign carry1_2[1:0] = carry1_1[1:0];
	assign carry0_2[1:0] = carry0_1[1:0];

	assign carry1_4[3:0] = carry1_2[3:0];
	assign carry0_4[3:0] = carry0_2[3:0];

	assign carry1_8[7:0] = carry1_4[7:0];
	assign carry0_8[7:0] = carry0_4[7:0];

	assign carry1_16[15:0] = carry1_8[15:0];
	assign carry0_16[15:0] = carry0_8[15:0];

	assign carry1_32[31:0] = carry1_16[31:0];
	assign carry0_32[31:0] = carry0_16[31:0];
	
	//kpg(input cur_bit_1, cur_bit_0, prev_bit_1, prev_bit_0,output reg out_bit_1, out_bit_0)
	kpg itr_1 [64:1] (carry1[64:1],   carry0[64:1], carry1[63:0], carry0[63:0], carry1_1[64:1], carry0_1[64:1]);
	kpg itr_2 [64:2] (carry1_1[64:2], carry0_1[64:2], carry1_1[62:0], carry0_1[62:0], carry1_2[64:2], carry0_2[64:2]);
	kpg itr_4 [64:4] (carry1_2[64:4], carry0_2[64:4], carry1_2[60:0], carry0_2[60:0], carry1_4[64:4], carry0_4[64:4]);
	kpg itr_8 [64:8] (carry1_4[64:8], carry0_4[64:8], carry1_4[56:0], carry0_4[56:0], carry1_8[64:8], carry0_8[64:8]);
	kpg itr_16[64:16](carry1_8[64:16], carry0_8[64:16], carry1_8[48:0], carry0_8[48:0], carry1_16[64:16], carry0_16[64:16]);
	kpg itr_32[64:32](carry1_16[64:32], carry0_16[64:32], carry1_16[32:0], carry0_16[32:0], carry1_32[64:32], carry0_32[64:32]);

endmodule

module SUB(a,b,cin,sum,cout);
input [63:0] a;
input [63:0] b;
input cin;
output reg [63:0] sum;
output reg cout;
reg [64:0] c;
integer i;
always @ (a or b or cin)
    begin
        c[0]=cin;
        if (cin == 1'b0) 
        begin
            for ( i=0; i<64 ; i=i+1)
            begin
                sum[i]= a[i]^b[i]^c[i];
                c[i+1]= (a[i]&b[i])|(a[i]&c[i])|(b[i]&c[i]);
            end
        end
    else if (cin == 1'b1) 
    begin
        for ( i=0; i<64 ; i=i+1)
        begin
            sum[i]= a[i]^(~ b[i])^c[i];
            c[i+1]= (a[i]&(~b[i]))|(a[i]&c[i])|((~b[i])&c[i]);
        end
    end
    cout=c[64];
    end
endmodule