module LIFObuffer (
    input  [3:0] dataIn,  // 4-bit input data to be pushed onto the buffer
    input        RW,       // Read/Write control signal (1 for read, 0 for write)
    input        EN,       // Enable signal to activate buffer operations
    input        Rst,      // Active high reset signal to initialize the buffer
    input        Clk,      // Clock signal for synchronous operations
    output       EMPTY,    // Flag indicating whether the buffer is empty
    output       FULL,     // Flag indicating whether the buffer is full
    output [3:0] dataOut  // 4-bit output data retrieved from the buffer
);

    // Stack memory array to store the data
    reg [3:0] stack_mem [0:3];
    reg [1:0] SP;  // Stack pointer

    // Internal signals for EMPTY and FULL flags
    reg internal_EMPTY;
    reg internal_FULL;

    // Assign internal flags to output ports
    assign EMPTY = internal_EMPTY;
    assign FULL = internal_FULL;

    // Stack operations
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset the stack pointer and clear stack memory
            SP <= 2'b10;  // Stack pointer set to 4 (indicating an empty buffer)
            for (int i = 0; i < 4; i = i + 1) begin
                stack_mem[i] <= 4'b0000;
            end
            internal_EMPTY <= 1'b1;
            internal_FULL <= 1'b0;
        end else if (EN) begin
            if (!RW && !internal_FULL) begin
                // Write operation: push data onto the stack
                SP <= SP - 1;
                stack_mem[SP] <= dataIn;
                if (SP == 2'b00) begin
                    internal_FULL <= 1'b1;
                end
                internal_EMPTY <= 1'b0;
            end else if (RW && !internal_EMPTY) begin
                // Read operation: pop data from the stack
                dataOut <= stack_mem[SP];
                stack_mem[SP] <= 4'b0000;  // Clear the stack memory location
                SP <= SP + 1;
                if (SP == 2'b10) begin
                    internal_EMPTY <= 1'b1;
                end
                internal_FULL <= 1'b0;
            end
        end
    end

endmodule