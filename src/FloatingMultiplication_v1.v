`timescale 1ns / 1ps
// v1: IO parameterization complete
// ref:https://github.com/akilm/FPU-IEEE-754
module FloatingMultiplication_v1(
                                // clk,
                                A,
                                B,
                                result
                            );

parameter N = 32;
parameter ES = 8;
parameter SS = N-ES-1;
parameter BIAS = 2**(ES-1)-1;

// input  wire clk;
input  wire [N-1:0] A;
input  wire [N-1:0] B;
output wire [N-1:0] result;

wire [SS:0] A_Mantissa = {1'b1, A[SS-1:0]}, B_Mantissa = {1'b1, B[SS-1:0]};
wire [ES-1:0] A_Exponent = A[N-2:SS], B_Exponent = B[N-2:SS];
wire A_sign = A[N-1], B_sign = B[N-1];

reg [2*SS+1:0] Temp_Mantissa;
wire [SS-1:0] Mantissa = Temp_Mantissa[2*SS-1:SS];  // highest bits of Temp_Mantissa, except for 1 carry bit (which causes bitshift)
reg [ES:0] Temp_Exponent;  // one bit bigger because of potential overflow
reg [ES-1:0] Exponent;
reg Sign;

assign result = {Sign, Exponent, Mantissa};

always@(*)
begin
Temp_Exponent = (A_Exponent + B_Exponent < BIAS) ? {ES{1'b0}} : A_Exponent + B_Exponent - BIAS;  // prevent exponent underflow
Temp_Mantissa = A_Mantissa*B_Mantissa;
Exponent = Temp_Exponent[ES-1:0];
// "carry"... increase exponent, shift
if (Temp_Mantissa[2*SS+1]) begin
    Temp_Mantissa = Temp_Mantissa << 1;  // Mantissa = Temp_Mantissa[46:24]
    Exponent = Exponent + 1;
end

// prevent exponent overflow
// if (Exponent[8])
if (Temp_Exponent[ES])
    Exponent = {ES{1'b1}};

Sign = A_sign^B_sign;
end
endmodule