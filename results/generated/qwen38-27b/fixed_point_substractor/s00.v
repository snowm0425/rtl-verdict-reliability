module fixed_point_subtractor #(
    parameter N = 16,
    parameter Q = 8
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Sign bits
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];

    // Absolute values (magnitude) of a and b
    // For two's complement, absolute value is the bit inversion plus 1, but we need to handle sign properly
    // If sign is 0, abs = value; if sign is 1, abs = ~value + 1 (two's complement negation)
    
    wire [N-1:0] abs_a = sign_a ? (~a + 1'b1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1'b1) : b;

    // Magnitude comparison for determining sign of result
    // Compare absolute values: abs_a > abs_b, abs_a == abs_b, abs_a < abs_b
    
    wire a_gt_b = (abs_a > abs_b);
    wire a_eq_b = (abs_a == abs_b);
    wire a_lt_b = (abs_a < abs_b);

    // Compute the magnitude of the result
    // Same sign case: result magnitude = |abs_a - abs_b|
    // Different sign case: result magnitude = abs_a + abs_b

    wire [N-1:0] magnitude;
    wire same_sign;

    assign same_sign = (sign_a == sign_b);

    // For same sign: subtract the magnitudes
    // For different sign: add the magnitudes
    wire [N-1:0] diff_mag;
    wire [N-1:0] sum_mag;

    assign diff_mag = abs_a - abs_b;  // This will underflow if abs_a < abs_b, but we only use it when abs_a >= abs_b
    assign sum_mag  = abs_a + abs_b;

    // For same sign:
    //   If sign is positive: result = abs_a - abs_b (with sign determined by which is larger)
    //   If sign is negative: result = -(abs_a - abs_b) = abs_b - abs_a (with sign determined by which is larger)
    //   Actually, for same sign subtraction: a - b where both have same sign
    //   If both positive: a - b = abs_a - abs_b, sign is positive if abs_a >= abs_b, negative if abs_a < abs_b
    //   If both negative: a - b = (-abs_a) - (-abs_b) = abs_b - abs_a, sign is negative if abs_b >= abs_a, positive if abs_b < abs_a
    //   So in both cases, the magnitude is |abs_a - abs_b|
    //   The sign:
    //     If both positive: sign = (abs_a >= abs_b) ? positive : negative
    //     If both negative: sign = (abs_b >= abs_a) ? negative : positive  => sign = (abs_a <= abs_b) ? negative : positive
    //     Which can be written as: sign = sign_a XOR (abs_a < abs_b)
    //     Let's verify:
    //       Both positive (sign_a=0): sign = 0 XOR (abs_a < abs_b) = (abs_a < abs_b) ? 1 : 0. Correct.
    //       Both negative (sign_a=1): sign = 1 XOR (abs_a < abs_b) = (abs_a < abs_b) ? 0 : 1. Correct.
    
    // For different sign:
    //   a positive, b negative: a - b = abs_a + abs_b, always positive
    //   a negative, b positive: a - b = -(abs_a + abs_b), always negative
    //   So sign = sign_a (since sign_a != sign_b, sign_a determines the sign of the result)
    //   Wait: if a is positive (sign_a=0), b is negative (sign_b=1): result is positive, sign=0=sign_a
    //   If a is negative (sign_a=1), b is positive (sign_b=0): result is negative, sign=1=sign_a
    //   So sign = sign_a for different sign case.

    // Let's compute the sign and magnitude separately.
    
    wire result_sign;
    wire [N-1:0] result_mag;

    // Determine sign of result
    // Same sign: result_sign = sign_a XOR (abs_a < abs_b)
    // Different sign: result_sign = sign_a
    
    wire same_sign_sign = sign_a ^ a_lt_b;
    wire diff_sign_sign = sign_a;

    assign result_sign = same_sign ? same_sign_sign : diff_sign_sign;

    // Determine magnitude of result
    // Same sign: magnitude = |abs_a - abs_b|
    //   If abs_a >= abs_b: magnitude = abs_a - abs_b
    //   If abs_a < abs_b: magnitude = abs_b - abs_a
    // Different sign: magnitude = abs_a + abs_b
    
    wire [N-1:0] same_sign_mag;
    assign same_sign_mag = a_lt_b ? (abs_b - abs_a) : (abs_a - abs_b);

    assign result_mag = same_sign ? same_sign_mag : sum_mag;

    // Convert result_mag and result_sign to two's complement
    // If result_sign is 0: result = result_mag
    // If result_sign is 1: result = ~result_mag + 1
    
    wire [N-1:0] two_comp_result;
    assign two_comp_result = result_sign ? (~result_mag + 1'b1) : result_mag;

    // Handle zero: if result is zero, set sign bit to 0
    // In two's complement, zero is represented as all zeros, so the sign bit is already 0.
    // But let's check: if result_mag is 0 and result_sign is 1, we'd get ~0 + 1 = 0, which is correct.
    // So two's complement naturally handles zero with sign bit 0.
    
    // However, the problem says "When the result is zero, the sign bit is explicitly set to 0"
    // In two's complement, -0 is the same as +0, so this should be automatically handled.
    // But let's be explicit: if two_comp_result is all zeros, ensure sign bit is 0.
    // Actually, if result_mag is 0, then ~0 + 1 = 0, so it's fine.
    
    // Compute final result
    always @(*) begin
        res = two_comp_result;
        // Ensure zero has sign bit 0
        if (res == {N{1'b0}}) begin
            res = {N{1'b0}};
        end
    end

    assign c = res;

endmodule