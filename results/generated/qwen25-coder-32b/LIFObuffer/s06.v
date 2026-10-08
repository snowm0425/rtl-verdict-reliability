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

    // Stack memory array to store data
    reg [3:0] stack_mem [0:3];

    // Stack pointer to track the current position in the stack
    reg [2:0] SP;

    // Initialize the stack memory and stack pointer
    integer i;
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            stack_mem[i] <= 0;
        end
        SP <= 4; // Indicates an empty buffer
    end

    // Main logic for buffer operations
    always @(posedge Clk) begin
        if (EN) begin
            if (Rst) begin
                // Reset the stack memory and stack pointer
                for (i = 0; i < 4; i = i + 1) begin
                    stack_mem[i] <= 0;
                end
                SP <= 4; // Indicates an empty buffer
                EMPTY <= 1;
                FULL <= 0;
            end else begin
                // Check if the buffer is full or empty
                FULL <= (SP == 0);
                EMPTY <= (SP == 4);

                if (!RW && !FULL) begin
                    // Write operation: Push data onto the stack
                    SP <= SP - 1;
                    stack_mem[SP] <= dataIn;
                end else if (RW && !EMPTY) begin
                    // Read operation: Pop data from the stack
                    dataOut <= stack_mem[SP];
                    stack_mem[SP] <= 0; // Clear the memory location
                    SP <= SP + 1;
                end
            end
        end
    end

endmodule