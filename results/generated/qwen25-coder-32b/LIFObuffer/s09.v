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

    // Internal signals and registers
    reg [1:0] SP;         // Stack Pointer (0 to 3)
    reg [3:0] stack_mem [3:0]; // Stack memory array
    reg       EMPTY_reg;  // Internal register for EMPTY flag
    reg       FULL_reg;   // Internal register for FULL flag

    // Output assignments
    assign EMPTY = EMPTY_reg;
    assign FULL  = FULL_reg;

    // Main logic
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset condition
            SP <= 2'b10; // Stack pointer set to 4 (indicating an empty buffer)
            EMPTY_reg <= 1'b1;
            FULL_reg  <= 1'b0;
            // Clear all memory locations
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
        end else if (EN) begin
            // Normal operation
            if (!RW && !FULL_reg) begin
                // Write operation
                SP <= SP - 1; // Decrement stack pointer
                stack_mem[SP] <= dataIn; // Push data onto stack
                if (SP == 2'b00) begin
                    FULL_reg <= 1'b1; // Set FULL flag if buffer is full
                end
                EMPTY_reg <= 1'b0; // Clear EMPTY flag
            end else if (RW && !EMPTY_reg) begin
                // Read operation
                dataOut <= stack_mem[SP]; // Pop data from stack
                stack_mem[SP] <= 4'b0000; // Clear stack memory location
                SP <= SP + 1; // Increment stack pointer
                if (SP == 2'b10) begin
                    EMPTY_reg <= 1'b1; // Set EMPTY flag if buffer is empty
                end
                FULL_reg <= 1'b0; // Clear FULL flag
            end
        end
    end

endmodule