//basically a close copy of https://github.com/ReaLLMASIC/nanoGPT/blob/master/HW/SA/verilog/fadd.sv


module fadd(
    input [`BIT_W-1:0] a_operand, b_operand, // Inputs in the format of IEEE-`EXP_W-154 Representation.
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


//for operations always operand_a must not be less than b_operand
assign {operand_a,operand_b} = (a_operand[`BIT_W-2:0] < b_operand[`BIT_W-2:0]) ? {b_operand,a_operand} : {a_operand,b_operand};

assign exp_a = operand_a[`BIT_W-2:`M_W];
assign exp_b = operand_b[`BIT_W-2:`M_W];

//Exception flag sets 1 if either one of the exponent is 255.
assign Exception = (&operand_a[`BIT_W-2:`M_W]) | (&operand_b[`BIT_W-2:`M_W]);

assign output_sign = operand_a[`BIT_W-1] ;

assign operation_sub_addBar =  ~(operand_a[`BIT_W-1] ^ operand_b[`BIT_W-1]);

//Assigining significand values according to Hidden Bit.
assign significand_a = {1'b1,operand_a[`M_W-1:0]};
assign significand_b = {1'b1,operand_b[`M_W-1:0]};

//Evaluating Exponent Difference
assign exponent_diff = operand_a[`BIT_W-2:`M_W] - operand_b[`BIT_W-2:`M_W];

//Shifting significand_b according to exponent_diff
assign significand_b_add = significand_b >> exponent_diff;

assign exponent_b_add = operand_b[`BIT_W-2:`M_W] + exponent_diff; 

//------------------------------------------------ADD BLOCK------------------------------------------//
assign significand_add = ( operation_sub_addBar) ? (significand_a + significand_b_add) : {(`M_W+2){1'b0}}; 

//Result will be equal to Most `M_W bits if carry generates else it will be Least `M_W-1 bits.
assign add_sum[`M_W-1:0] = significand_add[`M_W+1] ? significand_add[`M_W:1] : significand_add[`M_W-1:0];

//If carry generates in sum value then exponent must be added with 1 else feed as it is.
assign add_sum[`BIT_W-2:`M_W] = significand_add[`M_W+1] ? (1'b1 + operand_a[`BIT_W-2:`M_W]) : operand_a[`BIT_W-2:`M_W];

assign result = Exception ? {(`BIT_W){1'b0}} : {output_sign,add_sum};

endmodule