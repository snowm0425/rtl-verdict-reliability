module comparator_4bit (
    input [3:0] A,        // First 4-bit input operand
    input [3:0] B,        // Second 4-bit input operand
    output reg A_greater, // Output indicating if A is greater than B
    output reg A_equal,   // Output indicating if A is equal to B
    output reg A_less     // Output indicating if A is less than B
);

// Intermediate signals for subtraction
wire [3:0] diff;
wire borrow;

// Perform subtraction A - B using a full subtractor chain
assign diff[0] = A[0] ^ B[0];
assign borrow = ~A[0] & B[0];

assign diff[1] = A[1] ^ B[1] ^ borrow;
assign borrow = (~A[1] & (B[1] | borrow)) | (borrow & ~B[1]);

assign diff[2] = A[2] ^ B[2] ^ borrow;
assign borrow = (~A[2] & (B[2] | borrow)) | (borrow & ~B[2]);

assign diff[3] = A[3] ^ B[3] ^ borrow;
assign borrow = (~A[3] & (B[3] | borrow)) | (borrow & ~B[3]);

// Determine the relationship between A and B
always @(*) begin
    A_greater = (diff != 0) && ~borrow;
    A_equal = (diff == 0);
    A_less = borrow;
end

endmodule