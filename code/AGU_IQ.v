module AGU (
    input               clk,
    input               rst_n,

    input               flush,

    input               CACOP_already,      // 阻塞CACOP指令
    input               INVTLB_already,     // 阻塞INVTLB指令
    input               store_buffer_full,  // 阻塞store指令
    input               AGU_busy,           // 阻塞所有访存指令

    input               inst0_AGU_en,
    input               inst0_PR_dest_en,
    input               inst0_PR_source1_en,
    input               inst0_PR_source2_en,
    input               inst0_PR_source1_rdy,
    input               inst0_PR_source2_rdy,
    input       [6:0]   inst0_PR_dest,
    input       [6:0]   inst0_PR_source1,
    input       [6:0]   inst0_PR_source2,
    input       [3:0]   inst0_AGU_op,
    input       [16:0]  inst0_AGU_imm,
    input       [5:0]   inst0_ROB_ID,

    input               inst1_AGU_en,
    input               inst1_PR_dest_en,
    input               inst1_PR_source1_en,
    input               inst1_PR_source2_en,
    input               inst1_PR_source1_rdy,
    input               inst1_PR_source2_rdy,
    input       [6:0]   inst1_PR_dest,
    input       [6:0]   inst1_PR_source1,
    input       [6:0]   inst1_PR_source2,
    input       [3:0]   inst1_AGU_op,
    input       [16:0]  inst1_AGU_imm,
    input       [5:0]   inst1_ROB_ID,

    input               inst2_AGU_en,
    input               inst2_PR_dest_en,
    input               inst2_PR_source1_en,
    input               inst2_PR_source2_en,
    input               inst2_PR_source1_rdy,
    input               inst2_PR_source2_rdy,
    input       [6:0]   inst2_PR_dest,
    input       [6:0]   inst2_PR_source1,
    input       [6:0]   inst2_PR_source2,
    input       [3:0]   inst2_AGU_op,
    input       [16:0]  inst2_AGU_imm,
    input       [5:0]   inst2_ROB_ID,

    input               inst3_AGU_en,
    input               inst3_PR_dest_en,
    input               inst3_PR_source1_en,
    input               inst3_PR_source2_en,
    input               inst3_PR_source1_rdy,
    input               inst3_PR_source2_rdy,
    input       [6:0]   inst3_PR_dest,
    input       [6:0]   inst3_PR_source1,
    input       [6:0]   inst3_PR_source2,
    input       [3:0]   inst3_AGU_op,
    input       [16:0]  inst3_AGU_imm,
    input       [5:0]   inst3_ROB_ID,

    output              wr_AGU_IQ_pause,
    input               wr_pause,

    input       [6:0]   ALU0_dest,
    input       [6:0]   ALU1_dest,
    input       [6:0]   BRU_dest,

    output  reg         AGU_select_vld,
    output  reg [3:0]   AGU_select_op,
    output  reg [16:0]  AGU_select_imm,
    output  reg         AGU_select_dest_en,
    output  reg [6:0]   AGU_select_dest,
    output  reg [6:0]   AGU_select_source1,
    output  reg [6:0]   AGU_select_source2,
    output  reg [5:0]   AGU_select_ROB_ID
);
    reg [7:0]   AGU_IQ_vld;
    reg [7:0]   AGU_IQ_dest_en;
    reg [7:0]   AGU_IQ_source1_en;
    reg [7:0]   AGU_IQ_source1_rdy;
    reg [7:0]   AGU_IQ_source2_en;
    reg [7:0]   AGU_IQ_source2_rdy;
    reg [6:0]   AGU_IQ_dest    [7:0];
    reg [6:0]   AGU_IQ_source1 [7:0];
    reg [6:0]   AGU_IQ_source2 [7:0];
    reg [5:0]   AGU_IQ_ROB_ID  [7:0];
    reg [3:0]   AGU_IQ_op      [7:0];
    reg [16:0]  AGU_IQ_imm     [7:0];

    wire [2:0]  room_need;
    wire [3:0]  room_have;

    wire [7:0]  converse_vld;
    wire [7:0]  converse_last_vld;
    wire [7:0]  last_vld;

    wire [7:0]  first_wr_onehot;
    
    reg  [7:0]  wr_en;
    reg  [1:0]  wr_from [7:0];
    reg         grant;      // can excute

    assign room_need = inst0_AGU_en + inst1_AGU_en + inst2_AGU_en + inst3_AGU_en;
    assign room_have = (!AGU_IQ_vld[0]) + (!AGU_IQ_vld[1]) + (!AGU_IQ_vld[2]) + (!AGU_IQ_vld[3]) + 
                       (!AGU_IQ_vld[4]) + (!AGU_IQ_vld[5]) + (!AGU_IQ_vld[6]) + (!AGU_IQ_vld[7]) +
                       grant;

    assign wr_AGU_IQ_pause = (room_need > room_have);

    assign converse_vld = {ALU0_IQ_vld[0], ALU0_IQ_vld[1], ALU0_IQ_vld[2], ALU0_IQ_vld[3], 
                           ALU0_IQ_vld[4], ALU0_IQ_vld[5], ALU0_IQ_vld[6], ALU0_IQ_vld[7]};
    assign converse_last_vld = converse_vld & ((~converse_vld) + 1);
    assign last_vld = {converse_last_vld[0], converse_last_vld[1], converse_last_vld[2], converse_last_vld[3], 
                       converse_last_vld[4], converse_last_vld[5], converse_last_vld[6], converse_last_vld[7]};

    assign first_wr_onehot = grant ? last_vld : ((last_vld == 8'd0) ? 8'd1 : (last_vld << 1));

    always @(*) begin       // grant
        
    end

endmodule