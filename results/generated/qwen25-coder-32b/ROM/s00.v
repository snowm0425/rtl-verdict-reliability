module ROM (
    input  [7:0] addr,  // 8-bit address input
    output [15:0] dout  // 16-bit output data
);

    // Define a 256x16 ROM
    reg [15:0] mem [0:255];

    // Initial block to load fixed data into the ROM
    initial begin
        // Initialize the first four memory locations with specific values
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;

        // Initialize other memory locations as needed (example: all zeros)
        for (integer i = 4; i < 256; i = i + 1) begin
            mem[i] = 16'h0000;
        end
    end

    // Continuous assignment to output the data at the specified address
    assign dout = mem[addr];

endmodule