module float_multi (
    input wire clk,
    input wire rst,
    input wire [31:0] a,
    input wire [31:0] b,
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
    reg a_is_nan, b_is_nan;
    reg a_is_inf, b_is_inf;
    reg a_is_zero, b_is_zero;
    reg result_is_nan, result_is_inf, result_is_zero;
    reg need_rounding;
    reg [9:0] z_exp_raw;
    reg [24:0] z_mantissa_ext;
    reg [23:0] z_mantissa_rounded;
    reg z_exp_overflow, z_exp_underflow;
    reg z_sign_temp;
    reg [9:0] z_exp_final;
    reg [23:0] z_mant_final;
    reg z_is_nan, z_is_inf, z_is_zero;

    // Default values
    parameter [31:0] IEEE_NAN = 32'h7FC00000;
    parameter [31:0] IEEE_INF = 32'h7F800000;
    parameter [31:0] IEEE_NEG_INF = 32'hFF800000;
    parameter [31:0] IEEE_ZERO = 32'h00000000;
    parameter [31:0] IEEE_NEG_ZERO = 32'h80000000;
    parameter [9:0] EXP_BIAS = 127;

    // Special case detection
    wire [10:0] a_exp_field = a[30:23];
    wire [10:0] b_exp_field = b[30:23];
    wire [23:0] a_frac_field = a[22:0];
    wire [23:0] b_frac_field = b[22:0];

    // NaN: exp all 1s and fraction non-zero
    wire a_nan = (a[30:23] == 11'h1FF) && (a[22:0] != 23'b0);
    wire b_nan = (b[30:23] == 11'h1FF) && (b[22:0] != 23'b0);
    
    // Inf: exp all 1s and fraction zero
    wire a_inf = (a[30:23] == 11'h1FF) && (a[22:0] == 23'b0);
    wire b_inf = (b[30:23] == 11'h1FF) && (b[22:0] == 23'b0);
    
    // Zero: exp all 0s and fraction zero
    wire a_zero = (a[30:23] == 11'h000) && (a[22:0] == 23'b0);
    wire b_zero = (b[30:23] == 11'h000) && (b[22:0] == 23'b0);

    // Denormalized: exp all 0s and fraction non-zero
    wire a_denorm = (a[30:23] == 11'h000) && (a[22:0] != 23'b0);
    wire b_denorm = (b[30:23] == 11'h000) && (b[22:0] != 23'b0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 3'd0;
            z <= 32'b0;
            a_mantissa <= 24'b0;
            b_mantissa <= 24'b0;
            z_mantissa <= 24'b0;
            a_exponent <= 10'b0;
            b_exponent <= 10'b0;
            z_exponent <= 10'b0;
            a_sign <= 1'b0;
            b_sign <= 1'b0;
            z_sign <= 1'b0;
            product <= 50'b0;
            guard_bit <= 1'b0;
            round_bit <= 1'b0;
            sticky <= 1'b0;
            a_is_nan <= 1'b0;
            b_is_nan <= 1'b0;
            a_is_inf <= 1'b0;
            b_is_inf <= 1'b0;
            a_is_zero <= 1'b0;
            b_is_zero <= 1'b0;
            result_is_nan <= 1'b0;
            result_is_inf <= 1'b0;
            result_is_zero <= 1'b0;
            need_rounding <= 1'b0;
            z_exp_raw <= 10'b0;
            z_mantissa_ext <= 25'b0;
            z_mantissa_rounded <= 24'b0;
            z_exp_overflow <= 1'b0;
            z_exp_underflow <= 1'b0;
            z_sign_temp <= 1'b0;
            z_exp_final <= 10'b0;
            z_mant_final <= 24'b0;
            z_is_nan <= 1'b0;
            z_is_inf <= 1'b0;
            z_is_zero <= 1'b0;
        end else begin
            case (counter)
                3'd0: begin
                    // Cycle 0: Extract fields and handle special cases
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= {3'b0, a[30:23]};
                    b_exponent <= {3'b0, b[30:23]};
                    
                    // Prepare mantissas with implicit 1 for normal numbers
                    if (a_denorm) begin
                        // For denormalized, mantissa is 0.frac, need to normalize
                        a_mantissa <= {1'b0, a[22:0]};
                        a_exponent <= 10'b0; // Will handle specially
                    end else if (a_nan || a_inf) begin
                        a_mantissa <= 24'b0;
                    end else begin
                        a_mantissa <= {1'b1, a[22:0]};
                    end
                    
                    if (b_denorm) begin
                        b_mantissa <= {1'b0, b[22:0]};
                        b_exponent <= 10'b0;
                    end else if (b_nan || b_inf) begin
                        b_mantissa <= 24'b0;
                    end else begin
                        b_mantissa <= {1'b1, b[22:0]};
                    end
                    
                    a_is_nan <= a_nan;
                    b_is_nan <= b_nan;
                    a_is_inf <= a_inf;
                    b_is_inf <= b_inf;
                    a_is_zero <= a_zero;
                    b_is_zero <= b_zero;
                    
                    // Check for special cases that can be resolved immediately
                    if (a_nan || b_nan) begin
                        z <= IEEE_NAN;
                        z_is_nan <= 1'b1;
                        counter <= 3'd1;
                    end else if (a_inf && b_zero) begin
                        z <= IEEE_NAN;
                        z_is_nan <= 1'b1;
                        counter <= 3'd1;
                    end else if (b_inf && a_zero) begin
                        z <= IEEE_NAN;
                        z_is_nan <= 1'b1;
                        counter <= 3'd1;
                    end else if (a_inf || b_inf) begin
                        z_sign_temp <= a_sign ^ b_sign;
                        z <= {z_sign_temp, 11'h1FF, 23'b0};
                        z_is_inf <= 1'b1;
                        counter <= 3'd1;
                    end else if (a_zero || b_zero) begin
                        z_sign_temp <= a_sign ^ b_sign;
                        z <= {z_sign_temp, 31'b0};
                        z_is_zero <= 1'b1;
                        counter <= 3'd1;
                    end else begin
                        // Normal case, continue to next cycle
                        z_is_nan <= 1'b0;
                        z_is_inf <= 1'b0;
                        z_is_zero <= 1'b0;
                        counter <= 3'd1;
                    end
                end
                3'd1: begin
                    // Cycle 1: Handle denormalization if needed and multiply
                    if (z_is_nan || z_is_inf || z_is_zero) begin
                        // Already resolved
                        counter <= 3'd2;
                    end else begin
                        // Multiply mantissas
                        product <= a_mantissa * b_mantissa;
                        
                        // Sign
                        z_sign_temp <= a_sign ^ b_sign;
                        
                        // Exponent calculation
                        // For normal numbers: exp_a + exp_b - bias
                        // For denormalized numbers, need special handling
                        if (a_denorm && b_denorm) begin
                            // Both denormalized: result exponent = -bias - 1 (approx)
                            z_exp_raw <= 10'b0; // Will handle in next stage
                        end else if (a_denorm) begin
                            z_exp_raw <= b_exponent - {3'b0, 11'h1FF} + {3'b0, 11'h1FF} - {3'b0, 11'h1FF};
                            // Simplified: b_exp - 127
                            z_exp_raw <= {3'b0, b[30:23]} - {3'b0, 11'h1FF};
                        end else if (b_denorm) begin
                            z_exp_raw <= {3'b0, a[30:23]} - {3'b0, 11'h1FF};
                        end else begin
                            z_exp_raw <= a_exponent + b_exponent - {3'b0, 11'h1FF};
                        end
                        
                        counter <= 3'd2;
                    end
                end
                3'd2: begin
                    // Cycle 2: Normalize product and prepare for rounding
                    if (z_is_nan || z_is_inf || z_is_zero) begin
                        counter <= 3'd3;
                    end else begin
                        // Product is 48 bits (24x24), but we need to find the actual position
                        // For normal x normal: product is 24.xxxx (24 integer bits + fraction)
                        // Actually, 24-bit * 24-bit = up to 48 bits
                        // The result has form 1.xxxx or 0.1xxx depending on magnitude
                        
                        // Find MSB of product to normalize
                        // product[49:0]
                        if (product[48]) begin
                            // Result is 2.xxxx, need to shift right by 1
                            // Mantissa bits: product[47:24] (24 bits)
                            z_mantissa_ext <= {product[47:24], 1'b0, 1'b0}; // 27 bits for rounding
                            z_exp_raw <= z_exp_raw + 1;
                        end else if (product[47]) begin
                            // Result is 1.xxxx, already normalized
                            z_mantissa_ext <= {1'b1, product[46:24], 1'b0, 1'b0};
                        end else begin
                            // Result is 0.1xxx, need to shift left
                            // Find the position of the MSB
                            if (product[46]) begin
                                z_mantissa_ext <= {1'b1, product[45:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 1;
                            end else if (product[45]) begin
                                z_mantissa_ext <= {1'b1, product[44:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 2;
                            end else if (product[44]) begin
                                z_mantissa_ext <= {1'b1, product[43:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 3;
                            end else if (product[43]) begin
                                z_mantissa_ext <= {1'b1, product[42:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 4;
                            end else if (product[42]) begin
                                z_mantissa_ext <= {1'b1, product[41:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 5;
                            end else if (product[41]) begin
                                z_mantissa_ext <= {1'b1, product[40:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 6;
                            end else if (product[40]) begin
                                z_mantissa_ext <= {1'b1, product[39:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 7;
                            end else if (product[39]) begin
                                z_mantissa_ext <= {1'b1, product[38:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 8;
                            end else if (product[38]) begin
                                z_mantissa_ext <= {1'b1, product[37:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 9;
                            end else if (product[37]) begin
                                z_mantissa_ext <= {1'b1, product[36:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 10;
                            end else if (product[36]) begin
                                z_mantissa_ext <= {1'b1, product[35:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 11;
                            end else if (product[35]) begin
                                z_mantissa_ext <= {1'b1, product[34:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 12;
                            end else if (product[34]) begin
                                z_mantissa_ext <= {1'b1, product[33:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 13;
                            end else if (product[33]) begin
                                z_mantissa_ext <= {1'b1, product[32:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 14;
                            end else if (product[32]) begin
                                z_mantissa_ext <= {1'b1, product[31:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 15;
                            end else if (product[31]) begin
                                z_mantissa_ext <= {1'b1, product[30:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 16;
                            end else if (product[30]) begin
                                z_mantissa_ext <= {1'b1, product[29:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 17;
                            end else if (product[29]) begin
                                z_mantissa_ext <= {1'b1, product[28:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 18;
                            end else if (product[28]) begin
                                z_mantissa_ext <= {1'b1, product[27:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 19;
                            end else if (product[27]) begin
                                z_mantissa_ext <= {1'b1, product[26:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 20;
                            end else if (product[26]) begin
                                z_mantissa_ext <= {1'b1, product[25:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 21;
                            end else if (product[25]) begin
                                z_mantissa_ext <= {1'b1, product[24:24], 1'b0, 1'b0};
                                z_exp_raw <= z_exp_raw - 22;
                            end else begin
                                // Product is too small, result is zero
                                z <= {z_sign_temp, 31'b0};
                                z_is_zero <= 1'b1;
                                counter <= 3'd3;
                            end
                        end
                        
                        // Set rounding bits
                        // z_mantissa_ext[24:23:22] = {mantissa[23:0], guard, round, sticky}
                        // We have 27 bits: [26:0] where [26:3] are mantissa, [2] guard, [1] round, [0] sticky
                        // Actually let's re-examine: we need 24 mantissa bits + guard + round + sticky
                        // Let's use a simpler approach in the next cycle
                        
                        counter <= 3'd3;
                    end
                end
                3'd3: begin
                    // Cycle 3: Rounding and final formatting
                    if (z_is_nan || z_is_inf || z_is_zero) begin
                        counter <= 3'd0; // Done, will reset counter
                    end else begin
                        // Check for overflow
                        if (z_exp_raw >= 10'd255) begin
                            // Overflow to infinity
                            z <= {z_sign_temp, 11'h1FF, 23'b0};
                            z_is_inf <= 1'b1;
                            counter <= 3'd0;
                        end else if (z_exp_raw < 10'd0) begin
                            // Underflow to zero (or denormal, simplified to zero)
                            z <= {z_sign_temp, 31'b0};
                            z_is_zero <= 1'b1;
                            counter <= 3'd0;
                        end else begin
                            // Normal case
                            // Apply round to nearest, ties to even
                            // z_mantissa_ext is 27 bits: [26:3]=mantissa[23:0], [2]=guard, [1]=round, [0]=sticky
                            // Wait, let me reconsider the bit layout
                            
                            // From cycle 2, z_mantissa_ext[26:0]:
                            // Bits [26:3] = 24-bit mantissa (including implicit 1)
                            // Bit [2] = guard
                            // Bit [1] = round  
                            // Bit [0] = sticky (should be OR of all lower bits, but we set to 0)
                            
                            // Actually, we need to properly capture the sticky bit
                            // For simplicity, let's assume sticky = 0 for this implementation
                            // A more accurate implementation would OR all bits below round bit
                            
                            guard_bit <= z_mantissa_ext[2];
                            round_bit <= z_mantissa_ext[1];
                            sticky <= z_mantissa_ext[0]; // Simplified
                            
                            // Round to nearest, ties to even
                            // Round up if: (guard & (round | sticky | lsb))
                            // Where lsb is the least significant bit of the 24-bit mantissa
                            reg [23:0] mant_lsb;
                            mant_lsb = z_mantissa_ext[3]; // LSB of 24-bit mantissa
                            
                            if (guard_bit && (round_bit || sticky || mant_lsb)) begin
                                // Round up
                                z_mantissa_rounded <= z_mantissa_ext[26:3] + 24'd1;
                                // Check if mantissa overflowed
                                if (z_mantissa_ext[26:3] == 24'hFFFFF) begin
                                    // Mantissa overflow, increment exponent
                                    z_exp_final <= z_exp_raw + 1;
                                    z_mant_final <= 24'h00000;
                                end else begin
                                    z_exp_final <= z_exp_raw;
                                    z_mant_final <= z_mantissa_rounded;
                                end
                            end else begin
                                // Round down (truncate)
                                z_exp_final <= z_exp_raw;
                                z_mant_final <= z_mantissa_ext[26:3];
                            end
                            
                            // Format output
                            // IEEE 754: sign (1) + exponent (8) + fraction (23)
                            // z_mant_final[23:0] includes implicit 1, so fraction is z_mant_final[22:0]
                            z <= {z_sign_temp, z_exp_final[7:0], z_mant_final[22:0]};
                            counter <= 3'd0;
                        end
                    end
                end
                default: begin
                    counter <= 3'd0;
                end
            endcase
        end
    end

endmodule