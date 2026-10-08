module RAM (
    input clk,          // Clock signal used for synchronous operation.
    input rst_n,        // Active-low reset signal. Defined as 0 for reset and 1 for reset signal inactive.
    input write_en,     // Write enable signal to initiate a write operation.
    input [2:0] write_addr, // Address for the write operation (3 bits for depth of 8).
    input [5:0] write_data, // Data to be written to the RAM (6 bits).
    input read_en,      // Read enable signal to initiate a read operation.
    input [2:0] read_addr,  // Address for the read operation (3 bits for depth of 8).
    output reg [5:0] read_data // Output signal representing the data read from the RAM.
);

    // Parameters
    parameter WIDTH = 6;
    parameter DEPTH = 8;

    // RAM Array
    reg [WIDTH-1:0] RAM [DEPTH-1:0];

    // Initialize the RAM to 0 on reset
    initial begin
        for (integer i = 0; i < DEPTH; i = i + 1) begin
            RAM[i] = 0;
        end
    end

    // Write Operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear all memory locations on reset
            for (integer i = 0; i < DEPTH; i = i + 1) begin
                RAM[i] <= 0;
            end
        end else if (write_en) begin
            // Write data to the specified address
            RAM[write_addr] <= write_data;
        end
    end

    // Read Operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear read_data on reset
            read_data <= 0;
        end else if (read_en) begin
            // Read data from the specified address
            read_data <= RAM[read_addr];
        end else begin
            // Clear read_data if read_en is not active
            read_data <= 0;
        end
    end

endmodule