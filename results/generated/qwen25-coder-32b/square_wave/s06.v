module square_wave (
    input wire clk,          // Clock signal
    input wire [7:0] freq,   // Frequency control
    output reg wave_out      // Square wave output
);

    reg [7:0] count;         // Counter register

    // Always block sensitive to the rising edge of the clock
    always @(posedge clk) begin
        if (count == (freq - 1)) begin
            count <= 0;           // Reset the counter
            wave_out <= ~wave_out; // Toggle the wave_out signal
        end else begin
            count <= count + 1; // Increment the counter
        end
    end

endmodule