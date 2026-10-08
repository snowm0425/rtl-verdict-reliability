module LIFObuffer (
    input [3:0] dataIn,
    input RW,      // 1 for read, 0 for write
    input EN,      // Enable signal
    input Rst,     // Active high reset signal
    input Clk,     // Clock signal
    output reg EMPTY,
    output reg FULL,
    output reg [3:0] dataOut
);

    // Define the stack memory and stack pointer
    reg [3:0] stack_mem [3:0];  // 4 entries of 4 bits each
    reg [1:0] SP;                 // Stack pointer, range from 0 to 3

    // Initialize stack pointer and flags
    always @(posedge Clk) begin
        if (EN) begin
            if (Rst) begin
                SP <= 2'b11;  // Set stack pointer to 3 (indicating an empty buffer)
                EMPTY <= 1;
                FULL <= 0;
                // Clear stack memory
                stack_mem[0] <= 4'b0000;
                stack_mem[1] <= 4'b0000;
                stack_mem[2] <= 4'b0000;
                stack_mem[3] <= 4'b0000;
            end else begin
                if (!RW) begin  // Write operation
                    if (SP != 2'b00) begin  // Check if the buffer is not full
                        SP <= SP - 1;  // Decrement stack pointer
                        stack_mem[SP] <= dataIn;  // Push data onto the stack
                        EMPTY <= 0;  // Buffer is not empty
                        FULL <= (SP == 2'b01);  // Check if buffer is full
                    end
                end else begin  // Read operation
                    if (SP != 2'b11) begin  // Check if the buffer is not empty
                        dataOut <= stack_mem[SP];  // Pop data from the stack
                        stack_mem[SP] <= 4'b0000;  // Clear stack memory location
                        SP <= SP + 1;  // Increment stack pointer
                        FULL <= 0;  // Buffer is not full
                        EMPTY <= (SP == 2'b11);  // Check if buffer is empty
                    end
                end
            end
        end
    end

endmodule