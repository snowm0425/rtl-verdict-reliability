module ROM (
    input  [7:0] addr,  // 8-bit address input
    output [15:0] dout  // 16-bit data output
);

    // Define a 256x16 ROM
    reg [15:0] mem [0:255];

    // Initialize the ROM with fixed data
    initial begin
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;
        
        // Additional initializations can be done here if needed
        // For example:
        // mem[4] = 16'hE4E4;
        // mem[5] = 16'hF5F5;
        // ...
        // mem[255] = 16'hFFFF;
    end

    // Continuous assignment to output the data at the specified address
    always @(*) begin
        dout = mem[addr];
    end

endmodule