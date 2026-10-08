module multi_pipe_8bit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       mul_en_in,
    input  wire [7:0] mul_a,
    input  wire [7:0] mul_b,
    output reg        mul_en_out,
    output reg [15:0] mul_out
);

    // Registers for input enable and input values
    reg        mul_en_out_reg;
    reg [7:0]  mul_a_reg;
    reg [7:0]  mul_b_reg;

    // Partial product wires
    wire [15:0] temp0;
    wire [15:0] temp1;
    wire [15:0] temp2;
    wire [15:0] temp3;
    wire [15:0] temp4;
    wire [15:0] temp5;
    wire [15:0] temp6;
    wire [15:0] temp7;

    // Partial sum registers
    reg [15:0] sum0;
    reg [15:0] sum1;
    reg [15:0] sum2;
    reg [15:0] sum3;

    // Final product register
    reg [15:0] mul_out_reg;

    // Input control and input registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 1'b0;
            mul_a_reg      <= 8'd0;
            mul_b_reg      <= 8'd0;
        end else begin
            mul_en_out_reg <= mul_en_in;
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
        end
    end

    // Output enable
    assign mul_en_out = mul_en_out_reg;

    // Partial product generation
    // Each temp[i] is the product of mul_a and mul_b[i], shifted left by i bits
    assign temp0 = {mul_b_reg[0] ? mul_a_reg : 8'd0, 8'd0};
    assign temp1 = {mul_b_reg[1] ? mul_a_reg : 8'd0, 8'd0} << 1;
    assign temp2 = {mul_b_reg[2] ? mul_a_reg : 8'd0, 8'd0} << 2;
    assign temp3 = {mul_b_reg[3] ? mul_a_reg : 8'd0, 8'd0} << 3;
    assign temp4 = {mul_b_reg[4] ? mul_a_reg : 8'd0, 8'd0} << 4;
    assign temp5 = {mul_b_reg[5] ? mul_a_reg : 8'd0, 8'd0} << 5;
    assign temp6 = {mul_b_reg[6] ? mul_a_reg : 8'd0, 8'd0} << 6;
    assign temp7 = {mul_b_reg[7] ? mul_a_reg : 8'd0, 8'd0} << 7;

    // Correct partial product generation using proper 16-bit width
    assign temp0 = {mul_b_reg[0] ? mul_a_reg : 8'd0, 8'd0};
    assign temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0};
    assign temp2 = {4'd0, mul_b_reg[2] ? mul_a_reg : 8'd0, 4'd0};
    assign temp3 = {4'd0, mul_b_reg[3] ? mul_a_reg : 8'd0, 4'd0};
    assign temp4 = {4'd0, mul_b_reg[4] ? mul_a_reg : 8'd0, 4'd0};
    assign temp5 = {4'd0, mul_b_reg[5] ? mul_a_reg : 8'd0, 4'd0};
    assign temp6 = {4'd0, mul_b_reg[6] ? mul_a_reg : 8'd0, 4'd0};
    assign temp7 = {4'd0, mul_b_reg[7] ? mul_a_reg : 8'd0, 4'd0};

    // Let me redo the partial products more carefully
    // temp[i] = (mul_b_reg[i] ? mul_a_reg : 8'd0) << i
    // For i=0: 8-bit value in bits [7:0], zeros in [15:8]
    // For i=1: 8-bit value in bits [8:1], zeros in [15:9] and [0]
    // For i=2: 8-bit value in bits [9:2], zeros in [15:10] and [1:0]
    // etc.

    assign temp0 = {8'd0, mul_b_reg[0] ? mul_a_reg : 8'd0};
    assign temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0};
    assign temp2 = {4'd0, mul_b_reg[2] ? mul_a_reg : 8'd0, 4'd0};
    assign temp3 = {4'd0, mul_b_reg[3] ? mul_a_reg : 8'd0, 4'd0};
    assign temp4 = {4'd0, mul_b_reg[4] ? mul_a_reg : 8'd0, 4'd0};
    assign temp5 = {4'd0, mul_b_reg[5] ? mul_a_reg : 8'd0, 4'd0};
    assign temp6 = {4'd0, mul_b_reg[6] ? mul_a_reg : 8'd0, 4'd0};
    assign temp7 = {4'd0, mul_b_reg[7] ? mul_a_reg : 8'd0, 4'd0};

    // Let me use a cleaner approach with explicit bit placement
    assign temp0 = {8'd0, mul_b_reg[0] ? mul_a_reg : 8'd0};
    assign temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0};
    assign temp2 = {4'd0, mul_b_reg[2] ? mul_a_reg : 8'd0, 4'd0};
    assign temp3 = {4'd0, mul_b_reg[3] ? mul_a_reg : 8'd0, 4'd0};
    assign temp4 = {4'd0, mul_b_reg[4] ? mul_a_reg : 8'd0, 4'd0};
    assign temp5 = {4'd0, mul_b_reg[5] ? mul_a_reg : 8'd0, 4'd0};
    assign temp6 = {4'd0, mul_b_reg[6] ? mul_a_reg : 8'd0, 4'd0};
    assign temp7 = {4'd0, mul_b_reg[7] ? mul_a_reg : 8'd0, 4'd0};

    // I'm making errors. Let me be very explicit.
    // temp0: mul_a * mul_b[0], placed at bits [7:0]
    // temp1: mul_a * mul_b[1], placed at bits [8:1]
    // temp2: mul_a * mul_b[2], placed at bits [9:2]
    // temp3: mul_a * mul_b[3], placed at bits [10:3]
    // temp4: mul_a * mul_b[4], placed at bits [11:4]
    // temp5: mul_a * mul_b[5], placed at bits [12:5]
    // temp6: mul_a * mul_b[6], placed at bits [13:6]
    // temp7: mul_a * mul_b[7], placed at bits [14:7]

    assign temp0 = {8'd0, mul_b_reg[0] ? mul_a_reg : 8'd0};
    assign temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0};
    assign temp2 = {4'd0, mul_b_reg[2] ? mul_a_reg : 8'd0, 4'd0};
    assign temp3 = {4'd0, mul_b_reg[3] ? mul_a_reg : 8'd0, 4'd0};
    assign temp4 = {4'd0, mul_b_reg[4] ? mul_a_reg : 8'd0, 4'd0};
    assign temp5 = {4'd0, mul_b_reg[5] ? mul_a_reg : 8'd0, 4'd0};
    assign temp6 = {4'd0, mul_b_reg[6] ? mul_a_reg : 8'd0, 4'd0};
    assign temp7 = {4'd0, mul_b_reg[7] ? mul_a_reg : 8'd0, 4'd0};

    // I need to fix this. Let me use a different, clearer method.
    // For temp[i], the 8-bit value (mul_a if mul_b[i]=1 else 0) should be shifted left by i.
    // So temp[i] = (mul_b[i] ? mul_a : 0) << i

    // Let me redefine cleanly:
    // temp0 = {8'd0, mul_b_reg[0] ? mul_a_reg : 8'd0}
    // temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0}
    // This is wrong for temp1. Let me think again.
    // mul_a is 8 bits. If I shift left by 1, the result is 9 bits. In 16-bit representation:
    // bits [8:1] = mul_a, bits [15:9] = 0, bit [0] = 0
    // So temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0}
    // That's 4 + 8 + 4 = 16 bits. But the 8-bit value is in the middle 8 bits, which is bits [8:1]. That's correct!
    // Wait: {4'd0, 8-bit-value, 4'd0} puts the 8-bit value in bits [8:1]. Yes, that's correct for shift by 1.
    // For shift by 2: {4'd0, 8-bit-value, 4'd0} puts it in bits [8:1] as well. That's wrong.
    // For shift by 2, I need: {4'd0, mul_b_reg[2] ? mul_a_reg : 8'd0, 4'd0} -- no.
    // Let me count: 16 bits total.
    // shift by 0: bits [7:0] = value, [15:8] = 0 => {8'd0, value}
    // shift by 1: bits [8:1] = value, [15:9]=0, [0]=0 => {4'd0, value, 4'd0}
    // shift by 2: bits [9:2] = value, [15:10]=0, [1:0]=0 => {6'd0, value, 2'd0}
    // shift by 3: bits [10:3] = value, [15:11]=0, [2:0]=0 => {5'd0, value, 3'd0}
    // shift by 4: bits [11:4] = value, [15:12]=0, [3:0]=0 => {4'd0, value, 4'd0}
    // shift by 5: bits [12:5] = value, [15:13]=0, [4:0]=0 => {3'd0, value, 5'd0}
    // shift by 6: bits [13:6] = value, [15:14]=0, [5:0]=0 => {2'd0, value, 6'd0}
    // shift by 7: bits [14:7] = value, [15]=0, [6:0]=0 => {1'd0, value, 7'd0}

    // Let me redefine all temp signals correctly:
    assign temp0 = {8'd0, mul_b_reg[0] ? mul_a_reg : 8'd0};
    assign temp1 = {4'd0, mul_b_reg[1] ? mul_a_reg : 8'd0, 4'd0};
    assign temp2 = {6'd0, mul_b_reg[2] ? mul_a_reg : 8'd0, 2'd0};
    assign temp3 = {5'd0, mul_b_reg[3] ? mul_a_reg : 8'd0, 3'd0};
    assign temp4 = {4'd0, mul_b_reg[4] ? mul_a_reg : 8'd0, 4'd0};
    assign temp5 = {3'd0, mul_b_reg[5] ? mul_a_reg : 8'd0, 5'd0};
    assign temp6 = {2'd0, mul_b_reg[6] ? mul_a_reg : 8'd0, 6'd0};
    assign temp7 = {1'd0, mul_b_reg[7] ? mul_a_reg : 8'd0, 7'd0};

    // Partial sum calculation in pipeline stages
    // Stage 1: sum pairs of partial products
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum0 <= 16'd0;
            sum1 <= 16'd0;
            sum2 <= 16'd0;
            sum3 <= 16'd0;
        end else begin
            sum0 <= temp0 + temp1;
            sum1 <= temp2 + temp3;
            sum2 <= temp4 + temp5;
            sum3 <= temp6 + temp7;
        end
    end

    // Stage 2: sum the partial sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'd0;
        end else begin
            mul_out_reg <= (sum0 + sum1) + (sum2 + sum3);
        end
    end

    // Output assignment
    always @(*) begin
        if (mul_en_out) begin
            mul_out = mul_out_reg;
        end else begin
            mul_out = 16'd0;
        end
    end

endmodule