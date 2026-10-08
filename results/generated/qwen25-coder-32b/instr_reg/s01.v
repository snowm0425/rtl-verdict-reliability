module instr_reg (
    input clk,          // Clock signal for synchronization
    input rst,          // Active low reset signal to initialize the register
    input [1:0] fetch,  // Control signal indicating the source of the instruction (1 for register, 2 for RAM/ROM)
    input [7:0] data,   // 8-bit data input representing the instruction to be fetched

    output [2:0] ins,   // High 3 bits of the instruction, indicating the opcode or operation
    output [4:0] ad1,   // Low 5 bits of the instruction, representing the register address
    output [7:0] ad2    // The full 8-bit data from the second source
);

    // Two 8-bit registers to store instructions from different sources
    reg [7:0] ins_p1;
    reg [7:0] ins_p2;

    // On the rising edge of the clock (clk), if the reset (rst) signal is low, both registers are initialized to zero
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ins_p1 <= 8'b0;
            ins_p2 <= 8'b0;
        end else begin
            case (fetch)
                2'b01: ins_p1 <= data;  // Fetch from data input into ins_p1
                2'b10: ins_p2 <= data;  // Fetch from data input into ins_p2
                default: ;              // Retain previous values in both registers
            endcase
        end
    end

    // The outputs ins, ad1, and ad2 are derived from the stored instructions
    assign ins = ins_p1[7:5];  // High 3 bits of ins_p1
    assign ad1 = ins_p1[4:0];  // Low 5 bits of ins_p1
    assign ad2 = ins_p2;       // Full 8-bit data from ins_p2

endmodule