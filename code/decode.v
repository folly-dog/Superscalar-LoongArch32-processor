module decode (
    input               clk,
    input               rst_n,

    input               flush_stage3,
    input               hold_stage3,
    input        [1:0]  except_stage2,

    input       [31:0]  PC_stage2,

    input               instruction_vld,
    input       [31:0]  instruction,

    output  reg [31:0]  PC_stage3,
    output  reg  [2:0]  except_stage3,

    output  reg         decode_vld,
    output  reg  [3:0]  IQ_choose,      // 0000无需写入IQ
    output  reg             PLV,

    output  reg [3:0]   ALU0_op,
    output  reg [2:0]   ALU1_op,        // 乘除取余
    output  reg [3:0]   AGU_op,
    output  reg [3:0]   BRU_op,

    output  reg [11:0]  ALU0_imm,
    output  reg [19:0]  AGU_imm,        // 正常为12 bit, 将load立即数功能加入其中
    output  reg [25:0]  BRU_imm,        // 正常为16/26 bit, 将PCADDU加入其中
    
    output  reg [31:0]  PC_target_stage3,

    input       [31:0]  instruction_target_stage2,
    output  reg [31:0]  instruction_target_stage3,

    output  reg         destina_reg_en,
    output  reg [4:0]   destina_reg,
    output  reg         source1_reg_en,
    output  reg [4:0]   source1_reg,
    output  reg         source2_reg_en,
    output  reg [4:0]   source2_reg,




);  
    
endmodule