module LIFObuffer (
    input wire [3:0] dataIn,
    input wire RW,
    input wire EN,
    input wire Rst,
    input wire Clk,
    output wire EMPTY,
    output wire FULL,
    output wire [3:0] dataOut
);

    // Stack memory array: 4 entries, each 4 bits wide
    reg [3:0] stack_mem [0:3];
    
    // Stack pointer: points to the next available slot
    // When SP = 4, the buffer is empty
    // When SP = 0, the buffer is full
    reg [1:0] SP;
    
    // Output data
    reg [3:0] dataOut_reg;
    
    assign dataOut = dataOut_reg;
    
    // Flags
    assign EMPTY = (SP == 4);
    assign FULL = (SP == 0);
    
    integer i;
    
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset: clear stack, set SP to 4 (empty)
            SP <= 4;
            for (i = 0; i < 4; i = i + 1) begin
                stack_mem[i] <= 4'b0;
            end
            dataOut_reg <= 4'b0;
        end else if (EN) begin
            if (RW == 0) begin
                // Write operation (push)
                if (SP != 0) begin
                    // Not full, push data
                    stack_mem[SP] <= dataIn;
                    SP <= SP - 1;
                end
            end else begin
                // Read operation (pop)
                if (SP != 4) begin
                    // Not empty, pop data
                    dataOut_reg <= stack_mem[SP];
                    stack_mem[SP] <= 4'b0;
                    SP <= SP + 1;
                end
            end
        end
    end

endmodule