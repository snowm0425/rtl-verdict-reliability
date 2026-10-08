module LIFObuffer (
    input [3:0] dataIn,    // 4-bit input data to be pushed onto the buffer
    input RW,              // Read/Write control signal (1 for read, 0 for write)
    input EN,              // Enable signal to activate buffer operations
    input Rst,             // Active high reset signal to initialize the buffer
    input Clk,             // Clock signal for synchronous operations

    output reg EMPTY,      // Flag indicating whether the buffer is empty
    output reg FULL,       // Flag indicating whether the buffer is full
    output reg [3:0] dataOut // 4-bit output data retrieved from the buffer
);

    // Define the stack memory array and stack pointer
    reg [3:0] stack_mem [3:0]; // 4 entries of 4-bit each
    reg [1:0] SP; // Stack Pointer (0 to 3)

    // Initialize the stack memory and stack pointer
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            // Reset the stack memory and stack pointer
            SP <= 2'b10; // Set stack pointer to 4 (indicating an empty buffer)
            EMPTY <= 1'b1;
            FULL <= 1'b0;
            for (int i = 0; i < 4; i = i + 1) begin
                stack_mem[i] <= 4'b0000; // Clear all memory locations
            end
        end else if (EN) begin
            if (!RW && !FULL) begin // Write operation and not full
                // Decrement stack pointer
                SP <= SP - 1;
                // Push data onto the stack
                stack_mem[SP] <= dataIn;
                // Check if buffer is full
                if (SP == 2'b00) begin
                    FULL <= 1'b1;
                end
                EMPTY <= 1'b0;
            end else if (RW && !EMPTY) begin // Read operation and not empty
                // Pop data from the stack
                dataOut <= stack_mem[SP];
                // Clear the memory location
                stack_mem[SP] <= 4'b0000;
                // Increment stack pointer
                SP <= SP + 1;
                // Check if buffer is empty
                if (SP == 2'b10) begin
                    EMPTY <= 1'b1;
                end
                FULL <= 1'b0;
            end
        end
    end

endmodule