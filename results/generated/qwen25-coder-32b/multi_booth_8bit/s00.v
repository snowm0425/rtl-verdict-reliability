module multi_booth_8bit (
    input clk,          // Clock signal
    input reset,        // Reset signal
    input [7:0] a,      // 8-bit multiplicand
    input [7:0] b,      // 8-bit multiplier
    output [15:0] p,    // 16-bit product
    output reg rdy      // Ready signal
);

    // Registers for multiplier and multiplicand
    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    
    // Counter to track the number of iterations
    reg [4:0] ctr;
    
    // Product register
    reg [15:0] product;
    
    // Temporary register for Booth encoding
    reg [1:0] booth_code;
    
    // State machine states
    localparam IDLE = 2'b00;
    localparam MULTIPLY = 2'b01;
    localparam DONE = 2'b10;
    
    // State register
    reg [1:0] state, next_state;
    
    // Initialize registers on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            product <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
            state <= IDLE;
        end else begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    next_state <= MULTIPLY;
                end
                
                MULTIPLY: begin
                    if (ctr < 16) begin
                        // Booth encoding
                        booth_code = multiplicand[1:0];
                        
                        // Accumulate product based on Booth encoding
                        case (booth_code)
                            2'b01: product <= product + multiplicand;
                            2'b10: product <= product - multiplicand;
                            default: ; // 2'b00 and 2'b11 do nothing
                        endcase
                        
                        // Shift multiplicand left by 2 bits (Radix-4 Booth)
                        multiplicand <= multiplicand << 2;
                        
                        // Increment counter
                        ctr <= ctr + 1;
                    end else begin
                        // Multiplication done
                        next_state <= DONE;
                    end
                end
                
                DONE: begin
                    p <= product;
                    rdy <= 1'b1;
                    next_state <= IDLE;
                end
                
                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule