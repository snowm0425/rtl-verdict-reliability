module fixed_point_adder #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits (including integer and fractional parts)
)(
    input  [N-1:0] a,  // First fixed-point input operand
    input  [N-1:0] b,  // Second fixed-point input operand
    output [N-1:0] c   // Output result of the fixed-point addition
);

    // Internal wire to store the result of addition/subtraction
    wire [N:0] add_result;  // One extra bit to capture potential overflow
    wire [N-1:0] sub_result;

    // Determine if the inputs are positive or negative
    wire a_is_negative = a[N-1];
    wire b_is_negative = b[N-1];

    // Absolute value addition
    assign add_result = a + b;

    // Absolute value subtraction (a - b) and (b - a)
    assign sub_result = a_is_negative ? (a_is_negative == b_is_negative ? (a - b) : (b - a)) : (a_is_negative == b_is_negative ? (a - b) : (a - b));

    // Determine the final result
    assign c = (a_is_negative == b_is_negative) ? 
               {add_result[N], add_result[N-1:0]} :  // If both signs are the same, take the result of addition
               (a_is_negative ? 
                (sub_result[N-1] ? sub_result : 0) :  // If a is negative and b is positive, take the result if positive, otherwise 0
                (sub_result[N-1] ? {1'b0, sub_result[N-2:0]} : sub_result));  // If a is positive and b is negative, take the result if positive, otherwise sub_result

endmodule