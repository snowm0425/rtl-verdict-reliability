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

    reg [3:0] stack_mem [3:0];
    reg [2:0] SP;
    reg [3:0] dataOut_reg;

    assign EMPTY = (SP == 4);
    assign FULL = (SP == 0);
    assign dataOut = dataOut_reg;

    always @(posedge Clk) begin
        if (Rst) begin
            SP <= 4;
            dataOut_reg <= 4'b0000;
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
        end else if (EN) begin
            if (!RW) begin
                // Write operation (push)
                if (!FULL) begin
                    stack_mem[SP] <= dataIn;
                    SP <= SP - 1;
                end
            end else begin
                // Read operation (pop)
                if (!EMPTY) begin
                    dataOut_reg <= stack_mem[SP];
                    stack_mem[SP] <= 4'b0000;
                    SP <= SP + 1;
                end
            end
        end
    end

endmodule