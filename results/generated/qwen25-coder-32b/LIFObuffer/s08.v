module LIFObuffer (
    input wire [3:0] dataIn,  // 4-bit input data to be pushed onto the buffer
    input wire RW,            // Read/Write control signal (1 for read, 0 for write)
    input wire EN,            // Enable signal to activate buffer operations
    input wire Rst,           // Active high reset signal to initialize the buffer
    input wire Clk,           // Clock signal for synchronous operations

    output reg EMPTY,         // Flag indicating whether the buffer is empty
    output reg FULL,          // Flag indicating whether the buffer is full
    output reg [3:0] dataOut  // 4-bit output data retrieved from the buffer
);

    // Stack memory array (4 entries, 4-bit wide)
    reg [3:0] stack_mem [0:3];

    // Stack pointer (4-bit wide)
    reg [1:0] SP;  // Since we have 4 entries, 2 bits are sufficient to track the stack pointer

    // Initialize the stack memory and stack pointer on reset
    always @(posedge Clk or posedge Rst) begin
        if (Rst) begin
            SP <= 2'b10;  // Set stack pointer to 2 (indicating an empty buffer)
            EMPTY <= 1;
            FULL <= 0;
            for (int i = 0; i < 4; i = i + 1) begin
                stack_mem[i] <= 4'b0000;  // Clear all memory locations
            end
        end else if (EN) begin
            if (!RW && !FULL) begin  // Write operation and not full
                stack_mem[SP - 1] <= dataIn;  // Push data onto the stack
                SP <= SP - 1;  // Decrement stack pointer
                if (SP == 1) begin
                    FULL <= 1;
                end
                EMPTY <= 0;
            end else if (RW && !EMPTY) begin  // Read operation and not empty
                dataOut <= stack_mem[SP];  // Pop data from the stack
                stack_mem[SP] <= 4'b0000;  // Clear the memory location
                SP <= SP + 1;  // Increment stack pointer
                if (SP == 2) begin
                    EMPTY <= 1;
                end
                FULL <= 0;
            end
        end

        // Update EMPTY and FULL flags based on stack pointer status
        if (SP == 2) begin
            EMPTY <= 1;
            FULL <= 0;
        end else if (SP == 0) begin
            EMPTY <= 0;
            FULL <= 1;
        end else begin
            EMPTY <= 0;
            FULL <= 0;
        end
    end

endmodule