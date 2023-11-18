//basically a close copy of https://github.com/ReaLLMASIC/nanoGPT/blob/master/HW/SA/verilog/fadd.sv


module fadd(
    input [`BIT_W-1:0] a_in, b_in, // Inputs in the format of IEEE-`EXP_W-154 Representation.
    output [`BIT_W-1:0] result // Outputs in the format of IEEE-`EXP_W-154 Representation.
);

wire Exception;
wire output_sign;
wire operation_sub_addBar;

wire [`BIT_W-1:0] operand_a, operand_b;
wire [`M_W:0] significand_a, significand_b;
wire [`EXP_W-1:0] exponent_diff;

wire [`M_W:0] significand_b_add;
wire [`EXP_W-1:0] exponent_b_add;

wire [`M_W+1:0] significand_add;
wire [`BIT_W-2:0] add_sum;

wire [`EXP_W-1:0] exp_a, exp_b;


//for operations always operand_a must not be less than b_in
assign {operand_a,operand_b} = (a_in[`BIT_W-2:0] < b_in[`BIT_W-2:0]) ? {b_in,a_in} : {a_in,b_in};

assign exp_a = operand_a[`BIT_W-2:`M_W]; // extract exponent from operand_a
assign exp_b = operand_b[`BIT_W-2:`M_W]; // extract exponent from operand_b

//Exception flag sets 1 if either one of the exponent is 255.
assign Exception = (&operand_a[`BIT_W-2:`M_W]) | (&operand_b[`BIT_W-2:`M_W]);

assign output_sign = operand_a[`BIT_W-1] ; // since the operand_a is always greater than operand_b, the sign of the result will be same as operand_a.

//operation_sub_addBar is 1 if we are doing subtraction else 0.
assign operation_sub_addBar =  ~(operand_a[`BIT_W-1] ^ operand_b[`BIT_W-1]);

//Assigining significand values according to Hidden Bit.
assign significand_a = {1'b1,operand_a[`M_W-1:0]}; // expand the mantissa by 1 bit before multiplication since its always implied
assign significand_b = {1'b1,operand_b[`M_W-1:0]}; // same as above

//Evaluating Exponent Difference
assign exponent_diff = operand_a[`BIT_W-2:`M_W] - operand_b[`BIT_W-2:`M_W];

//Shifting significand_b to the right according to exponent_diff. Exapmle: if we have 1.0101 >> 2 = 0.0101 then exponent_diff = 2 and significand_b_add = significand_b >> exponent_diff
assign significand_b_add = significand_b >> exponent_diff;

//Adding exponent_diff to exponent_b. Exapmle: if we have 1.0101 << 2 = 101.01 then exponent_diff = 2 and exponent_b_add = exponent_b + exponent_diff
assign exponent_b_add = operand_b[`BIT_W-2:`M_W] + exponent_diff; 

//------------------------------------------------ADD BLOCK------------------------------------------//
//if we are adding(operation_sub_addBar=1) need to add significand_b_add to significand_a. 
//Or sets the significand to zero if the signs are different(this means we are doing subtraction), effectively determining the core operation of the floating-point addition based on the sign of the operands.
assign significand_add = ( operation_sub_addBar) ? (significand_a + significand_b_add) : {(`M_W+2){1'b0}}; 

//Taking care of the resulting mantissa. 
//If there is a carry, then the result is normalized by shifting the significand right by one bit(because its implied) and incrementing the exponent by one.
//If there is no carry, we just use the result of the addition, and we have `M_W-1:0 due to the fact that we are using the hidden bit(implied 1).
assign add_sum[`M_W-1:0] = significand_add[`M_W+1] ? significand_add[`M_W:1] : significand_add[`M_W-1:0];

// Taking care of the resulting exponent.
//If carry generates in sum value then exponent must be added with 1 else feed as it is.
assign add_sum[`BIT_W-2:`M_W] = significand_add[`M_W+1] ? (1'b1 + operand_a[`BIT_W-2:`M_W]) : operand_a[`BIT_W-2:`M_W];

assign result = Exception ? {(`BIT_W){1'b0}} : {output_sign,add_sum};

endmodule