module RAM (
    input clk,            // Clock signal
    input rst_n,          // Active-low reset signal
    input write_en,       // Write enable signal
    input [2:0] write_addr, // Write address (3 bits for depth of 8)
    input [5:0] write_data, // Data to be written (6 bits)
    input read_en,        // Read enable signal
    input [2:0] read_addr,  // Read address (3 bits for depth of 8)
    output reg [5:0] read_data // Data read from RAM (6 bits)
);

    // Parameters
    parameter WIDTH = 6;
    parameter DEPTH = 8;

    // RAM array declaration
    reg [WIDTH-1:0] RAM [DEPTH-1:0];

    // Initialize RAM to 0 on reset
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            RAM[i] = 0;
        end
    end

    // Write operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear all memory locations on reset
            for (i = 0; i < DEPTH; i = i + 1) begin
                RAM[i] <= 0;
            end
        end else if (write_en) begin
            // Write data to RAM at specified address
            RAM[write_addr] <= write_data;
        end
    end

    // Read operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear read_data on reset
            read_data <= 0;
        end else if (read_en) begin
            // Read data from RAM at specified address
            read_data <= RAM[read_addr];
        end else begin
            // Clear read_data if read is not enabled
            read_data <= 0;
        end
    end

endmodule