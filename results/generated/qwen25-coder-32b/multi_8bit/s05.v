module multi_8bit (
    input  [7:0] A,          // First 8-bit input operand (multiplicand)
    input  [7:0] B,          // Second 8-bit input operand (multiplier)
    output [15:0] product    // 16-bit output representing the product (A * B)
);

    reg [15:0] acc;          // Accumulator to store the intermediate product
    reg [7:0] multiplicand;  // Register to hold the multiplicand A
    reg [7:0] multiplier;    // Register to hold the multiplier B
    reg [3:0] count;         // Counter to iterate through each bit of B

    // Initialize registers at the start of each multiplication
    initial begin
        acc = 16'b0;
        multiplicand = A;
        multiplier = B;
        count = 4'b0;
    end

    // Sequential logic for shift-and-add
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acc <= 16'b0;
            multiplicand <= A;
            multiplier <= B;
            count <= 4'b0;
        end else if (count < 8) begin
            // Add multiplicand to accumulator if the current bit of multiplier is 1
            if (multiplier[0] == 1'b1) begin
                acc <= acc + {8'b0, multiplicand}; // Shift multiplicand left by 8 bits and add to acc
            end
            // Shift multiplicand left by 1 bit
            multiplicand <= multiplicand << 1;
            // Shift multiplier right by 1 bit
            multiplier <= multiplier >> 1;
            // Increment the counter
            count <= count + 1;
        end else begin
            // Load the final product into the output port
            product <= acc;
        end
    end

endmodule