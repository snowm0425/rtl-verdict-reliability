module RAM (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input write_en,     // Write enable signal
    input [2:0] write_addr, // Write address (3 bits for 8 locations)
    input [5:0] write_data, // Write data (6 bits)
    input read_en,      // Read enable signal
    input [2:0] read_addr,  // Read address (3 bits for 8 locations)
    output reg [5:0] read_data // Read data (6 bits)
);

    // Parameter definitions
    parameter WIDTH = 6;
    parameter DEPTH = 8;

    // RAM array declaration
    reg [WIDTH-1:0] RAM [DEPTH-1:0];

    // Initialization of RAM on reset
    initial begin
        for (integer i = 0; i < DEPTH; i = i + 1) begin
            RAM[i] = 0;
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
            // Clear read_data if read_en is not active
            read_data <= 0;
        end
    end

endmodule