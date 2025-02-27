module  stage4_exclud_renmae(
    input               clk,
    input               rst_n,

    input               flush_stage4,
    input               hold_stage4,
    input               stage4_pause,

    input               inst0_decode_vld,
    input               inst0_PC_stage3,
    input               inst0_PC_target_stage3,
    input       [2:0]   inst0_except_stage3,
    input       [14:0]  inst0_except_code_stage3,
    input       [3:0]   inst0_IQ_choose,
    input       [4:0]   inst0_ALU0_op,
    input       [2:0]   inst0_ALU1_op,
    input       [3:0]   inst0_AGU_op,
    input       [3:0]   inst0_BRU_op,
    input       [3:0]   inst0_ROB_op,
    input       [19:0]  inst0_ALU0_imm,
    input       [16:0]  inst0_AGU_imm,
    input       [25:0]  inst0_BRU_imm,

    input               inst1_decode_vld,
    input               inst1_PC_stage3,
    input               inst1_PC_target_stage3,
    input       [2:0]   inst1_except_stage3,
    input       [14:0]  inst1_except_code_stage3,
    input       [3:0]   inst1_IQ_choose,
    input       [4:0]   inst1_ALU0_op,
    input       [2:0]   inst1_ALU1_op,
    input       [3:0]   inst1_AGU_op,
    input       [3:0]   inst1_BRU_op,
    input       [3:0]   inst1_ROB_op,
    input       [19:0]  inst1_ALU0_imm,
    input       [16:0]  inst1_AGU_imm,
    input       [25:0]  inst1_BRU_imm,

    input               inst2_decode_vld,
    input               inst2_PC_stage3,
    input               inst2_PC_target_stage3,
    input       [2:0]   inst2_except_stage3,
    input       [14:0]  inst2_except_code_stage3,
    input       [3:0]   inst2_IQ_choose,
    input       [4:0]   inst2_ALU0_op,
    input       [2:0]   inst2_ALU1_op,
    input       [3:0]   inst2_AGU_op,
    input       [3:0]   inst2_BRU_op,
    input       [3:0]   inst2_ROB_op,
    input       [19:0]  inst2_ALU0_imm,
    input       [16:0]  inst2_AGU_imm,
    input       [25:0]  inst2_BRU_imm,

    input               inst3_decode_vld,
    input               inst3_PC_stage3,
    input               inst3_PC_target_stage3,
    input       [2:0]   inst3_except_stage3,
    input       [14:0]  inst3_except_code_stage3,
    input       [3:0]   inst3_IQ_choose,
    input       [4:0]   inst3_ALU0_op,
    input       [2:0]   inst3_ALU1_op,
    input       [3:0]   inst3_AGU_op,
    input       [3:0]   inst3_BRU_op,
    input       [3:0]   inst3_ROB_op,
    input       [19:0]  inst3_ALU0_imm,
    input       [16:0]  inst3_AGU_imm,
    input       [25:0]  inst3_BRU_imm,

    output  reg         inst0_vld_stage4,
    output  reg         inst0_PC_stage4,
    output  reg         inst0_PC_target_stage4,
    output  reg [2:0]   inst0_except_stage4,
    output  reg [14:0]  inst0_except_code_stage4,
    output  reg [3:0]   inst0_IQ_choose_stage4,
    output  reg [4:0]   inst0_ALU0_op_stage4,
    output  reg [2:0]   inst0_ALU1_op_stage4,
    output  reg [3:0]   inst0_AGU_op_stage4,
    output  reg [3:0]   inst0_BRU_op_stage4,
    output  reg [3:0]   inst0_ROB_op_stage4,
    output  reg [19:0]  inst0_ALU0_imm_stage4,
    output  reg [16:0]  inst0_AGU_imm_stage4,
    output  reg [25:0]  inst0_BRU_imm_stage4,

    output  reg         inst1_vld_stage4,
    output  reg         inst1_PC_stage4,
    output  reg         inst1_PC_target_stage4,
    output  reg [2:0]   inst1_except_stage4,
    output  reg [14:0]  inst1_except_code_stage4,
    output  reg [3:0]   inst1_IQ_choose_stage4,
    output  reg [4:0]   inst1_ALU0_op_stage4,
    output  reg [2:0]   inst1_ALU1_op_stage4,
    output  reg [3:0]   inst1_AGU_op_stage4,
    output  reg [3:0]   inst1_BRU_op_stage4,
    output  reg [3:0]   inst1_ROB_op_stage4,
    output  reg [19:0]  inst1_ALU0_imm_stage4,
    output  reg [16:0]  inst1_AGU_imm_stage4,
    output  reg [25:0]  inst1_BRU_imm_stage4,

    output  reg         inst2_vld_stage4,
    output  reg         inst2_PC_stage4,
    output  reg         inst2_PC_target_stage4,
    output  reg [2:0]   inst2_except_stage4,
    output  reg [14:0]  inst2_except_code_stage4,
    output  reg [3:0]   inst2_IQ_choose_stage4,
    output  reg [4:0]   inst2_ALU0_op_stage4,
    output  reg [2:0]   inst2_ALU1_op_stage4,
    output  reg [3:0]   inst2_AGU_op_stage4,
    output  reg [3:0]   inst2_BRU_op_stage4,
    output  reg [3:0]   inst2_ROB_op_stage4,
    output  reg [19:0]  inst2_ALU0_imm_stage4,
    output  reg [16:0]  inst2_AGU_imm_stage4,
    output  reg [25:0]  inst2_BRU_imm_stage4,

    output  reg         inst3_vld_stage4,
    output  reg         inst3_PC_stage4,
    output  reg         inst3_PC_target_stage4,
    output  reg [2:0]   inst3_except_stage4,
    output  reg [14:0]  inst3_except_code_stage4,
    output  reg [3:0]   inst3_IQ_choose_stage4,
    output  reg [4:0]   inst3_ALU0_op_stage4,
    output  reg [2:0]   inst3_ALU1_op_stage4,
    output  reg [3:0]   inst3_AGU_op_stage4,
    output  reg [3:0]   inst3_BRU_op_stage4,
    output  reg [3:0]   inst3_ROB_op_stage4,
    output  reg [19:0]  inst3_ALU0_imm_stage4,
    output  reg [16:0]  inst3_AGU_imm_stage4,
    output  reg [25:0]  inst3_BRU_imm_stage4
);
    wire inst0_except;
    wire inst1_except;
    wire inst2_except;

    assign inst0_except = |inst0_except_stage3 || (inst0_decode_vld && ((inst0_ROB_op == 1) || (inst0_ROB_op == 2)));
    assign inst1_except = |inst1_except_stage3 || (inst1_decode_vld && ((inst1_ROB_op == 1) || (inst1_ROB_op == 2)));
    assign inst2_except = |inst2_except_stage3 || (inst2_decode_vld && ((inst2_ROB_op == 1) || (inst2_ROB_op == 2)));

    always@(posedge clk or negedge rst_n)begin      // inst0_vld_stage4
        if(!rst_n)
            inst0_vld_stage4 <= 1'b0;
        else if(flush_stage4)
            inst0_vld_stage4 <= 1'b0;
        else if(hold_stage4)
            inst0_vld_stage4 <= inst0_vld_stage4;
        else if(stage4_pause)
            inst0_vld_stage4 <= 1'b0;
        else 
            inst0_vld_stage4 <= inst0_decode_vld;
    end 
    always@(posedge clk or negedge rst_n)begin      // inst1_vld_stage4
        if(!rst_n)
            inst1_vld_stage4 <= 1'b0;
        else if(flush_stage4)
            inst1_vld_stage4 <= 1'b0;
        else if(hold_stage4)
            inst1_vld_stage4 <= inst1_vld_stage4;
        else if(stage4_pause || inst0_except)
            inst1_vld_stage4 <= 1'b0;
        else 
            inst1_vld_stage4 <= inst1_decode_vld;
    end 
    always@(posedge clk or negedge rst_n)begin      // inst2_vld_stage4
        if(!rst_n)
            inst2_vld_stage4 <= 1'b0;
        else if(flush_stage4)
            inst2_vld_stage4 <= 1'b0;
        else if(hold_stage4)
            inst2_vld_stage4 <= inst2_vld_stage4;
        else if(stage4_pause || inst0_except || inst1_except)
            inst2_vld_stage4 <= 1'b0;
        else 
            inst2_vld_stage4 <= inst2_decode_vld;
    end 
    always@(posedge clk or negedge rst_n)begin      // inst3_vld_stage4
        if(!rst_n)
            inst3_vld_stage4 <= 1'b0;
        else if(flush_stage4)
            inst3_vld_stage4 <= 1'b0;
        else if(hold_stage4)
            inst3_vld_stage4 <= inst3_vld_stage4;
        else if(stage4_pause || inst0_except || inst1_except || inst2_except)
            inst3_vld_stage4 <= 1'b0;
        else 
            inst3_vld_stage4 <= inst3_decode_vld;
    end 

    always @(posedge clk or negedge rst_n) begin    // inst0_PC_stage4
        if(!rst_n)
            inst0_PC_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) &&
                (inst0_decode_vld || (|inst0_except_stage3)))
            inst0_PC_stage4 <= inst0_PC_stage3;
    end
    always @(posedge clk or negedge rst_n) begin    // inst1_PC_stage4
        if(!rst_n)
            inst1_PC_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) && (!inst0_except) &&
                (inst1_decode_vld || (|inst1_except_stage3)))
            inst1_PC_stage4 <= inst1_PC_stage3;
    end
    always @(posedge clk or negedge rst_n) begin    // inst2_PC_stage4
        if(!rst_n)
            inst2_PC_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) && (!inst0_except) && (!inst1_except) &&
                (inst2_decode_vld || (|inst2_except_stage3)))
            inst2_PC_stage4 <= inst2_PC_stage3;
    end
    always @(posedge clk or negedge rst_n) begin    // inst3_PC_stage4
        if(!rst_n)
            inst3_PC_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) && (!inst0_except) && (!inst1_except) && (!inst2_except) &&
                (inst3_decode_vld || (|inst3_except_stage3)))
            inst3_PC_stage4 <= inst3_PC_stage3;
    end

    always @(posedge clk or negedge rst_n) begin    // inst0_PC_target_stage4
        if(!rst_n)
            inst0_PC_target_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) &&
                (inst0_decode_vld || (|inst0_except_stage3)))
            inst0_PC_target_stage4 <= inst0_PC_target_stage3;
    end
    always @(posedge clk or negedge rst_n) begin    // inst1_PC_target_stage4
        if(!rst_n)
            inst1_PC_target_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) && (!inst0_except) &&
                (inst1_decode_vld || (|inst1_except_stage3)))
            inst1_PC_target_stage4 <= inst1_PC_target_stage3;
    end
    always @(posedge clk or negedge rst_n) begin    // inst2_PC_target_stage4
        if(!rst_n)
            inst2_PC_target_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) && (!inst0_except) && (!inst1_except) &&
                (inst2_decode_vld || (|inst2_except_stage3)))
            inst2_PC_target_stage4 <= inst2_PC_target_stage3;
    end
    always @(posedge clk or negedge rst_n) begin    // inst3_PC_target_stage4
        if(!rst_n)
            inst3_PC_target_stage4 <= 32'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause) && (!inst0_except) && (!inst1_except) && (!inst2_except) &&
                (inst3_decode_vld || (|inst3_except_stage3)))
            inst3_PC_target_stage4 <= inst3_PC_target_stage3;
    end

    always@(posedge clk or negedge rst_n)begin      // inst0_except_stage4
        if(!rst_n)
            inst0_except_stage4 <= 3'd0;
        else if(flush_stage4)
            inst0_except_stage4 <= 3'd0;
        else if(hold_stage4)
            inst0_except_stage4 <= inst0_except_stage4;
        else if(stage4_pause)
            inst0_except_stage4 <= 3'd0;
        else 
            inst0_except_stage4 <= inst0_except_stage3;
    end 
    always@(posedge clk or negedge rst_n)begin      // inst1_except_stage4
        if(!rst_n)
            inst1_except_stage4 <= 3'd0;
        else if(flush_stage4)
            inst1_except_stage4 <= 3'd0;
        else if(hold_stage4)
            inst1_except_stage4 <= inst1_except_stage4;
        else if(stage4_pause || inst0_except)
            inst1_except_stage4 <= 3'd0;
        else 
            inst1_except_stage4 <= inst1_except_stage3;
    end 
    always@(posedge clk or negedge rst_n)begin      // inst2_except_stage4
        if(!rst_n)
            inst2_except_stage4 <= 3'd0;
        else if(flush_stage4)
            inst2_except_stage4 <= 3'd0;
        else if(hold_stage4)
            inst2_except_stage4 <= inst2_except_stage4;
        else if(stage4_pause || inst0_except || inst1_except)
            inst2_except_stage4 <= 3'd0;
        else 
            inst2_except_stage4 <= inst2_except_stage3;
    end 
    always@(posedge clk or negedge rst_n)begin      // inst3_except_stage4
        if(!rst_n)
            inst3_except_stage4 <= 3'd0;
        else if(flush_stage4)
            inst3_except_stage4 <= 3'd0;
        else if(hold_stage4)
            inst3_except_stage4 <= inst3_except_stage4;
        else if(stage4_pause || inst0_except || inst1_except || inst2_except)
            inst3_except_stage4 <= 3'd0;
        else 
            inst3_except_stage4 <= inst3_except_stage3;
    end 

    always @(posedge clk or negedge rst_n) begin    // inst0_except_code_stage4
        if(!rst_n)
            inst0_except_code_stage4 <= 15'd0;
        else if(flush_stage4)
            inst0_except_code_stage4 <= 15'd0;
        else if(hold_stage4)
            inst0_except_code_stage4 <= inst0_except_code_stage4;
        else if(inst0_decode_vld && ((inst0_ROB_op == 1) || (inst0_ROB_op == 2)))
            inst0_except_code_stage4 <= inst0_except_code_stage3;
    end    
    always @(posedge clk or negedge rst_n) begin    // inst1_except_code_stage4
        if(!rst_n)
            inst1_except_code_stage4 <= 15'd0;
        else if(flush_stage4)
            inst1_except_code_stage4 <= 15'd0;
        else if(hold_stage4)
            inst1_except_code_stage4 <= inst1_except_code_stage4;
        else if(inst1_decode_vld && ((inst1_ROB_op == 1) || (inst1_ROB_op == 2)))
            inst1_except_code_stage4 <= inst1_except_code_stage3;
    end   
    always @(posedge clk or negedge rst_n) begin    // inst2_except_code_stage4
        if(!rst_n)
            inst2_except_code_stage4 <= 15'd0;
        else if(flush_stage4)
            inst2_except_code_stage4 <= 15'd0;
        else if(hold_stage4)
            inst2_except_code_stage4 <= inst2_except_code_stage4;
        else if(inst2_decode_vld && ((inst2_ROB_op == 1) || (inst2_ROB_op == 2)))
            inst2_except_code_stage4 <= inst2_except_code_stage3;
    end   
    always @(posedge clk or negedge rst_n) begin    // inst3_except_code_stage4
        if(!rst_n)
            inst3_except_code_stage4 <= 15'd0;
        else if(flush_stage4)
            inst3_except_code_stage4 <= 15'd0;
        else if(hold_stage4)
            inst3_except_code_stage4 <= inst3_except_code_stage4;
        else if(inst3_decode_vld && ((inst3_ROB_op == 1) || (inst3_ROB_op == 2)))
            inst3_except_code_stage4 <= inst3_except_code_stage3;
    end   

    always@(posedge clk or negedge rst_n) begin     // inst0_IQ_choose_stage4
        if(!rst_n)
            inst0_IQ_choose_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_IQ_choose_stage4 <= inst0_IQ_choose;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_IQ_choose_stage4
        if(!rst_n)
            inst1_IQ_choose_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_IQ_choose_stage4 <= inst1_IQ_choose;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_IQ_choose_stage4
        if(!rst_n)
            inst2_IQ_choose_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_IQ_choose_stage4 <= inst2_IQ_choose;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_IQ_choose_stage4
        if(!rst_n)
            inst3_IQ_choose_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_IQ_choose_stage4 <= inst3_IQ_choose;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_ALU0_op_stage4
        if(!rst_n)
            inst0_ALU0_op_stage4 <= 5'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_ALU0_op_stage4 <= inst0_ALU0_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_ALU0_op_stage4
        if(!rst_n)
            inst1_ALU0_op_stage4 <= 5'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_ALU0_op_stage4 <= inst1_ALU0_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_ALU0_op_stage4
        if(!rst_n)
            inst2_ALU0_op_stage4 <= 5'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_ALU0_op_stage4 <= inst2_ALU0_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_ALU0_op_stage4
        if(!rst_n)
            inst3_ALU0_op_stage4 <= 5'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_ALU0_op_stage4 <= inst3_ALU0_op;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_ALU1_op_stage4
        if(!rst_n)
            inst0_ALU1_op_stage4 <= 3'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_ALU1_op_stage4 <= inst0_ALU1_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_ALU1_op_stage4
        if(!rst_n)
            inst1_ALU1_op_stage4 <= 3'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_ALU1_op_stage4 <= inst1_ALU1_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_ALU1_op_stage4
        if(!rst_n)
            inst2_ALU1_op_stage4 <= 3'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_ALU1_op_stage4 <= inst2_ALU1_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_ALU1_op_stage4
        if(!rst_n)
            inst3_ALU1_op_stage4 <= 3'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_ALU1_op_stage4 <= inst3_ALU1_op;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_AGU_op_stage4
        if(!rst_n)
            inst0_AGU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_AGU_op_stage4 <= inst0_AGU_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_AGU_op_stage4
        if(!rst_n)
            inst1_AGU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_AGU_op_stage4 <= inst1_AGU_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_AGU_op_stage4
        if(!rst_n)
            inst2_AGU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_AGU_op_stage4 <= inst2_AGU_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_AGU_op_stage4
        if(!rst_n)
            inst3_AGU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_AGU_op_stage4 <= inst3_AGU_op;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_BRU_op_stage4
        if(!rst_n)
            inst0_BRU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_BRU_op_stage4 <= inst0_BRU_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_BRU_op_stage4
        if(!rst_n)
            inst1_BRU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_BRU_op_stage4 <= inst1_BRU_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_BRU_op_stage4
        if(!rst_n)
            inst2_BRU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_BRU_op_stage4 <= inst2_BRU_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_BRU_op_stage4
        if(!rst_n)
            inst3_BRU_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_BRU_op_stage4 <= inst3_BRU_op;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_ROB_op_stage4
        if(!rst_n)
            inst0_ROB_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_ROB_op_stage4 <= inst0_ROB_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_ROB_op_stage4
        if(!rst_n)
            inst1_ROB_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_ROB_op_stage4 <= inst1_ROB_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_ROB_op_stage4
        if(!rst_n)
            inst2_ROB_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_ROB_op_stage4 <= inst2_ROB_op;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_ROB_op_stage4
        if(!rst_n)
            inst3_ROB_op_stage4 <= 4'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_ROB_op_stage4 <= inst3_ROB_op;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_ALU0_imm_stage4
        if(!rst_n)
            inst0_ALU0_imm_stage4 <= 20'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_ALU0_imm_stage4 <= inst0_ALU0_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_ALU0_imm_stage4
        if(!rst_n)
            inst1_ALU0_imm_stage4 <= 20'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_ALU0_imm_stage4 <= inst1_ALU0_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_ALU0_imm_stage4
        if(!rst_n)
            inst2_ALU0_imm_stage4 <= 20'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_ALU0_imm_stage4 <= inst2_ALU0_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_ALU0_imm_stage4
        if(!rst_n)
            inst3_ALU0_imm_stage4 <= 20'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_ALU0_imm_stage4 <= inst3_ALU0_imm;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_AGU_imm_stage4
        if(!rst_n)
            inst0_AGU_imm_stage4 <= 17'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_AGU_imm_stage4 <= inst0_AGU_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_AGU_imm_stage4
        if(!rst_n)
            inst1_AGU_imm_stage4 <= 17'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_AGU_imm_stage4 <= inst1_AGU_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_AGU_imm_stage4
        if(!rst_n)
            inst2_AGU_imm_stage4 <= 17'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_AGU_imm_stage4 <= inst2_AGU_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_AGU_imm_stage4
        if(!rst_n)
            inst3_AGU_imm_stage4 <= 17'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_AGU_imm_stage4 <= inst3_AGU_imm;
    end

    always@(posedge clk or negedge rst_n) begin     // inst0_BRU_imm_stage4
        if(!rst_n)
            inst0_BRU_imm_stage4 <= 26'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst0_BRU_imm_stage4 <= inst0_BRU_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst1_BRU_imm_stage4
        if(!rst_n)
            inst1_BRU_imm_stage4 <= 26'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst1_BRU_imm_stage4 <= inst1_BRU_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst2_BRU_imm_stage4
        if(!rst_n)
            inst2_BRU_imm_stage4 <= 26'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst2_BRU_imm_stage4 <= inst2_BRU_imm;
    end
    always@(posedge clk or negedge rst_n) begin     // inst3_BRU_imm_stage4
        if(!rst_n)
            inst3_BRU_imm_stage4 <= 26'd0;
        else if((!flush_stage4) && (!hold_stage4) && (!stage4_pause))
            inst3_BRU_imm_stage4 <= inst3_BRU_imm;
    end

endmodule