module fp_mult_24b(
                    // clk,
                    a,
                    b,
                    r
);
    parameter N = 24;
    parameter ES = 6;

    // input  wire clk;
    input  wire [N-1:0] a;
    input  wire [N-1:0] b;
    output wire [N-1:0] r;

    FloatingMultiplication_v1 #(.N(N),.ES(ES)) 
                            mult_inst(
                            // .clk(clk),
                            .A(a),
                            .B(b),
                            .result(r)
                            );
endmodule