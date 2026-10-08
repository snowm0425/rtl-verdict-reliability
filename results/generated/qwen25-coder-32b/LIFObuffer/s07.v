module LIFObuffer (
    input [3:0] dataIn,       // 4-bit input data to be pushed onto the buffer
    input RW,                 // Read/Write control signal (1 for read, 0 for write)
    input EN,                 // Enable signal to activate buffer operations
    input Rst,                // Active high reset signal to initialize the buffer
    input Clk,                // Clock signal for synchronous operations

    output reg EMPTY,         // Flag indicating whether the buffer is empty
    output reg FULL,          // Flag indicating whether the buffer is full
    output reg [3:0] dataOut  // 4-bit output data retrieved from the buffer
);

    reg [1:0] SP;             // Stack pointer (2 bits for a 4-entry buffer)
    reg [3:0] stack_mem [3:0]; // Stack memory array to store data

    always @(posedge Clk) begin
        if (Rst) begin
            // Reset the buffer and stack pointer
            SP <= 2'b10; // Stack pointer set to 4 (indicating an empty buffer)
            EMPTY <= 1;
            FULL <= 0;
            dataOut <= 4'b0000;
            // Clear all memory locations
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
        end else if (EN) begin
            if (!RW && !FULL) begin
                // Write operation and buffer is not full
                stack_mem[SP] <= dataIn;
                SP <= SP - 1;
                if (SP == 2'b00) begin
                    FULL <= 1;
                end
                EMPTY <= 0;
            end else if (RW && !EMPTY) begin
                // Read operation and buffer is not empty
                dataOut <= stack_mem[SP + 1];
                stack_mem[SP + 1] <= 4'b0000; // Clear the memory location
                SP <= SP + 1;
                if (SP == 2'b10) begin
                    EMPTY <= 1;
                end
                FULL <= 0;
            end
            // Update EMPTY and FULL flags based on stack pointer status
            if (SP == 2'b10) begin
                EMPTY <= 1;
                FULL <= 0;
            end else if (SP == 2'b00) begin
                EMPTY <= 0;
                FULL <= 1;
            end else begin
                EMPTY <= 0;
                FULL <= 0;
            end
        end
    end
endmodule