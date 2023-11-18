//basically a close copy of 


module fmul(
    input [`BIT_W-1:0] a_in,
    input [`BIT_W-1:0] b_in,
    output [`BIT_W-1:0] result
);

    reg [`MULT_W-1:0] mul_fix_out;
    reg [`M_W-1:0] M_result;
    wire [`EXP_W-1:0] e_result;
    wire sign;
    reg [`EXP_W:0] e_result0;
    reg overflow;
    reg zero_check;
    
    // Multiplication logic
    always @* begin
        mul_fix_out = {1'b1, a_in[`M_W-1:0]} * {1'b1, b_in[`M_W-1:0]};
    end

    // Zero check
    always @* begin
        if (a_in[`BIT_W-2:`M_W] == 0 || b_in[`BIT_W-2:`M_W] == 0) begin
            zero_check = 1'b1;
        end else begin
            zero_check = 1'b0;
        end
    end

    // Generate M
    always @* begin
        case(mul_fix_out[`MULT_W-1:`MULT_W-2])
            2'b01: M_result = mul_fix_out[`MULT_W-3:`M_W];
            2'b10: M_result = mul_fix_out[`MULT_W-2:`M_W+1];
            2'b11: M_result = mul_fix_out[`MULT_W-2:`M_W+1];
            default: M_result = mul_fix_out[`MULT_W-2:`M_W+1];
        endcase
    end

    // Overflow check
    always @* begin
        overflow = (zero_check || ({1'b0, a_in[`BIT_W-2:`M_W]} + {1'b0, b_in[`BIT_W-2:`M_W]} + {{`EXP_W{1'b0}}, mul_fix_out[`MULT_W-1]}) < {2'b0,{(`EXP_W-1){1'b1}}} || ({1'b0, a_in[`BIT_W-2:`M_W]} + {1'b0, b_in[`BIT_W-2:`M_W]} + {8'd0, mul_fix_out[`MULT_W-1]}) > `EXP_MAX);

        if (~zero_check) begin
            if (overflow) begin
                e_result0 = {(`EXP_W+1){1'b1}};
            end else begin
                e_result0 = ({1'b0, a_in[`BIT_W-2:`M_W]} + {1'b0, b_in[`BIT_W-2:`M_W]} + {{`EXP_W{1'b0}}, mul_fix_out[`MULT_W-1]}) - {2'b0,{(`EXP_W-1){1'b1}}};
            end
        end else begin
            e_result0 = 0;
        end
    end
    assign e_result = e_result0[`EXP_W-1:0];

    // Sign calculation
    assign sign = a_in[`BIT_W-1] ^ b_in[`BIT_W-1];

    wire [`M_W-1:0] overflow_mask;
    assign overflow_mask = overflow ? 0 : {(`M_W){1'b1}};

    assign result = {sign, e_result, overflow_mask & M_result};
endmodule
