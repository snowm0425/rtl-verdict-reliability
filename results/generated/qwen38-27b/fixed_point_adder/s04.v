module fixed_point_adder #(
    parameter Q = 4,
    parameter N = 8
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Sign bits
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];

    // Magnitude (absolute value) of a and b
    // For two's complement, the magnitude is the absolute value.
    // If the number is negative, we need to invert and add 1.
    // However, for addition/subtraction logic with sign-magnitude interpretation,
    // we need to extract the magnitude properly.
    // 
    // In two's complement, the magnitude of a negative number is ~a + 1.
    // But the problem description suggests using absolute values with sign handling.
    // Let's interpret the inputs as two's complement fixed-point numbers.
    //
    // Actually, re-reading the problem:
    // "If the most significant bits (MSBs) of `a` and `b` are the same (both positive or both negative), their absolute values are added."
    // This suggests a sign-magnitude-like approach, but fixed-point arithmetic is typically two's complement.
    //
    // Let me re-interpret: The inputs are two's complement fixed-point numbers.
    // The addition of two's complement numbers is straightforward: a + b.
    // However, the problem describes a specific algorithm that uses absolute values.
    //
    // Let me follow the problem's algorithm literally:
    // 1. If sign_a == sign_b: add absolute values, sign of result = sign_a
    // 2. If sign_a != sign_b: subtract smaller absolute value from larger, sign depends on which is larger
    //
    // To get absolute value from two's complement:
    // If a[N-1] == 0: abs_a = a
    // If a[N-1] == 1: abs_a = ~a + 1
    //
    // But wait, the result is N-bit. If we add two positive numbers and overflow, the MSB will flip.
    // The problem says "Overflow is managed internally by observing the MSB to ensure the result fits within the N-bit range."
    //
    // Let me implement this step by step.

    // Compute absolute values
    wire [N-1:0] abs_a = sign_a ? (~a + 1'b1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1'b1) : b;

    // Determine if a is greater than or equal to b (in terms of absolute value)
    // We compare abs_a and abs_b
    wire a_ge_b = (abs_a >= abs_b);

    // Case 1: Same sign
    wire same_sign = (sign_a == sign_b);

    // Case 2: Different sign
    wire diff_sign = (sign_a != sign_b);

    // For same sign: result magnitude = abs_a + abs_b, sign = sign_a
    // For diff sign: 
    //   if abs_a >= abs_b: result magnitude = abs_a - abs_b, sign = sign_a
    //   if abs_a < abs_b: result magnitude = abs_b - abs_a, sign = sign_b

    // Compute the result magnitude
    wire [N-1:0] mag_same = abs_a + abs_b;
    wire [N-1:0] mag_diff = a_ge_b ? (abs_a - abs_b) : (abs_b - abs_a);

    // Determine the sign of the result
    // For same sign: sign_res = sign_a
    // For diff sign: 
    //   if abs_a >= abs_b: sign_res = sign_a
    //   else: sign_res = sign_b
    wire sign_res = same_sign ? sign_a : (a_ge_b ? sign_a : sign_b);

    // Combine sign and magnitude into two's complement result
    // If sign_res is 0: res = mag
    // If sign_res is 1: res = ~mag + 1
    wire [N-1:0] mag_result = same_sign ? mag_same : mag_diff;

    // Convert magnitude to two's complement based on sign
    res = sign_res ? (~mag_result + 1'b1) : mag_result;

    // Special case: if the result magnitude is zero, the sign should be 0 (positive zero)
    // In two's complement, -0 and +0 are the same, so this is handled naturally.
    // But if sign_res is 1 and mag_result is 0, ~0 + 1 = 0, so it's fine.

    assign c = res;

endmodule