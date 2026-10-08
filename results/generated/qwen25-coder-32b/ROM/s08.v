module ROM (
    input  wire  [7:0] addr,  // 8-bit address input
    output wire [15:0] dout   // 16-bit output data
);

    // Define a 256x16 ROM
    reg [15:0] mem [0:255];

    // Initialize the ROM with some fixed data
    initial begin
        mem[0]   = 16'hA0A0;
        mem[1]   = 16'hB1B1;
        mem[2]   = 16'hC2C2;
        mem[3]   = 16'hD3D3;
        
        // Initialize other memory locations as needed
        // For example:
        // mem[4]   = 16'h0000;
        // mem[5]   = 16'h1111;
        // ...
        // mem[255] = 16'hFFFF;
    end

    // Continuous assignment to output the data at the specified address
    assign dout = mem[addr];

endmodule