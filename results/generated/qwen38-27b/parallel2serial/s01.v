module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);

    reg [3:0] data;
    reg [1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data <= 4'b0;
            cnt <= 2'b00;
            valid_out <= 1'b0;
            dout <= 1'b0;
        end else begin
            if (cnt == 2'd3) begin
                // Last bit of current parallel data
                // Update data with new parallel input
                data <= d;
                // Reset counter to 0
                cnt <= 2'b00;
                // Set valid to 1 (the current bit is valid)
                valid_out <= 1'b1;
                // Output the MSB of the current data (which is being output this cycle)
                // Wait, let's re-read the specification carefully.
                
                // "When valid_out = 1, the most significant bit of d is output"
                // "On each clock cycle, if the counter (cnt) is 3, indicating the last bit of the parallel input, the module updates the data register (data) with the parallel input (d), resets the counter (cnt) to 0, and sets the valid signal (valid) to 1."
                
                // This description is a bit ambiguous. Let me re-interpret:
                // The conversion happens over 4 cycles.
                // Cycle 0: output MSB, valid_out = 1
                // Cycle 1: output next bit, valid_out = 1
                // Cycle 2: output next bit, valid_out = 1
                // Cycle 3: output LSB, valid_out = 1
                // Then on the next cycle, we load new data.
                
                // But the description says: "if the counter (cnt) is 3... sets the valid signal (valid) to 1"
                // And "Otherwise... sets the valid signal (valid) to 0"
                
                // This suggests that valid_out is 1 only when cnt == 3? That doesn't make sense for serial output where all 4 bits should be valid.
                
                // Let me re-read: "The output signal valid_out is set to 1 to indicate the availability of valid serial output. When valid_out = 1, the most significant bit of d is output, and the remaining three bits are output sequentially in the following 3 cycles."
                
                // So valid_out should be 1 for all 4 cycles of output.
                
                // But the implementation description says: "if the counter (cnt) is 3... sets the valid signal (valid) to 1. Otherwise... sets the valid signal (valid) to 0"
                
                // This is contradictory. Let me think about this differently.
                
                // Perhaps the counter counts 0, 1, 2, 3 and when cnt==3, it means we just finished outputting the last bit, so we load new data and the next bit (MSB of new data) will be output in the next cycle with valid=1.
                
                // Actually, let me re-read more carefully: "if the counter (cnt) is 3, indicating the last bit of the parallel input, the module updates the data register (data) with the parallel input (d), resets the counter (cnt) to 0, and sets the valid signal (valid) to 1."
                
                // So when cnt==3, we are outputting the 4th bit (LSB). At this moment, we also load new data, reset cnt to 0, and set valid=1. This means in the next cycle (when cnt=0), we output the MSB of the new data with valid=1.
                
                // But what about the other 3 bits? The "Otherwise" clause says valid=0. That would mean only the LSB has valid=1? That doesn't match "When valid_out = 1, the most significant bit of d is output, and the remaining three bits are output sequentially in the following 3 cycles."
                
                // I think there's a misunderstanding in the problem description. Let me implement it so that valid_out is 1 for all 4 bits of the serial output.
                
                // Actually, let me just follow the implementation description literally, even if it seems odd:
                // - When cnt == 3: valid_out = 1, load new data, reset cnt to 0
                // - Otherwise: valid_out = 0, increment cnt, shift data
                
                // But wait, if valid_out is 0 for cnt=0,1,2, then only the bit when cnt=3 is valid? That doesn't make sense.
                
                // Let me try another interpretation: maybe valid_out should be 1 for all 4 cycles. The description might have an error. Let me implement the sensible version where valid_out is 1 for all 4 serial bits.
                
                // Actually, let me re-read once more. "The output signal valid_out is set to 1 to indicate the availability of valid serial output." This suggests valid_out should be 1 whenever there is valid serial output, which is all 4 bits.
                
                // I'll implement it so that valid_out is 1 for all 4 bits of each parallel input.
            end
            else begin
                cnt <= cnt + 1'b1;
                valid_out <= 1'b1;
                // Shift data left, MSB goes to LSB
                data <= {data[2:0], data[3]};
            end
            
            // Output the MSB of data
            dout <= data[3];
        end
    end

endmodule