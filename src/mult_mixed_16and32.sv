module mult_mixed_16and32(
    clk,
    reset,
    input_valid,
    a,
    b,
    output_valid,
    r
);  
    parameter  WIDTH = 16;
    localparam FP_WIDTH = 32;
    localparam FP_ES = 8;
    input wire clk;
    input wire reset;
    input wire input_valid;
    input wire  [WIDTH-1:0] a;
    input wire  [WIDTH-1:0] b;
    // output wire output_valid;
    output reg  output_valid;
    output wire [WIDTH-1:0] r;

    // reg [WIDTH-1:0] a_reg,b_reg;
    wire [FP_WIDTH-1:0] a_fp,b_fp;
    reg  [FP_WIDTH-1:0] a_fp_reg,b_fp_reg;
    // Posit 16 to float 32 converter
    p16_to_f32 #(.FN(FP_WIDTH),.FE(FP_ES)) conv0(
                .posit_in(a),
                .float_out(a_fp)
            );
    p16_to_f32 #(.FN(FP_WIDTH),.FE(FP_ES)) conv1(
                .posit_in(b),
                .float_out(b_fp)
            );
    wire [FP_WIDTH-1:0] r_fp;
    FloatingMultiplication_v1 #(.N(FP_WIDTH),.ES(FP_ES)) 
                            mult_inst(
                            .A(a_fp_reg),
                            .B(b_fp_reg),
                            .result(r_fp)
                            );
    reg [FP_WIDTH-1:0] r_fp_reg;
    // Float 32 to posit 16 converter
    f32_to_p16 #(.FN(FP_WIDTH),.FE(FP_ES)) conv2(
                .float_in(r_fp_reg),
                .posit_out(r)
            );

    typedef enum reg [1:0] {IDLE,S1,S2,S3} state_t;
    state_t CS,NS;
    // State transition logic
    always @(posedge clk) begin
        if (reset)  CS <= IDLE;
        else        NS <= CS;
    end 
    // Next state logic 
    always_comb begin
        NS = CS;
        case(CS)
            IDLE: NS=(input_valid)? S1:IDLE;
            S1:     NS=S2;
            S2:     NS=S3;
        endcase
    end
    // Output logic
    always @(posedge clk) begin
        if (reset) begin
            output_valid <= 0;
            // r <= 0;
        end
        else begin
            output_valid <= 0;
            case(NS)
                IDLE:;
                S1: begin
                    a_fp_reg <= a_fp;
                    b_fp_reg <= b_fp;
                end
                S2: begin
                    r_fp_reg <= r_fp;
                end
                S3: begin
                    output_valid <= 1;
                end
            endcase
        end
    end
endmodule