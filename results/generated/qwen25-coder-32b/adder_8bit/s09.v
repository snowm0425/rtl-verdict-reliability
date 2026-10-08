module full_adder (
    input a,        // First bit of operand A
    input b,        // First bit of operand B
    input cin,      // Carry-in from the previous bit
    output sum,     // Sum of the current bit
    output cout     // Carry-out to the next bit
);
    assign sum = a ^ b ^ cin;       // Sum calculation
    assign cout = (a & b) | (cin & (a ^ b));  // Carry-out calculation
endmodule

// 8-bit Adder Module
module adder_8bit (
    input [7:0] a,  // 8-bit input operand A
    input [7:0] b,  // 8-bit input operand B
    input cin,      // Carry-in input
    output [7:0] sum,  // 8-bit output representing the sum of A and B
    output cout      // Carry-out output
);
    wire [7:0] carry;  // Internal carry lines

    // Instantiate 8 full adders
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : fa_gen
            if (i == 0) begin
                // First full adder takes cin as input
                full_adder fa0 (
                    .a(a[0]),
                    .b(b[0]),
                    .cin(cin),
                    .sum(sum[0]),
                    .cout(carry[0])
                );
            end else begin
                // Subsequent full adders take carry from the previous adder
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate

    // The final carry-out is the last carry in the chain
    assign cout = carry[7];
endmodule