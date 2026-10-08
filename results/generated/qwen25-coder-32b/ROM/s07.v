module ROM (
    input [7:0] addr,  // 8-bit address input
    output reg [15:0] dout  // 16-bit output
);

    // Define a 256x16 ROM
    reg [15:0] mem [0:255];

    // Initial block to load fixed data into the ROM
    initial begin
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;
        // Initialize other memory locations as needed
        // Example: mem[4] = 16'hXXXX;
        // Example: mem[5] = 16'hYYYY;
        // ...
    end

    // Continuously output the data stored in the ROM at the specified address
    always @(*) begin
        dout = mem[addr];
    end

endmodule