module square_wave (
    input clk,          // Clock signal driving the module
    input [7:0] freq,   // Frequency control value
    output reg wave_out // Square wave output signal
);

    reg [7:0] count;  // Counter register to track cycles between wave toggles

    // Always block to handle the counter and wave toggling
    always @(posedge clk) begin
        if (freq == 0) begin
            // If frequency is 0, set wave_out to 0 (or any fixed state)
            wave_out <= 0;
            count <= 0;
        end else begin
            if (count == (freq - 1)) begin
                // When count reaches (freq - 1), reset count to 0 and toggle wave_out
                count <= 0;
                wave_out <= ~wave_out;
            end else begin
                // Otherwise, increment the count
                count <= count + 1;
            end
        end
    end

endmodule