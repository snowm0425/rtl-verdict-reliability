module ROM (
    input  [7:0] addr,    // 8-bit address input
    output [15:0] dout    // 16-bit data output
);

    // Define the ROM memory array with 256 locations, each 16 bits wide
    reg [15:0] mem [0:255];

    // Initial block to pre-load the ROM with fixed data
    initial begin
        // Initialize specific memory locations with values
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;
        
        // You can initialize other locations as needed
        // For example:
        // mem[4] = 16'hE4E4;
        // mem[5] = 16'hF5F5;
        // and so on...
    end

    // Continuously output the data stored in the ROM at the specified address
    always @(*) begin
        dout = mem[addr];
    end

endmodule