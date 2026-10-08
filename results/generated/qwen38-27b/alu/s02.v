module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [5:0]  aluc,
    output wire [31:0] r,
    output wire        zero,
    output wire        carry,
    output wire        negative,
    output wire        overflow,
    output wire        flag
);

    // Define opcodes
    localparam ADD  = 6'b100000;
    localparam ADDU = 6'b100001;
    localparam SUB  = 6'b100010;
    localparam SUBU = 6'b100011;
    localparam AND  = 6'b100100;
    localparam OR   = 6'b100101;
    localparam XOR  = 6'b100110;
    localparam NOR  = 6'b100111;
    localparam SLT  = 6'b101010;
    localparam SLTU = 6'b101011;
    localparam SLL  = 6'b000000;
    localparam SRL  = 6'b000010;
    localparam SRA  = 6'b000011;
    localparam SLLV = 6'b000100;
    localparam SRLV = 6'b000110;
    localparam SRAV = 6'b000111;
    localparam LUI  = 6'b001111;

    // Internal signals
    wire [31:0] result;
    wire [32:0] add_sub_result; // 33 bits to capture carry/borrow
    wire [4:0]  shamt;
    
    // Calculate shift amount: use lower 5 bits of 'a' as per prompt
    assign shamt = a[4:0];

    // Calculate addition/subtraction with carry
    // For SUB, we do a + (~b) + 1
    wire [31:0] b_inverted = ~b;
    assign add_sub_result = a + b_inverted + 1'b1; // This is effectively a - b with carry/borrow
    
    // Wait, for ADD we need a + b. For SUB we need a - b.
    // Let's use separate calculations or a mux.
    // Actually, we can compute both and select.
    
    wire [32:0] add_result = a + b + 1'b0;
    wire [32:0] sub_result = a + (~b) + 1'b1;

    // Mux for result based on aluc
    reg [31:0] r_reg;
    reg        carry_reg;
    reg        overflow_reg;
    reg        flag_reg;

    always @(*) begin
        // Defaults
        r_reg = 32'b0;
        carry_reg = 1'b0;
        overflow_reg = 1'b0;
        flag_reg = 1'bz; // High impedance by default

        case (aluc)
            ADD: begin
                r_reg = add_result[31:0];
                carry_reg = 1'b0; // ADD (signed) doesn't typically use carry flag, but if needed, it's add_result[32]
                overflow_reg = (a[31] == b[31]) && (a[31] != r_reg[31]);
            end
            ADDU: begin
                r_reg = add_result[31:0];
                carry_reg = add_result[32];
                overflow_reg = 1'b0;
            end
            SUB: begin
                r_reg = sub_result[31:0];
                carry_reg = 1'b0; // SUB (signed) doesn't typically use carry flag
                overflow_reg = (a[31] != b[31]) && (a[31] != r_reg[31]);
            end
            SUBU: begin
                r_reg = sub_result[31:0];
                // Borrow is 1 if no carry out in a + ~b + 1
                carry_reg = ~sub_result[32];
                overflow_reg = 1'b0;
            end
            AND: begin
                r_reg = a & b;
            end
            OR: begin
                r_reg = a | b;
            end
            XOR: begin
                r_reg = a ^ b;
            end
            NOR: begin
                r_reg = ~(a | b);
            end
            SLT: begin
                // Signed comparison: a < b
                if ($signed(a) < $signed(b)) begin
                    r_reg = 32'd1;
                    flag_reg = 1'b1;
                end else begin
                    r_reg = 32'd0;
                    flag_reg = 1'b0;
                end
            end
            SLTU: begin
                // Unsigned comparison: a < b
                if (a < b) begin
                    r_reg = 32'd1;
                    flag_reg = 1'b1;
                end else begin
                    r_reg = 32'd0;
                    flag_reg = 1'b0;
                end
            end
            SLL: begin
                r_reg = b << shamt;
            end
            SRL: begin
                r_reg = b >> shamt;
            end
            SRA: begin
                r_reg = $signed(b) >>> shamt;
            end
            SLLV: begin
                r_reg = b << a[4:0];
            end
            SRLV: begin
                r_reg = b >> a[4:0];
            end
            SRAV: begin
                r_reg = $signed(b) >>> a[4:0];
            end
            LUI: begin
                r_reg = {a[15:0], 16'b0};
            end
            default: begin
                r_reg = 32'b0;
            end
        endcase
    end

    // Assign outputs
    assign r = r_reg;
    assign zero = (r == 32'b0);
    assign negative = r[31];
    assign carry = carry_reg;
    assign overflow = overflow_reg;
    assign flag = flag_reg;

endmodule