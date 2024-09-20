module p16_to_f32(
    // clk,
    posit_in,
    float_out
);
    // Posit parameters
    parameter N = 16;
    parameter es = 1;
    parameter rs = $clog2(N);
    // Float parameters
    parameter FN = 32;
    parameter FE = 8;
    parameter BIAS = 2**(FE-1)-1;

    // input  wire clk;
    input  wire [N-1:0]  posit_in;
    output reg  [FN-1:0] float_out;

    wire zf; // Zero flag
    assign zf = ~(|posit_in[N-2:0]);
    wire sign;
    wire [N-2:0] posit_abs;
    // Step 1: Seperate the sign bit and get the absolute value
    assign sign = posit_in[N-1];
    assign posit_abs = (sign)? -(posit_in[N-2:0]):(posit_in[N-2:0]);
    // Step 2: Decode posit input and seperate regime,exponent and fractions
    wire rc;
    wire [rs-1:0]   posit_regime;
    wire [es-1:0]   posit_exp;
    wire [N-es-1:0] posit_mant;

    data_extract_v2 #(.N(N),.es(es)) uut_de2(.in({sign,posit_abs}), .rc(rc), .regime(posit_regime), .exp(posit_exp), .mant(posit_mant));

    // Step 3: Compute frlat exponent by adding bias
    wire [FE-1:0] exp,tmp_exp;
    assign tmp_exp = {{(FE-rs-1){~rc}},posit_regime,posit_exp};
    assign exp = tmp_exp + BIAS;
    // Step 4: Compute float significand by concatenating zeros at the end (lsb)
    wire [FN-FE-2:0] tmp_frac;
    assign tmp_frac = {posit_mant,{(FN-FE-N+es-1){1'b0}}};
    always_comb begin
    // always @ (posedge clk) begin
        if (sign && zf)         float_out = {1'b0,{(FE){1'b1}},{(FN-FE-1){1'b0}}};
        else if (~sign && zf)   float_out = {FN{1'b0}};
        else                    float_out = {sign,exp,tmp_frac};
    end
endmodule

module data_extract_v2(in, rc, regime, exp, mant);
    // Negative value of k is returned if the regime MSB is zero
    function [31:0] log2;
    input reg [31:0] value;
        begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
                value = value>>1;
            end
    endfunction

    parameter N=16;
    parameter Bs=log2(N);
    parameter es = 2;

    input [N-1:0] in;
    output rc;
    output [Bs-1:0] regime;
    output [es-1:0] exp;
    output [N-es-1:0] mant;

    wire [N-1:0] xin = in;
    assign rc = xin[N-2];

    wire [N-1:0] xin_r = rc ? ~xin : xin;

    wire [Bs-1:0] k;
    LOD_N #(.N(N)) xinst_k(.in({xin_r[N-2:0],rc^1'b0}), .out(k));

    assign regime = rc ? k-1 : -k;

    wire [N-1:0] xin_tmp;
    DSR_left_N_S #(.N(N), .S(Bs)) ls (.a({xin[N-3:0],2'b0}),.b(k),.c(xin_tmp));

    assign exp= xin_tmp[N-1:N-es];
    assign mant= xin_tmp[N-es-1:0];
endmodule

module DSR_left_N_S(a,b,c);
    parameter N=16;
    parameter S=4;
    input [N-1:0] a;
    input [S-1:0] b;
    output [N-1:0] c;

    wire [N-1:0] tmp [S-1:0];
    assign tmp[0]  = b[0] ? a << 7'd1  : a; 
    genvar i;
    generate
        for (i=1; i<S; i=i+1)begin:loop_blk
            assign tmp[i] = b[i] ? tmp[i-1] << 2**i : tmp[i-1];
        end
    endgenerate
    assign c = tmp[S-1];
endmodule

module LOD_N (in, out);

    function [31:0] log2;
        input reg [31:0] value;
        begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
        value = value>>1;
        end
    endfunction

    parameter N = 64;
    parameter S = log2(N); 
    input [N-1:0] in;
    output [S-1:0] out;

    wire vld;
    LOD #(.N(N)) l1 (in, out, vld);
endmodule

module LOD (in, out, vld);

    function [31:0] log2;
        input reg [31:0] value;
        begin
            value = value-1;
            for (log2=0; value>0; log2=log2+1)
                value = value>>1;
        end
    endfunction

    parameter N = 64;
    parameter S = log2(N);

    input [N-1:0] in;
    output [S-1:0] out;
    output vld;

    generate
        if (N == 2)
        begin
            assign vld = |in;
            assign out = ~in[1] & in[0];
        end
        else if (N & (N-1))
            //LOD #(1<<S) LOD ({1<<S {1'b0}} | in,out,vld);
            LOD #(1<<S) LOD ({in,{((1<<S) - N) {1'b0}}},out,vld);
        else
        begin
            wire [S-2:0] out_l, out_h;
            wire out_vl, out_vh;
            LOD #(N>>1) l(in[(N>>1)-1:0],out_l,out_vl);
            LOD #(N>>1) h(in[N-1:N>>1],out_h,out_vh);
            assign vld = out_vl | out_vh;
            assign out = out_vh ? {1'b0,out_h} : {out_vl,out_l};
        end
    endgenerate
endmodule