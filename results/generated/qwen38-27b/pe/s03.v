module pe (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] c
);

    // Use a wider temporary variable for the product to avoid overflow issues
    // The product of two 32-bit integers can be up to 64 bits, but we only
    // keep the lower 32 bits for the accumulation as specified by the 32-bit output.
    
    wire [31:0] product;

    assign product = a * b;

    always @(posedge clk or posedge rst) begin
        if (rst)
            c <= 32'd0;
        else
            c <= c + product;
    end

endmodule