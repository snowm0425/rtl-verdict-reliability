module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

module adder_8bit (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire [7:0] carry;

    // Instantiate 8 full adders
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_adder_instances
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin((i == 0) ? cin : carry[i-1]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    // The carry-out of the last full adder is the final cout
    assign cout = carry[7];
endmodule