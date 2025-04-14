module BTB (
    input               clk,
    input               rst_n,

    input               PC_vld,
    input       [31:0]  PC,

    input               retire_en,
    input       [31:0]  PC_retire,
    input       [31:0]  PC_target_retire,

    input               hold_stage1_2,

    output  reg [31:0]  PC_target,
    output  reg [31:0]  PC_target_stage1,
    output              BTB_hit,
    output              instruction0_vld_stage0,
    output              instruction1_vld_stage0,
    output              instruction2_vld_stage0,
    output              instruction3_vld_stage0
);
    
    reg  [31:11] BTB_tag [10:4];
    reg  [3:2]   BTB_offest [10:4];
    reg          BTB_vld [10:4];
    reg  [31:0]  BTB_target [10:4];

    reg  [1:0] offest_switch;
    reg  [3:0] PC_inst_vld;
    reg  [3:0] hit_inst_vld;

    wire  BTB_hit_wr;
    integer i;

    assign BTB_hit_wr = PC_vld && retire_en && (PC[31:11] == PC_retire[31:11]) && (PC[3:2] <= PC_retire[3:2]);
    assign BTB_hit = PC_vld && BTB_vld[PC[10:4]] && (PC[31:11] == BTB_tag[PC[10:4]]) && (PC[3:2] <= BTB_offest[PC[10:4]]);

    always @(posedge clk or negedge rst_n) begin            // retire
        if(!rst_n)
            for(i = 0; i < 7'h7f; i = i + 1)begin
                BTB_tag[i] <= 21'd0;
                BTB_offest[i] <= 2'd0;
                BTB_vld[i] <= 1'b0;
                BTB_target[i] <= 32'd0;
            end
        else if(retire_en)begin
            BTB_tag[PC_retire[10:4]] <= PC_retire[31:11];
            BTB_offest[PC_retire[10:4]] <= PC_retire[3:2];
            BTB_vld[PC_retire[10:4]] <= 1'b1;
            BTB_target[PC_retire[10:4]] <= PC_target_retire;
        end
    end

    always@(*)begin          // PC_target
        if(BTB_hit_wr)
            PC_target = PC_target_retire;
        else if(BTB_hit)
            PC_target = BTB_target[PC[10:4]];
        else
            PC_target = 32'd0;
    end

    always @(posedge clk or negedge rst_n) begin        // PC_target_stage1
        if(!rst_n)
            PC_target_stage1 <= 32'd0;
        else if(!hold_stage1_2) begin
            if(BTB_hit || BTB_hit_wr)
                PC_target_stage1 <= PC_target;
            else
                PC_target_stage1 <= (((PC >> 4) + 1'b1) << 4);
        end
    end

    always @(*) begin           // offest_switch
        if(BTB_hit_wr)
            offest_switch = PC_retire[3:2];
        else if(BTB_hit)
            offest_switch = BTB_offest[PC[10:4]];
        else
            offest_switch = 2'b11;
    end

    always @(*) begin           // PC_inst_vld
        case (PC[3:2])
            2'b00: PC_inst_vld = 4'b1111;
            2'b01: PC_inst_vld = 4'b0111;
            2'b10: PC_inst_vld = 4'b0011;
            2'b11: PC_inst_vld = 4'b0001;
        endcase
    end

    always @(*) begin           // hit_inst_vld
        case (offest_switch)
            2'b00: PC_inst_vld = 4'b1000;
            2'b01: PC_inst_vld = 4'b1100;
            2'b10: PC_inst_vld = 4'b1110;
            2'b11: PC_inst_vld = 4'b1111;
        endcase
    end

    assign {instruction0_vld_stage0, instruction1_vld_stage0, 
            instruction0_vld_stage2, instruction3_vld_stage0} = PC_inst_vld & hit_inst_vld;

endmodule