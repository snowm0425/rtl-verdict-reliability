module float_multi (
    input clk,          // Clock signal for synchronization
    input rst,          // Reset signal (active high)
    input [31:0] a,     // First operand in IEEE 754 format
    input [31:0] b,     // Second operand in IEEE 754 format
    output reg [31:0] z // Result of the multiplication in IEEE 754 format
);

    // Internal signals
    reg [2:0] counter;                // Cycle counter for operation sequencing
    reg [23:0] a_mantissa, b_mantissa, z_mantissa; // Mantissas of input and output numbers
    reg [9:0] a_exponent, b_exponent, z_exponent; // Exponents of input and output numbers
    reg a_sign, b_sign, z_sign;       // Sign bits for inputs and output
    reg [49:0] product;               // Intermediate product of the mantissas
    reg guard_bit, round_bit, sticky; // Rounding control bits

    // Constants
    localparam EXP_BIAS = 127;
    localparam EXP_MIN = 0;
    localparam EXP_MAX = 255;
    localparam NAN = 32'hFFC00000;
    localparam INF = 32'h7F800000;
    localparam NEG_INF = 32'hFF800000;
    localparam ZERO = 32'h00000000;

    // State machine states
    typedef enum reg [2:0] {
        IDLE = 3'b000,
        PROCESS_INPUT = 3'b001,
        SPECIAL_CASES = 3'b010,
        NORMALIZE = 3'b011,
        MULTIPLY = 3'b100,
        ROUND_ADJUST = 3'b101,
        FORMAT_OUTPUT = 3'b110
    } state_t;

    state_t state, next_state;

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE:
                if (counter == 0)
                    next_state = PROCESS_INPUT;
                else
                    next_state = IDLE;

            PROCESS_INPUT:
                next_state = SPECIAL_CASES;

            SPECIAL_CASES:
                next_state = NORMALIZE;

            NORMALIZE:
                next_state = MULTIPLY;

            MULTIPLY:
                next_state = ROUND_ADJUST;

            ROUND_ADJUST:
                next_state = FORMAT_OUTPUT;

            FORMAT_OUTPUT:
                next_state = IDLE;

            default:
                next_state = IDLE;
        endcase
    end

    // Counter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 3'b000;
        end else if (counter == 7) begin
            counter <= 3'b000;
        end else begin
            counter <= counter + 1;
        end
    end

    // Main processing logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_mantissa <= 24'h0;
            b_mantissa <= 24'h0;
            z_mantissa <= 24'h0;
            a_exponent <= 10'h0;
            b_exponent <= 10'h0;
            z_exponent <= 10'h0;
            a_sign <= 1'b0;
            b_sign <= 1'b0;
            z_sign <= 1'b0;
            product <= 50'h0;
            guard_bit <= 1'b0;
            round_bit <= 1'b0;
            sticky <= 1'b0;
            z <= 32'h0;
        end else begin
            case (state)
                PROCESS_INPUT: begin
                    a_sign = a[31];
                    b_sign = b[31];
                    a_exponent = a[30:23];
                    b_exponent = b[30:23];
                    a_mantissa = {1'b1, a[22:0]};
                    b_mantissa = {1'b1, b[22:0]};
                end

                SPECIAL_CASES: begin
                    if (a_exponent == EXP_MAX && a_mantissa != 24'h0) begin
                        z <= a; // NaN or infinity
                    end else if (b_exponent == EXP_MAX && b_mantissa != 24'h0) begin
                        z <= b; // NaN or infinity
                    end else if (a_exponent == EXP_MAX && b_exponent == EXP_MIN) begin
                        z <= a; // Infinity times zero
                    end else if (a_exponent == EXP_MIN && b_exponent == EXP_MAX) begin
                        z <= b; // Zero times infinity
                    end else begin
                        // Normal case
                    end
                end

                NORMALIZE: begin
                    // No normalization needed for IEEE 754 multiplication
                end

                MULTIPLY: begin
                    product = a_mantissa * b_mantissa;
                    z_exponent = a_exponent + b_exponent - EXP_BIAS;
                    z_sign = a_sign ^ b_sign;
                end

                ROUND_ADJUST: begin
                    // Extract guard, round, and sticky bits
                    guard_bit = product[23];
                    round_bit = product[22];
                    sticky = |product[21:0];
                    // Rounding logic
                    if (round_bit && (sticky || guard_bit)) begin
                        z_mantissa = product[49:26] + 1;
                        if (z_mantissa[24] == 1'b1) begin
                            z_exponent = z_exponent + 1;
                            z_mantissa = z_mantissa[23:1];
                        end else begin
                            z_mantissa = z_mantissa[23:1];
                        end
                    end else begin
                        z_mantissa = product[49:26];
                    end
                end

                FORMAT_OUTPUT: begin
                    if (z_exponent == EXP_MIN && z_mantissa[23] == 1'b1) begin
                        z_exponent = EXP_MIN + 1;
                        z_mantissa = z_mantissa << 1;
                    end else if (z_exponent == EXP_MIN && |z_mantissa[22:0] == 1'b1) begin
                        z_exponent = EXP_MIN;
                        z_mantissa = z_mantissa << 1;
                        while (z_mantissa[23] == 1'b0) begin
                            z_mantissa = z_mantissa << 1;
                            z_exponent = z_exponent - 1;
                        end
                        z_exponent = z_exponent + 1;
                        z_mantissa = z_mantissa[23:1];
                    end else if (z_exponent > EXP_MAX) begin
                        z <= (z_sign) ? NEG_INF : INF; // Overflow
                    end else if (z_exponent < EXP_MIN) begin
                        z <= ZERO; // Underflow
                    end else begin
                        z = {z_sign, z_exponent, z_mantissa};
                    end
                end

                default: begin
                    z <= 32'h0;
                end
            endcase
        end
    end

endmodule