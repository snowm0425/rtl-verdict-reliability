module square_wave (
    input clk,
    input [7:0] freq,
    output reg wave_out
);

    // Internal register to keep track of the count
    reg [7:0] count;

    // Always block to handle the counting and toggling logic
    always @(posedge clk) begin
        if (count == (freq - 1)) begin
            // Reset the counter
            count <= 0;
            // Toggle the wave_out signal
            wave_out <= ~wave_out;
        end else begin
            // Increment the counter
            count <= count + 1;
        end
    end

endmodule