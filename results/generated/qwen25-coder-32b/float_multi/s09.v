module float_multi (
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] z
);

    // Internal signals
    reg [2:0] counter;
    reg [23:0] a_mantissa, b_mantissa, z_mantissa;
    reg [9:0] a_exponent, b_exponent, z_exponent;
    reg a_sign, b_sign, z_sign;
    reg [49:0] product;
    reg guard_bit, round_bit, sticky;

    // Special case flags
    reg a_nan, b_nan, a_inf, b_inf, a_zero, b_zero;

    // Initialize all signals
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            z <= 32'h0;
        end else begin
            case (counter)
                0: begin
                    // Extract sign, exponent, and mantissa from inputs
                    a_sign = a[31];
                    b_sign = b[31];
                    a_exponent = a[30:23];
                    b_exponent = b[30:23];
                    a_mantissa = a[22:0];
                    b_mantissa = b[22:0];

                    // Handle special cases
                    a_nan = (a_exponent == 10'b11111111) && (a_mantissa != 0);
                    b_nan = (b_exponent == 10'b11111111) && (b_mantissa != 0);
                    a_inf = (a_exponent == 10'b11111111) && (a_mantissa == 0);
                    b_inf = (b_exponent == 10'b11111111) && (b_mantissa == 0);
                    a_zero = (a_exponent == 10'b00000000) && (a_mantissa == 0);
                    b_zero = (b_exponent == 10'b00000000) && (b_mantissa == 0);

                    // Handle NaN and infinity cases
                    if (a_nan || b_nan) begin
                        z <= 32'hFFC00000; // NaN result
                    end else if (a_inf || b_inf) begin
                        if (a_zero || b_zero) begin
                            z <= 32'hFFC00000; // NaN result
                        end else begin
                            z_sign = a_sign ^ b_sign;
                            z_exponent = 10'b11111111;
                            z_mantissa = 0;
                            z <= {z_sign, z_exponent, z_mantissa};
                        end
                    end else begin
                        // Normalize mantissas
                        a_mantissa = {1'b1, a_mantissa};
                        b_mantissa = {1'b1, b_mantissa};

                        // Calculate sign of result
                        z_sign = a_sign ^ b_sign;

                        // Add exponents
                        z_exponent = a_exponent + b_exponent - 127;

                        // Multiply mantissas
                        product = a_mantissa * b_mantissa;

                        // Prepare for rounding and normalization
                        guard_bit = product[23];
                        round_bit = product[22];
                        sticky = |product[21:0];

                        // Normalize the product
                        if (product[49]) begin
                            z_mantissa = product[48:25];
                            z_exponent = z_exponent + 1;
                        end else begin
                            z_mantissa = product[47:24];
                        end

                        // Round the result
                        if (guard_bit && (round_bit || sticky)) begin
                            z_mantissa = z_mantissa + 1;
                            if (z_mantissa == 24'h1000000) begin
                                z_exponent = z_exponent + 1;
                                z_mantissa = 24'h800000;
                            end
                        end

                        // Check for overflow and underflow
                        if (z_exponent > 254) begin
                            z_exponent = 255;
                            z_mantissa = 0;
                            z <= {z_sign, z_exponent, z_mantissa}; // Infinity
                        end else if (z_exponent < 1) begin
                            if (z_exponent == 0) begin
                                z_mantissa = {z_mantissa[22:0], 1'b0}; // Denormalize
                            end else begin
                                z_mantissa = 0;
                            end
                            z_exponent = 0;
                            z <= {z_sign, z_exponent, z_mantissa}; // Zero or Denormal
                        end else begin
                            z <= {z_sign, z_exponent, z_mantissa};
                        end
                    end

                    counter <= 1;
                end
                default: begin
                    counter <= 0;
                end
            endcase
        end
    end
endmodule