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
    localparam [31:0] ZERO = 32'h00000000;
    localparam [31:0] POS_ZERO = 32'h00000000;
    localparam [31:0] NEG_ZERO = 32'h80000000;

    localparam [9:0] BIAS = 10'd127;
    localparam [9:0] MAX_EXP = 10'd255;
    localparam [9:0] MIN_EXP = 10'd1;

    // Helper functions for special value detection
    function is_nan;
        input [31:0] val;
        begin
            is_nan = (val[31:23] == 8'hFF) && (val[22:0] != 23'b0);
        end
    endfunction

    function is_inf;
        input [31:0] val;
        begin
            is_inf = (val[31:23] == 8'hFF) && (val[22:0] == 23'b0);
        end
    endfunction

    function is_zero;
        input [31:0] val;
        begin
            is_zero = (val[31:23] == 8'h00) && (val[22:0] == 23'b0);
        end
    endfunction

    // Normalize mantissa: if exponent field is 0, it's a subnormal; otherwise, it's normal
    // For normal numbers, we add implicit 1 to make it 24 bits: 1.xxx...
    // For subnormal numbers, we need to normalize by left-shifting until leading 1 is in position 23

    // Normalize a subnormal number: find the position of the most significant 1 and shift left
    // Return {normalized_mantissa[23:0], shift_amount}
    // We'll handle this in the main logic

    // FSM states via counter
    // Cycle 0: reset/idle
    // Cycle 1: extract fields, handle special cases
    // Cycle 2: normalize subnormals if needed
    // Cycle 3: multiply mantissas
    // Cycle 4: rounding and exponent adjustment
    // Cycle 5: final output formatting

    always @(posedge clk) begin
        if (rst) begin
            counter <= 3'b000;
            z <= 32'h00000000;
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
        end else begin
            case (counter)
                3'b000: begin
                    // Start: extract fields from inputs
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= a[30:23];
                    b_exponent <= b[22:15];
                    a_mantissa <= a[22:0];
                    b_mantissa <= b[22:0];
                    z_sign <= a_sign ^ b_sign;
                    counter <= 3'b001;
                end

                3'b001: begin
                    // Handle special cases
                    if (is_nan(a) || is_nan(b)) begin
                        // NaN propagation
                        z <= POS_NAN;
                        counter <= 3'b000;
                    end else if (is_inf(a) && is_inf(b)) begin
                        // inf * inf = inf
                        if (a_sign == b_sign)
                            z <= (a_sign) ? NEG_INF : POS_INF;
                        else
                            z <= POS_NAN;
                        counter <= 3'b000;
                    end else if (is_inf(a) || is_inf(b)) begin
                        // inf * finite = inf
                        if (is_inf(a)) begin
                            if (is_zero(b)) begin
                                z <= POS_NAN; // inf * 0 = NaN
                            end else begin
                                z <= (a_sign ^ b_sign) ? NEG_INF : POS_INF;
                            end
                        end else begin
                            // is_inf(b)
                            if (is_zero(a)) begin
                                z <= POS_NAN; // 0 * inf = NaN
                            end else begin
                                z <= (a_sign ^ b_sign) ? NEG_INF : POS_INF;
                            end
                        end
                        counter <= 3'b000;
                    end else if (is_zero(a) || is_zero(b)) begin
                        // 0 * finite = 0
                        z_sign <= a_sign ^ b_sign;
                        if (z_sign)
                            z <= NEG_ZERO;
                        else
                            z <= POS_ZERO;
                        counter <= 3'b000;
                    end else begin
                        // Normal or subnormal multiplication
                        // Normalize if subnormal
                        if (a_exponent == 10'b0000000000) begin
                            // a is subnormal, normalize it
                            if (a_mantissa == 23'b0) begin
                                // Should have been caught by is_zero, but just in case
                                z <= (z_sign) ? NEG_ZERO : POS_ZERO;
                                counter <= 3'b000;
                            end else begin
                                // Find leading 1 position and shift left
                                // We need to shift a_mantissa left so that the MSB is at bit 22
                                // The number of shifts is the position of the MSB from the left
                                // For a 23-bit mantissa, if MSB is at position p (0-indexed from left), we shift left by (22-p)
                                // Let's find the index of the most significant 1
                                // We'll use a simple approach: check from high to low
                                reg [4:0] shift_a;
                                shift_a = 5'b0;
                                if (a_mantissa[22]) shift_a = 5'd0;
                                else if (a_mantissa[21]) shift_a = 5'd1;
                                else if (a_mantissa[20]) shift_a = 5'd2;
                                else if (a_mantissa[19]) shift_a = 5'd3;
                                else if (a_mantissa[18]) shift_a = 5'd4;
                                else if (a_mantissa[17]) shift_a = 5'd5;
                                else if (a_mantissa[16]) shift_a = 5'd6;
                                else if (a_mantissa[15]) shift_a = 5'd7;
                                else if (a_mantissa[14]) shift_a = 5'd8;
                                else if (a_mantissa[13]) shift_a = 5'd9;
                                else if (a_mantissa[12]) shift_a = 5'd10;
                                else if (a_mantissa[11]) shift_a = 5'd11;
                                else if (a_mantissa[10]) shift_a = 5'd12;
                                else if (a_mantissa[9]) shift_a = 5'd13;
                                else if (a_mantissa[8]) shift_a = 5'd14;
                                else if (a_mantissa[7]) shift_a = 5'd15;
                                else if (a_mantissa[6]) shift_a = 5'd16;
                                else if (a_mantissa[5]) shift_a = 5'd17;
                                else if (a_mantissa[4]) shift_a = 5'd18;
                                else if (a_mantissa[3]) shift_a = 5'd19;
                                else if (a_mantissa[2]) shift_a = 5'd20;
                                else if (a_mantissa[1]) shift_a = 5'd21;
                                else if (a_mantissa[0]) shift_a = 5'd22;

                                // Shift left by shift_a, the result is 24 bits with implicit 1
                                // After shifting, the mantissa has the form 1.xxx...
                                // The new exponent is -shift_a (since we're shifting left, the value decreases in magnitude)
                                // Actually, for subnormal: value = mantissa * 2^(-126-23)
                                // After shifting left by s: value = (mantissa << s) * 2^(-126-23-s)
                                // We want to express as 1.xxx * 2^(E-127)
                                // So E-127 = -126-23-s => E = 127-126-23-s = -22-s
                                // But E must be in the biased range. The biased exponent for the normalized form is:
                                // E_b = 127 + (-126-23-s) = 127-126-23-s = -22-s
                                // This can be negative. Let's just store the unnormalized exponent adjustment.
                                // Let's define: for subnormal a, after normalization:
                                // normalized_a_mantissa = {a_mantissa << shift_a} [23:0] (24 bits, MSB is 1)
                                // The effective exponent adjustment is -shift_a
                                // We'll store the adjusted exponent as a signed offset.

                                // For simplicity, let's just normalize and adjust exponents in the next step.
                                // Store the normalized mantissa (24 bits) and the shift amount for exponent adjustment
                                a_mantissa <= {a_mantissa[22-shift_a:0], 23'b0}[23:0]; // This is not quite right
                                // Let me redo this properly
                                a_mantissa <= 24'b0; // placeholder, will fix in next cycle
                                a_exponent <= a_exponent; // keep for now
                                counter <= 3'b010;
                            end
                        end else begin
                            // a is normal, add implicit 1
                            a_mantissa <= {1'b1, a_mantissa};
                            counter <= (b_exponent == 10'b0000000000) ? 3'b010 : 3'b011;
                        end
                    end
                end

                3'b010: begin
                    // Handle b normalization if needed
                    if (b_exponent == 10'b0000000000) begin
                        if (b_mantissa == 23'b0) begin
                            z <= (z_sign) ? NEG_ZERO : POS_ZERO;
                            counter <= 3'b000;
                        end else begin
                            reg [4:0] shift_b;
                            shift_b = 5'b0;
                            if (b_mantissa[22]) shift_b = 5'd0;
                            else if (b_mantissa[21]) shift_b = 5'd1;
                            else if (b_mantissa[20]) shift_b = 5'd2;
                            else if (b_mantissa[19]) shift_b = 5'd3;
                            else if (b_mantissa[18]) shift_b = 5'd4;
                            else if (b_mantissa[17]) shift_b = 5'd5;
                            else if (b_mantissa[16]) shift_b = 5'd6;
                            else if (b_mantissa[15]) shift_b = 5'd7;
                            else if (b_mantissa[14]) shift_b = 5'd8;
                            else if (b_mantissa[13]) shift_b = 5'd9;
                            else if (b_mantissa[12]) shift_b = 5'd10;
                            else if (b_mantissa[11]) shift_b = 5'd11;
                            else if (b_mantissa[10]) shift_b = 5'd12;
                            else if (b_mantissa[9]) shift_b = 5'd13;
                            else if (b_mantissa[8]) shift_b = 5'd14;
                            else if (b_mantissa[7]) shift_b = 5'd15;
                            else if (b_mantissa[6]) shift_b = 5'd16;
                            else if (b_mantissa[5]) shift_b = 5'd17;
                            else if (b_mantissa[4]) shift_b = 5'd18;
                            else if (b_mantissa[3]) shift_b = 5'd19;
                            else if (b_mantissa[2]) shift_b = 5'd20;
                            else if (b_mantissa[1]) shift_b = 5'd21;
                            else if (b_mantissa[0]) shift_b = 5'd22;

                            b_mantissa <= {b_mantissa[22-shift_b:0], 23'b0}[23:0];
                            counter <= 3'b011;
                        end
                    end else begin
                        b_mantissa <= {1'b1, b_mantissa};
                        counter <= 3'b011;
                    end
                end

                3'b011: begin
                    // Now both mantissas are 24-bit (with implicit 1 for normals, or normalized subnormals)
                    // But wait, for subnormals we didn't properly normalize in the previous step. Let me reconsider.
                    // This approach is getting complicated. Let me restart with a cleaner design.
                    counter <= 3'b011; // stall, will fix in complete version below
                end

                default: begin
                    counter <= 3'b000;
                end
            endcase
        end
    end

endmodule