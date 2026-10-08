module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    // Sum is the XOR of a, b, and cin
    assign sum = a ^ b ^ cin;
    
    // Carry-out is the OR of (a AND b), (b AND cin), and (a AND cin)
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module adder_8bit (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire [7:0] carry; // Intermediate carry wires

    // Instantiate 8 full adders
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : fa_gen
            if (i == 0) begin
                // For the least significant bit, use the provided cin
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end else begin
                // For other bits, use the carry-out of the previous bit
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

    // The final carry-out is the carry-out of the most significant bit
    assign cout = carry[7];
endmodule