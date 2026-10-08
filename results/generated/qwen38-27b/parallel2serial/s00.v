module parallel2serial (
    input wire clk,
    input wire rst_n,
    input wire [3:0] d,
    output reg valid_out,
    output reg dout
);

    reg [3:0] data;
    reg [1:0] cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            data <= 4'b0;
            cnt <= 2'b0;
            valid_out <= 1'b0;
            dout <= 1'b0;
        end else begin
            if (cnt == 2'd3) begin
                // Last bit of the 4-bit sequence
                data <= d;
                cnt <= 2'd0;
                valid_out <= 1'b1;
                dout <= data[3]; // MSB of the new data
            end else begin
                // Not the last bit, shift and continue
                cnt <= cnt + 1'b1;
                valid_out <= 1'b0;
                // Shift left with MSB going to LSB? 
                // Wait, let's re-read the requirement carefully.
                
                // "When valid_out = 1, the most significant bit of d is output, and the remaining three bits are output sequentially in the following 3 cycles."
                // This means:
                // Cycle 0 (cnt=0): output MSB (bit 3)
                // Cycle 1 (cnt=1): output bit 2
                // Cycle 2 (cnt=2): output bit 1
                // Cycle 3 (cnt=3): output bit 0, then load new data
                
                // The description says:
                // "The most significant bit of the parallel input is assigned to the serial output (dout)."
                // "Otherwise, the module increments the counter (cnt) by 1, sets the valid signal (valid) to 0, and shifts the data register (data) one bit to the left, with the most significant bit shifted to the least significant bit."
                
                // This is a bit confusing. Let's think about it differently.
                // We need to output MSB first, then next, etc.
                // So at cnt=0, dout = data[3]
                // At cnt=1, dout = data[2]
                // At cnt=2, dout = data[1]
                // At cnt=3, dout = data[0]
                
                // One way: store the data in a register and use cnt to index into it.
                // But the description mentions shifting.
                
                // Let's re-read: "shifts the data register (data) one bit to the left, with the most significant bit shifted to the least significant bit."
                // This sounds like a circular left shift.
                
                // Let's trace through with this approach:
                // Suppose d = 4'b1010 (10 in decimal)
                // We want to output: 1, 0, 1, 0
                
                // If we store data = d initially.
                // cnt=0: valid_out=1, dout = data[3] = 1. Then shift left circular: data becomes 0101
                // cnt=1: valid_out=0, dout = data[3] = 0. Then shift left circular: data becomes 1010... wait that's wrong.
                
                // Hmm, let me reconsider. Maybe the shifting is different.
                // "shifts the data register (data) one bit to the left, with the most significant bit shifted to the least significant bit"
                // This is a left rotate.
                
                // Let's try: 
                // data starts as d = 1010
                // cnt=0: dout = data[3] = 1, valid_out=1. Then rotate left: data = 0101
                // cnt=1: dout = data[3] = 0, valid_out=0. Then rotate left: data = 1010
                // cnt=2: dout = data[3] = 1, valid_out=0. Then rotate left: data = 0101
                // cnt=3: dout = data[3] = 0, valid_out=0. Then load new d, reset cnt to 0.
                
                // That gives: 1, 0, 1, 0. Correct!
                
                // But wait, the description says "When valid_out = 1, the most significant bit of d is output". 
                // So valid_out should be 1 only when the first bit (MSB) is being output.
                
                // Let me re-read: "The output signal valid_out is set to 1 to indicate the availability of valid serial output. When valid_out = 1, the most significant bit of d is output, and the remaining three bits are output sequentially in the following 3 cycles."
                
                // So valid_out = 1 only on the cycle when MSB is output. The other three cycles have valid_out = 0.
                
                // So the logic should be:
                // When we load new data, we output the MSB with valid_out=1.
                // For the next three cycles, we output the remaining bits with valid_out=0.
                
                // Let me restructure:
                // On reset, cnt=0, data=0, valid_out=0, dout=0
                // When we detect that we need to start a new conversion (i.e., cnt==3 was the last bit), we load d into data, set valid_out=1, and output data[3].
                // Then for the next three cycles, valid_out=0, and we output the next bit.
                
                // Let's use a different approach. Use cnt to index into the data register directly.
                
                // Actually, let me re-read the implementation description more carefully:
                // "The most significant bit of the parallel input is assigned to the serial output (dout). On each clock cycle, if the counter (cnt) is 3, indicating the last bit of the parallel input, the module updates the data register (data) with the parallel input (d), resets the counter (cnt) to 0, and sets the valid signal (valid) to 1."
                // "Otherwise, the module increments the counter (cnt) by 1, sets the valid signal (valid) to 0, and shifts the data register (data) one bit to the left, with the most significant bit shifted to the least significant bit."
                // "Counter Register: If the reset signal (rst_n) is high, the register (cnt) is incremented by 1."
                
                // This last statement is confusing. "If the reset signal (rst_n) is high, the register (cnt) is incremented by 1." That doesn't make sense. rst_n is active low, so rst_n=1 means not in reset. Maybe it's a typo and it should be "If not in reset, cnt is incremented"?
                
                // Let me just implement it based on the behavioral description, ignoring the confusing "Counter Register" statement.
                
                // I'll use a state machine approach with cnt going from 0 to 3.
                // cnt=0: Output MSB, valid_out=1
                // cnt=1: Output bit 2, valid_out=0
                // cnt=2: Output bit 1, valid_out=0
                // cnt=3: Output bit 0, valid_out=0, then prepare for next cycle
                
                // But the description says when cnt==3, we load new data and set valid=1. That suggests that on the cycle after cnt==3, we're back to cnt=0 with new data and valid=1.
                
                // Let me think about this differently. Maybe the valid_out is 1 for all four cycles? No, the description says valid_out=1 indicates availability, and specifically "When valid_out = 1, the most significant bit of d is output".
                
                // I think the intended behavior is:
                // valid_out is 1 only on the cycle when the MSB is output.
                
                // Let me just implement it cleanly:
                
                // I'll use the data register and cnt to determine which bit to output.
                // dout = data[3 - cnt] or something similar.
                
                // Actually, let's just follow the shifting approach as described.
            end
        end
    end

    // Let me rewrite this more carefully.
    
endmodule