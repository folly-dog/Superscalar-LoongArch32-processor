module I_cache (
    input                clk,
    input                rst_n,

    input                flush_stage1_2,
    input                hold_stage1_2,
    input                except_en,

    input         [31:0] IF_PC,
    input                IF_PC_vld,

    input        [31:12] IF_PC_PPN,

    input                CACOP_vld,
    input         [4:3]  CACOP_op,      // 0: tag_initial, 1: coherence_direct, 2: coherence_load

    output               IF_hold_CACOP,


    output  reg  [31:0]  PC_stage2,
    output  reg          instruction0_vld,
    output  reg  [31:0]  instruction0,
    output  reg          instruction1_vld,
    output  reg  [31:0]  instruction1,
    output  reg          instruction2_vld,
    output  reg  [31:0]  instruction2,
    output  reg          instruction3_vld,
    output  reg  [31:0]  instruction3,

    output               I_cache_req,
    output               I_cache_req_op,        // 0: read, 1: write
    output       [31:0]  I_cache_req_addr,
    output      [511:0]  I_cache_wr_data,

    input                L2_cache_ack,
    input       [511:0]  I_cache_rd_data

    output reg           stage1_2_pause
);

    reg         vld_line0 [11:6];
    reg [31:12] tag_line0 [11:6];
    reg [127:0]   data0_line0 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line0 [11:6];
    reg [383:256] data2_line0 [11:6];
    reg [511:384] data3_line0 [11:6];

    reg         vld_line1 [11:6];
    reg [31:12] tag_line1 [11:6];
    reg [127:0]   data0_line1 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line1 [11:6];
    reg [383:256] data2_line1 [11:6];
    reg [511:384] data3_line1 [11:6];

    reg         vld_line2 [11:6];
    reg [31:12] tag_line2 [11:6];
    reg [127:0]   data0_line2 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line2 [11:6];
    reg [383:256] data2_line2 [11:6];
    reg [511:384] data3_line2 [11:6];

    reg         vld_line3 [11:6];
    reg [31:12] tag_line3 [11:6];
    reg [127:0]   data0_line3 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line3 [11:6];
    reg [383:256] data2_line3 [11:6];
    reg [511:384] data3_line3 [11:6];
    
    reg vld_line0_stage1;
    reg vld_line1_stage1;
    reg vld_line2_stage1;
    reg vld_line3_stage1;
    reg [31:12] tag_line0_stage1;
    reg [31:12] tag_line1_stage1;
    reg [31:12] tag_line2_stage1;
    reg [31:12] tag_line3_stage1;

    reg [1:0]   cnt_cycle;  //用于循环计数，挑选替代的cacheline

    wire line0_hit;
    wire line1_hit;
    wire line2_hit;
    wire line3_hit;

    wire stage1_vld;
    wire way_full;
    wire IF_miss;

    parameter Default_pipeline   = 1'b0;
    parameter rd_L2              = 1'b1;

    reg [1:0]   current_state;
    reg [1:0]   next_state;

    assign line0_hit = vld_line0_stage1 && (tag_line0_stage1 == IF_PC_PPN);
    assign line1_hit = vld_line1_stage1 && (tag_line1_stage1 == IF_PC_PPN);
    assign line2_hit = vld_line2_stage1 && (tag_line2_stage1 == IF_PC_PPN);
    assign line3_hit = vld_line3_stage1 && (tag_line3_stage1 == IF_PC_PPN);

    assign stage1_vld = (vld_line0_stage1 | vld_line1_stage1 | vld_line2_stage1 | vld_line3_stage1);
    assign way_full = (vld_line0_stage1 & vld_line1_stage1 & vld_line2_stage1 & vld_line3_stage1);
    assign IF_miss = !(line0_hit || line1_hit || line2_hit || line3_hit);   


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= Default_pipeline;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            Default_pipeline:  next_state = (IF_miss & stage1_vld)? rd_L2 : Default_pipeline;
            rd_L2: next_state = (L2_cache_ack) ? Default_pipeline : rd_L2;
            default: next_state = Default_pipeline;
        endcase
    end

endmodule