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

    // State machine states
    localparam IDLE = 3'b000;
    localparam PROCESS_INPUT = 3'b001;
    localparam SPECIAL_CASES = 3'b010;
    localparam NORMALIZE = 3'b011;
    localparam MULTIPLY = 3'b100;
    localparam ROUND_ADJUST = 3'b101;
    localparam OUTPUT_GENERATION = 3'b110;

    // State register
    reg [2:0] state;

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            counter <= 3'b000;
            z <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (a != 0 && b != 0) begin
                        state <= PROCESS_INPUT;
                    end
                end
                PROCESS_INPUT: begin
                    a_sign = a[31];
                    a_exponent = a[30:23];
                    a_mantissa = {1'b1, a[22:0]}; // Hidden bit
                    b_sign = b[31];
                    b_exponent = b[30:23];
                    b_mantissa = {1'b1, b[22:0]}; // Hidden bit
                    state <= SPECIAL_CASES;
                end
                SPECIAL_CASES: begin
                    if (a_exponent == 10'b11111111 || b_exponent == 10'b11111111) begin
                        // NaN or Infinity
                        if (a_mantissa != 0 || b_mantissa != 0) begin
                            z <= 32'b01111111110000000000000000000000; // NaN
                        end else begin
                            z_sign = a_sign ^ b_sign;
                            z_exponent = 10'b11111111;
                            z_mantissa = 24'b0;
                            state <= OUTPUT_GENERATION;
                        end
                    end else begin
                        state <= NORMALIZE;
                    end
                end
                NORMALIZE: begin
                    // Normalize mantissas if necessary
                    a_mantissa = a_mantissa >> 1;
                    a_exponent = a_exponent + 1;
                    b_mantissa = b_mantissa >> 1;
                    b_exponent = b_exponent + 1;
                    state <= MULTIPLY;
                end
                MULTIPLY: begin
                    product = a_mantissa * b_mantissa;
                    z_sign = a_sign ^ b_sign;
                    z_exponent = a_exponent + b_exponent - 127;
                    state <= ROUND_ADJUST;
                end
                ROUND_ADJUST: begin
                    // Extract guard, round, and sticky bits
                    guard_bit = product[24];
                    round_bit = product[23];
                    sticky = (product[22:0] != 0);
                    // Rounding
                    if (round_bit && (guard_bit || sticky)) begin
                        z_mantissa = product[49:25] + 1;
                    end else begin
                        z_mantissa = product[49:25];
                    end
                    // Handle overflow
                    if (z_mantissa[24]) begin
                        z_mantissa = z_mantissa >> 1;
                        z_exponent = z_exponent + 1;
                    end
                    // Handle underflow
                    if (z_exponent == 0) begin
                        z_mantissa = z_mantissa >> 1;
                    end
                    state <= OUTPUT_GENERATION;
                end
                OUTPUT_GENERATION: begin
                    z = {z_sign, z_exponent, z_mantissa[22:0]};
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule