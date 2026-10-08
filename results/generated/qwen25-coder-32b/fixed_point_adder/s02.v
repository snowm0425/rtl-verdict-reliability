module fixed_point_adder #(
    parameter Q = 4,  // Number of fractional bits
    parameter N = 8   // Total number of bits
) (
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point addition
);

    reg [N-1:0] res;  // Internal register to store the result

    // Internal wires for intermediate results
    wire [N-1:0] abs_a;
    wire [N-1:0] abs_b;
    wire [N-1:0] add_res;
    wire [N-1:0] sub_res_a_b;
    wire [N-1:0] sub_res_b_a;

    // Absolute values of a and b
    assign abs_a = a[N-2:0] + {N-1{a[N-1]}};  // Two's complement to absolute value
    assign abs_b = b[N-2:0] + {N-1{b[N-1]}};

    // Addition of absolute values
    assign add_res = abs_a + abs_b;

    // Subtraction of absolute values (a - b)
    assign sub_res_a_b = a - b;

    // Subtraction of absolute values (b - a)
    assign sub_res_b_a = b - a;

    // Logic to determine the final result based on the MSBs of a and b
    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            // Both numbers have the same sign, add their absolute values
            res = {add_res[N-1], add_res[N-2:0]};
        end else begin
            // Numbers have different signs, perform subtraction
            if (a > b) begin
                // a is greater than b, result is positive
                res = sub_res_a_b;
            end else begin
                // b is greater than or equal to a, result is negative or zero
                res = sub_res_b_a;
            end
        end
    end

    // Assign the final result to the output port
    assign c = res;

endmodule