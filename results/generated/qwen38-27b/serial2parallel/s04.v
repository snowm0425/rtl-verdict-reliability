module serial2parallel (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       din_serial,
    input  wire       din_valid,
    output reg  [7:0] dout_parallel,
    output reg        dout_valid
);

    reg [3:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'd0;
            dout_parallel <= 8'd0;
            dout_valid <= 1'b0;
        end else begin
            if (din_valid) begin
                if (cnt == 4'd7) begin
                    // The last bit (LSB) is being received
                    dout_parallel[0] <= din_serial;
                    dout_valid <= 1'b1;
                    cnt <= 4'd0; // Reset counter for next sequence
                end else begin
                    // Shift in the new bit as MSB of the next position
                    // We are building from MSB to LSB
                    // When cnt=0, we receive the first bit which goes to bit[7]
                    // When cnt=1, we receive the second bit which goes to bit[6]
                    // ...
                    // When cnt=6, we receive the 7th bit which goes to bit[1]
                    // When cnt=7, we receive the 8th bit which goes to bit[0]
                    
                    // Shift the existing parallel data left by 1, and put new bit in LSB of the shifted position?
                    // Let's think: 
                    // After 1 bit: dout_parallel[7] = bit0
                    // After 2 bits: dout_parallel[7:6] = {bit0, bit1}
                    // So we can shift left and put new bit in bit[0] of the temporary register?
                    // Actually, let's use a different approach:
                    // Keep a shift register where we shift left and put new bit at LSB.
                    // But then the final result would have the first received bit at the MSB.
                    
                    // Let's re-think:
                    // We want: dout_parallel = {b0, b1, b2, b3, b4, b5, b6, b7}
                    // where b0 is the first received bit (MSB), b7 is the last received bit (LSB).
                    
                    // Strategy: Use a shift register. On each valid input, shift left and put new bit in bit[0].
                    // But that would give us {b7, b6, ..., b0} which is reversed.
                    
                    // Alternative: On each valid input, put the new bit into the correct position based on cnt.
                    // When cnt=0: put din_serial into dout_parallel[7]
                    // When cnt=1: put din_serial into dout_parallel[6]
                    // ...
                    // When cnt=7: put din_serial into dout_parallel[0]
                    
                    // So: dout_parallel[7-cnt] <= din_serial;
                    
                    dout_parallel[7-cnt] <= din_serial;
                    cnt <= cnt + 4'd1;
                    dout_valid <= 1'b0; // Not valid until all 8 bits are received
                end
            end else begin
                // No valid input, hold current state
                dout_valid <= 1'b0;
            end
        end
    end

endmodule