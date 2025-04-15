module  bypass(
    input               ALU0_result_vld,
    input       [5:0]   ALU0_PR_result,
    input       [31:0]  ALU0_result,

    input               BRU_result_vld,
    input       [5:0]   BRU_PR_result,
    input       [31:0]  BRU_result,

    output      [5:0]   ALU0_PR_bypass,
    output      [31:0]  ALU0_data_bypass,
    output      [5:0]   BRU_PR_bypass,
    output      [31:0]  BRU_data_bypass
);

    wire ALU0_wr = ALU0_result_vld & (ALU0_PR_result != 6'd0);
    wire BRU_wr  = BRU_result_vld  & (BRU_PR_result  != 6'd0);

    assign ALU0_PR_bypass = ALU0_wr ? ALU0_PR_result : 6'd0;
    assign BRU_PR_bypass = BRU_wr ? BRU_PR_result : 6'd0;

    assign ALU0_data_bypass = ALU0_wr ? ALU0_result : 32'd0;
    assign BRU_data_bypass = BRU_wr ? BRU_result : 32'd0;

endmodule