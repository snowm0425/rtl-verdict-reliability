module instr_reg (
    input clk,          // Clock signal for synchronization
    input rst,          // Active low reset signal to initialize the register
    input [1:0] fetch,  // Control signal indicating the source of the instruction
    input [7:0] data,   // 8-bit data input representing the instruction to be fetched

    output reg [2:0] ins, // High 3 bits of the instruction (opcode)
    output reg [4:0] ad1, // Low 5 bits of the instruction (register address)
    output reg [7:0] ad2  // The full 8-bit data from the second source
);

    // Two 8-bit registers to store instructions from different sources
    reg [7:0] ins_p1;
    reg [7:0] ins_p2;

    // On the rising edge of the clock, if reset is low, both registers are initialized to zero
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ins_p1 <= 8'b00000000;
            ins_p2 <= 8'b00000000;
            ins <= 3'b000;
            ad1 <= 5'b00000;
            ad2 <= 8'b00000000;
        end else begin
            case (fetch)
                2'b01: begin
                    // Fetch instruction from data input into ins_p1
                    ins_p1 <= data;
                end
                2'b10: begin
                    // Fetch instruction from data input into ins_p2
                    ins_p2 <= data;
                end
                default: begin
                    // Retain previous values in both registers
                end
            endcase

            // Derive outputs from the stored instructions
            ins <= ins_p1[7:5];  // High 3 bits of ins_p1 for opcode
            ad1 <= ins_p1[4:0];  // Low 5 bits of ins_p1 for register address
            ad2 <= ins_p2;       // Full 8-bit data from ins_p2
        end
    end

endmodule