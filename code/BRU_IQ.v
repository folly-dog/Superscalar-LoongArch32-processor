module BRU_IQ (
    input               clk,
    input               rst_n,

    input               flush,

    input       [31:0]  inst0_PC,
    input       [31:0]  inst0_target_PC,
    input       [25:0]  inst0_BRU_imm,
    input               inst0_BRU_en,
    input               inst0_PR_dest_en,
    input               inst0_PR_source1_en,
    input               inst0_PR_source2_en,
    input               inst0_PR_source1_rdy,
    input               inst0_PR_source2_rdy,
    input       [6:0]   inst0_PR_dest,
    input       [6:0]   inst0_PR_source1,
    input       [6:0]   inst0_PR_source2,
    input       [3:0]   inst0_BRU_op,
    input       [5:0]   inst0_ROB_ID,

    input       [31:0]  inst1_PC,
    input       [31:0]  inst1_target_PC,
    input       [25:0]  inst1_BRU_imm,
    input               inst1_BRU_en,
    input               inst1_PR_dest_en,
    input               inst1_PR_source1_en,
    input               inst1_PR_source2_en,
    input               inst1_PR_source1_rdy,
    input               inst1_PR_source2_rdy,
    input       [6:0]   inst1_PR_dest,
    input       [6:0]   inst1_PR_source1,
    input       [6:0]   inst1_PR_source2,
    input       [3:0]   inst1_BRU_op,
    input       [5:0]   inst1_ROB_ID,

    input       [31:0]  inst2_PC,
    input       [31:0]  inst2_target_PC,
    input       [25:0]  inst2_BRU_imm,
    input               inst2_BRU_en,
    input               inst2_PR_dest_en,
    input               inst2_PR_source1_en,
    input               inst2_PR_source2_en,
    input               inst2_PR_source1_rdy,
    input               inst2_PR_source2_rdy,
    input       [6:0]   inst2_PR_dest,
    input       [6:0]   inst2_PR_source1,
    input       [6:0]   inst2_PR_source2,
    input       [3:0]   inst2_BRU_op,
    input       [5:0]   inst2_ROB_ID,

    input       [31:0]  inst3_PC,
    input       [31:0]  inst3_target_PC,
    input       [25:0]  inst3_BRU_imm,
    input               inst3_BRU_en,
    input               inst3_PR_dest_en,
    input               inst3_PR_source1_en,
    input               inst3_PR_source2_en,
    input               inst3_PR_source1_rdy,
    input               inst3_PR_source2_rdy,
    input       [6:0]   inst3_PR_dest,
    input       [6:0]   inst3_PR_source1,
    input       [6:0]   inst3_PR_source2,
    input       [3:0]   inst3_BRU_op,
    input       [5:0]   inst3_ROB_ID,

    output              wr_BRU_IQ_pause,
    input               wr_pause,

    input       [7:0]   dest_ALU0,
    input       [7:0]   dest_AGU,
    input       [7:0]   dest_ALU1,

    output  reg         BRU_select_vld,
    output  reg         BRU_select_dest_en,
    output  reg [31:0]  BRU_select_PC,
    output  reg [31:0]  BRU_select_target_PC,
    output  reg [25:0]  BRU_select_imm,
    output  reg [3:0]   BRU_select_op,
    output  reg [6:0]   BRU_select_dest,
    output  reg [6:0]   BRU_select_source1,
    output  reg [6:0]   BRU_select_source2,
    output  reg [5:0]   BRU_select_ROB_ID
);
    reg [3:0]   BRU_IQ_vld;
    reg [3:0]   BRU_IQ_dest_en;
    reg [31:0]  BRU_IQ_PC [3:0];
    reg [31:0]  BRU_IQ_target_PC [31:0];
    reg [25:0]  BRU_IQ_imm  [31:0];
    reg [3:0]   BRU_IQ_source1_en;
    reg [3:0]   BRU_IQ_source2_en;
    reg [3:0]   BRU_IQ_source1_rdy;
    reg [3:0]   BRU_IQ_source2_rdy;
    reg [6:0]   BRU_IQ_dest    [3:0];
    reg [6:0]   BRU_IQ_source1 [3:0];
    reg [6:0]   BRU_IQ_source2 [3:0];
    reg [5:0]   BRU_IQ_ROB_ID  [3:0];
    reg [3:0]   BRU_IQ_op      [3:0];

    wire [3:0]  req_excute;
    wire [3:0]  grant_excute;

    wire [3:0]  converse_vld;
    wire [3:0]  converse_last_vld;
    wire [3:0]  last_vld;

    wire [3:0]  first_wr_onehot;
    
    reg  [3:0]  wr_en;
    reg  [1:0]  wr_from [3:0];

    wire [2:0]  room_need;
    wire [2:0]  room_have;

    assign room_need = inst0_BRU_en + inst1_BRU_en + inst2_BRU_en + inst3_BRU_en;
    assign room_have = (!BRU_IQ_vld[0]) + (!BRU_IQ_vld[1]) + (!BRU_IQ_vld[2]) + (!BRU_IQ_vld[3]) + 
                       (|grant_excute);

    assign wr_BRU_IQ_pause = (room_need > room_have);

    assign req_excute[0] = BRU_IQ_vld[0] & ((BRU_IQ_source1_en[0] & BRU_IQ_source1_rdy[0]) | !BRU_IQ_source1_en[0]) & 
                                           ((BRU_IQ_source2_en[0] & BRU_IQ_source2_rdy[0]) | !BRU_IQ_source2_en[0]);
    assign req_excute[1] = BRU_IQ_vld[1] & ((BRU_IQ_source1_en[1] & BRU_IQ_source1_rdy[1]) | !BRU_IQ_source1_en[1]) & 
                                           ((BRU_IQ_source2_en[1] & BRU_IQ_source2_rdy[1]) | !BRU_IQ_source2_en[1]);
    assign req_excute[2] = BRU_IQ_vld[2] & ((BRU_IQ_source1_en[2] & BRU_IQ_source1_rdy[2]) | !BRU_IQ_source1_en[2]) & 
                                           ((BRU_IQ_source2_en[2] & BRU_IQ_source2_rdy[2]) | !BRU_IQ_source2_en[2]);
    assign req_excute[3] = BRU_IQ_vld[3] & ((BRU_IQ_source1_en[3] & BRU_IQ_source1_rdy[3]) | !BRU_IQ_source1_en[3]) & 
                                           ((BRU_IQ_source2_en[3] & BRU_IQ_source2_rdy[3]) | !BRU_IQ_source2_en[3]);

    assign grant_excute = wr_pause ? 4'd0 : ( req_excute & ((~req_excute) + 1));

    assign converse_vld  = {BRU_IQ_vld[0], BRU_IQ_vld[1], BRU_IQ_vld[2], BRU_IQ_vld[3]};
    assign converse_last_vld = converse_vld & ((~converse_vld) + 1);
    assign last_vld = {converse_last_vld[0], converse_last_vld[1], converse_last_vld[2], converse_last_vld[3]};

    assign first_wr_onehot = (|grant_excute) ? last_vld : ((last_vld == 4'd0) ? 4'd1 : (last_vld << 1));

    always @(*) begin       // wr_en
        if(wr_pause)
            wr_en = 4'd0;
        else case (first_wr_onehot)
            4'b0001: 
                case (room_need)
                    3'd0: wr_en = 4'd0;
                    3'd1: wr_en = 4'b0001;
                    3'd2: wr_en = 4'b0011;
                    3'd3: wr_en = 4'b0111;
                    3'd4: wr_en = 4'b1111;
                    default: wr_en = 4'd0;
                endcase
            4'b0010: 
                case (room_need)
                    3'd0: wr_en = 4'd0;
                    3'd1: wr_en = 4'b0010;
                    3'd2: wr_en = 4'b0110;
                    3'd3: wr_en = 4'b1110;
                    default: wr_en = 4'd0;
                endcase
            4'b0100: 
                case (room_need)
                    3'd0: wr_en = 4'd0;
                    3'd1: wr_en = 4'b0100;
                    3'd2: wr_en = 4'b1100;
                    default: wr_en = 4'd0;
                endcase
            4'b1000: 
                case (room_need)
                    3'd1: wr_en = 4'b1000;
                    default: wr_en = 4'd0;
                endcase
            default: wr_en = 8'd0;
        endcase
    end

    always @(*) begin       // wr_from[0]
        case (first_wr_onehot)
            4'b0001: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1???: wr_from[0] = 2'b00;
                4'b01??: wr_from[0] = 2'b01;
                4'b001?: wr_from[0] = 2'b10;
                4'b0001: wr_from[0] = 2'b11;
                default: wr_from[0] = 2'b00;
            endcase
            default: wr_from[0] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[1]
        case (first_wr_onehot)
            4'b0001: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1111: wr_from[1] = 2'b01;
                4'b1110: wr_from[1] = 2'b01;
                4'b1101: wr_from[1] = 2'b01;
                4'b1011: wr_from[1] = 2'b10;
                4'b0111: wr_from[1] = 2'b10;
                4'b1100: wr_from[1] = 2'b01;
                4'b1010: wr_from[1] = 2'b10;
                4'b0110: wr_from[1] = 2'b10;
                4'b1001: wr_from[1] = 2'b11;
                4'b0101: wr_from[1] = 2'b11;
                4'b0011: wr_from[1] = 2'b11;
                default: wr_from[1] = 2'b00;
            endcase
            4'b0010: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1???: wr_from[1] = 2'b00;
                4'b01??: wr_from[1] = 2'b01;
                4'b001?: wr_from[1] = 2'b10;
                4'b0001: wr_from[1] = 2'b11;
                default: wr_from[1] = 2'b00;
            endcase
            default: wr_from[1] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[2]
        case (first_wr_onehot)
            4'b0001: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1111: wr_from[2] = 2'b10;
                4'b1110: wr_from[2] = 2'b10;
                4'b1101: wr_from[2] = 2'b11;
                4'b1011: wr_from[2] = 2'b11;
                4'b0111: wr_from[2] = 2'b11;
                default: wr_from[2] = 2'b00;
            endcase
            4'b0010: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1111: wr_from[2] = 2'b01;
                4'b1110: wr_from[2] = 2'b01;
                4'b1101: wr_from[2] = 2'b01;
                4'b1011: wr_from[2] = 2'b10;
                4'b0111: wr_from[2] = 2'b10;
                4'b1100: wr_from[2] = 2'b01;
                4'b1010: wr_from[2] = 2'b10;
                4'b0110: wr_from[2] = 2'b10;
                4'b1001: wr_from[2] = 2'b11;
                4'b0101: wr_from[2] = 2'b11;
                4'b0011: wr_from[2] = 2'b11;
                default: wr_from[2] = 2'b00;
            endcase
            4'b0100: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1???: wr_from[2] = 2'b00;
                4'b01??: wr_from[2] = 2'b01;
                4'b001?: wr_from[2] = 2'b10;
                4'b0001: wr_from[2] = 2'b11;
                default: wr_from[2] = 2'b00;
            endcase
            default: wr_from[2] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[3]
        case (first_wr_onehot)
            4'b0001: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            4'b0010: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1111: wr_from[3] = 2'b10;
                4'b1110: wr_from[3] = 2'b10;
                4'b1101: wr_from[3] = 2'b11;
                4'b1011: wr_from[3] = 2'b11;
                4'b0111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            4'b0100: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1111: wr_from[3] = 2'b01;
                4'b1110: wr_from[3] = 2'b01;
                4'b1101: wr_from[3] = 2'b01;
                4'b1011: wr_from[3] = 2'b10;
                4'b0111: wr_from[3] = 2'b10;
                4'b1100: wr_from[3] = 2'b01;
                4'b1010: wr_from[3] = 2'b10;
                4'b0110: wr_from[3] = 2'b10;
                4'b1001: wr_from[3] = 2'b11;
                4'b0101: wr_from[3] = 2'b11;
                4'b0011: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            4'b1000: casez ({inst0_BRU_en, inst1_BRU_en, inst2_BRU_en, inst3_BRU_en})
                4'b1???: wr_from[3] = 2'b00;
                4'b01??: wr_from[3] = 2'b01;
                4'b001?: wr_from[3] = 2'b10;
                4'b0001: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            default: wr_from[3] = 2'b00;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin    // entry0
        if((!rst_n) || flush)begin
            BRU_IQ_vld[0] <= 1'b0;
            BRU_IQ_dest_en <= 1'b0;
            BRU_IQ_source1_rdy[0] <= 1'b0;
            BRU_IQ_source2_rdy[0] <= 1'b0;
        end
        else if(wr_en[0])
            case (wr_from[0])
                2'b00:begin
                    BRU_IQ_vld[0] <= 1'b1;
                    BRU_IQ_dest_en[0] <= inst0_PR_dest_en;
                    BRU_IQ_source1_en[0] <= inst0_PR_source1_en;
                    BRU_IQ_source2_en[0] <= inst0_PR_source2_en;
                    BRU_IQ_PC[0] <= inst0_PC;
                    BRU_IQ_target_PC[0] <= inst0_target_PC;
                    BRU_IQ_imm[0] <= inst0_BRU_imm;
                    BRU_IQ_source1_rdy[0] <= inst0_PR_source1_rdy;
                    BRU_IQ_source2_rdy[0] <= inst0_PR_source2_rdy;
                    BRU_IQ_dest[0] <= inst0_PR_dest;
                    BRU_IQ_source1[0] <= inst0_PR_source1;
                    BRU_IQ_source2[0] <= inst0_PR_source2;
                    BRU_IQ_op[0] <= inst0_BRU_op;
                    BRU_IQ_ROB_ID[0] <= inst0_ROB_ID;
                end
                2'b01:begin
                    BRU_IQ_vld[0] <= 1'b1;
                    BRU_IQ_dest_en[0] <= inst1_PR_dest_en;
                    BRU_IQ_source1_en[0] <= inst1_PR_source1_en;
                    BRU_IQ_source2_en[0] <= inst1_PR_source2_en;
                    BRU_IQ_PC[0] <= inst1_PC;
                    BRU_IQ_target_PC[0] <= inst1_target_PC;
                    BRU_IQ_imm[0] <= inst1_BRU_imm;
                    BRU_IQ_source1_rdy[0] <= inst1_PR_source1_rdy;
                    BRU_IQ_source2_rdy[0] <= inst1_PR_source2_rdy;
                    BRU_IQ_dest[0] <= inst1_PR_dest;
                    BRU_IQ_source1[0] <= inst1_PR_source1;
                    BRU_IQ_source2[0] <= inst1_PR_source2;
                    BRU_IQ_op[0] <= inst1_BRU_op;
                    BRU_IQ_ROB_ID[0] <= inst1_ROB_ID;
                end
                2'b10:begin
                    BRU_IQ_vld[0] <= 1'b1;
                    BRU_IQ_dest_en[0] <= inst2_PR_dest_en;
                    BRU_IQ_source1_en[0] <= inst2_PR_source1_en;
                    BRU_IQ_source2_en[0] <= inst2_PR_source2_en;
                    BRU_IQ_PC[0] <= inst2_PC;
                    BRU_IQ_target_PC[0] <= inst2_target_PC;
                    BRU_IQ_imm[0] <= inst2_BRU_imm;
                    BRU_IQ_source1_rdy[0] <= inst2_PR_source1_rdy;
                    BRU_IQ_source2_rdy[0] <= inst2_PR_source2_rdy;
                    BRU_IQ_dest[0] <= inst2_PR_dest;
                    BRU_IQ_source1[0] <= inst2_PR_source1;
                    BRU_IQ_source2[0] <= inst2_PR_source2;
                    BRU_IQ_op[0] <= inst2_BRU_op;
                    BRU_IQ_ROB_ID[0] <= inst2_ROB_ID;
                end
                2'b11:begin
                    BRU_IQ_vld[0] <= 1'b1;
                    BRU_IQ_dest_en[0] <= inst3_PR_dest_en;
                    BRU_IQ_source1_en[0] <= inst3_PR_source1_en;
                    BRU_IQ_source2_en[0] <= inst3_PR_source2_en;
                    BRU_IQ_PC[0] <= inst3_PC;
                    BRU_IQ_target_PC[0] <= inst3_target_PC;
                    BRU_IQ_imm[0] <= inst3_BRU_imm;
                    BRU_IQ_source1_rdy[0] <= inst3_PR_source1_rdy;
                    BRU_IQ_source2_rdy[0] <= inst3_PR_source2_rdy;
                    BRU_IQ_dest[0] <= inst3_PR_dest;
                    BRU_IQ_source1[0] <= inst3_PR_source1;
                    BRU_IQ_source2[0] <= inst3_PR_source2;
                    BRU_IQ_op[0] <= inst3_BRU_op;
                    BRU_IQ_ROB_ID[0] <= inst3_ROB_ID;
                end
            endcase
        else if(grant_excute[0])begin
            BRU_IQ_vld[0] <= BRU_IQ_vld[1];
            BRU_IQ_dest_en[0] <= BRU_IQ_dest_en[1];
            BRU_IQ_source1_en[0] <= BRU_IQ_source1_en[1];
            BRU_IQ_source2_en[0] <= BRU_IQ_source2_en[1];
            BRU_IQ_PC[0] <= BRU_IQ_PC[1];
            BRU_IQ_target_PC[0] <= BRU_IQ_target_PC[1];
            BRU_IQ_imm[0] <= BRU_IQ_imm[1];
             BRU_IQ_dest[0] <= BRU_IQ_dest[1];
             BRU_IQ_source1[0] <= BRU_IQ_source1[1];
             BRU_IQ_source2[0] <= BRU_IQ_source2[1];
             BRU_IQ_op[0] <= BRU_IQ_op[1];
             BRU_IQ_ROB_ID[0] <= BRU_IQ_ROB_ID[1];
            if(( BRU_IQ_source1[1] == dest_ALU0) || ( BRU_IQ_source1[1] == dest_AGU) ||
               ( BRU_IQ_source1[1] == dest_ALU1))
                 BRU_IQ_source1_rdy[0] <= 1'b1;
            if(( BRU_IQ_source2[1] == dest_ALU0) || ( BRU_IQ_source2[1] == dest_AGU) ||
               ( BRU_IQ_source2[1] == dest_ALU1))
                 BRU_IQ_source2_rdy[0] <= 1'b1;
        end
        else begin
            if(( BRU_IQ_source1[0] == dest_ALU0) || ( BRU_IQ_source1[0] == dest_AGU) ||
               ( BRU_IQ_source1[0] == dest_ALU1))
                 BRU_IQ_source1_rdy[0] <= 1'b1;
            if(( BRU_IQ_source2[0] == dest_ALU0) || ( BRU_IQ_source2[0] == dest_AGU) ||
               ( BRU_IQ_source2[0] == dest_ALU1))
                 BRU_IQ_source2_rdy[0] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin    // entry1
        if((!rst_n) || flush)begin
            BRU_IQ_vld[1] <= 1'b0;
            BRU_IQ_dest_en <= 1'b0;
            BRU_IQ_source1_rdy[1] <= 1'b0;
            BRU_IQ_source2_rdy[1] <= 1'b0;
        end
        else if(wr_en[1])
            case (wr_from[1])
                2'b00:begin
                    BRU_IQ_vld[1] <= 1'b1;
                    BRU_IQ_dest_en[1] <= inst0_PR_dest_en;
                    BRU_IQ_source1_en[1] <= inst0_PR_source1_en;
                    BRU_IQ_source2_en[1] <= inst0_PR_source2_en;
                    BRU_IQ_PC[1] <= inst0_PC;
                    BRU_IQ_target_PC[1] <= inst0_target_PC;
                    BRU_IQ_imm[1] <= inst0_BRU_imm;
                    BRU_IQ_source1_rdy[1] <= inst0_PR_source1_rdy;
                    BRU_IQ_source2_rdy[1] <= inst0_PR_source2_rdy;
                    BRU_IQ_dest[1] <= inst0_PR_dest;
                    BRU_IQ_source1[1] <= inst0_PR_source1;
                    BRU_IQ_source2[1] <= inst0_PR_source2;
                    BRU_IQ_op[1] <= inst0_BRU_op;
                    BRU_IQ_ROB_ID[1] <= inst0_ROB_ID;
                end
                2'b01:begin
                    BRU_IQ_vld[1] <= 1'b1;
                    BRU_IQ_dest_en[1] <= inst1_PR_dest_en;
                    BRU_IQ_source1_en[1] <= inst1_PR_source1_en;
                    BRU_IQ_source2_en[1] <= inst1_PR_source2_en;
                    BRU_IQ_PC[1] <= inst1_PC;
                    BRU_IQ_target_PC[1] <= inst1_target_PC;
                    BRU_IQ_imm[1] <= inst1_BRU_imm;
                    BRU_IQ_source1_rdy[1] <= inst1_PR_source1_rdy;
                    BRU_IQ_source2_rdy[1] <= inst1_PR_source2_rdy;
                    BRU_IQ_dest[1] <= inst1_PR_dest;
                    BRU_IQ_source1[1] <= inst1_PR_source1;
                    BRU_IQ_source2[1] <= inst1_PR_source2;
                    BRU_IQ_op[1] <= inst1_BRU_op;
                    BRU_IQ_ROB_ID[1] <= inst1_ROB_ID;
                end
                2'b10:begin
                    BRU_IQ_vld[1] <= 1'b1;
                    BRU_IQ_dest_en[1] <= inst2_PR_dest_en;
                    BRU_IQ_source1_en[1] <= inst2_PR_source1_en;
                    BRU_IQ_source2_en[1] <= inst2_PR_source2_en;
                    BRU_IQ_PC[1] <= inst2_PC;
                    BRU_IQ_target_PC[1] <= inst2_target_PC;
                    BRU_IQ_imm[1] <= inst2_BRU_imm;
                    BRU_IQ_source1_rdy[1] <= inst2_PR_source1_rdy;
                    BRU_IQ_source2_rdy[1] <= inst2_PR_source2_rdy;
                    BRU_IQ_dest[1] <= inst2_PR_dest;
                    BRU_IQ_source1[1] <= inst2_PR_source1;
                    BRU_IQ_source2[1] <= inst2_PR_source2;
                    BRU_IQ_op[1] <= inst2_BRU_op;
                    BRU_IQ_ROB_ID[1] <= inst2_ROB_ID;
                end
                2'b11:begin
                    BRU_IQ_vld[1] <= 1'b1;
                    BRU_IQ_dest_en[1] <= inst3_PR_dest_en;
                    BRU_IQ_source1_en[1] <= inst3_PR_source1_en;
                    BRU_IQ_source2_en[1] <= inst3_PR_source2_en;
                    BRU_IQ_PC[1] <= inst3_PC;
                    BRU_IQ_target_PC[1] <= inst3_target_PC;
                    BRU_IQ_imm[1] <= inst3_BRU_imm;
                    BRU_IQ_source1_rdy[1] <= inst3_PR_source1_rdy;
                    BRU_IQ_source2_rdy[1] <= inst3_PR_source2_rdy;
                    BRU_IQ_dest[1] <= inst3_PR_dest;
                    BRU_IQ_source1[1] <= inst3_PR_source1;
                    BRU_IQ_source2[1] <= inst3_PR_source2;
                    BRU_IQ_op[1] <= inst3_BRU_op;
                    BRU_IQ_ROB_ID[1] <= inst3_ROB_ID;
                end
            endcase
        else if(grant_excute[1] | grant_excute[0])begin
            BRU_IQ_vld[1] <= BRU_IQ_vld[2];
            BRU_IQ_dest_en[1] <= BRU_IQ_dest_en[2];
            BRU_IQ_source1_en[1] <= BRU_IQ_source1_en[2];
            BRU_IQ_source2_en[1] <= BRU_IQ_source2_en[2];
            BRU_IQ_PC[1] <= BRU_IQ_PC[2];
            BRU_IQ_target_PC[1] <= BRU_IQ_target_PC[2];
            BRU_IQ_imm[1] <= BRU_IQ_imm[2];
             BRU_IQ_dest[1] <= BRU_IQ_dest[2];
             BRU_IQ_source1[1] <= BRU_IQ_source1[2];
             BRU_IQ_source2[1] <= BRU_IQ_source2[2];
             BRU_IQ_op[1] <= BRU_IQ_op[2];
             BRU_IQ_ROB_ID[1] <= BRU_IQ_ROB_ID[2];
            if(( BRU_IQ_source1[2] == dest_ALU0) || ( BRU_IQ_source1[2] == dest_AGU) ||
               ( BRU_IQ_source1[2] == dest_ALU1))
                 BRU_IQ_source1_rdy[1] <= 1'b1;
            if(( BRU_IQ_source2[2] == dest_ALU0) || ( BRU_IQ_source2[2] == dest_AGU) ||
               ( BRU_IQ_source2[2] == dest_ALU1))
                 BRU_IQ_source2_rdy[1] <= 1'b1;
        end
        else begin
            if(( BRU_IQ_source1[1] == dest_ALU0) || ( BRU_IQ_source1[1] == dest_AGU) ||
               ( BRU_IQ_source1[1] == dest_ALU1))
                 BRU_IQ_source1_rdy[1] <= 1'b1;
            if(( BRU_IQ_source2[1] == dest_ALU0) || ( BRU_IQ_source2[1] == dest_AGU) ||
               ( BRU_IQ_source2[1] == dest_ALU1))
                 BRU_IQ_source2_rdy[1] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin    // entry2
        if((!rst_n) || flush)begin
            BRU_IQ_vld[2] <= 1'b0;
            BRU_IQ_dest_en <= 1'b0;
            BRU_IQ_source1_rdy[2] <= 1'b0;
            BRU_IQ_source2_rdy[2] <= 1'b0;
        end
        else if(wr_en[2])
            case (wr_from[2])
                2'b00:begin
                    BRU_IQ_vld[2] <= 1'b1;
                    BRU_IQ_dest_en[2] <= inst0_PR_dest_en;
                    BRU_IQ_source1_en[2] <= inst0_PR_source1_en;
                    BRU_IQ_source2_en[2] <= inst0_PR_source2_en;
                    BRU_IQ_PC[2] <= inst0_PC;
                    BRU_IQ_target_PC[2] <= inst0_target_PC;
                    BRU_IQ_imm[2] <= inst0_BRU_imm;
                    BRU_IQ_source1_rdy[2] <= inst0_PR_source1_rdy;
                    BRU_IQ_source2_rdy[2] <= inst0_PR_source2_rdy;
                    BRU_IQ_dest[2] <= inst0_PR_dest;
                    BRU_IQ_source1[2] <= inst0_PR_source1;
                    BRU_IQ_source2[2] <= inst0_PR_source2;
                    BRU_IQ_op[2] <= inst0_BRU_op;
                    BRU_IQ_ROB_ID[2] <= inst0_ROB_ID;
                end
                2'b01:begin
                    BRU_IQ_vld[2] <= 1'b1;
                    BRU_IQ_dest_en[2] <= inst1_PR_dest_en;
                    BRU_IQ_source1_en[2] <= inst1_PR_source1_en;
                    BRU_IQ_source2_en[2] <= inst1_PR_source2_en;
                    BRU_IQ_PC[2] <= inst1_PC;
                    BRU_IQ_target_PC[2] <= inst1_target_PC;
                    BRU_IQ_imm[2] <= inst1_BRU_imm;
                    BRU_IQ_source1_rdy[2] <= inst1_PR_source1_rdy;
                    BRU_IQ_source2_rdy[2] <= inst1_PR_source2_rdy;
                    BRU_IQ_dest[2] <= inst1_PR_dest;
                    BRU_IQ_source1[2] <= inst1_PR_source1;
                    BRU_IQ_source2[2] <= inst1_PR_source2;
                    BRU_IQ_op[2] <= inst1_BRU_op;
                    BRU_IQ_ROB_ID[2] <= inst1_ROB_ID;
                end
                2'b10:begin
                    BRU_IQ_vld[2] <= 1'b1;
                    BRU_IQ_dest_en[2] <= inst2_PR_dest_en;
                    BRU_IQ_source1_en[2] <= inst2_PR_source1_en;
                    BRU_IQ_source2_en[2] <= inst2_PR_source2_en;
                    BRU_IQ_PC[2] <= inst2_PC;
                    BRU_IQ_target_PC[2] <= inst2_target_PC;
                    BRU_IQ_imm[2] <= inst2_BRU_imm;
                    BRU_IQ_source1_rdy[2] <= inst2_PR_source1_rdy;
                    BRU_IQ_source2_rdy[2] <= inst2_PR_source2_rdy;
                    BRU_IQ_dest[2] <= inst2_PR_dest;
                    BRU_IQ_source1[2] <= inst2_PR_source1;
                    BRU_IQ_source2[2] <= inst2_PR_source2;
                    BRU_IQ_op[2] <= inst2_BRU_op;
                    BRU_IQ_ROB_ID[2] <= inst2_ROB_ID;
                end
                2'b11:begin
                    BRU_IQ_vld[2] <= 1'b1;
                    BRU_IQ_dest_en[2] <= inst3_PR_dest_en;
                    BRU_IQ_source1_en[2] <= inst3_PR_source1_en;
                    BRU_IQ_source2_en[2] <= inst3_PR_source2_en;
                    BRU_IQ_PC[2] <= inst3_PC;
                    BRU_IQ_target_PC[2] <= inst3_target_PC;
                    BRU_IQ_imm[2] <= inst3_BRU_imm;
                    BRU_IQ_source1_rdy[2] <= inst3_PR_source1_rdy;
                    BRU_IQ_source2_rdy[2] <= inst3_PR_source2_rdy;
                    BRU_IQ_dest[2] <= inst3_PR_dest;
                    BRU_IQ_source1[2] <= inst3_PR_source1;
                    BRU_IQ_source2[2] <= inst3_PR_source2;
                    BRU_IQ_op[2] <= inst3_BRU_op;
                    BRU_IQ_ROB_ID[2] <= inst3_ROB_ID;
                end
            endcase
        else if(grant_excute[2] | grant_excute[1] | grant_excute[0])begin
            BRU_IQ_vld[2] <= BRU_IQ_vld[3];
            BRU_IQ_dest_en[2] <= BRU_IQ_dest_en[3];
            BRU_IQ_source1_en[2] <= BRU_IQ_source1_en[3];
            BRU_IQ_source2_en[2] <= BRU_IQ_source2_en[3];
            BRU_IQ_PC[2] <= BRU_IQ_PC[3];
            BRU_IQ_target_PC[2] <= BRU_IQ_target_PC[3];
            BRU_IQ_imm[2] <= BRU_IQ_imm[3];
             BRU_IQ_dest[2] <= BRU_IQ_dest[3];
             BRU_IQ_source1[2] <= BRU_IQ_source1[3];
             BRU_IQ_source2[2] <= BRU_IQ_source2[3];
             BRU_IQ_op[2] <= BRU_IQ_op[3];
             BRU_IQ_ROB_ID[2] <= BRU_IQ_ROB_ID[3];
            if(( BRU_IQ_source1[3] == dest_ALU0) || ( BRU_IQ_source1[3] == dest_AGU) ||
               ( BRU_IQ_source1[3] == dest_ALU1))
                 BRU_IQ_source1_rdy[2] <= 1'b1;
            if(( BRU_IQ_source2[3] == dest_ALU0) || ( BRU_IQ_source2[3] == dest_AGU) ||
               ( BRU_IQ_source2[3] == dest_ALU1))
                 BRU_IQ_source2_rdy[2] <= 1'b1;
        end
        else begin
            if(( BRU_IQ_source1[2] == dest_ALU0) || ( BRU_IQ_source1[2] == dest_AGU) ||
               ( BRU_IQ_source1[2] == dest_ALU1))
                 BRU_IQ_source1_rdy[2] <= 1'b1;
            if(( BRU_IQ_source2[2] == dest_ALU0) || ( BRU_IQ_source2[2] == dest_AGU) ||
               ( BRU_IQ_source2[2] == dest_ALU1))
                 BRU_IQ_source2_rdy[2] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin    // entry3
        if((!rst_n) || flush)begin
            BRU_IQ_vld[3] <= 1'b0;
            BRU_IQ_dest_en <= 1'b0;
            BRU_IQ_source1_rdy[3] <= 1'b0;
            BRU_IQ_source2_rdy[3] <= 1'b0;
        end
        else if(wr_en[3])
            case (wr_from[3])
                2'b00:begin
                    BRU_IQ_vld[3] <= 1'b1;
                    BRU_IQ_dest_en[3] <= inst0_PR_dest_en;
                    BRU_IQ_source1_en[3] <= inst0_PR_source1_en;
                    BRU_IQ_source2_en[3] <= inst0_PR_source2_en;
                    BRU_IQ_PC[3] <= inst0_PC;
                    BRU_IQ_target_PC[3] <= inst0_target_PC;
                    BRU_IQ_imm[3] <= inst0_BRU_imm;
                    BRU_IQ_source1_rdy[3] <= inst0_PR_source1_rdy;
                    BRU_IQ_source2_rdy[3] <= inst0_PR_source2_rdy;
                    BRU_IQ_dest[3] <= inst0_PR_dest;
                    BRU_IQ_source1[3] <= inst0_PR_source1;
                    BRU_IQ_source2[3] <= inst0_PR_source2;
                    BRU_IQ_op[3] <= inst0_BRU_op;
                    BRU_IQ_ROB_ID[3] <= inst0_ROB_ID;
                end
                2'b01:begin
                    BRU_IQ_vld[3] <= 1'b1;
                    BRU_IQ_dest_en[3] <= inst1_PR_dest_en;
                    BRU_IQ_source1_en[3] <= inst1_PR_source1_en;
                    BRU_IQ_source2_en[3] <= inst1_PR_source2_en;
                    BRU_IQ_PC[3] <= inst1_PC;
                    BRU_IQ_target_PC[3] <= inst1_target_PC;
                    BRU_IQ_imm[3] <= inst1_BRU_imm;
                    BRU_IQ_source1_rdy[3] <= inst1_PR_source1_rdy;
                    BRU_IQ_source2_rdy[3] <= inst1_PR_source2_rdy;
                    BRU_IQ_dest[3] <= inst1_PR_dest;
                    BRU_IQ_source1[3] <= inst1_PR_source1;
                    BRU_IQ_source2[3] <= inst1_PR_source2;
                    BRU_IQ_op[3] <= inst1_BRU_op;
                    BRU_IQ_ROB_ID[3] <= inst1_ROB_ID;
                end
                2'b10:begin
                    BRU_IQ_vld[3] <= 1'b1;
                    BRU_IQ_dest_en[3] <= inst2_PR_dest_en;
                    BRU_IQ_source1_en[3] <= inst2_PR_source1_en;
                    BRU_IQ_source2_en[3] <= inst2_PR_source2_en;
                    BRU_IQ_PC[3] <= inst2_PC;
                    BRU_IQ_target_PC[3] <= inst2_target_PC;
                    BRU_IQ_imm[3] <= inst2_BRU_imm;
                    BRU_IQ_source1_rdy[3] <= inst2_PR_source1_rdy;
                    BRU_IQ_source2_rdy[3] <= inst2_PR_source2_rdy;
                    BRU_IQ_dest[3] <= inst2_PR_dest;
                    BRU_IQ_source1[3] <= inst2_PR_source1;
                    BRU_IQ_source2[3] <= inst2_PR_source2;
                    BRU_IQ_op[3] <= inst2_BRU_op;
                    BRU_IQ_ROB_ID[3] <= inst2_ROB_ID;
                end
                2'b11:begin
                    BRU_IQ_vld[3] <= 1'b1;
                    BRU_IQ_dest_en[3] <= inst3_PR_dest_en;
                    BRU_IQ_source1_en[3] <= inst3_PR_source1_en;
                    BRU_IQ_source2_en[3] <= inst3_PR_source2_en;
                    BRU_IQ_PC[3] <= inst3_PC;
                    BRU_IQ_target_PC[3] <= inst3_target_PC;
                    BRU_IQ_imm[3] <= inst3_BRU_imm;
                    BRU_IQ_source1_rdy[3] <= inst3_PR_source1_rdy;
                    BRU_IQ_source2_rdy[3] <= inst3_PR_source2_rdy;
                    BRU_IQ_dest[3] <= inst3_PR_dest;
                    BRU_IQ_source1[3] <= inst3_PR_source1;
                    BRU_IQ_source2[3] <= inst3_PR_source2;
                    BRU_IQ_op[3] <= inst3_BRU_op;
                    BRU_IQ_ROB_ID[3] <= inst3_ROB_ID;
                end
            endcase
        else if(|grant_excute)begin
            BRU_IQ_vld[3] <= 1'b0;
            BRU_IQ_dest_en[3] <= 1'b0;
            BRU_IQ_source1_en[3] <= 1'b0;
            BRU_IQ_source2_en[3] <= 1'b0;
            BRU_IQ_source1_rdy[3] <= 1'b0;
            BRU_IQ_source2_rdy[3] <= 1'b0;
            BRU_IQ_PC[3] <= 32'd0;
            BRU_IQ_target_PC[3] <= 32'd0;
            BRU_IQ_imm[3] <= 26'd0;
            BRU_IQ_dest[3] <= 7'd0;
            BRU_IQ_source1[3] <= 7'd0;
            BRU_IQ_source2[3] <= 7'd0;
            BRU_IQ_op[3] <= 4'd0;
            BRU_IQ_ROB_ID[3] <= 6'd0;
        end
        else begin
            if(( BRU_IQ_source1[3] == dest_ALU0) || ( BRU_IQ_source1[3] == dest_AGU) ||
               ( BRU_IQ_source1[3] == dest_ALU1))
                 BRU_IQ_source1_rdy[3] <= 1'b1;
            if(( BRU_IQ_source2[3] == dest_ALU0) || ( BRU_IQ_source2[3] == dest_AGU) ||
               ( BRU_IQ_source2[3] == dest_ALU1))
                 BRU_IQ_source2_rdy[3] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // out
        if((!rst_n) || flush)begin
            BRU_select_vld <= 1'b0;
            BRU_select_dest_en <= 1'b0;
            BRU_select_PC <= 32'd0;
            BRU_select_target_PC <= 32'd0;
            BRU_select_imm <= 26'd0;
            BRU_select_op <= 4'd0;
            BRU_select_dest <= 7'd0;
            BRU_select_source1 <= 7'd0;
            BRU_select_source2 <= 7'd0;
            BRU_select_ROB_ID <= 6'd0;
        end
        else case (grant_excute)
            4'b0001: begin
                BRU_select_vld <= 1'b1;
                BRU_select_dest_en <= BRU_IQ_dest_en[0];
                BRU_select_PC <= BRU_IQ_PC[0];
                BRU_select_target_PC <= BRU_IQ_target_PC[0];
                BRU_select_imm <= BRU_IQ_imm[0];
                BRU_select_op <= BRU_IQ_op[0];
                BRU_select_dest <= BRU_IQ_dest[0];
                BRU_select_source1 <= BRU_IQ_source1[0];
                BRU_select_source2 <= BRU_IQ_source2[0];
                BRU_select_ROB_ID <= BRU_IQ_ROB_ID[0];
            end
            4'b0010: begin
                BRU_select_vld <= 1'b1;
                BRU_select_dest_en <= BRU_IQ_dest_en[1];
                BRU_select_PC <= BRU_IQ_PC[1];
                BRU_select_target_PC <= BRU_IQ_target_PC[1];
                BRU_select_imm <= BRU_IQ_imm[1];
                BRU_select_op <= BRU_IQ_op[1];
                BRU_select_dest <= BRU_IQ_dest[1];
                BRU_select_source1 <= BRU_IQ_source1[1];
                BRU_select_source2 <= BRU_IQ_source2[1];
                BRU_select_ROB_ID <= BRU_IQ_ROB_ID[1];
            end
            4'b0100: begin
                BRU_select_vld <= 1'b1;
                BRU_select_dest_en <= BRU_IQ_dest_en[2];
                BRU_select_PC <= BRU_IQ_PC[2];
                BRU_select_target_PC <= BRU_IQ_target_PC[2];
                BRU_select_imm <= BRU_IQ_imm[2];
                BRU_select_op <= BRU_IQ_op[2];
                BRU_select_dest <= BRU_IQ_dest[2];
                BRU_select_source1 <= BRU_IQ_source1[2];
                BRU_select_source2 <= BRU_IQ_source2[2];
                BRU_select_ROB_ID <= BRU_IQ_ROB_ID[2];
            end
            4'b1000: begin
                BRU_select_vld <= 1'b1;
                BRU_select_dest_en <= BRU_IQ_dest_en[3];
                BRU_select_PC <= BRU_IQ_PC[3];
                BRU_select_target_PC <= BRU_IQ_target_PC[3];
                BRU_select_imm <= BRU_IQ_imm[3];
                BRU_select_op <= BRU_IQ_op[3];
                BRU_select_dest <= BRU_IQ_dest[3];
                BRU_select_source1 <= BRU_IQ_source1[3];
                BRU_select_source2 <= BRU_IQ_source2[3];
                BRU_select_ROB_ID <= BRU_IQ_ROB_ID[3];
            end
            default: BRU_select_vld <= 1'b0;
        endcase 
    end
    
endmodule