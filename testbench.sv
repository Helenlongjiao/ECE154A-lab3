// testbench.sv -- self-checking testbench for the 32-bit ALU (ECE 154A Lab 3)
// Reads alu.tv line by line:  f  a  b  result  zero  overflow  carry  negative  (all hex)
module testbench();

  // ---- signals connected to the ALU ----
  logic [31:0] a, b, result;
  logic [2:0]  f;
  logic        zero, overflow, carry, negative;

  // ---- expected values read from alu.tv ----
  logic [31:0] result_exp;
  logic        zero_exp, overflow_exp, carry_exp, negative_exp;

  // ---- bookkeeping ----
  integer fd, n, vectornum, errors;

  // ---- device under test ----
  alu dut(.a(a), .b(b), .f(f),
          .result(result), .zero(zero), .overflow(overflow),
          .carry(carry), .negative(negative));

  initial begin
    fd = $fopen("alu.tv", "r");
    if (fd == 0) begin
      $display("ERROR: could not open alu.tv");
      $stop;
    end

    vectornum = 0;
    errors    = 0;

    while (!$feof(fd)) begin
      // read one line: 8 hex fields separated by spaces/tabs
      n = $fscanf(fd, "%h %h %h %h %h %h %h %h\n",
                  f, a, b, result_exp,
                  zero_exp, overflow_exp, carry_exp, negative_exp);
      if (n != 8) break;            // blank/garbled line or end of file

      #10;                          // let the ALU outputs settle

      if (result   !== result_exp   || zero  !== zero_exp  ||
          overflow !== overflow_exp || carry !== carry_exp ||
          negative !== negative_exp) begin
        $display("ERROR vector %0d: f=%0d a=%h b=%h", vectornum, f, a, b);
        $display("   got      result=%h z=%b v=%b c=%b n=%b",
                 result, zero, overflow, carry, negative);
        $display("   expected result=%h z=%b v=%b c=%b n=%b",
                 result_exp, zero_exp, overflow_exp, carry_exp, negative_exp);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
    end

    $display("%0d tests completed with %0d errors", vectornum, errors);
    $fclose(fd);
    $stop;
  end

endmodule
