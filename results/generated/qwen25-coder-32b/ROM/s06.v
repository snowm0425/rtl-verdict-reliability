module ROM (
    input [7:0] addr,   // 8-bit address input
    output reg [15:0] dout  // 16-bit output
);

    // Define a ROM with 256 locations, each 16 bits wide
    reg [15:0] mem [0:255];

    // Initial block to pre-load the ROM with fixed data
    initial begin
        // Initialize specific memory locations
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;
        // Initialize other locations as needed (optional)
        // For example, you can initialize the rest to 0 or any other value
        for (integer i = 4; i < 256; i = i + 1) begin
            mem[i] = 16'h0000;  // Initialize to 0
        end
    end

    // Continuous assignment to output the data at the specified address
    always @(*) begin
        dout = mem[addr];
    end

endmodule