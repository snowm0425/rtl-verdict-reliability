module adder_bcd (
    input [3:0] A,    // First BCD input (4-bit, representing a decimal digit from 0 to 9)
    input [3:0] B,    // Second BCD input (4-bit, representing a decimal digit from 0 to 9)
    input Cin,        // Carry-in input (1-bit)
    output [3:0] Sum, // 4-bit output representing the sum of the two BCD inputs, corrected to be a valid BCD digit (0–9)
    output Cout       // Carry-out output (1-bit), used when the sum exceeds the decimal value of 9
);

    // Internal wire to hold the initial binary sum
    wire [4:0] bin_sum;

    // Perform binary addition of A, B, and Cin
    assign bin_sum = A + B + Cin;

    // Internal wire to hold the corrected BCD sum
    reg [3:0] corrected_sum;

    // Internal wire to hold the carry-out
    reg carry_out;

    // Logic to correct the sum if it exceeds 9
    always @(*) begin
        if (bin_sum > 9) begin
            corrected_sum = bin_sum + 6; // Add 6 to correct the BCD sum
            carry_out = 1;             // Set carry-out to 1
        end else begin
            corrected_sum = bin_sum;   // No correction needed
            carry_out = 0;             // Set carry-out to 0
        end
    end

    // Assign the corrected sum and carry-out to the output ports
    assign Sum = corrected_sum;
    assign Cout = carry_out;

endmodule