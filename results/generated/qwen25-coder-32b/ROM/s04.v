module ROM (
    input  [7:0] addr,    // 8-bit address input
    output [15:0] dout    // 16-bit data output
);

    // Define a 256x16 memory array
    reg [15:0] mem [0:255];

    // Initialize the ROM with fixed data
    initial begin
        // Initialize specific memory locations
        mem[0] = 16'hA0A0;
        mem[1] = 16'hB1B1;
        mem[2] = 16'hC2C2;
        mem[3] = 16'hD3D3;

        // Initialize other memory locations as needed
        // For example, initialize the rest to 0
        for (integer i = 4; i < 256; i = i + 1) begin
            mem[i] = 16'h0000;
        end
    end

    // Output the data stored in the ROM at the specified address
    always @(*) begin
        dout = mem[addr];
    end

endmodule