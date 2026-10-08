module fixed_point_adder #(
    parameter Q = 8, // Number of fractional bits (precision)
    parameter N = 16 // Total number of bits, including integer and fractional parts
)(
    input wire [N-1:0] a, // First N-bit fixed-point input operand
    input wire [N-1:0] b, // Second N-bit fixed-point input operand
    output reg [N-1:0] c  // N-bit output representing the result of the fixed-point addition
);

    // Internal Registers
    reg [N:0] res; // N+1-bit register to handle potential overflow during addition

    // Wires for MSBs
    wire a_msb = a[N-1];
    wire b_msb = b[N-1];

    // Wires for absolute values
    wire [N-1:0] abs_a = a_msb ? (~a + 1) : a;
    wire [N-1:0] abs_b = b_msb ? (~b + 1) : b;

    // Wires for comparison
    wire [N:0] abs_a_ext = {a_msb, abs_a};
    wire [N:0] abs_b_ext = {b_msb, abs_b};

    // Logic for addition or subtraction based on signs
    always @(*) begin
        if (a_msb == b_msb) begin
            // Both numbers have the same sign, add absolute values
            res = abs_a_ext + abs_b_ext;
            c[N-1] = a_msb; // Keep the sign bit consistent
            c[N-2:0] = res[N-2:0]; // Assign the result, trimming to N bits
        end else begin
            // Different signs, perform subtraction based on absolute values
            if (abs_a_ext > abs_b_ext) begin
                res = abs_a_ext - abs_b_ext;
                c[N-1] = 0; // Result is positive
                c[N-2:0] = res[N-2:0]; // Assign the result, trimming to N bits
            end else if (abs_a_ext < abs_b_ext) begin
                res = abs_b_ext - abs_a_ext;
                c[N-1] = (res[N-2] == 1'b1) ? 1'b1 : 1'b0; // Set sign bit based on result
                c[N-2:0] = res[N-2:0]; // Assign the result, trimming to N bits
            end else begin
                // abs_a_ext == abs_b_ext, result is zero
                c = 0;
            end
        end

        // Handle overflow
        if (res[N] != c[N-1]) begin
            // Overflow occurred, set result to max/min value based on sign
            c = (c[N-1] == 1'b0) ? {1'b0, {N-1{1'b1}}} : {1'b1, {N-1{1'b0}}};
        end
    end

endmodule