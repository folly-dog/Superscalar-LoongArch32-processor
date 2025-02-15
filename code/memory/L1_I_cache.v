module I_cache (
    input                clk,
    input                rst_n,

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
);

    reg [7:0]  LRU [11:6];      //每way的4条line用一个8bit的LRU记录

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
    
endmodule