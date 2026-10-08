module RAM (
    input wire clk,          // Clock signal used for synchronous operation.
    input wire rst_n,        // Active-low reset signal. Defined as 0 for reset and 1 for reset signal inactive.
    input wire write_en,     // Write enable signal to initiate a write operation.
    input wire [2:0] write_addr, // Address for the write operation (3 bits for depth of 8).
    input wire [5:0] write_data, // Data to be written to the RAM (6 bits wide).
    input wire read_en,      // Read enable signal to initiate a read operation.
    input wire [2:0] read_addr,  // Address for the read operation (3 bits for depth of 8).
    output reg [5:0] read_data // Output signal representing the data read from the RAM (6 bits wide).
);

    parameter WIDTH = 6;
    parameter DEPTH = 8;

    // RAM array declaration
    reg [WIDTH-1:0] RAM [DEPTH-1:0];

    // Initialization of the RAM array to 0 on reset
    initial begin
        for (integer i = 0; i < DEPTH; i = i + 1) begin
            RAM[i] <= 0;
        end
    end

    // Write operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear all memory locations on reset
            for (integer i = 0; i < DEPTH; i = i + 1) begin
                RAM[i] <= 0;
            end
        end else if (write_en) begin
            // Write data to the RAM array at the specified address
            RAM[write_addr] <= write_data;
        end
    end

    // Read operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear read_data on reset
            read_data <= 0;
        end else if (read_en) begin
            // Read data from the RAM array at the specified address
            read_data <= RAM[read_addr];
        end else begin
            // Clear read_data if read_en is not active
            read_data <= 0;
        end
    end

endmodule