module before_dispatch (
    input               clk,
    input               rst_n,

    input               flush,

    input               wr_ALU0_IQ_pause,
    input               wr_ALU1_IQ_pause,
    input               wr_AGU_IQ_pause,
    input               wr_BRU_IQ_pause,

    input       [6:0]   ROB_wr_ptr_exp,
    input       [6:0]   ROB_room,

    input               inst0_vld_stage4,
    input               inst1_vld_stage4,
    input               inst2_vld_stage4,
    input               inst3_vld_stage4,

    input               inst0_source1_en_stage4,
    input               inst1_source1_en_stage4,
    input               inst2_source1_en_stage4,
    input               inst3_source1_en_stage4,
    input               inst0_source2_en_stage4,
    input               inst1_source2_en_stage4,
    input               inst2_source2_en_stage4,
    input               inst3_source2_en_stage4,

    input       [3:0]   inst0_IQ_choose_stage4,
    input       [3:0]   inst1_IQ_choose_stage4,
    input       [3:0]   inst2_IQ_choose_stage4,
    input       [3:0]   inst3_IQ_choose_stage4,

    input       [2:0]   inst0_except_stage4,
    input       [2:0]   inst1_except_stage4,
    input       [2:0]   inst2_except_stage4,
    input       [2:0]   inst3_except_stage4,

    input       [64:0]  PR_status,
    input       [6:0]   inst0_source1_PR_stage4,
    input       [6:0]   inst1_source1_PR_stage4,
    input       [6:0]   inst2_source1_PR_stage4,
    input       [6:0]   inst3_source1_PR_stage4,
    input       [6:0]   inst0_source2_PR_stage4,
    input       [6:0]   inst1_source2_PR_stage4,
    input       [6:0]   inst2_source2_PR_stage4,
    input       [6:0]   inst3_source2_PR_stage4,

    output              wr_pause,

    output reg  [5:0]   inst0_ROB_ID,
    output reg  [5:0]   inst1_ROB_ID,
    output reg  [5:0]   inst2_ROB_ID,
    output reg  [5:0]   inst3_ROB_ID,

    output reg  [3:0]   inst0_IQ_choose_bf_dispatch,
    output reg  [3:0]   inst1_IQ_choose_bf_dispatch,
    output reg  [3:0]   inst2_IQ_choose_bf_dispatch,
    output reg  [3:0]   inst3_IQ_choose_bf_dispatch,

    output              inst0_PR_source1_rdy,
    output              inst1_PR_source1_rdy,
    output              inst2_PR_source1_rdy,
    output              inst3_PR_source1_rdy,
    output              inst0_PR_source2_rdy,
    output              inst1_PR_source2_rdy,
    output              inst2_PR_source2_rdy,
    output              inst3_PR_source2_rdy,

    output      [2:0]   wr_ROB_num,
    output  reg [1:0]   wr_ROB_fisrt
);
    wire wr_ROB_pause;
    wire [5:0]  ROB_wr_ptr;

    assign ROB_wr_ptr = ROB_wr_ptr_exp[5:0];

    always @(*) begin       // inst0_IQ_choose_bf_dispatch
        if(inst0_vld_stage4)
            inst0_IQ_choose_bf_dispatch = inst0_IQ_choose_stage4;
        else
            inst0_IQ_choose_bf_dispatch = 4'd0;
    end
    always @(*) begin       // inst1_IQ_choose_bf_dispatch
        if(inst1_vld_stage4 && (!(|inst0_except_stage4)))
            inst1_IQ_choose_bf_dispatch = inst1_IQ_choose_stage4;
        else
            inst1_IQ_choose_bf_dispatch = 4'd0;
    end
    always @(*) begin       // inst2_IQ_choose_bf_dispatch
        if(inst2_vld_stage4 && (!(|inst0_except_stage4)) && (!(|inst1_except_stage4)))
            inst2_IQ_choose_bf_dispatch = inst2_IQ_choose_stage4;
        else
            inst2_IQ_choose_bf_dispatch = 4'd0;
    end
    always @(*) begin       // inst3_IQ_choose_bf_dispatch
        if(inst3_vld_stage4 && (!(|inst0_except_stage4)) && (!(|inst1_except_stage4)) && (!(|inst2_except_stage4)))
            inst3_IQ_choose_bf_dispatch = inst3_IQ_choose_stage4;
        else
            inst3_IQ_choose_bf_dispatch = 4'd0;
    end

    assign wr_ROB_num = (inst0_vld_stage4 || (|inst0_except_stage4)) + 
                        (inst1_vld_stage4 || (|inst1_except_stage4)) + 
                        (inst2_vld_stage4 || (|inst2_except_stage4)) + 
                        (inst3_vld_stage4 || (|inst3_except_stage4));

    assign wr_ROB_pause = (wr_ROB_num > ROB_room);

    assign wr_pause = (wr_ALU0_IQ_pause | wr_ALU1_IQ_pause | wr_AGU_IQ_pause | wr_BRU_IQ_pause | wr_ROB_pause);

    always @(*) begin       // wr_ROB_first
        if(inst0_vld_stage4 || (|inst0_except_stage4))
            wr_ROB_fisrt = 2'b00;
        else if(inst1_vld_stage4 || (|inst1_except_stage4))
            wr_ROB_fisrt = 2'b01;
        else if(inst2_vld_stage4 || (|inst2_except_stage4))
            wr_ROB_fisrt = 2'b10;
        else
            wr_ROB_fisrt = 2'b11;
    end

    assign inst0_PR_source1_rdy = inst0_source1_en_stage4 ? PR_status[inst0_source1_PR_stage4] : 1'b1;
    assign inst1_PR_source1_rdy = inst1_source1_en_stage4 ? PR_status[inst1_source1_PR_stage4] : 1'b1;
    assign inst2_PR_source1_rdy = inst2_source1_en_stage4 ? PR_status[inst2_source1_PR_stage4] : 1'b1;
    assign inst3_PR_source1_rdy = inst3_source1_en_stage4 ? PR_status[inst3_source1_PR_stage4] : 1'b1;
    assign inst0_PR_source2_rdy = inst0_source2_en_stage4 ? PR_status[inst0_source2_PR_stage4] : 1'b1;
    assign inst1_PR_source2_rdy = inst1_source2_en_stage4 ? PR_status[inst1_source2_PR_stage4] : 1'b1;
    assign inst2_PR_source2_rdy = inst2_source2_en_stage4 ? PR_status[inst2_source2_PR_stage4] : 1'b1;
    assign inst3_PR_source2_rdy = inst3_source2_en_stage4 ? PR_status[inst3_source2_PR_stage4] : 1'b1;
       
    always @(*) begin       // instx_ID
        case (wr_ROB_fisrt)
            2'b00: begin
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr + 1;
                inst0_ROB_ID = ROB_wr_ptr + 2;
                inst0_ROB_ID = ROB_wr_ptr + 3;
            end
            2'b01: begin
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr + 1;
                inst0_ROB_ID = ROB_wr_ptr + 2;
            end
            2'b10: begin
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr + 1;
            end
            2'b11: begin
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr;
                inst0_ROB_ID = ROB_wr_ptr;
            end
        endcase
    end

endmodule