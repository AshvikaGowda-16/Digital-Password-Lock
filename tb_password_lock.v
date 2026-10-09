 // Testbench Signals
    reg        clk;
    reg        reset;
    reg  [3:0] a;
    reg  [3:0] b;
    reg        attempt;

    wire       unlocked;
    wire       locked;

    // Instantiate Unit Under Test (UUT)
    password_lock uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .attempt(attempt),
        .unlocked(unlocked),
        .locked(locked)
    );

    // 100MHz Clock Generation (10ns period)
    always #5 clk = ~clk;

    // Task to pulse the attempt switch/button
    task trigger_attempt;
        begin
            #10 attempt = 1'b1;
            #20 attempt = 1'b0;
            #10;
        end
    endtask

    initial begin
        // Initialize Inputs
        clk     = 1'b0;
        reset   = 1'b0;
        attempt = 1'b0;
        a       = 4'b0000;
        b       = 4'b1010; // Target stored password = 4'b1010

        // Display Output Header
        $monitor("Time=%0t | Reset=%b | Target(b)=%b | Input(a)=%b | Unlocked=%b | Locked=%b",
                 $time, reset, b, a, unlocked, locked);

        // --- Scenario 1: System Reset ---
        $display("\n--- Applying System Reset ---");
        reset = 1'b1;
        #20;
        reset = 1'b0;
        #10;

        // --- Scenario 2: Incorrect Password Attempts (Attempt 1 & 2) ---
        $display("\n--- Attempt 1: Incorrect Password ---");
        a = 4'b0001;
        trigger_attempt();

        $display("--- Attempt 2: Incorrect Password ---");
        a = 4'b0110;
        trigger_attempt();

        // --- Scenario 3: Attempt 3 - Password Locked Trigger ---
        $display("--- Attempt 3: Incorrect Password (Should Lock) ---");
        a = 4'b1111;
        trigger_attempt();
        #20;

        // --- Scenario 4: Attempting Correct Password While Locked ---
        $display("\n--- Entering Correct Password While System is Locked ---");
        a = 4'b1010;
        trigger_attempt();
        #20;

        // --- Scenario 5: Resetting the Lock and Successful Unlocking ---
        $display("\n--- Resetting System to Clear Lock State ---");
        reset = 1'b1;
        #20;
        reset = 1'b0;
        #10;

        $display("--- Attempting Correct Password After Reset ---");
        a = 4'b1010;
        trigger_attempt();
        #30;

        $display("\nSimulation Complete.");
        $finish;
    end

endmodule
