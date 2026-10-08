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

    // Special value constants
    localparam [31:0] POS_INF = 32'h7F800000;
    localparam [31:0] NEG_INF = 32'hFF800000;
    localparam [31:0] POS_NAN = 32'h7FC00000;
    localparam [31:0] NEG_NAN = 32'hFFC00000;
    localparam [31:0] POS_ZERO = 32'h00000000;
    localparam [31:0] NEG_ZERO = 32'h80000000;
    localparam [9:0] BIAS = 10'd127;
    localparam [9:0] MAX_EXP = 10'd254;
    localparam [9:0] MIN_EXP = 10'd0;

    // Helper: check if exponent is all 1s (inf/nan)
    wire a_is_inf_or_nan = (a[30:23] == 8'hFF);
    wire b_is_inf_or_nan = (b[30:23] == 8'hFF);
    wire a_is_zero = (a[30:0] == 21'd0);
    wire b_is_zero = (b[30:0] == 21'd0);

    // Helper: check if exponent is all 0s (zero or subnormal)
    wire a_exp_zero = (a[30:23] == 8'h00);
    wire b_exp_zero = (b[30:23] == 8'h00);

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
                    a_mantissa <= a[22:0];
                    b_mantissa <= b[22:0];
                    counter <= 3'd1;
                end

                3'd1: begin
                    // Handle special cases and prepare for multiplication
                    // First, determine if we have special values
                    if (a_is_inf_or_nan || b_is_inf_or_nan) begin
                        // If either is NaN, result is NaN
                        if (a_is_inf_or_nan && a[22:0] != 23'd0) begin
                            // a is NaN
                            z_sign <= a_sign;
                            z_exponent <= 10'd255;
                            z_mantissa <= a[22:0];
                            z <= {z_sign, 8'hFF, z_mantissa};
                            counter <= 3'd0;
                        end else if (b_is_inf_or_nan && b[22:0] != 23'd0) begin
                            // b is NaN
                            z_sign <= b_sign;
                            z_exponent <= 10'd255;
                            z_mantissa <= b[22:0];
                            z <= {z_sign, 8'hFF, z_mantissa};
                            counter <= 3'd0;
                        end else begin
                            // Check for inf * 0 or inf * inf
                            if (a_is_inf_or_nan && a[22:0] == 23'd0) begin
                                // a is infinity
                                if (b_is_zero) begin
                                    // inf * 0 = NaN
                                    z_sign <= 1'b0;
                                    z_exponent <= 10'd255;
                                    z_mantissa <= 23'h400000; // quiet NaN
                                    z <= {z_sign, 8'hFF, z_mantissa};
                                end else if (b_is_inf_or_nan) begin
                                    // inf * inf
                                    z_sign <= a_sign ^ b_sign;
                                    z_exponent <= 10'd255;
                                    z_mantissa <= 23'd0;
                                    z <= {z_sign, 8'hFF, z_mantissa};
                                end else begin
                                    // inf * finite = inf
                                    z_sign <= a_sign ^ b_sign;
                                    z_exponent <= 10'd255;
                                    z_mantissa <= 23'd0;
                                    z <= {z_sign, 8'hFF, z_mantissa};
                                end
                            end else if (b_is_inf_or_nan && b[22:0] == 23'd0) begin
                                // b is infinity
                                if (a_is_zero) begin
                                    // 0 * inf = NaN
                                    z_sign <= 1'b0;
                                    z_exponent <= 10'd255;
                                    z_mantissa <= 23'h400000;
                                    z <= {z_sign, 8'hFF, z_mantissa};
                                end else if (a_is_inf_or_nan) begin
                                    // inf * inf
                                    z_sign <= a_sign ^ b_sign;
                                    z_exponent <= 10'd255;
                                    z_mantissa <= 23'd0;
                                    z <= {z_sign, 8'hFF, z_mantissa};
                                end else begin
                                    // finite * inf = inf
                                    z_sign <= a_sign ^ b_sign;
                                    z_exponent <= 10'd255;
                                    z_mantissa <= 23'd0;
                                    z <= {z_sign, 8'hFF, z_mantissa};
                                end
                            end else begin
                                // Both are NaN, already handled above
                                z_sign <= 1'b0;
                                z_exponent <= 10'd255;
                                z_mantissa <= 23'h400000;
                                z <= {z_sign, 8'hFF, z_mantissa};
                            end
                            counter <= 3'd0;
                        end
                    end else if (a_is_zero || b_is_zero) begin
                        // Zero times anything (except inf, handled above) is zero
                        z_sign <= a_sign ^ b_sign;
                        // Handle signed zero: if both are zero, sign is XOR
                        z_exponent <= 10'd0;
                        z_mantissa <= 23'd0;
                        z <= {z_sign, 8'h00, 23'd0};
                        counter <= 3'd0;
                    end else begin
                        // Normal or subnormal case: proceed with multiplication
                        // Prepare mantissas with implicit leading 1 for normal numbers
                        // For subnormals, the value is 0.mantissa * 2^(-126)
                        // We'll handle by scaling appropriately
                        
                        // Determine actual exponent values
                        reg [9:0] a_exp_actual, b_exp_actual;
                        reg [23:0] a_man_actual, b_man_actual;
                        
                        if (a_exp_zero) begin
                            // a is subnormal or zero (zero handled above, so subnormal)
                            a_exp_actual <= 10'd0; // will adjust later
                            a_man_actual <= {1'b0, a_mantissa};
                        end else begin
                            // a is normal
                            a_exp_actual <= a_exponent - BIAS;
                            a_man_actual <= {1'b1, a_mantissa};
                        end
                        
                        if (b_exp_zero) begin
                            b_exp_actual <= 10'd0;
                            b_man_actual <= {1'b0, b_mantissa};
                        end else begin
                            b_exp_actual <= b_exponent - BIAS;
                            b_man_actual <= {1'b1, b_mantissa};
                        end
                        
                        // For subnormals, we need to normalize or handle specially
                        // Simplified approach: convert subnormals to equivalent normal form
                        // by left-shifting mantissa and adjusting exponent
                        reg [31:0] a_norm_man;
                        reg [9:0] a_norm_exp;
                        reg [31:0] b_norm_man;
                        reg [9:0] b_norm_exp;
                        
                        // We'll do the normalization in the next step for simplicity
                        // Store the prepared values and move to multiplication
                        counter <= 3'd2;
                    end
                end

                3'd2: begin
                    // Normalize subnormals if needed and perform mantissa multiplication
                    // Determine if inputs are subnormal
                    reg [9:0] a_exp_val, b_exp_val;
                    reg [23:0] a_man_val, b_man_val;
                    reg [9:0] a_exp_final, b_exp_final;
                    reg [23:0] a_man_final, b_man_final;
                    
                    if (a_exp_zero) begin
                        // Subnormal a: find leading 1 position
                        // a_man_val is the raw mantissa (23 bits), value = 0.a_man_val * 2^-126
                        // We need to normalize: find msb position
                        reg [4:0] a_shift;
                        a_shift <= 5'd0;
                        if (a_mantissa[22] == 1'b0) begin
                            if (a_mantissa[21] == 1'b0) begin
                                if (a_mantissa[20] == 1'b0) begin
                                    if (a_mantissa[19] == 1'b0) begin
                                        if (a_mantissa[18] == 1'b0) begin
                                            if (a_mantissa[17] == 1'b0) begin
                                                if (a_mantissa[16] == 1'b0) begin
                                                    if (a_mantissa[15] == 1'b0) begin
                                                        if (a_mantissa[14] == 1'b0) begin
                                                            if (a_mantissa[13] == 1'b0) begin
                                                                if (a_mantissa[12] == 1'b0) begin
                                                                    if (a_mantissa[11] == 1'b0) begin
                                                                        if (a_mantissa[10] == 1'b0) begin
                                                                            if (a_mantissa[9] == 1'b0) begin
                                                                                if (a_mantissa[8] == 1'b0) begin
                                                                                    if (a_mantissa[7] == 1'b0) begin
                                                                                        if (a_mantissa[6] == 1'b0) begin
                                                                                            if (a_mantissa[5] == 1'b0) begin
                                                                                                if (a_mantissa[4] == 1'b0) begin
                                                                                                    if (a_mantissa[3] == 1'b0) begin
                                                                                                        if (a_mantissa[2] == 1'b0) begin
                                                                                                            if (a_mantissa[1] == 1'b0) begin
                                                                                                                a_shift <= 5'd22;
                                                                                                            end else begin
                                                                                                                a_shift <= 5'd21;
                                                                                                            end
                                                                                                        end else begin
                                                                                                            a_shift <= 5'd20;
                                                                                                        end
                                                                                                    end else begin
                                                                                                        a_shift <= 5'd19;
                                                                                                    end
                                                                                                end else begin
                                                                                                    a_shift <= 5'd18;
                                                                                                    end
                                                                                            end else begin
                                                                                            a_shift <= 5'd17;
                                                                                            end
                                                                                        end else begin
                                                                                        a_shift <= 5'd16;
                                                                                        end
                                                                                    end else begin
                                                                                    a_shift <= 5'd15;
                                                                                    end
                                                                                end else begin
                                                                                a_shift <= 5'd14;
                                                                                end
                                                                            end else begin
                                                                            a_shift <= 5'd13;
                                                                            end
                                                                        end else begin
                                                                        a_shift <= 5'd12;
                                                                        end
                                                                    end else begin
                                                                    a_shift <= 5'd11;
                                                                    end
                                                                end else begin
                                                                a_shift <= 5'd10;
                                                                end
                                                            end else begin
                                                            a_shift <= 5'd9;
                                                            end
                                                        end else begin
                                                        a_shift <= 5'd8;
                                                        end
                                                    end else begin
                                                    a_shift <= 5'd7;
                                                    end
                                                end else begin
                                                a_shift <= 5'd6;
                                                end
                                            end else begin
                                            a_shift <= 5'd5;
                                            end
                                        end else begin
                                        a_shift <= 5'd4;
                                        end
                                    end else begin
                                    a_shift <= 5'd3;
                                    end
                                end else begin
                                a_shift <= 5'd2;
                                end
                            end else begin
                            a_shift <= 5'd1;
                            end
                        end else begin
                            a_shift <= 5'd0;
                        end
                        
                        // Left shift mantissa by (22 - a_shift) to normalize
                        // The normalized mantissa has leading 1
                        // After shifting, the exponent becomes -126 - a_shift
                        a_man_val <= a_mantissa << (22 - a_shift);
                        a_exp_val <= 10'd0; // placeholder, will compute actual exponent
                        a_exp_final <= (10'd126 + a_shift) - 10'd127; // = a_shift - 1
                        a_man_final <= a_mantissa << (22 - a_shift);
                    end else begin
                        a_man_val <= {1'b1, a_mantissa};
                        a_exp_val <= a_exponent - BIAS;
                        a_exp_final <= a_exponent - BIAS;
                        a_man_final <= {1'b1, a_mantissa}[23:1]; // 23-bit fraction, but we need 24-bit with implicit 1
                    end
                    
                    if (b_exp_zero) begin
                        reg [4:0] b_shift;
                        b_shift <= 5'd0;
                        if (b_mantissa[22] == 1'b0) begin
                            if (b_mantissa[21] == 1'b0) begin
                                if (b_mantissa[20] == 1'b0) begin
                                    if (b_mantissa[19] == 1'b0) begin
                                        if (b_mantissa[18] == 1'b0) begin
                                            if (b_mantissa[17] == 1'b0) begin
                                                if (b_mantissa[16] == 1'b0) begin
                                                    if (b_mantissa[15] == 1'b0) begin
                                                        if (b_mantissa[14] == 1'b0) begin
                                                            if (b_mantissa[13] == 1'b0) begin
                                                                if (b_mantissa[12] == 1'b0) begin
                                                                    if (b_mantissa[11] == 1'b0) begin
                                                                        if (b_mantissa[10] == 1'b0) begin
                                                                            if (b_mantissa[9] == 1'b0) begin
                                                                                if (b_mantissa[8] == 1'b0) begin
                                                                                    if (b_mantissa[7] == 1'b0) begin
                                                                                        if (b_mantissa[6] == 1'b0) begin
                                                                                            if (b_mantissa[5] == 1'b0) begin
                                                                                                if (b_mantissa[4] == 1'b0) begin
                                                                                                    if (b_mantissa[3] == 1'b0) begin
                                                                                                        if (b_mantissa[2] == 1'b0) begin
                                                                                                            if (b_mantissa[1] == 1'b0) begin
                                                                                                                b_shift <= 5'd22;
                                                                                                            end else begin
                                                                                                                b_shift <= 5'd21;
                                                                                                            end
                                                                                                        end else begin
                                                                                                            b_shift <= 5'd20;
                                                                                                        end
                                                                                                    end else begin
                                                                                                        b_shift <= 5'd19;
                                                                                                    end
                                                                                                end else begin
                                                                                                    b_shift <= 5'd18;
                                                                                                    end
                                                                                            end else begin
                                                                                            b_shift <= 5'd17;
                                                                                            end
                                                                                        end else begin
                                                                                        b_shift <= 5'd16;
                                                                                        end
                                                                                    end else begin
                                                                                    b_shift <= 5'd15;
                                                                                    end
                                                                                end else begin
                                                                                b_shift <= 5'd14;
                                                                                end
                                                                            end else begin
                                                                            b_shift <= 5'd13;
                                                                            end
                                                                        end else begin
                                                                        b_shift <= 5'd12;
                                                                        end
                                                                    end else begin
                                                                    b_shift <= 5'd11;
                                                                    end
                                                                end else begin
                                                                b_shift <= 5'd10;
                                                                end
                                                            end else begin
                                                            b_shift <= 5'd9;
                                                            end
                                                        end else begin
                                                        b_shift <= 5'd8;
                                                        end
                                                    end else begin
                                                    b_shift <= 5'd7;
                                                    end
                                                end else begin
                                                b_shift <= 5'd6;
                                                end
                                            end else begin
                                            b_shift <= 5'd5;
                                            end
                                        end else begin
                                        b_shift <= 5'd4;
                                        end
                                    end else begin
                                    b_shift <= 5'd3;
                                    end
                                end else begin
                                b_shift <= 5'd2;
                                end
                            end else begin
                            b_shift <= 5'd1;
                            end
                        end else begin
                            b_shift <= 5'd0;
                        end
                        
                        b_man_val <= b_mantissa << (22 - b_shift);
                        b_exp_val <= 10'd0;
                        b_exp_final <= (10'd126 + b_shift) - 10'd127;
                        b_man_final <= b_mantissa << (22 - b_shift);
                    end else begin
                        b_man_val <= {1'b1, b_mantissa};
                        b_exp_val <= b_exponent - BIAS;
                        b_exp_final <= b_exponent - BIAS;
                        b_man_final <= {1'b1, b_mantissa}[23:1];
                    end
                    
                    // For normal numbers, the mantissa is 1.fraction, so we use 24-bit: 1 + 23 fraction bits
                    // For subnormals after normalization, same format
                    // Compute product of 24-bit mantissas
                    // We need to use the full 24-bit mantissas
                    // Let's redefine: for normal, man = 24'h1_XXXXXXX where X is 23-bit fraction
                    // For subnormal after norm, same
                    
                    // Recompute properly
                    reg [23:0] a_man_24, b_man_24;
                    reg [9:0] a_exp_10, b_exp_10;
                    
                    if (a_exp_zero) begin
                        // Find shift for a
                        reg [4:0] as;
                        as <= 5'd0;
                        if (a_mantissa[22] == 0) begin
                            if (a_mantissa[21] == 0) begin
                                if (a_mantissa[20] == 0) begin
                                    if (a_mantissa[19] == 0) begin
                                        if (a_mantissa[18] == 0) begin
                                            if (a_mantissa[17] == 0) begin
                                                if (a_mantissa[16] == 0) begin
                                                    if (a_mantissa[15] == 0) begin
                                                        if (a_mantissa[14] == 0) begin
                                                            if (a_mantissa[13] == 0) begin
                                                                if (a_mantissa[12] == 0) begin
                                                                    if (a_mantissa[11] == 0) begin
                                                                        if (a_mantissa[10] == 0) begin
                                                                            if (a_mantissa[9] == 0) begin
                                                                                if (a_mantissa[8] == 0) begin
                                                                                    if (a_mantissa[7] == 0) begin
                                                                                        if (a_mantissa[6] == 0) begin
                                                                                            if (a_mantissa[5] == 0) begin
                                                                                                if (a_mantissa[4] == 0) begin
                                                                                                    if (a_mantissa[3] == 0) begin
                                                                                                        if (a_mantissa[2] == 0) begin
                                                                                                            if (a_mantissa[1] == 0) begin
                                                                                                                as <= 5'd22;
                                                                                                            end else begin
                                                                                                                as <= 5'd21;
                                                                                                            end
                                                                                                        end else begin
                                                                                                            as <= 5'd20;
                                                                                                        end
                                                                                                    end else begin
                                                                                                        as <= 5'd19;
                                                                                                    end
                                                                                                end else begin
                                                                                                    as <= 5'd18;
                                                                                                    end
                                                                                            end else begin
                                                                                            as <= 5'd17;
                                                                                            end
                                                                                        end else begin
                                                                                        as <= 5'd16;
                                                                                        end
                                                                                    end else begin
                                                                                    as <= 5'd15;
                                                                                    end
                                                                                end else begin
                                                                                as <= 5'd14;
                                                                                end
                                                                            end else begin
                                                                            as <= 5'd13;
                                                                            end
                                                                        end else begin
                                                                        as <= 5'd12;
                                                                        end
                                                                    end else begin
                                                                    as <= 5'd11;
                                                                    end
                                                                end else begin
                                                                as <= 5'd10;
                                                                end
                                                            end else begin
                                                            as <= 5'd9;
                                                            end
                                                        end else begin
                                                        as <= 5'd8;
                                                        end
                                                    end else begin
                                                    as <= 5'd7;
                                                    end
                                                end else begin
                                                as <= 5'd6;
                                                end
                                            end else begin
                                            as <= 5'd5;
                                            end
                                        end else begin
                                        as <= 5'd4;
                                        end
                                    end else begin
                                    as <= 5'd3;
                                    end
                                end else begin
                                as <= 5'd2;
                                end
                            end else begin
                            as <= 5'd1;
                            end
                        end else begin
                            as <= 5'd0;
                        end
                        a_man_24 <= a_mantissa << (22 - as);
                        a_exp_10 <= (10'd126 + as) - 10'd127; // actual exponent
                    end else begin
                        a_man_24 <= {1'b1, a_mantissa};
                        a_exp_10 <= a_exponent - BIAS;
                    end
                    
                    if (b_exp_zero) begin
                        reg [4:0] bs;
                        bs <= 5'd0;
                        if (b_mantissa[22] == 0) begin
                            if (b_mantissa[21] == 0) begin
                                if (b_mantissa[20] == 0) begin
                                    if (b_mantissa[19] == 0) begin
                                        if (b_mantissa[18] == 0) begin
                                            if (b_mantissa[17] == 0) begin
                                                if (b_mantissa[16] == 0) begin
                                                    if (b_mantissa[15] == 0) begin
                                                        if (b_mantissa[14] == 0) begin
                                                            if (b_mantissa[13] == 0) begin
                                                                if (b_mantissa[12] == 0) begin
                                                                    if (b_mantissa[11] == 0) begin
                                                                        if (b_mantissa[10] == 0) begin
                                                                            if (b_mantissa[9] == 0) begin
                                                                                if (b_mantissa[8] == 0) begin
                                                                                    if (b_mantissa[7] == 0) begin
                                                                                        if (b_mantissa[6] == 0) begin
                                                                                            if (b_mantissa[5] == 0) begin
                                                                                                if (b_mantissa[4] == 0) begin
                                                                                                    if (b_mantissa[3] == 0) begin
                                                                                                        if (b_mantissa[2] == 0) begin
                                                                                                            if (b_mantissa[1] == 0) begin
                                                                                                                bs <= 5'd22;
                                                                                                            end else begin
                                                                                                                bs <= 5'd21;
                                                                                                            end
                                                                                                        end else begin
                                                                                                            bs <= 5'd20;
                                                                                                        end
                                                                                                    end else begin
                                                                                                        bs <= 5'd19;
                                                                                                    end
                                                                                                end else begin
                                                                                                    bs <= 5'd18;
                                                                                                    end
                                                                                            end else begin
                                                                                            bs <= 5'd17;
                                                                                            end
                                                                                        end else begin
                                                                                        bs <= 5'd16;
                                                                                        end
                                                                                    end else begin
                                                                                    bs <= 5'd15;
                                                                                    end
                                                                                end else begin
                                                                                bs <= 5'd14;
                                                                                end
                                                                            end else begin
                                                                            bs <= 5'd13;
                                                                            end
                                                                        end else begin
                                                                        bs <= 5'd12;
                                                                        end
                                                                    end else begin
                                                                    bs <= 5'd11;
                                                                    end
                                                                end else begin
                                                                bs <= 5'd10;
                                                                end
                                                            end else begin
                                                            bs <= 5'd9;
                                                            end
                                                        end else begin
                                                        bs <= 5'd8;
                                                        end
                                                    end else begin
                                                    bs <= 5'd7;
                                                    end
                                                end else begin
                                                bs <= 5'd6;
                                                end
                                            end else begin
                                            bs <= 5'd5;
                                            end
                                        end else begin
                                        bs <= 5'd4;
                                        end
                                    end else begin
                                    bs <= 5'd3;
                                    end
                                end else begin
                                bs <= 5'd2;
                                end
                            end else begin
                            bs <= 5'd1;
                            end
                        end else begin
                            bs <= 5'd0;
                        end
                        b_man_24 <= b_mantissa << (22 - bs);
                        b_exp_10 <= (10'd126 + bs) - 10'd127;
                    end else begin
                        b_man_24 <= {1'b1, b_mantissa};
                        b_exp_10 <= b_exponent - BIAS;
                    end
                    
                    // Multiply 24-bit mantissas to get 48-bit product
                    product <= a_man_24 * b_man_24;
                    z_sign <= a_sign ^ b_sign;
                    
                    // Combined exponent
                    z_exponent <= a_exp_10 + b_exp_10;
                    
                    counter <= 3'd3;
                end

                3'd3: begin
                    // Rounding and normalization of result
                    // product is 48-bit: [47:0]
                    // The true product has a leading 1 at bit 47 or 46
                    // If product[47] == 1, then product is 1.xxx * 2^47, so mantissa is product[47:0] with implicit 1 at pos 47
                    // Actually, since both operands are 24-bit with leading 1, product is between 2^46 and 2^48-2^47
                    // So product[47] can be 0 or 1
                    
                    reg [47:0] prod_48;
                    prod_48 <= product[47:0];
                    
                    if (product[47] == 1'b1) begin
                        // Product is 1.xxx * 2^47, so the 24-bit mantissa is product[47:24]
                        // Wait, product is 48 bits. The significand is 1.fraction where fraction is 47 bits
                        // We need to round to 23-bit fraction (24-bit significand)
                        // product[47:0] = 1.fraction_47_bits
                        // We want 1.fraction_23_bits
                        // So we look at bits [47:24] as the 24-bit significand (bit 47 is the leading 1)
                        // Guard bit = product[23]
                        // Round bit = product[22]
                        // Sticky = OR of product[21:0]
                        
                        z_mantissa <= product[47:24];
                        guard_bit <= product[23];
                        round_bit <= product[22];
                        sticky <= |product[21:0];
                        
                        // Exponent adjustment: since we didn't shift, exponent stays
                        // But the significand is already in the right position
                    end else begin
                        // Product is 0.1xxx * 2^47 = 1.xxx * 2^46
                        // So we need to left shift by 1
                        // product[46:0] gives us 1.xxx * 2^46
                        // The 24-bit significand is product[46:23]
                        // Guard bit = product[22]
                        // Round bit = product[21]
                        // Sticky = OR of product[20:0]
                        
                        z_mantissa <= {1'b0, product[46:24]};
                        guard_bit <= product[23];
                        round_bit <= product[22];
                        sticky <= |product[21:0];
                        
                        // Adjust exponent down by 1
                        z_exponent <= z_exponent - 10'd1;
                    end
                    
                    counter <= 3'd4;
                end

                3'd4: begin
                    // Apply rounding
                    // Round to nearest, ties to even
                    // If guard=1 and (round=1 or sticky=1 or (round=0 and sticky=0 and mantissa[0]=1)), then round up
                    reg round_up;
                    round_up <= 1'b0;
                    
                    if (guard_bit) begin
                        if (round_bit || sticky) begin
                            round_up <= 1'b1;
                        end else begin
                            // Guard=1, Round=0, Sticky=0: tie, round to even
                            if (z_mantissa[0]) begin
                                round_up <= 1'b1;
                            end
                        end
                    end
                    
                    if (round_up) begin
                        z_mantissa <= z_mantissa + 24'd1;
                        // Check if mantissa overflowed (became 24'h1000000)
                        if (z_mantissa == 24'h1000000) begin
                            z_mantissa <= 24'd0;
                            z_exponent <= z_exponent + 10'd1;
                        end
                    end
                    
                    counter <= 3'd5;
                end

                3'd5: begin
                    // Format the result, handling overflow and underflow
                    // z_exponent is the actual exponent (not biased)
                    // Biased exponent = z_exponent + 127
                    
                    reg [9:0] biased_exp;
                    biased_exp <= z_exponent + BIAS;
                    
                    if (z_exponent >= 10'd128) begin
                        // Overflow: result is infinity
                        z_sign <= z_sign;
                        z_exponent <= 10'd255;
                        z_mantissa <= 23'd0;
                        z <= {z_sign, 8'hFF, z_mantissa};
                    end else if (z_exponent <= 10'd(-126)) begin
                        // Underflow: result is zero (or subnormal, but for simplicity, flush to zero)
                        // Proper underflow handling would generate subnormals, but let's do flush to zero
                        z_sign <= z_sign;
                        z_exponent <= 10'd0;
                        z_mantissa <= 23'd0;
                        z <= {z_sign, 8'h00, z_mantissa};
                    end else begin
                        // Normal result
                        // Biased exponent should be between 1 and 254
                        if (biased_exp == 10'd0) begin
                            // Subnormal result
                            // This case needs special handling
                            z_sign <= z_sign;
                            z_exponent <= 10'd0;
                            z_mantissa <= 23'd0;
                            z <= {z_sign, 8'h00, z_mantissa};
                        end else if (biased_exp == 10'd255) begin
                            // Should not happen if we handled overflow above
                            z_sign <= z_sign;
                            z_exponent <= 10'd255;
                            z_mantissa <= 23'd0;
                            z <= {z_sign, 8'hFF, z_mantissa};
                        end else begin
                            // Normal: extract 23-bit fraction from z_mantissa (which is 24-bit with leading 1)
                            z_sign <= z_sign;
                            z_exponent <= biased_exp;
                            z_mantissa <= z_mantissa[22:0];
                            z <= {z_sign, biased_exp[7:0], z_mantissa};
                        end
                    end
                    
                    counter <= 3'd0;
                end

                default: begin
                    counter <= 3'd0;
                end
            end
        end
    end

endmodule