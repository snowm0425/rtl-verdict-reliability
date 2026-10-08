module multi_16bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] ain,
    input  wire [15:0] bin,
    output reg  [31:0] yout,
    output wire        done
);

    // Internal registers
    reg  [15:0] areg;
    reg  [15:0] breg;
    reg  [31:0] yout_r;
    reg  [4:0]  i;       // shift count register, 0 to 17
    reg         done_r;

    // Assign output
    assign done = done_r;
    always @(*) yout = yout_r;

    // Shift count register i
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 5'd0;
        end else if (start && i < 5'd17) begin
            i <= i + 5'd1;
        end else if (!start) begin
            i <= 5'd0;
        end
    end

    // Done flag
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_r <= 1'b0;
        end else if (i == 5'd16) begin
            done_r <= 1'b1;
        end else if (i == 5'd17) begin
            done_r <= 1'b0;
        end
    end

    // Data registers and shift-accumulate
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            areg   <= 16'd0;
            breg   <= 16'd0;
            yout_r <= 32'd0;
        end else if (start) begin
            if (i == 5'd0) begin
                // Load inputs
                areg   <= ain;
                breg   <= bin;
                yout_r <= 32'd0;
            end else if (i > 5'd0 && i < 5'd17) begin
                // Shift and accumulate
                if (areg[i-1]) begin
                    yout_r <= yout_r + ({breg, 16'd0} << (i-1));
                end else begin
                    yout_r <= yout_r;
                end
                // Keep areg and breg unchanged during accumulation
                areg   <= areg;
                breg   <= breg;
            end
        end else begin
            // When start is inactive, keep registers as-is or reset?
            // Per spec: only reset on rst_n or when start loads at i==0
            // So hold values
            areg   <= areg;
            breg   <= breg;
            yout_r <= yout_r;
        end
    end

endmodule