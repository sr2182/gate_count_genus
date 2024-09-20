module posit_divider_16(
        clk,
        a,
        b,
        input_valid,
        r,
        output_valid,
        inf,
        zero
    );
    parameter N=16; // Num bits (posit)
    parameter es=1; // Exponent size

    input  wire clk;
    input  wire [N-1:0] a; 
    input  wire [N-1:0] b; 
    input  wire input_valid;
    output wire [N-1:0] r;
    output wire output_valid;
    output wire inf; 
    output wire zero;

    div_N32_ES6_PIPE12 #(.N(N),.es(es)) div_inst(
        .clk(clk), 
        .in1(a), 
        .in2(b), 
        .start(input_valid), 
        .out(r), 
        .inf(inf), 
        .zero(zero), 
        .done(output_valid)
    ); 
endmodule 