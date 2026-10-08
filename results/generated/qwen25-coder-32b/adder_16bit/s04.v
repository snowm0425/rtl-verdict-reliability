module
module adder_8bit (
    input  [7:0] a,    // 8-bit input operand A
    input  [7:0] b,    // 8-bit input operand B
    input        cin,   // Carry-in input
    output [7:0] y,    // 8-bit output representing the sum
    output       cout   // Carry-out output
);

    // Internal signals
    wire [7:0] sum;
    wire       carry;

    // Generate sum and carry for each bit
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_adders
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin((i == 0) ? cin : carry),
                .y(sum[i]),
                .cout(carry)
            );
        end
    endgenerate

    // Assign outputs
    assign y = sum;
    assign cout = carry;

endmodule

// Full adder for a single bit
module full_adder (
    input  a,    // Input bit A
    input  b,    // Input bit B
    input  cin,  // Carry-in input
    output y,    // Sum output
    output cout  // Carry-out output
);

    // Sum and carry-out logic
    assign y = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));

endmodule

// 16-bit full adder module using two 8-bit adders
module adder_16bit (
    input  [15:0] a,    // 16-bit input operand A
    input  [15:0] b,    // 16-bit input operand B
    input         cin,  // Carry-in input
    output [15:0] y,    // 16-bit output representing the sum
    output        cout  // Carry-out output
);

    // Internal signals
    wire [7:0] y_low;  // Lower 8-bit sum
    wire [7:0] y_high; // Upper 8-bit sum
    wire       cout_low; // Carry-out from lower 8-bit adder

    // Instantiate two 8-bit adders
    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(cin),
        .y(y_low),
        .cout(cout_low)
    );

    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(cout_low),
        .y(y_high),
        .cout(cout)
    );

    // Assign the final 16-bit sum
    assign y = {y_high, y_low};

endmodule