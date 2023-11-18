//basically a close copy of https://github.com/ReaLLMASIC/nanoGPT/blob/master/HW/SA/verilog/fmul.sv


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
        mul_fix_out = {1'b1, a_in[`M_W-1:0]} * {1'b1, b_in[`M_W-1:0]}; //extend the mantissa by 1 bit before multiplication
    end

    // Zero check
    always @* begin
        if (a_in[`BIT_W-2:`M_W] == 0 || b_in[`BIT_W-2:`M_W] == 0) begin
            zero_check = 1'b1;
        end else begin
            zero_check = 1'b0;
        end
    end

    // Generate Mantissa. We are only considering the most significat bits of the product to generate the mantissa.
    always @* begin
        //select two MSBs of the product
        case(mul_fix_out[`MULT_W-1:`MULT_W-2])
           //Example: If mul_fix_out is 8 bits wide and represents 01xxxxxx (binary), it extracts xxxxxx, assuming the MSBs are 01
            2'b01: M_result = mul_fix_out[`MULT_W-3:`M_W]; //MSB is dropped(as it is always 1)
            //In 2'b10 or 2'b11 case: 10yyyyyy → Shift → 0yyyyyy (Extract yyyyyy)
            2'b10: M_result = mul_fix_out[`MULT_W-2:`M_W+1]; // Between two and just under 4. product larger than normalized range, so we need to shift right 
            2'b11: M_result = mul_fix_out[`MULT_W-2:`M_W+1]; // same as line above. 
            default: M_result = mul_fix_out[`MULT_W-2:`M_W+1]; // default same as two lines above
        endcase
    end

    // Overflow check
    always @* begin
        //Different cases for overflow:
        //1. If either of the inputs is zero, then the result is zero and there is no overflow.
        //2. Underflow check: If the sum of the exponents is less than the minimum exponent, then the result is zero and there is no overflow. {2'b0,{(EXP_W-1){1'b1}}} is the minimum exponent(001111111 in case of 32bit float)
        //3. Overflow check: If the sum of the exponents is greater than the maximum exponent, then the result is infinity and there is overflow. EXP_MAX is the maximum exponent.
        overflow = (zero_check || ({1'b0, a_in[`BIT_W-2:`M_W]} + {1'b0, b_in[`BIT_W-2:`M_W]} + {{`EXP_W{1'b0}}, mul_fix_out[`MULT_W-1]}) < {2'b0,{(`EXP_W-1){1'b1}}} || ({1'b0, a_in[`BIT_W-2:`M_W]} + {1'b0, b_in[`BIT_W-2:`M_W]} + {8'd0, mul_fix_out[`MULT_W-1]}) > `EXP_MAX);

        if (~zero_check) begin
            if (overflow) begin
                e_result0 = {(`EXP_W+1){1'b1}};
            end else begin
                //1. We extend the exponent by 1 bit because the result of addition of two exponents can be 1 bit larger than the exponent itself.
                //2. We add the MSB of the mantissa multiplication(before normalization) to the exponent sum to account for the shifting of the mantissa.
                //3. We subtract the bias from the exponent sum to get the final exponent because just adding two exponents would give us exp1 + exp2 + 2 x bias.
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
