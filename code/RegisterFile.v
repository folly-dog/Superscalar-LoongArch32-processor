module  RegisterFile(
    input               clk,

    input               ALU0_result_vld,
    input               ALU1_result_vld,
    input               AGU_result_vld,
    input               BRU_result_vld,

    input       [5:0]   ALU0_result_PR,
    input       [5:0]   ALU1_result_PR,
    input       [5:0]   AGU_result_PR,
    input       [5:0]   BRU_result_PR,

    input       [31:0]  ALU0_result,
    input       [31:0]  ALU1_result,
    input       [31:0]  AGU_result,
    input       [31:0]  BRU_result,     

    output reg  [31:0]  regfile[63:0]
);

    wire ALU0_wr = ALU0_result_vld & (ALU0_result_PR != 6'd0);
    wire ALU1_wr = ALU1_result_vld & (ALU1_result_PR != 6'd0);
    wire AGU_wr  = AGU_result_vld  & (AGU_result_PR  != 6'd0);
    wire BRU_wr  = BRU_result_vld  & (BRU_result_PR  != 6'd0);

    always@(*)      // r0 always = 0
        regfile[0] = 32'd0;

    always@(posedge clk)begin
        if(ALU0_wr)
            regfile[ALU0_result_PR] <= ALU0_result;
        if(ALU1_wr)
            regfile[ALU1_result_PR] <= ALU1_result;
        if(AGU_wr)
            regfile[AGU_result_PR]  <= AGU_result;
        if(BRU_wr)
            regfile[BRU_result_PR]  <= BRU_result;
    end

endmodule