module fixed_point_subtractor #(
    parameter N = 8,
    parameter Q = 4
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output reg  [N-1:0] c
);

    reg [N-1:0] res;

    always @(*) begin
        // Determine signs
        wire sign_a = a[N-1];
        wire sign_b = b[N-1];

        // Get absolute values (magnitude)
        // For two's complement, abs is ~x + 1, but for 0 it stays 0
        // We can compute abs by conditionally negating
        wire [N-1:0] abs_a = sign_a ? (~a + 1'b1) : a;
        wire [N-1:0] abs_b = sign_b ? (~b + 1'b1) : b;

        if (sign_a == sign_b) begin
            // Same sign: subtract magnitudes
            // Result sign is the same as inputs (unless result is zero)
            // We need to compute |abs_a - abs_b| and assign sign appropriately
            if (abs_a >= abs_b) begin
                res = abs_a - abs_b;
                // Sign is the same as a (and b)
                c = sign_a ? (~res + 1'b1) : res;
            end else begin
                res = abs_b - abs_a;
                // Result sign is opposite of input signs
                c = sign_a ? res : (~res + 1'b1);
            end
        end else begin
            // Different signs: add magnitudes
            // a + (-b) if b is negative, or a - b if b is positive... 
            // Actually: a - b. If b is negative, a - (-|b|) = a + |b|
            // If b is positive, a - |b|... wait, no.
            // Let's think: a - b.
            // If sign_a == 0 (a positive) and sign_b == 1 (b negative):
            //   a - b = a - (-|b|) = a + |b|. Result is positive.
            // If sign_a == 1 (a negative) and sign_b == 0 (b positive):
            //   a - b = -|a| - |b| = -( |a| + |b| ). Result is negative.
            if (!sign_a && sign_b) begin
                // a positive, b negative: result = |a| + |b|, positive
                res = abs_a + abs_b;
                c = res;
            end else begin
                // sign_a == 1, sign_b == 0: result = -( |a| + |b| ), negative
                res = abs_a + abs_b;
                c = ~res + 1'b1;
            end
        end

        // Handle zero: if result is zero, set sign bit to 0
        if (c == 0) begin
            c = {1'b0, {(N-1){1'b0}}};
        end
    end

endmodule