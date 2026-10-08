module fixed_point_adder #(
    parameter Q = 4,
    parameter N = 8
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output reg  [N-1:0] c
);

    reg [N-1:0] res;

    // Function to get absolute value of a two's complement number
    function [N-1:0] abs_val;
        input [N-1:0] val;
        begin
            if (val[N-1])
                abs_val = (~val) + 1'b1;
            else
                abs_val = val;
        end
    endfunction

    always @* begin
        if (a[N-1] == b[N-1]) begin
            // Same sign: add absolute values
            res = abs_val(a) + abs_val(b);
            // Set sign bit to match the input sign
            if (a[N-1])
                c = (~res) + 1'b1; // negative result
            else
                c = res;           // positive result
        end else begin
            // Different signs: subtract smaller absolute value from larger
            if (abs_val(a) >= abs_val(b)) begin
                res = abs_val(a) - abs_val(b);
                // Result is non-negative since |a| >= |b| and a is positive or b is negative
                // a is positive (MSB=0), b is negative (MSB=1)
                // Result sign is positive (0)
                c = res;
            end else begin
                res = abs_val(b) - abs_val(a);
                // |b| > |a|, b is negative, so result is negative
                c = (~res) + 1'b1;
            end
        end
    end

endmodule