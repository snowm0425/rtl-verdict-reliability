module
module adder_8bit (
    input [7:0] a,    // 8-bit input operand A
    input [7:0] b,    // 8-bit input operand B
    input Cin,        // Carry-in input
    output [7:0] y,   // 8-bit output representing the sum of A and B
    output Co         // Carry-out output
);

    wire [7:0] c;    // Internal carry signals

    // Generate the 8 full adders
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_adder_gen
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(i == 0 ? Cin : c[i-1]),
                .sum(y[i]),
                .cout(c[i])
            );
        end
    endgenerate

    // The carry-out of the last full adder is the module's Co
    assign Co = c[7];
endmodule

// 1-bit full adder module
module full_adder (
    input a,          // 1-bit input operand A
    input b,          // 1-bit input operand B
    input cin,        // Carry-in input
    output sum,       // 1-bit output representing the sum of A, B, and Cin
    output cout       // 1-bit carry-out output
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// 16-bit full adder module
module adder_16bit (
    input [15:0] a,   // 16-bit input operand A
    input [15:0] b,   // 16-bit input operand B
    input Cin,        // Carry-in input
    output [15:0] y,  // 16-bit output representing the sum of A and B
    output Co         // Carry-out output
);

    wire [7:0] y_low, y_high;   // Outputs of the 8-bit adders
    wire c_low;                  // Carry-out of the lower 8-bit adder

    // Instantiate the first 8-bit adder for the lower 8 bits
    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(y_low),
        .Co(c_low)
    );

    // Instantiate the second 8-bit adder for the upper 8 bits
    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(c_low),
        .y(y_high),
        .Co(Co)
    );

    // Assign the outputs of the 8-bit adders to the final output
    assign y[7:0] = y_low;
    assign y[15:8] = y_high;
endmodule