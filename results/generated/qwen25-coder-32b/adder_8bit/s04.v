module full_adder (
    input a,        // First input bit
    input b,        // Second input bit
    input cin,      // Carry-in
    output sum,     // Sum of the three inputs
    output cout     // Carry-out
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// 8-bit Adder Module
module adder_8bit (
    input [7:0] a,  // 8-bit input operand A
    input [7:0] b,  // 8-bit input operand B
    input cin,      // Carry-in
    output [7:0] sum, // 8-bit output representing the sum of A and B
    output cout     // Carry-out
);

    wire [7:0] carry; // Internal carry wires

    // Full adder for the least significant bit (LSB)
    full_adder fa0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(carry[0])
    );

    // Full adders for the remaining bits
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin : fa_gen
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i-1]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    // The carry-out of the most significant bit (MSB) is the final cout
    assign cout = carry[7];

endmodule