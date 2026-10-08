module sub_64bit (
    input  wire [63:0] A,
    input  wire [63:0] B,
    output wire [63:0] result,
    output wire overflow
);

    // Perform subtraction: result = A - B
    // In two's complement, A - B = A + (~B + 1)
    // We can simply use the subtraction operator which handles two's complement naturally.
    
    wire [63:0] diff = A - B;
    
    // Overflow detection for subtraction:
    // Positive overflow: A is positive (sign bit 0), B is negative (sign bit 1), result is negative (sign bit 1)
    //   i.e., A >= 0, B < 0, result < 0
    // Negative overflow: A is negative (sign bit 1), B is positive (sign bit 0), result is positive (sign bit 0)
    //   i.e., A < 0, B >= 0, result >= 0
    
    // Extract sign bits
    wire sign_A     = A[63];
    wire sign_B     = B[63];
    wire sign_result = diff[63];
    
    // Positive overflow: A positive, B negative, result negative
    wire pos_overflow = (~sign_A) & sign_B & sign_result;
    
    // Negative overflow: A negative, B positive, result positive
    wire neg_overflow = sign_A & (~sign_B) & (~sign_result);
    
    // Overflow is high if either condition is true
    assign overflow = pos_overflow | neg_overflow;
    
    assign result = diff;

endmodule