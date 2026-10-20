module alu(input [31:0] a, b,
    input [2:0] f,
    output logic [31:0] result,
    output logic zero,
    output logic overflow,
    output logic carry,
    output logic negative);
localparam WIDTH = 32;

typedef enum logic [2:0] {
    OP_ADD = 3'b000,
    OP_SUB = 3'b001,
    OP_AND = 3'b010,
    OP_OR  = 3'b011,
    OP_SLT = 3'b101
} alu_op_t;

logic [WIDTH:0] ext_sum;
logic [WIDTH-1:0] sum;
logic [WIDTH-1:0] second;
logic cin;
logic cout;
logic over;

always_comb begin : opFSM
    // For SUB/SLT: invert b and inject carry-in of 1 (2's complement subtraction)
    // This correctly produces the carry flag for all values of b, including b=0.
    if ((f == OP_SUB) || (f == OP_SLT)) begin
        second = ~b;
        cin = 1'b1;
    end else begin
        second = b;
        cin = 1'b0;
    end

    ext_sum = {1'b0, a} + {1'b0, second} + {{WIDTH{1'b0}}, cin};
    sum = ext_sum[WIDTH-1:0];
    cout = ext_sum[WIDTH];
    over = !(a[WIDTH-1] ^ second[WIDTH-1]) && (a[WIDTH-1] ^ sum[WIDTH-1]);

    result = '0;
    zero = 1'b0;
    overflow = 1'b0;
    carry = 1'b0;

    unique case (f)
        OP_ADD: begin
            carry = cout;
            overflow = over;
            result = sum;
        end
        OP_SUB: begin
            carry = cout;
            overflow = over;
            result = sum;
        end
        OP_AND: begin
            result = a & b;
            overflow = '0;
            carry = '0;
        end
        OP_OR: begin
            result = a | b;
            overflow = '0;
            carry = '0;
        end
        OP_SLT: begin
            // Expose adder carry and overflow (textbook Fig 5.18b)
            carry = cout;
            overflow = over;
            result = {{(WIDTH-1){1'b0}}, over ^ sum[WIDTH-1]};
        end
        default: begin
            result = '0;
        end
    endcase

    zero = (result == '0);
    negative = result[WIDTH-1];
end

endmodule
