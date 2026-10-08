module adder_8bit (
    input [7:0] a,    // 8-bit input operand A
    input [7:0] b,    // 8-bit input operand B
    input       cin,  // Carry-in input
    output [7:0] y,   // 8-bit output representing the sum of A and B
    output      cout  // Carry-out output
);
    // Internal signals
    wire [7:0] sum;
    wire       carry;

    // Full adder for each bit position
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_adder
            if (i == 0) begin
                // For the least significant bit, use cin
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(sum[i]),
                    .carry(carry)
                );
            end else begin
                // For other bits, use the carry from the previous bit
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry),
                    .sum(sum[i]),
                    .carry(carry)
                );
            end
        end
    endgenerate

    // Assign the final sum and carry out
    assign y = sum;
    assign cout = carry;
endmodule

// Full adder for a single bit
module full_adder (
    input a,    // 1-bit input A
    input b,    // 1-bit input B
    input cin,  // Carry-in input
    output sum, // Sum output
    output carry // Carry-out output
);
    assign sum = a ^ b ^ cin;
    assign carry = (a & b) | (cin & (a ^ b));
endmodule