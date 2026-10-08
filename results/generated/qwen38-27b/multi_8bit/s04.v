module multi_8bit (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] product
);

    // Shift-and-add method for 8-bit multiplication
    // product = A * B
    // We iterate through each bit of B (multiplier)
    // For each bit i that is set, add A shifted left by i positions to the product

    reg [15:0] prod;
    reg [15:0] shifted_a;

    integer i;

    always @* begin
        prod = 16'd0;
        for (i = 0; i < 8; i = i + 1) begin
            shifted_a = {A, 8'd0} << i; // A shifted left by i bits, zero-extended to 16 bits
            if (B[i]) begin
                prod = prod + shifted_a;
            end
        end
    end

    assign product = prod;

endmodule