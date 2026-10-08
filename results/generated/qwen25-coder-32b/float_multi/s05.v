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
    reg [27:0] normalized_mantissa;
    reg [9:0] adjusted_exponent;
    reg [31:0] nan_or_inf;

    // Special case handling flags
    reg is_nan, is_inf, is_zero;

    // States
    parameter IDLE = 3'b000;
    parameter PROCESS_INPUTS = 3'b001;
    parameter HANDLE_SPECIAL_CASES = 3'b010;
    parameter NORMALIZE = 3'b011;
    parameter MULTIPLY = 3'b100;
    parameter ROUND_ADJUST = 3'b101;
    parameter OUTPUT_GENERATION = 3'b110;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= IDLE;
            z <= 32'b0;
        end else begin
            case (counter)
                IDLE: begin
                    counter <= PROCESS_INPUTS;
                end
                PROCESS_INPUTS: begin
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= a[30:23];
                    b_exponent <= b[30:23];
                    a_mantissa <= a[22:0];
                    b_mantissa <= b[22:0];
                    counter <= HANDLE_SPECIAL_CASES;
                end
                HANDLE_SPECIAL_CASES: begin
                    is_nan <= (a_exponent == 9'b11111111 && a_mantissa != 23'b0) ||
                              (b_exponent == 9'b11111111 && b_mantissa != 23'b0);
                    is_inf <= (a_exponent == 9'b11111111 && a_mantissa == 23'b0) ||
                              (b_exponent == 9'b11111111 && b_mantissa == 23'b0);
                    is_zero <= (a_exponent == 9'b0 && a_mantissa == 23'b0) ||
                              (b_exponent == 9'b0 && b_mantissa == 23'b0);

                    if (is_nan) begin
                        nan_or_inf <= 32'b01111111111000000000000000000000; // NaN
                        counter <= OUTPUT_GENERATION;
                    end else if (is_inf) begin
                        if (is_zero) begin
                            nan_or_inf <= 32'b01111111111000000000000000000000; // NaN
                        end else begin
                            nan_or_inf <= {a_sign ^ b_sign, 9'b11111111, 23'b0}; // Inf
                        end
                        counter <= OUTPUT_GENERATION;
                    end else begin
                        counter <= NORMALIZE;
                    end
                end
                NORMALIZE: begin
                    a_mantissa <= {1'b1, a_mantissa};
                    b_mantissa <= {1'b1, b_mantissa};
                    counter <= MULTIPLY;
                end
                MULTIPLY: begin
                    product <= a_mantissa * b_mantissa;
                    counter <= ROUND_ADJUST;
                end
                ROUND_ADJUST: begin
                    normalized_mantissa <= product[49:24];
                    guard_bit <= product[23];
                    round_bit <= product[22];
                    sticky <= |product[21:0];

                    // Rounding logic (round to nearest, ties to even)
                    if (guard_bit && (round_bit || sticky)) begin
                        normalized_mantissa <= normalized_mantissa + 1;
                    end

                    // Handle overflow after rounding
                    if (normalized_mantissa[27]) begin
                        normalized_mantissa <= normalized_mantissa >> 1;
                        adjusted_exponent <= a_exponent + b_exponent + 1;
                    end else begin
                        adjusted_exponent <= a_exponent + b_exponent;
                    end

                    // Handle underflow
                    if (adjusted_exponent == 10'b0 && !normalized_mantissa[26]) begin
                        adjusted_exponent <= 10'b0;
                        normalized_mantissa <= 24'b0;
                    end

                    // Handle overflow to infinity
                    if (adjusted_exponent >= 10'b11111111) begin
                        adjusted_exponent <= 10'b11111111;
                        normalized_mantissa <= 24'b0;
                    end

                    counter <= OUTPUT_GENERATION;
                end
                OUTPUT_GENERATION: begin
                    z_sign <= a_sign ^ b_sign;
                    z_exponent <= adjusted_exponent;
                    z_mantissa <= normalized_mantissa[26:4];
                    z <= {z_sign, z_exponent, z_mantissa};

                    if (is_nan || is_inf) begin
                        z <= nan_or_inf;
                    end

                    counter <= IDLE;
                end
            endcase
        end
    end

endmodule