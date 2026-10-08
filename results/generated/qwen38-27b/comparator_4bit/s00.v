module comparator_4bit (
    input  [3:0] A,
    input  [3:0] B,
    output A_greater,
    output A_equal,
    output A_less
);

    // Perform subtraction A - B
    // The borrow out of the most significant bit indicates if A < B
    // We use a 5-bit result to capture the borrow
    wire [4:0] diff;
    
    // Subtract B from A: A - B = A + (~B) + 1
    // The 5th bit (index 4) is the borrow/carry out
    assign diff = {1'b0, A} - {1'b0, B};
    
    // A_less: borrow occurred (bit 4 of diff is 1, meaning A < B)
    // Actually, in unsigned subtraction, if A < B, the result wraps around and the carry out is 0.
    // Let's think more carefully.
    // For unsigned subtraction A - B:
    // If A >= B, no borrow, carry out (from the MSB subtraction) is 1 in the 5-bit representation? 
    // Let's use a different approach: use the standard borrow chain.
    // 
    // Actually, the simplest way: 
    // A_less = 1 if A < B, which means there's a borrow from the MSB.
    // In Verilog, we can compute the borrow by checking if the subtraction result in 4 bits
    // is not equal to the true mathematical difference, but that's circular.
    //
    // Better approach: Use the fact that for 4-bit unsigned subtraction:
    // diff_4bit = A - B (mod 16)
    // A < B if and only if there is a borrow out from the MSB.
    // The borrow out can be determined by: (A - B) computed in 5 bits.
    // Let's compute: {1'b0, A} - {1'b0, B} gives a 5-bit result.
    // If A >= B, the result is a 4-bit number with MSB (bit 4) = 0.
    // If A < B, the result is a 4-bit number with MSB (bit 4) = 1 (because of the borrow).
    // Wait, no. Let's verify: 
    // A = 0001 (1), B = 0010 (2). A - B = -1. In 5-bit two's complement or just unsigned subtraction:
    // {1'b0, 0001} - {1'b0, 0010} = 00001 - 00010 = 11111 (in 5-bit, which is -1 in signed, but for unsigned borrow detection)
    // Actually, in hardware, subtraction is done as addition of two's complement.
    // A - B = A + ~B + 1.
    // The carry out of the MSB addition tells us if there was no borrow.
    // Let's just use: 
    // wire borrow;
    // assign {borrow, diff_4bit} = A - B; // This doesn't directly give borrow in all tools.
    //
    // Most reliable: 
    // A_less is true if A < B. We can compute this by checking the borrow from each bit position.
    // But the problem says to use subtraction and carry/borrow generation.
    //
    // Let's use: 
    // wire [3:0] diff_4bit;
    // wire borrow;
    // assign {borrow, diff_4bit} = A - B; // In Verilog, this may not synthesize as expected for borrow extraction.
    //
    // Actually, in Verilog, if we do:
    // wire [4:0] sub_result;
    // assign sub_result = {1'b0, A} - {1'b0, B};
    // Then if A >= B, sub_result[4] = 0 and sub_result[3:0] = A - B.
    // If A < B, sub_result[4] = 1 and sub_result[3:0] = (A - B) mod 16.
    // Wait, let me verify: A=1, B=2. {1'b0,1} - {1'b0,2} = 00001 - 00010. 
    // In 5-bit: 00001 - 00010. Since 1 < 2, we need to borrow. The result in 5-bit unsigned would be 00001 + (16-1) = 00001 + 11111 = 10000? No.
    // Actually, subtraction in Verilog for unsigned is modular. But when extended to 5 bits:
    // {1'b0, A} is a 5-bit number equal to A. {1'b0, B} is a 5-bit number equal to B.
    // If A >= B, the 5-bit result is just A-B with MSB 0.
    // If A < B, the 5-bit result is (A - B + 16) with MSB... wait, 5 bits can hold 0-31. A and B are 0-15.
    // If A < B, A - B is negative, so in 5-bit two's complement it would be represented as 16 + (A-B) = 16 - (B-A).
    // For A=1, B=2: 16 + (1-2) = 15 = 01111 in 5 bits. So bit[4] = 0. That doesn't work for borrow detection.
    //
    // I think the correct way is to use the carry out from the subtraction when computed as addition of two's complement.
    // A - B = A + (~B) + 1. The carry out of the MSB is 1 if A >= B (no borrow), 0 if A < B (borrow occurred).
    //
    // Let's implement it that way:
    wire [3:0] not_B;
    wire [3:0] sum_4bit;
    wire carry_out;
    
    assign not_B = ~B;
    // A + ~B + 1
    // We can do this in one step:
    // Actually, let's just use the subtraction and check for equality and magnitude.
    //
    // Simplest correct approach:
    // A_equal = (A == B)
    // A_greater = (A > B)
    // A_less = (A < B)
    // But the problem asks for bit-level comparators and subtraction-based logic.
    //
    // Let me reconsider. The problem states:
    // - A subtraction operation is performed: A - B.
    // - Carry Generation: If a borrow occurs during the subtraction, A is less than B (A_less).
    // - If no borrow occurs and the result of subtraction is non-zero, A is greater than B (A_greater).
    // - If A and B are equal, the result of subtraction is zero (A_equal).
    //
    // So I need to extract the borrow and the zero flag.
    //
    // For 4-bit subtraction A - B:
    // Borrow from MSB (bit 3) indicates A < B.
    // Zero flag indicates A == B.
    //
    // Let's implement a 4-bit subtractor with borrow chain:
    // 
    // Bit 0: sum0 = A[0] - B[0], borrow0
    // Bit 1: sum1 = A[1] - B[1] - borrow0, borrow1
    // Bit 2: sum2 = A[2] - B[2] - borrow1, borrow2
    // Bit 3: sum3 = A[3] - B[3] - borrow2, borrow3 (this is the final borrow)
    //
    // A_less = borrow3
    // A_equal = (~sum0 & ~sum1 & ~sum2 & ~sum3)  [all bits of difference are 0]
    // A_greater = ~borrow3 & ~(~sum0 & ~sum1 & ~sum2 & ~sum3)  [no borrow and not zero]
    //
    // Full subtractor: 
    // Difference = A XOR B XOR Bin
    // Borrow out = (A' AND B) OR (A' AND Bin) OR (B AND Bin)
    //            = (NOT A AND B) OR (NOT A AND Bin) OR (B AND Bin)
    //            = (NOT A AND (B OR Bin)) OR (B AND Bin)
    //            = (NOT A AND (B OR Bin)) OR (B AND Bin)
    // Let's use: Borrow = (NOT A AND B) OR (NOT A AND Bin) OR (B AND Bin)
    
    wire [3:0] diff_bits;
    wire [2:0] borrow_internal;
    wire borrow_final;
    
    // Bit 0
    assign diff_bits[0] = A[0] ^ B[0] ^ 1'b0;  // Bin = 0
    assign borrow_internal[0] = (~A[0] & B[0]) | (~A[0] & 1'b0) | (B[0] & 1'b0);
    // Simplified: borrow_internal[0] = ~A[0] & B[0]
    
    // Bit 1
    assign diff_bits[1] = A[1] ^ B[1] ^ borrow_internal[0];
    assign borrow_internal[1] = (~A[1] & B[1]) | (~A[1] & borrow_internal[0]) | (B[1] & borrow_internal[0]);
    
    // Bit 2
    assign diff_bits[2] = A[2] ^ B[2] ^ borrow_internal[1];
    assign borrow_internal[2] = (~A[2] & B[2]) | (~A[2] & borrow_internal[1]) | (B[2] & borrow_internal[1]);
    
    // Bit 3
    assign diff_bits[3] = A[3] ^ B[3] ^ borrow_internal[2];
    assign borrow_final = (~A[3] & B[3]) | (~A[3] & borrow_internal[2]) | (B[3] & borrow_internal[2]);
    
    // A_equal: all difference bits are 0
    wire zero_flag = ~diff_bits[0] & ~diff_bits[1] & ~diff_bits[2] & ~diff_bits[3];
    
    // Outputs
    assign A_less    = borrow_final;
    assign A_equal   = zero_flag;
    assign A_greater = ~borrow_final & ~zero_flag;

endmodule