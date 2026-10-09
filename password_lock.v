module password_lock (
    input  wire       clk,        // Clock signal driving the flip-flops
    input  wire       reset,      // Reset button signal
    input  wire [3:0] a,          // Entered 4-bit password (a3, a2, a1, a0)
    input  wire [3:0] b,          // Stored/Target 4-bit password (b3, b2, b3, b0)
    input  wire       attempt,    // Pulse generated on password attempt (clocking the counter)
    output reg        unlocked,   // Unlocked indicator LED/output
    output reg        locked      // Locked indicator LED/output
);

    // 4-bit Password Equality Comparison (XNOR gates followed by AND tree)
    wire match = (a == b);

    // 2-bit Attempt Counter (using T flip-flops connected in ripple configuration)
    reg tff0_q;
    reg tff1_q;

    // Counter Flip-Flop 0 (T = 1, toggles on each attempt)
    always @(posedge attempt or posedge reset) begin
        if (reset)
            tff0_q <= 1'b0;
        else
            tff0_q <= ~tff0_q;
    end

    // Counter Flip-Flop 1 (T = 1, triggered by negative edge of FF0 output for binary counting)
    always @(negedge tff0_q or posedge reset) begin
        if (reset)
            tff1_q <= 1'b0;
        else
            tff1_q <= ~tff1_q;
    end

    // Detects when attempt count reaches 3 (both counter outputs high: 2'b11)
    wire count_equals_3 = tff0_q & tff1_q;

    // Unlocked Flip-Flop (D Flip-Flop clocked on system clock)
    always @(posedge clk or posedge reset) begin
        if (reset)
            unlocked <= 1'b0;
        else
            unlocked <= match;
    end

    // NOR gate latch detecting persistent error or reset lockout condition
    wire nor_latch_out;
    assign nor_latch_out = ~(reset | unlocked);

    // Locked status feedback and logic gate condition
    wire lock_condition = (~match) & nor_latch_out & count_equals_3;

    // Locked Flip-Flop
    always @(posedge clk or posedge reset) begin
        if (reset)
            locked <= 1'b0;
        else if (locked || lock_condition)
            locked <= 1'b1;
        else
            locked <= 1'b0;
    end

endmodule
