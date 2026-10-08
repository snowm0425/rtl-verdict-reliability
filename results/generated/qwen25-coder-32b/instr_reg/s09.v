module instr_reg (
    input wire clk,          // Clock signal for synchronization
    input wire rst,          // Active low reset signal
    input wire [1:0] fetch,  // Control signal indicating the source of the instruction
    input wire [7:0] data,   // 8-bit data input representing the instruction to be fetched

    output wire [2:0] ins,   // High 3 bits of the instruction (opcode)
    output wire [4:0] ad1,   // Low 5 bits of the instruction (register address)
    output wire [7:0] ad2    // Full 8-bit data from the second source
);

    reg [7:0] ins_p1;        // Register to store instruction from data input when fetch is 2'b01
    reg [7:0] ins_p2;        // Register to store instruction from data input when fetch is 2'b10

    // On rising edge of clock, initialize registers to zero if reset is low
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ins_p1 <= 8'b00000000;
            ins_p2 <= 8'b00000000;
        end else begin
            case (fetch)
                2'b01: ins_p1 <= data;  // Fetch from data input into ins_p1
                2'b10: ins_p2 <= data;  // Fetch from data input into ins_p2
                default: begin
                    // Retain previous values in both registers
                    ins_p1 <= ins_p1;
                    ins_p2 <= ins_p2;
                end
            endcase
        end
    end

    // Assign outputs based on the stored instructions
    assign ins = ins_p1[7:5];  // High 3 bits of ins_p1 as opcode
    assign ad1 = ins_p1[4:0];  // Low 5 bits of ins_p1 as register address
    assign ad2 = ins_p2;       // Full 8 bits of ins_p2

endmodule