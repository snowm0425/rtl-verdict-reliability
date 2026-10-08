module adder_8bit (
    input [7:0] a,      // 8-bit input operand A
    input [7:0] b,      // 8-bit input operand B
    input Cin,          // Carry-in input
    output [7:0] y,     // 8-bit output representing the sum
    output Co           // Carry-out output
);

    wire [7:0] carry;

    // Full adder for each bit position
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_adder
            if (i == 0) begin
                // First bit uses Cin
                full_adder_bit fa (
                    .a(a[0]),
                    .b(b[0]),
                    .Cin(Cin),
                    .y(y[0]),
                    .Co(carry[0])
                );
            end else begin
                // Subsequent bits use the carry from the previous bit
                full_adder_bit fa (
                    .a(a[i]),
                    .b(b[i]),
                    .Cin(carry[i-1]),
                    .y(y[i]),
                    .Co(carry[i])
                );
            end
        end
    endgenerate

    // The final carry-out is the carry from the last bit
    assign Co = carry[7];

endmodule

// Full adder for a single bit
module full_adder_bit (
    input a,            // Input A
    input b,            // Input B
    input Cin,          // Carry-in
    output y,           // Sum output
    output Co           // Carry-out
);

    assign y = a ^ b ^ Cin;
    assign Co = (a & b) | (Cin & (a ^ b));

endmodule