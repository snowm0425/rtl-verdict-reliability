module signal_generator (
    input clk,
    input rst_n,
    output reg [4:0] wave
);

    reg state;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= 0;
            wave <= 0;
        end else begin
            case (state)
                0: begin
                    if (wave == 31) begin
                        state <= 1;
                        wave <= 30; // Decrement from 31 to 30
                    end else begin
                        wave <= wave + 1;
                    end
                end
                1: begin
                    if (wave == 0) begin
                        state <= 0;
                        wave <= 1; // Increment from 0 to 1
                    end else begin
                        wave <= wave - 1;
                    end
                end
            endcase
        end
    end

endmodule