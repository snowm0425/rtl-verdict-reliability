module float_multi (
    input clk,              // Clock signal for synchronization
    input rst,              // Reset signal (active high)
    input [31:0] a,         // First operand in IEEE 754 format
    input [31:0] b,         // Second operand in IEEE 754 format
    output reg [31:0] z     // Result of the multiplication in IEEE 754 format
);

    // Internal signals
    reg [2:0] counter;      // Cycle counter for operation sequencing
    reg [23:0] a_mantissa, b_mantissa, z_mantissa; // Mantissas of input and output numbers
    reg [9:0] a_exponent, b_exponent, z_exponent;   // Exponents of input and output numbers
    reg a_sign, b_sign, z_sign;                    // Sign bits for inputs and output
    reg [49:0] product;                            // Intermediate product of the mantissas
    reg guard_bit, round_bit, sticky;              // Rounding control bits

    // Constants for IEEE-754 single-precision
    localparam EXP_BIAS = 127;
    localparam EXP_INF = 255;
    localparam EXP_ZERO = 0;

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            z <= 32'b0;
        end else begin
            case (counter)
                0: begin
                    // Extract sign, exponent, and mantissa from inputs
                    a_sign = a[31];
                    a_exponent = a[30:23];
                    a_mantissa = {1'b1, a[22:0]}; // Add implicit leading 1 for normalization

                    b_sign = b[31];
                    b_exponent = b[30:23];
                    b_mantissa = {1'b1, b[22:0]}; // Add implicit leading 1 for normalization

                    // Handle special cases
                    if (a_exponent == EXP_INF || b_exponent == EXP_INF) begin
                        // Infinity * 0 or Infinity * any number = Infinity
                        if ((a_exponent == EXP_INF && a_mantissa == 24'b0 && a_sign != b_sign) ||
                            (b_exponent == EXP_INF && b_mantissa == 24'b0 && a_sign != b_sign)) begin
                            z <= {a_sign ^ b_sign, EXP_INF, 23'b0}; // NaN result
                        end else begin
                            z <= {a_sign ^ b_sign, EXP_INF, 23'b0}; // Infinity result
                        end
                    end else if (a_exponent == EXP_ZERO && a_mantissa == 24'b0) begin
                        // 0 * any number = 0
                        z <= 32'b0;
                    end else if (b_exponent == EXP_ZERO && b_mantissa == 24'b0) begin
                        // any number * 0 = 0
                        z <= 32'b0;
                    end else if (a_exponent == EXP_INF && b_exponent == EXP_INF) begin
                        // Infinity * Infinity = Infinity
                        z <= {a_sign ^ b_sign, EXP_INF, 23'b0};
                    end else begin
                        // Normal multiplication
                        z_sign = a_sign ^ b_sign;
                        z_exponent = a_exponent + b_exponent - EXP_BIAS;
                        product = a_mantissa * b_mantissa;
                        counter <= 1;
                    end
                end
                1: begin
                    // Normalize the product
                    if (product[48]) begin
                        z_mantissa = product[47:24];
                        round_bit = product[23];
                        guard_bit = product[22];
                        sticky = |product[21:0];
                    end else begin
                        z_mantissa = product[46:23];
                        round_bit = product[22];
                        guard_bit = product[21];
                        sticky = |product[20:0];
                        z_exponent = z_exponent - 1;
                    end
                    counter <= 2;
                end
                2: begin
                    // Rounding and adjustment
                    if (round_bit && (guard_bit || sticky || z_mantissa[0])) begin
                        z_mantissa = z_mantissa + 1;
                        if (z_mantissa == 25'b1000000000000000000000000) begin
                            z_exponent = z_exponent + 1;
                            z_mantissa = 24'b100000000000000000000000;
                        end
                    end
                    // Handle overflow
                    if (z_exponent > EXP_INF) begin
                        z <= {z_sign, EXP_INF, 23'b0}; // Overflow to infinity
                    end
                    // Handle underflow
                    else if (z_exponent <= EXP_ZERO) begin
                        if (z_exponent < EXP_ZERO - 23) begin
                            z <= 32'b0; // Underflow to zero
                        end else begin
                            // Denormalize
                            z_mantissa = z_mantissa >> (EXP_ZERO - z_exponent);
                            z_exponent = EXP_ZERO;
                            z <= {z_sign, z_exponent, z_mantissa[22:0]};
                        end
                    end else begin
                        z <= {z_sign, z_exponent, z_mantissa[22:0]};
                    end
                    counter <= 0;
                end
            endcase
        end
    end

endmodule