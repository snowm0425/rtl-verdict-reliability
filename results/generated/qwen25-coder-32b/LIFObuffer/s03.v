module LIFObuffer (
    input  wire [3:0] dataIn,   // 4-bit input data to be pushed onto the buffer
    input  wire       RW,       // Read/Write control signal (1 for read, 0 for write)
    input  wire       EN,       // Enable signal to activate buffer operations
    input  wire       Rst,      // Active high reset signal to initialize the buffer
    input  wire       Clk,      // Clock signal for synchronous operations
    output wire       EMPTY,    // Flag indicating whether the buffer is empty
    output wire       FULL,     // Flag indicating whether the buffer is full
    output wire [3:0] dataOut   // 4-bit output data retrieved from the buffer
);

    // Internal signals and registers
    reg [1:0] SP;               // Stack pointer, range from 0 to 3 (4 entries)
    reg [3:0] stack_mem [0:3];  // Stack memory array to hold 4 entries of 4-bit data

    // Output signal assignments
    assign EMPTY = (SP == 3);    // Stack is empty when SP is 3
    assign FULL  = (SP == 0);     // Stack is full when SP is 0

    // Process on the rising edge of the clock
    always @(posedge Clk) begin
        if (EN) begin            // Check if enable signal is high
            if (Rst) begin       // Check if reset signal is high
                SP <= 3;         // Set stack pointer to 3 (indicating an empty buffer)
                // Initialize all memory locations to 0
                stack_mem[0] <= 4'b0000;
                stack_mem[1] <= 4'b0000;
                stack_mem[2] <= 4'b0000;
                stack_mem[3] <= 4'b0000;
            end else begin
                if (!RW && !FULL) begin // Write operation and buffer not full
                    SP <= SP - 1;       // Decrement stack pointer
                    stack_mem[SP] <= dataIn; // Push data onto the stack
                end else if (RW && !EMPTY) begin // Read operation and buffer not empty
                    dataOut <= stack_mem[SP]; // Pop data from the stack
                    stack_mem[SP] <= 4'b0000; // Clear the memory location
                    SP <= SP + 1;       // Increment stack pointer
                end
            end
        end
    end

endmodule