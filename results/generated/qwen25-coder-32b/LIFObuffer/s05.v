module LIFObuffer (
    input [3:0] dataIn,      // 4-bit input data to be pushed onto the buffer
    input RW,                // Read/Write control signal (1 for read, 0 for write)
    input EN,                // Enable signal to activate buffer operations
    input Rst,               // Active high reset signal to initialize the buffer
    input Clk,               // Clock signal for synchronous operations
    
    output reg EMPTY,        // Flag indicating whether the buffer is empty
    output reg FULL,         // Flag indicating whether the buffer is full
    output reg [3:0] dataOut // 4-bit output data retrieved from the buffer
);

    // Stack memory array to hold up to 4 entries
    reg [3:0] stack_mem [3:0];
    
    // Stack pointer to track the current position in the stack
    reg [2:0] SP;
    
    // Internal signals
    reg [3:0] temp_data;
    
    // Initialize the buffer on reset
    always @(posedge Clk) begin
        if (Rst) begin
            SP <= 3'b100;  // Set stack pointer to 4 (indicating an empty buffer)
            FULL <= 1'b0;  // Buffer is not full
            EMPTY <= 1'b1; // Buffer is empty
            for (int i = 0; i < 4; i = i + 1) begin
                stack_mem[i] <= 4'b0000; // Initialize all memory locations to 0
            end
        end else if (EN) begin
            // Handle write operation
            if (~RW && ~FULL) begin
                SP <= SP - 1;  // Decrement stack pointer for write
                stack_mem[SP] <= dataIn; // Write data to stack memory
                if (SP == 3'b000) begin
                    FULL <= 1'b1;  // Buffer is now full
                end
                EMPTY <= 1'b0; // Buffer is not empty
            end
            
            // Handle read operation
            else if (RW && ~EMPTY) begin
                temp_data <= stack_mem[SP];  // Read data from stack memory
                stack_mem[SP] <= 4'b0000;    // Clear the memory location
                SP <= SP + 1;                // Increment stack pointer for read
                if (SP == 3'b100) begin
                    EMPTY <= 1'b1;  // Buffer is now empty
                end
                FULL <= 1'b0; // Buffer is not full
            end
            
            // Update output data
            dataOut <= temp_data;
        end
    end

endmodule