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

    // Initialization
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            z <= 32'b0;
        end else begin
            case (counter)
                0: begin // Extract sign, exponent, and mantissa
                    a_sign = a[31];
                    b_sign = b[31];
                    a_exponent = a[30:23];
                    b_exponent = b[30:23];
                    a_mantissa = {1'b1, a[22:0]}; // Hidden bit for normalized numbers
                    b_mantissa = {1'b1, b[22:0]};
                    counter <= counter + 1;
                end
                1: begin // Handle special cases and normalize
                    // Handle NaN and Infinity
                    if (a_exponent == 10'b11111111 || b_exponent == 10'b11111111) begin
                        if (a_mantissa != 24'b0 || b_mantissa != 24'b0) begin // NaN
                            z <= {a_sign ^ b_sign, 10'b11111111, 23'b1}; // NaN result
                        end else begin // Infinity
                            z_sign = a_sign ^ b_sign;
                            z_exponent = 10'b11111111;
                            z_mantissa = 24'b0;
                            counter <= 3; // Skip multiplication
                        end
                    end else if (a_exponent == 0 || b_exponent == 0) begin // Zero or Denormal
                        if (a_exponent == 0) begin
                            a_exponent = 10'b0;
                            a_mantissa = a[22:0];
                        end
                        if (b_exponent == 0) begin
                            b_exponent = 10'b0;
                            b_mantissa = b[22:0];
                        end
                        counter <= 2;
                    end else begin
                        counter <= 2;
                    end
                end
                2: begin // Perform multiplication
                    product = a_mantissa * b_mantissa;
                    counter <= 3;
                end
                3: begin // Calculate sign, exponent, and normalize result
                    z_sign = a_sign ^ b_sign;
                    z_exponent = a_exponent + b_exponent - 127;
                    z_mantissa = product[47:24];
                    guard_bit = product[23];
                    round_bit = product[22];
                    sticky = |product[21:0];
                    // Normalize the result
                    if (z_mantissa[23] == 0) begin
                        z_mantissa = {z_mantissa[22:0], guard_bit};
                        z_exponent = z_exponent - 1;
                        guard_bit = round_bit;
                        round_bit = sticky;
                        sticky = 1'b0;
                    end
                    counter <= 4;
                end
                4: begin // Rounding
                    if (guard_bit && (round_bit || sticky || z_mantissa[0])) begin
                        z_mantissa = z_mantissa + 1;
                        if (z_mantissa[23] == 1) begin // Handle overflow
                            z_exponent = z_exponent + 1;
                            z_mantissa = z_mantissa >> 1;
                        end
                    end
                    // Handle underflow
                    if (z_exponent < 0) begin
                        z_exponent = 0;
                        z_mantissa = 0;
                    end
                    counter <= 5;
                end
                5: begin // Format the result
                    z = {z_sign, z_exponent, z_mantissa[22:0]};
                    counter <= 0; // Reset counter for next multiplication
                end
            endcase
        end
    end

endmodule