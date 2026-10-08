module LIFObuffer (
    input [3:0] dataIn,  // 4-bit input data
    input RW,            // Read/Write control signal (1 for read, 0 for write)
    input EN,            // Enable signal
    input Rst,           // Active high reset signal
    input Clk,           // Clock signal

    output reg EMPTY,    // Flag indicating if the buffer is empty
    output reg FULL,     // Flag indicating if the buffer is full
    output reg [3:0] dataOut // 4-bit output data
);

    // Define the stack size
    localparam SIZE = 4;

    // Stack memory declaration
    reg [3:0] stack_mem [SIZE-1:0];

    // Stack pointer declaration
    reg [2:0] SP;

    // Initialize the stack pointer to indicate an empty buffer
    initial begin
        SP = SIZE; // Indicates empty buffer
        EMPTY = 1;
        FULL = 0;
        dataOut = 4'b0000;
    end

    // Main logic
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset the stack pointer and clear the stack memory
            SP = SIZE;
            EMPTY = 1;
            FULL = 0;
            for (int i = 0; i < SIZE; i = i + 1) begin
                stack_mem[i] = 4'b0000;
            end
        end else if (EN) begin
            // Check for write operation
            if (!RW && !FULL) begin
                // Push data onto the stack
                SP = SP - 1;
                stack_mem[SP] = dataIn;
                // Update flags
                if (SP == 0) begin
                    FULL = 1;
                end
                EMPTY = 0;
            end

            // Check for read operation
            else if (RW && !EMPTY) begin
                // Pop data from the stack
                dataOut = stack_mem[SP];
                stack_mem[SP] = 4'b0000; // Clear the memory location
                SP = SP + 1;
                // Update flags
                if (SP == SIZE) begin
                    EMPTY = 1;
                end
                FULL = 0;
            end
        end
    end
endmodule