module f32_to_p16(
        // clk,
        float_in,
        posit_out
    );
    // Posit parameters
    parameter N = 16;
    parameter es = 1;
    // Float parameters
    parameter FN = 32;
    parameter FE = 8;
    parameter BIAS = 2**(FE-1)-1;
    parameter FS = FN-FE-1;

    // input  wire clk;
    input  wire [FN-1:0] float_in;
    output reg  [N-1:0]  posit_out;
    // output wire [N-1:0]  posit_out;
    
    wire zf,inf; // Zero flag, infinity flag
    assign zf = ~(|float_in[FN-2:0]);
    assign inf = (&float_in[FN-2:FS]);
    wire sign = float_in[FN-1];
    wire [FS-1:0] frac;
    assign frac = float_in[FS-1:0];
    wire signed [FE-1:0] exp;
    assign exp = float_in[FN-2:FS]-BIAS;

    wire [FS+es-1:0] frac1;
    generate 
        if (es==0)  assign frac1 = frac;
        else        assign frac1 = {exp[es-1:0],frac};
    endgenerate

    wire [1:0] regime;
    assign regime = (~exp[FE-1])? 2'b10:2'b01;
    wire signed [FS+es+1:0] frac2;
    assign frac2 = {regime,frac1};

    wire [FE-es-1:0] shift_count;
    assign shift_count = (~exp[FE-1])? exp[FE-1:es]:~exp[FE-1:es];
    
    wire of,uf; // overflow,underflow flag
    assign of = ((exp >=  (2**es)*(N-2)));
    assign uf = ((exp <= -(2**es)*(N-2)));

    reg G,R,S; // Guard bit, Round bit and Sticky bit
    reg [FS-1:0]    frac_shifted;
    reg [FE-es-1:0] shift_count2 ;
    // Rounding to nearest even
    always_comb begin
        G = 0;
        S = 0;
        R = 0;
        frac_shifted = 0;
        if (shift_count == N-3) begin               // Case 1: 0 fraction bits. -3 because of one sign bit and two regime bits 
            G = regime[0];
            R = exp[0];
            S = frac[FS-1] | (|frac[FS-2:0]);       // The expression is |frac[FS-1:0]. written this way to reuse the latter expression and lower LUT count.
        end
        else if (shift_count == N-3-es) begin       // Case 2: es fraction bits. -3 because of one sign bit and two regime bits
            G =  exp[0];
            R =  frac[FS-es];
            S = |frac[FS-es-1:0];
        end
        else begin
            shift_count2 = ((N-3-es-1)-shift_count);// N-3-es-1: 3 because of one sign bit and two regime bits,-1 because we need to check the Guard bit.
            frac_shifted = frac << shift_count2;    
            G =  frac_shifted[FS-1];
            R =  frac_shifted[FS-2];
            S = |frac_shifted[FS-3:0];
        end
    end

    wire RNE;
    assign RNE = (R & (G | S));
    wire [N-1:0]  posit_out_temp;
    generate
        if ((FS+es+1)>N) begin
            wire [FS+es+1:0] frac3;
            assign frac3 = frac2 >>> shift_count;
            assign posit_out_temp = (RNE)? {1'b0,frac3[(FS+es+1)-:N-1]}+1'b1:{1'b0,frac3[(FS+es+1)-:N-1]}+1'b0; // TODO: Fix this expression for N = 32
        end
        else begin
            wire [N-1:0] frac3;
            assign frac3 = {frac2,{(FS+es+1-N){1'b0}}} >>> shift_count;
            assign posit_out_temp = (RNE)? {1'b0,frac3[N-1:1]}+1'b1:{1'b0,frac3[N-1:1]}+1'b0; 
        end
    endgenerate

    // Posit packing and exception handling
    always_comb begin
        if (zf)         posit_out = {N{1'b0}};
        else if (inf)   posit_out = {1'b1,{(N-1){1'b0}}}; 
        else if (uf)    posit_out = (sign)? -{{(N-1){1'b0}},1'b1} : {{(N-1){1'b0}},1'b1}; // Min pos: 16'h0001
        else if (of)    posit_out = (sign)? -{1'b0,{(N-1){1'b1}}} : {1'b0,{(N-1){1'b1}}}; // Max pos: 16'h7FFF
        else            posit_out = (sign)? -posit_out_temp:posit_out_temp;
    end

endmodule