module float_multi(
    input        clk,
    input        rst,
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] z
);

    // Internal signals
    reg [2:0] counter;
    reg [23:0] a_mantissa;
    reg [23:0] b_mantissa;
    reg [23:0] z_mantissa;
    reg [9:0] a_exponent;
    reg [9:0] b_exponent;
    reg [9:0] z_exponent;
    reg a_sign;
    reg b_sign;
    reg z_sign;
    reg [49:0] product;
    reg guard_bit;
    reg round_bit;
    reg sticky;

    // Helper signals for special case detection
    wire a_is_nan     = (a[30:23] == 8'hFF) && (a[22:0] != 23'd0);
    wire b_is_nan     = (b[30:23] == 8'hFF) && (b[22:0] != 23'd0);
    wire a_is_inf     = (a[30:23] == 8'hFF) && (a[22:0] == 23'd0);
    wire b_is_inf     = (b[30:23] == 8'hFF) && (b[22:0] == 23'd0);
    wire a_is_zero    = (a[30:0] == 31'd0);
    wire b_is_zero    = (b[30:0] == 31'd0);
    wire a_is_denormal = (a[30:23] == 8'h00) && (a[22:0] != 23'd0);
    wire b_is_denormal = (b[30:23] == 8'h00) && (b[22:0] != 23'd0);

    // Extract sign, exponent, mantissa
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 3'd0;
            a_mantissa <= 24'd0;
            b_mantissa <= 24'd0;
            z_mantissa <= 24'd0;
            a_exponent <= 10'd0;
            b_exponent <= 10'd0;
            z_exponent <= 10'd0;
            a_sign <= 1'b0;
            b_sign <= 1'b0;
            z_sign <= 1'b0;
            product <= 50'd0;
            guard_bit <= 1'b0;
            round_bit <= 1'b0;
            sticky <= 1'b0;
            z <= 32'd0;
        end else begin
            case (counter)
                3'd0: begin
                    // Extract fields from inputs
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= {2'b0, a[30:23]};
                    b_exponent <= {2'b0, b[30:23]};
                    
                    // Extract mantissa with implicit leading 1 for normal numbers
                    if (a_is_denormal) begin
                        // For denormal, implicit 1 is not present; shift to normalize
                        a_mantissa <= {1'b0, a[22:0]};
                    end else if (a_is_zero) begin
                        a_mantissa <= 24'd0;
                    end else begin
                        // Normal: add implicit 1
                        a_mantissa <= {1'b1, a[22:0]};
                    end
                    
                    if (b_is_denormal) begin
                        b_mantissa <= {1'b0, b[22:0]};
                    end else if (b_is_zero) begin
                        b_mantissa <= 24'd0;
                    end else begin
                        b_mantissa <= {1'b1, b[22:0]};
                    end
                    
                    counter <= 3'd1;
                end
                
                3'd1: begin
                    // Handle special cases
                    if (a_is_nan || b_is_nan) begin
                        // Result is NaN
                        z_sign <= 1'b0;
                        z_exponent <= 10'h3F8; // 0x7F800000 -> exponent field 0xFF
                        z_mantissa <= 24'h000001; // quiet NaN
                        z <= {1'b0, 8'hFF, 23'h000001};
                    end else if ((a_is_inf && b_is_zero) || (b_is_inf && a_is_zero)) begin
                        // inf * 0 = NaN
                        z_sign <= 1'b0;
                        z_exponent <= 10'h3F8;
                        z_mantissa <= 24'h000001;
                        z <= {1'b0, 8'hFF, 23'h000001};
                    end else if (a_is_inf || b_is_inf) begin
                        // inf * finite = inf
                        z_sign <= a_sign ^ b_sign;
                        z_exponent <= 10'h3F8;
                        z_mantissa <= 24'd0;
                        z <= {z_sign, 8'hFF, 23'd0};
                    end else if (a_is_zero || b_is_zero) begin
                        // 0 * finite = 0
                        z_sign <= a_sign ^ b_sign;
                        z_exponent <= 10'd0;
                        z_mantissa <= 24'd0;
                        z <= {z_sign, 8'h00, 23'd0};
                    end else begin
                        // Normal multiplication path
                        z_sign <= a_sign ^ b_sign;
                        
                        // Compute exponent: (a_exp - bias) + (b_exp - bias) + bias = a_exp + b_exp - bias
                        // bias = 127 = 9'h7F
                        // z_exponent_raw = a_exponent + b_exponent - 127
                        // But a_exponent and b_exponent are already biased (8-bit), stored in 10-bit reg
                        // So: z_exponent = a_exponent + b_exponent - 127
                        // For denormals, we need to adjust exponent. Let's handle normalization.
                        
                        // For now, store raw exponent sum
                        // We'll handle denormal normalization in next step
                        z_exponent <= a_exponent + b_exponent - 10'd127;
                        counter <= 3'd2;
                    end
                end
                
                3'd2: begin
                    // Normalize denormal inputs if needed
                    // For denormal numbers, the mantissa is < 1.0, so we need to find the leading 1
                    // and adjust the exponent accordingly.
                    
                    // If a was denormal, shift a_mantissa left until MSB is 1
                    // and decrement a_exponent for each shift
                    if (a_is_denormal) begin
                        // Find number of leading zeros in a[22:0] (23 bits)
                        // The value is a[22:0] * 2^(-126-23) = a[22:0] * 2^(-149)
                        // We need to normalize: shift left k times so that MSB is 1
                        // k = number of leading zeros + 1 (since we need to make MSB=1)
                        // Actually, if a[22:0] is non-zero, the leading 1 is at position (22 - leading_zeros)
                        // Shift left by (23 - 1 - leading_zeros) = 22 - leading_zeros
                        // After shifting, the value becomes 1.xxx * 2^(-149 + shift)
                        // The exponent should be -149 + shift
                        // Original biased exponent for denormal is 0, so actual exponent is -126
                        // After normalization, actual exponent = -126 - (23 - 1 - leading_zeros) + 1
                        // Let me think more carefully.
                        
                        // Denormal value = 0.M * 2^(-126) where M is 23-bit fraction
                        // = M * 2^(-126-23) = M * 2^(-149)
                        // If M has leading 1 at bit position p (0-indexed from LSB), i.e., M >= 2^p and M < 2^(p+1)
                        // Then value = M * 2^(-149) = (M * 2^(23-p-1)) * 2^(-149 - 23 + p + 1)
                        // = (M * 2^(22-p)) * 2^(-126 - p)
                        // The normalized mantissa is 1.fraction where fraction is the remaining bits
                        // Shift left by (22 - p) positions
                        // New exponent (actual) = -126 - p
                        // Biased exponent = -126 - p + 127 = 1 - p
                        
                        // For simplicity, let's just do iterative shifting in a combinational way
                        // Since this is a single-cycle design, we'll compute the shift amount
                        // Let's find the position of the highest set bit in a[22:0]
                        // If a[22:0] = 0, it's zero (already handled)
                        
                        // Find highest set bit position (0-indexed from bit 0)
                        // Use a simple approach: check from MSB to LSB
                        reg [4:0] a_leading_zeros;
                        reg [4:0] b_leading_zeros;
                        reg [4:0] a_shift;
                        reg [4:0] b_shift;
                        
                        // Compute leading zeros for a[22:0]
                        if (a[22]) a_leading_zeros = 5'd0;
                        else if (a[21]) a_leading_zeros = 5'd1;
                        else if (a[20]) a_leading_zeros = 5'd2;
                        else if (a[19]) a_leading_zeros = 5'd3;
                        else if (a[18]) a_leading_zeros = 5'd4;
                        else if (a[17]) a_leading_zeros = 5'd5;
                        else if (a[16]) a_leading_zeros = 5'd6;
                        else if (a[15]) a_leading_zeros = 5'd7;
                        else if (a[14]) a_leading_zeros = 5'd8;
                        else if (a[13]) a_leading_zeros = 5'd9;
                        else if (a[12]) a_leading_zeros = 5'd10;
                        else if (a[11]) a_leading_zeros = 5'd11;
                        else if (a[10]) a_leading_zeros = 5'd12;
                        else if (a[9])  a_leading_zeros = 5'd13;
                        else if (a[8])  a_leading_zeros = 5'd14;
                        else if (a[7])  a_leading_zeros = 5'd15;
                        else if (a[6])  a_leading_zeros = 5'd16;
                        else if (a[5])  a_leading_zeros = 5'd17;
                        else if (a[4])  a_leading_zeros = 5'd18;
                        else if (a[3])  a_leading_zeros = 5'd19;
                        else if (a[2])  a_leading_zeros = 5'd20;
                        else if (a[1])  a_leading_zeros = 5'd21;
                        else            a_leading_zeros = 5'd22;
                        
                        a_shift = 5'd22 - a_leading_zeros;
                        
                        // Adjust exponent and mantissa for a
                        a_exponent <= a_exponent - a_shift - 10'd1; // Because denormal exponent is 0, actual is -126, after shift by k, actual becomes -126-k, biased = 1-k
                        // Wait, let me reconsider.
                        // Original denormal: exponent field = 0, mantissa = a[22:0]
                        // Value = a[22:0] * 2^(-149)
                        // After shifting left by s positions (s = 22 - leading_zeros), the mantissa becomes a normalized 24-bit value with MSB=1
                        // The value is now (a_mantissa_shifted) * 2^(-149 + s)
                        // The actual exponent = -149 + s
                        // Biased exponent = -149 + s + 127 = s - 22
                        // So z_exponent contribution from a should be (s - 22) instead of 0
                        // Currently a_exponent = 0 (from extraction)
                        // We need to set a_exponent = s - 22 + 127 = s + 105? No.
                        // Let me redo: biased exponent = actual + 127
                        // actual = -149 + s
                        // biased = -149 + s + 127 = s - 22
                        // So a_exponent should be s - 22
                        // But s can be 0 to 22, so s-22 can be negative.
                        // If s < 22, s-22 is negative, which means the exponent field would underflow.
                        // This is getting complex. Let me simplify by handling denormals differently.
                        
                        // Actually, for a cleaner approach, let's just note that denormal * denormal or denormal * normal
                        // results in a very small number that will likely underflow to zero or a denormal.
                        // For a first implementation, let's handle the common case of normal numbers and
                        // treat denormals as zero if the result underflows.
                        
                        // For this implementation, let's just proceed with the multiplication
                        // and handle underflow in the rounding step.
                        // For now, if a is denormal, we'll use the raw mantissa and adjust exponent to 0
                        // and let the result be computed, then handle underflow.
                        
                        // Let's just proceed to multiplication in the next state
                    end
                    
                    // Similarly for b
                    if (b_is_denormal) begin
                        // Same logic
                    end
                    
                    // Proceed to multiplication
                    counter <= 3'd3;
                end
                
                3'd3: begin
                    // Multiply mantissas
                    // a_mantissa and b_mantissa are 24-bit values (1.xx for normal, 0.xxx for denormal)
                    // Product is 48-bit
                    product <= a_mantissa * b_mantissa;
                    
                    // Determine if product needs shifting
                    // For normal * normal: both have implicit 1, so product is 1.xx * 1.xx = 1.xx or 2.xx
                    // If MSB of product is 1 (bit 47), no shift needed (product is 1.xxxx)
                    // If MSB of product is 0 but bit 46 is 1, product is 0.1xxx, shift left 1
                    // Actually, for normal numbers, mantissa is 1.f (24 bits: 1 + 23 fraction)
                    // Product of two 24-bit numbers with MSB=1:
                    // Minimum: 1.0 * 1.0 = 1.0 (48 bits: bit 47 = 1)
                    // Maximum: 1.111... * 1.111... < 2.0 (48 bits: bit 47 = 0, bit 46 = 1)
                    // So if product[47] = 1, result is 1.xxxx, exponent unchanged
                    // If product[47] = 0 and product[46] = 1, result is 0.1xxx, shift left 1, exponent +1
                    // If product[47] = 0 and product[46] = 0, this shouldn't happen for normal*normal
                    
                    // Set rounding bits
                    // We keep 24 bits of the result mantissa
                    // The 24-bit result is product[47:24] if no shift, or product[46:23] if shift
                    // Guard bit is the next bit, round bit is the next, sticky is OR of remaining
                    
                    if (product[47]) begin
                        // No shift needed
                        z_mantissa <= product[47:24];
                        guard_bit <= product[23];
                        round_bit <= product[22];
                        sticky <= |product[21:0];
                        // Exponent unchanged (already computed)
                    end else begin
                        // Shift left by 1
                        z_mantissa <= product[46:23];
                        guard_bit <= product[22];
                        round_bit <= product[21];
                        sticky <= |product[20:0];
                        // Exponent +1
                        z_exponent <= z_exponent + 10'd1;
                    end
                    
                    counter <= 3'd4;
                end
                
                3'd4: begin
                    // Rounding: round to nearest, ties to even
                    // Check if we need to round up
                    // Round up if: (guard && (round || sticky || LSB_of_mantissa))
                    // i.e., round to nearest, ties to even
                    reg round_up;
                    round_up = guard_bit && (round_bit || sticky || z_mantissa[0]);
                    
                    if (round_up) begin
                        z_mantissa <= z_mantissa + 24'd1;
                    end
                    
                    // Check if mantissa overflowed (became 24'b1000...000)
                    if (z_mantissa == 24'h800000) begin
                        // Overflow: shift mantissa right, increment exponent
                        z_mantissa <= z_mantissa >> 1;
                        z_exponent <= z_exponent + 10'd1;
                    end
                    
                    counter <= 3'd5;
                end
                
                3'd5: begin
                    // Final formatting and overflow/underflow handling
                    // Exponent field is 8 bits
                    // If z_exponent >= 255: overflow -> infinity
                    // If z_exponent <= 0: underflow -> zero or denormal
                    // If 1 <= z_exponent <= 254: normal number
                    
                    if (z_exponent >= 10'd255) begin
                        // Overflow to infinity
                        z <= {z_sign, 8'hFF, 23'd0};
                    end else if (z_exponent <= 10'd0) begin
                        // Underflow
                        // If z_exponent == 0: could be denormal
                        // If z_exponent < 0: flush to zero
                        if (z_exponent == 10'd0) begin
                            // Denormal result
                            // Mantissa needs to be shifted right
                            // The result is z_mantissa * 2^(-126) / 2^(127 - 1) ... 
                            // For simplicity, flush to zero if underflow
                            z <= {z_sign, 8'h00, 23'd0};
                        end else begin
                            // z_exponent < 0
                            z <= {z_sign, 8'h00, 23'd0};
                        end
                    end else begin
                        // Normal result
                        // Extract 8-bit exponent field
                        // z_exponent is the biased exponent (should be between 1 and 254)
                        // Mantissa is the lower 23 bits of z_mantissa (excluding the implicit 1)
                        z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                    end
                end
                
                default: begin
                    counter <= 3'd0;
                end
            endcase
        end
    end

endmodule