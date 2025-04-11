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
    input       [5:0]   inst0_PR_dest,
    input       [5:0]   inst0_PR_source1,
    input       [5:0]   inst0_PR_source2,
    input       [3:0]   inst0_AGU_op,
    input       [16:0]  inst0_AGU_imm,
    input       [5:0]   inst0_ROB_ID,

    input               inst1_AGU_en,
    input               inst1_PR_dest_en,
    input               inst1_PR_source1_en,
    input               inst1_PR_source2_en,
    input               inst1_PR_source1_rdy,
    input               inst1_PR_source2_rdy,
    input       [5:0]   inst1_PR_dest,
    input       [5:0]   inst1_PR_source1,
    input       [5:0]   inst1_PR_source2,
    input       [3:0]   inst1_AGU_op,
    input       [16:0]  inst1_AGU_imm,
    input       [5:0]   inst1_ROB_ID,

    input               inst2_AGU_en,
    input               inst2_PR_dest_en,
    input               inst2_PR_source1_en,
    input               inst2_PR_source2_en,
    input               inst2_PR_source1_rdy,
    input               inst2_PR_source2_rdy,
    input       [5:0]   inst2_PR_dest,
    input       [5:0]   inst2_PR_source1,
    input       [5:0]   inst2_PR_source2,
    input       [3:0]   inst2_AGU_op,
    input       [16:0]  inst2_AGU_imm,
    input       [5:0]   inst2_ROB_ID,

    input               inst3_AGU_en,
    input               inst3_PR_dest_en,
    input               inst3_PR_source1_en,
    input               inst3_PR_source2_en,
    input               inst3_PR_source1_rdy,
    input               inst3_PR_source2_rdy,
    input       [5:0]   inst3_PR_dest,
    input       [5:0]   inst3_PR_source1,
    input       [5:0]   inst3_PR_source2,
    input       [3:0]   inst3_AGU_op,
    input       [16:0]  inst3_AGU_imm,
    input       [5:0]   inst3_ROB_ID,

    output              wr_AGU_IQ_pause,
    input               wr_pause,

    input       [5:0]   dest_ALU0,
    input       [5:0]   dest_ALU1,
    input       [5:0]   dest_AGU,
    input       [5:0]   dest_BRU,

    output  reg         AGU_select_vld,
    output  reg [3:0]   AGU_select_op,
    output  reg [16:0]  AGU_select_imm,
    output  reg         AGU_select_dest_en,
    output  reg [5:0]   AGU_select_dest,
    output  reg [5:0]   AGU_select_source1,
    output  reg [5:0]   AGU_select_source2,
    output  reg [5:0]   AGU_select_ROB_ID
);
    reg [7:0]   AGU_IQ_vld;
    reg [7:0]   AGU_IQ_dest_en;
    reg [7:0]   AGU_IQ_source1_en;
    reg [7:0]   AGU_IQ_source1_rdy;
    reg [7:0]   AGU_IQ_source2_en;
    reg [7:0]   AGU_IQ_source2_rdy;
    reg [5:0]   AGU_IQ_dest    [7:0];
    reg [5:0]   AGU_IQ_source1 [7:0];
    reg [5:0]   AGU_IQ_source2 [7:0];
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
    wire        entry0_ready;
    reg         grant;      // can excute

    assign room_need = inst0_AGU_en + inst1_AGU_en + inst2_AGU_en + inst3_AGU_en;
    assign room_have = (!AGU_IQ_vld[0]) + (!AGU_IQ_vld[1]) + (!AGU_IQ_vld[2]) + (!AGU_IQ_vld[3]) + 
                       (!AGU_IQ_vld[4]) + (!AGU_IQ_vld[5]) + (!AGU_IQ_vld[6]) + (!AGU_IQ_vld[7]) +
                       grant;

    assign wr_AGU_IQ_pause = (room_need > room_have);

    assign converse_vld = {AGU_IQ_vld[0], AGU_IQ_vld[1], AGU_IQ_vld[2], AGU_IQ_vld[3], 
                           AGU_IQ_vld[4], AGU_IQ_vld[5], AGU_IQ_vld[6], AGU_IQ_vld[7]};
    assign converse_last_vld = converse_vld & ((~converse_vld) + 1);
    assign last_vld = {converse_last_vld[0], converse_last_vld[1], converse_last_vld[2], converse_last_vld[3], 
                       converse_last_vld[4], converse_last_vld[5], converse_last_vld[6], converse_last_vld[7]};

    assign first_wr_onehot = grant ? last_vld : ((last_vld == 8'd0) ? 8'd1 : (last_vld << 1));

    assign entry0_ready = AGU_IQ_vld[0] & ((!AGU_IQ_source1_en[0]) | (AGU_IQ_source1_en[0] & AGU_IQ_source1_rdy[0])) & 
                                          ((!AGU_IQ_source2_en[0]) | (AGU_IQ_source2_en[0] & AGU_IQ_source2_rdy[0]));

    always @(*) begin       // grant
        if(!entry0_ready)
            grant = 1'b0;
        else begin
            if(AGU_busy)
                grant = 1'b0;
            else case (AGU_IQ_op[0])
                4'b0000: grant = (!INVTLB_already);
                4'b0001: grant = (!CACOP_already);
                default: grant = 1'b1;
            endcase
        end
    end 

    always @(*) begin       // wr_en
        if(wr_pause)
            wr_en = 8'd0;
        else case (first_wr_onehot)
            8'b00000001: 
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b00000001;
                    4'd2: wr_en = 8'b00000011;
                    4'd3: wr_en = 8'b00000111;
                    4'd4: wr_en = 8'b00001111;
                    default: wr_en = 8'd0;
                endcase
            8'b00000010:
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b00000010;
                    4'd2: wr_en = 8'b00000110;
                    4'd3: wr_en = 8'b00001110;
                    4'd4: wr_en = 8'b00011110;
                    default: wr_en = 8'd0;
                endcase
            8'b00000100: 
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b00000100;
                    4'd2: wr_en = 8'b00001100;
                    4'd3: wr_en = 8'b00011100;
                    4'd4: wr_en = 8'b00111100;
                    default: wr_en = 8'd0;
                endcase
            8'b00001000:
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b00001000;
                    4'd2: wr_en = 8'b00011000;
                    4'd3: wr_en = 8'b00111000;
                    4'd4: wr_en = 8'b01111000;
                    default: wr_en = 8'd0;
                endcase
            8'b00010000:
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b00010000;
                    4'd2: wr_en = 8'b00110000;
                    4'd3: wr_en = 8'b01110000;
                    4'd4: wr_en = 8'b11110000;
                    default: wr_en = 8'd0;
                endcase
            8'b00100000:
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b00100000;
                    4'd2: wr_en = 8'b01100000;
                    4'd3: wr_en = 8'b11100000;
                    default: wr_en = 8'd0;
                endcase
            8'b01000000:
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b01000000;
                    4'd2: wr_en = 8'b11000000;
                    default: wr_en = 8'd0;
                endcase
            8'b10000000:
                case (room_need)
                    4'd0: wr_en = 8'd0;
                    4'd1: wr_en = 8'b10000000;
                    default: wr_en = 8'd0;
                endcase
            default: wr_en = 8'd0;
        endcase
    end

    always @(*) begin       // wr_from[0]
        case (first_wr_onehot)
            8'b00000001: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
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
            8'b00000001: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
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
            8'b00000010: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
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
            8'b00000001: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[2] = 2'b10;
                4'b1110: wr_from[2] = 2'b10;
                4'b1101: wr_from[2] = 2'b11;
                4'b1011: wr_from[2] = 2'b11;
                4'b0111: wr_from[2] = 2'b11;
                default: wr_from[2] = 2'b00;
            endcase
            8'b00000010: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
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
            8'b00000100: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
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
            8'b00000001: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            8'b00000010: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[3] = 2'b10;
                4'b1110: wr_from[3] = 2'b10;
                4'b1101: wr_from[3] = 2'b11;
                4'b1011: wr_from[3] = 2'b11;
                4'b0111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            8'b00000100: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
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
            8'b00001000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1???: wr_from[3] = 2'b00;
                4'b01??: wr_from[3] = 2'b01;
                4'b001?: wr_from[3] = 2'b10;
                4'b0001: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            default: wr_from[3] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[4]
        case (first_wr_onehot)
            8'b00000010: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[4] = 2'b11;
                default: wr_from[4] = 2'b00;
            endcase
            8'b00000100: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[4] = 2'b10;
                4'b1110: wr_from[4] = 2'b10;
                4'b1101: wr_from[4] = 2'b11;
                4'b1011: wr_from[4] = 2'b11;
                4'b0111: wr_from[4] = 2'b11;
                default: wr_from[4] = 2'b00;
            endcase
            8'b00001000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[4] = 2'b01;
                4'b1110: wr_from[4] = 2'b01;
                4'b1101: wr_from[4] = 2'b01;
                4'b1011: wr_from[4] = 2'b10;
                4'b0111: wr_from[4] = 2'b10;
                4'b1100: wr_from[4] = 2'b01;
                4'b1010: wr_from[4] = 2'b10;
                4'b0110: wr_from[4] = 2'b10;
                4'b1001: wr_from[4] = 2'b11;
                4'b0101: wr_from[4] = 2'b11;
                4'b0011: wr_from[4] = 2'b11;
                default: wr_from[4] = 2'b00;
            endcase
            8'b00010000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1???: wr_from[4] = 2'b00;
                4'b01??: wr_from[4] = 2'b01;
                4'b001?: wr_from[4] = 2'b10;
                4'b0001: wr_from[4] = 2'b11;
                default: wr_from[4] = 2'b00;
            endcase
            default: wr_from[4] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[5]
        case (first_wr_onehot)
            8'b00000100: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[5] = 2'b11;
                default: wr_from[5] = 2'b00;
            endcase
            8'b00001000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[5] = 2'b10;
                4'b1110: wr_from[5] = 2'b10;
                4'b1101: wr_from[5] = 2'b11;
                4'b1011: wr_from[5] = 2'b11;
                4'b0111: wr_from[5] = 2'b11;
                default: wr_from[5] = 2'b00;
            endcase
            8'b00010000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[5] = 2'b01;
                4'b1110: wr_from[5] = 2'b01;
                4'b1101: wr_from[5] = 2'b01;
                4'b1011: wr_from[5] = 2'b10;
                4'b0111: wr_from[5] = 2'b10;
                4'b1100: wr_from[5] = 2'b01;
                4'b1010: wr_from[5] = 2'b10;
                4'b0110: wr_from[5] = 2'b10;
                4'b1001: wr_from[5] = 2'b11;
                4'b0101: wr_from[5] = 2'b11;
                4'b0011: wr_from[5] = 2'b11;
                default: wr_from[5] = 2'b00;
            endcase
            8'b00100000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1???: wr_from[5] = 2'b00;
                4'b01??: wr_from[5] = 2'b01;
                4'b001?: wr_from[5] = 2'b10;
                4'b0001: wr_from[5] = 2'b11;
                default: wr_from[5] = 2'b00;
            endcase
            default: wr_from[5] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[6]
        case (first_wr_onehot)
            8'b00001000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[6] = 2'b11;
                default: wr_from[6] = 2'b00;
            endcase
            8'b00010000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[6] = 2'b10;
                4'b1110: wr_from[6] = 2'b10;
                4'b1101: wr_from[6] = 2'b11;
                4'b1011: wr_from[6] = 2'b11;
                4'b0111: wr_from[6] = 2'b11;
                default: wr_from[6] = 2'b00;
            endcase
            8'b00100000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[6] = 2'b01;
                4'b1110: wr_from[6] = 2'b01;
                4'b1101: wr_from[6] = 2'b01;
                4'b1011: wr_from[6] = 2'b10;
                4'b0111: wr_from[6] = 2'b10;
                4'b1100: wr_from[6] = 2'b01;
                4'b1010: wr_from[6] = 2'b10;
                4'b0110: wr_from[6] = 2'b10;
                4'b1001: wr_from[6] = 2'b11;
                4'b0101: wr_from[6] = 2'b11;
                4'b0011: wr_from[6] = 2'b11;
                default: wr_from[6] = 2'b00;
            endcase
            8'b01000000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1???: wr_from[6] = 2'b00;
                4'b01??: wr_from[6] = 2'b01;
                4'b001?: wr_from[6] = 2'b10;
                4'b0001: wr_from[6] = 2'b11;
                default: wr_from[6] = 2'b00;
            endcase
            default: wr_from[6] = 2'b00;
        endcase
    end
    always @(*) begin       // wr_from[7]
        case (first_wr_onehot)
            8'b00010000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[7] = 2'b11;
                default: wr_from[7] = 2'b00;
            endcase
            8'b00100000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[7] = 2'b10;
                4'b1110: wr_from[7] = 2'b10;
                4'b1101: wr_from[7] = 2'b11;
                4'b1011: wr_from[7] = 2'b11;
                4'b0111: wr_from[7] = 2'b11;
                default: wr_from[7] = 2'b00;
            endcase
            8'b01000000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1111: wr_from[7] = 2'b01;
                4'b1110: wr_from[7] = 2'b01;
                4'b1101: wr_from[7] = 2'b01;
                4'b1011: wr_from[7] = 2'b10;
                4'b0111: wr_from[7] = 2'b10;
                4'b1100: wr_from[7] = 2'b01;
                4'b1010: wr_from[7] = 2'b10;
                4'b0110: wr_from[7] = 2'b10;
                4'b1001: wr_from[7] = 2'b11;
                4'b0101: wr_from[7] = 2'b11;
                4'b0011: wr_from[7] = 2'b11;
                default: wr_from[7] = 2'b00;
            endcase
            8'b10000000: casez ({inst0_AGU_en, inst1_AGU_en, inst2_AGU_en, inst3_AGU_en})
                4'b1???: wr_from[7] = 2'b00;
                4'b01??: wr_from[7] = 2'b01;
                4'b001?: wr_from[7] = 2'b10;
                4'b0001: wr_from[7] = 2'b11;
                default: wr_from[7] = 2'b00;
            endcase
            default: wr_from[7] = 2'b00;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin        // entry0
        if((!rst_n) || flush)begin
            AGU_IQ_vld[0] <= 1'b0;
            AGU_IQ_dest_en[0] <= 1'b0;
            AGU_IQ_source1_en[0] <= 1'b0;
            AGU_IQ_source1_rdy[0] <= 1'b0;
            AGU_IQ_source2_en[0] <= 1'b0;
            AGU_IQ_source2_rdy[0] <= 1'b0;
        end
        else if(wr_en[0])begin
            case (wr_from[0])
                2'b00: begin
                    AGU_IQ_vld[0] <= 1'b1;
                    AGU_IQ_dest_en[0] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[0] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[0] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[0] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[0] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[0] <= inst0_PR_dest;
                    AGU_IQ_source1[0] <= inst0_PR_source1;
                    AGU_IQ_source2[0] <= inst0_PR_source2;
                    AGU_IQ_op[0] <= inst0_AGU_op;
                    AGU_IQ_imm[0] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[0] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[0] <= 1'b1;
                    AGU_IQ_dest_en[0] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[0] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[0] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[0] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[0] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[0] <= inst1_PR_dest;
                    AGU_IQ_source1[0] <= inst1_PR_source1;
                    AGU_IQ_source2[0] <= inst1_PR_source2;
                    AGU_IQ_op[0] <= inst1_AGU_op;
                    AGU_IQ_imm[0] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[0] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[0] <= 1'b1;
                    AGU_IQ_dest_en[0] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[0] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[0] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[0] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[0] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[0] <= inst2_PR_dest;
                    AGU_IQ_source1[0] <= inst2_PR_source1;
                    AGU_IQ_source2[0] <= inst2_PR_source2;
                    AGU_IQ_op[0] <= inst2_AGU_op;
                    AGU_IQ_imm[0] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[0] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[0] <= 1'b1;
                    AGU_IQ_dest_en[0] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[0] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[0] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[0] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[0] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[0] <= inst3_PR_dest;
                    AGU_IQ_source1[0] <= inst3_PR_source1;
                    AGU_IQ_source2[0] <= inst3_PR_source2;
                    AGU_IQ_op[0] <= inst3_AGU_op;
                    AGU_IQ_imm[0] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[0] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[0] <= AGU_IQ_vld[1];
            AGU_IQ_dest_en[0] <= AGU_IQ_dest_en[1];
            AGU_IQ_source1_en[0] <= AGU_IQ_source1_en[1];
            AGU_IQ_source2_en[0] <= AGU_IQ_source2_en[1];
            AGU_IQ_dest[0] <= AGU_IQ_dest[1];
            AGU_IQ_source1[0] <= AGU_IQ_source1[1];
            AGU_IQ_source2[0] <= AGU_IQ_source2[1];
            AGU_IQ_op[0] <= AGU_IQ_op[1];
            AGU_IQ_imm[0] <= AGU_IQ_imm[1];
            AGU_IQ_ROB_ID[0] <= AGU_IQ_ROB_ID[1];
            if((AGU_IQ_source1[1] == dest_ALU1) || (AGU_IQ_source1[1] == dest_ALU0) ||
               (AGU_IQ_source1[1] == dest_BRU)  || (AGU_IQ_source1[1] == dest_AGU))
                AGU_IQ_source1_rdy[0] <= 1'b1;
            if((AGU_IQ_source2[1] == dest_ALU1) || (AGU_IQ_source2[1] == dest_ALU0) ||
               (AGU_IQ_source2[1] == dest_BRU)  || (AGU_IQ_source2[1] == dest_AGU))
                AGU_IQ_source2_rdy[0] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[0] == dest_ALU1) || (AGU_IQ_source1[0] == dest_ALU0) ||
               (AGU_IQ_source1[0] == dest_BRU)  || (AGU_IQ_source1[0] == dest_AGU))
                AGU_IQ_source1_rdy[0] <= 1'b1;
            if((AGU_IQ_source2[0] == dest_ALU1) || (AGU_IQ_source2[0] == dest_ALU0) ||
               (AGU_IQ_source2[0] == dest_BRU)  || (AGU_IQ_source2[0] == dest_AGU))
                AGU_IQ_source2_rdy[0] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry1
        if((!rst_n) || flush)begin
            AGU_IQ_vld[1] <= 1'b0;
            AGU_IQ_dest_en[1] <= 1'b0;
            AGU_IQ_source1_en[1] <= 1'b0;
            AGU_IQ_source1_rdy[1] <= 1'b0;
            AGU_IQ_source2_en[1] <= 1'b0;
            AGU_IQ_source2_rdy[1] <= 1'b0;
        end
        else if(wr_en[1])begin
            case (wr_from[1])
                2'b00: begin
                    AGU_IQ_vld[1] <= 1'b1;
                    AGU_IQ_dest_en[1] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[1] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[1] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[1] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[1] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[1] <= inst0_PR_dest;
                    AGU_IQ_source1[1] <= inst0_PR_source1;
                    AGU_IQ_source2[1] <= inst0_PR_source2;
                    AGU_IQ_op[1] <= inst0_AGU_op;
                    AGU_IQ_imm[1] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[1] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[1] <= 1'b1;
                    AGU_IQ_dest_en[1] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[1] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[1] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[1] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[1] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[1] <= inst1_PR_dest;
                    AGU_IQ_source1[1] <= inst1_PR_source1;
                    AGU_IQ_source2[1] <= inst1_PR_source2;
                    AGU_IQ_op[1] <= inst1_AGU_op;
                    AGU_IQ_imm[1] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[1] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[1] <= 1'b1;
                    AGU_IQ_dest_en[1] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[1] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[1] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[1] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[1] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[1] <= inst2_PR_dest;
                    AGU_IQ_source1[1] <= inst2_PR_source1;
                    AGU_IQ_source2[1] <= inst2_PR_source2;
                    AGU_IQ_op[1] <= inst2_AGU_op;
                    AGU_IQ_imm[1] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[1] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[1] <= 1'b1;
                    AGU_IQ_dest_en[1] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[1] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[1] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[1] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[1] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[1] <= inst3_PR_dest;
                    AGU_IQ_source1[1] <= inst3_PR_source1;
                    AGU_IQ_source2[1] <= inst3_PR_source2;
                    AGU_IQ_op[1] <= inst3_AGU_op;
                    AGU_IQ_imm[1] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[1] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[1] <= AGU_IQ_vld[2];
            AGU_IQ_dest_en[1] <= AGU_IQ_dest_en[2];
            AGU_IQ_source1_en[1] <= AGU_IQ_source1_en[2];
            AGU_IQ_source2_en[1] <= AGU_IQ_source2_en[2];
            AGU_IQ_dest[1] <= AGU_IQ_dest[2];
            AGU_IQ_source1[1] <= AGU_IQ_source1[2];
            AGU_IQ_source2[1] <= AGU_IQ_source2[2];
            AGU_IQ_op[1] <= AGU_IQ_op[2];
            AGU_IQ_imm[1] <= AGU_IQ_imm[2];
            AGU_IQ_ROB_ID[1] <= AGU_IQ_ROB_ID[2];
            if((AGU_IQ_source1[2] == dest_ALU1) || (AGU_IQ_source1[2] == dest_ALU0) ||
               (AGU_IQ_source1[2] == dest_BRU)  || (AGU_IQ_source1[2] == dest_AGU))
                AGU_IQ_source1_rdy[1] <= 1'b1;
            if((AGU_IQ_source2[2] == dest_ALU1) || (AGU_IQ_source2[2] == dest_ALU0) ||
               (AGU_IQ_source2[2] == dest_BRU)  || (AGU_IQ_source2[2] == dest_AGU))
                AGU_IQ_source2_rdy[1] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[1] == dest_ALU1) || (AGU_IQ_source1[1] == dest_ALU0) ||
               (AGU_IQ_source1[1] == dest_BRU)  || (AGU_IQ_source1[1] == dest_AGU))
                AGU_IQ_source1_rdy[1] <= 1'b1;
            if((AGU_IQ_source2[1] == dest_ALU1) || (AGU_IQ_source2[1] == dest_ALU0) ||
               (AGU_IQ_source2[1] == dest_BRU)  || (AGU_IQ_source2[1] == dest_AGU))
                AGU_IQ_source2_rdy[1] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry2
        if((!rst_n) || flush)begin
            AGU_IQ_vld[2] <= 1'b0;
            AGU_IQ_dest_en[2] <= 1'b0;
            AGU_IQ_source1_en[2] <= 1'b0;
            AGU_IQ_source1_rdy[2] <= 1'b0;
            AGU_IQ_source2_en[2] <= 1'b0;
            AGU_IQ_source2_rdy[2] <= 1'b0;
        end
        else if(wr_en[2])begin
            case (wr_from[2])
                2'b00: begin
                    AGU_IQ_vld[2] <= 1'b1;
                    AGU_IQ_dest_en[2] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[2] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[2] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[2] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[2] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[2] <= inst0_PR_dest;
                    AGU_IQ_source1[2] <= inst0_PR_source1;
                    AGU_IQ_source2[2] <= inst0_PR_source2;
                    AGU_IQ_op[2] <= inst0_AGU_op;
                    AGU_IQ_imm[2] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[2] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[2] <= 1'b1;
                    AGU_IQ_dest_en[2] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[2] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[2] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[2] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[2] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[2] <= inst1_PR_dest;
                    AGU_IQ_source1[2] <= inst1_PR_source1;
                    AGU_IQ_source2[2] <= inst1_PR_source2;
                    AGU_IQ_op[2] <= inst1_AGU_op;
                    AGU_IQ_imm[2] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[2] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[2] <= 1'b1;
                    AGU_IQ_dest_en[2] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[2] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[2] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[2] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[2] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[2] <= inst2_PR_dest;
                    AGU_IQ_source1[2] <= inst2_PR_source1;
                    AGU_IQ_source2[2] <= inst2_PR_source2;
                    AGU_IQ_op[2] <= inst2_AGU_op;
                    AGU_IQ_imm[2] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[2] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[2] <= 1'b1;
                    AGU_IQ_dest_en[2] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[2] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[2] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[2] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[2] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[2] <= inst3_PR_dest;
                    AGU_IQ_source1[2] <= inst3_PR_source1;
                    AGU_IQ_source2[2] <= inst3_PR_source2;
                    AGU_IQ_op[2] <= inst3_AGU_op;
                    AGU_IQ_imm[2] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[2] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[2] <= AGU_IQ_vld[3];
            AGU_IQ_dest_en[2] <= AGU_IQ_dest_en[3];
            AGU_IQ_source1_en[2] <= AGU_IQ_source1_en[3];
            AGU_IQ_source2_en[2] <= AGU_IQ_source2_en[3];
            AGU_IQ_dest[2] <= AGU_IQ_dest[3];
            AGU_IQ_source1[2] <= AGU_IQ_source1[3];
            AGU_IQ_source2[2] <= AGU_IQ_source2[3];
            AGU_IQ_op[2] <= AGU_IQ_op[3];
            AGU_IQ_imm[2] <= AGU_IQ_imm[3];
            AGU_IQ_ROB_ID[2] <= AGU_IQ_ROB_ID[3];
            if((AGU_IQ_source1[3] == dest_ALU1) || (AGU_IQ_source1[3] == dest_ALU0) ||
               (AGU_IQ_source1[3] == dest_BRU)  || (AGU_IQ_source1[3] == dest_AGU))
                AGU_IQ_source1_rdy[2] <= 1'b1;
            if((AGU_IQ_source2[3] == dest_ALU1) || (AGU_IQ_source2[3] == dest_ALU0) ||
               (AGU_IQ_source2[3] == dest_BRU)  || (AGU_IQ_source2[3] == dest_AGU))
                AGU_IQ_source2_rdy[2] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[2] == dest_ALU1) || (AGU_IQ_source1[2] == dest_ALU0) ||
               (AGU_IQ_source1[2] == dest_BRU)  || (AGU_IQ_source1[2] == dest_AGU))
                AGU_IQ_source1_rdy[2] <= 1'b1;
            if((AGU_IQ_source2[2] == dest_ALU1) || (AGU_IQ_source2[2] == dest_ALU0) ||
               (AGU_IQ_source2[2] == dest_BRU)  || (AGU_IQ_source2[2] == dest_AGU))
                AGU_IQ_source2_rdy[2] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry3
        if((!rst_n) || flush)begin
            AGU_IQ_vld[3] <= 1'b0;
            AGU_IQ_dest_en[3] <= 1'b0;
            AGU_IQ_source1_en[3] <= 1'b0;
            AGU_IQ_source1_rdy[3] <= 1'b0;
            AGU_IQ_source2_en[3] <= 1'b0;
            AGU_IQ_source2_rdy[3] <= 1'b0;
        end
        else if(wr_en[3])begin
            case (wr_from[3])
                2'b00: begin
                    AGU_IQ_vld[3] <= 1'b1;
                    AGU_IQ_dest_en[3] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[3] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[3] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[3] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[3] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[3] <= inst0_PR_dest;
                    AGU_IQ_source1[3] <= inst0_PR_source1;
                    AGU_IQ_source2[3] <= inst0_PR_source2;
                    AGU_IQ_op[3] <= inst0_AGU_op;
                    AGU_IQ_imm[3] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[3] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[3] <= 1'b1;
                    AGU_IQ_dest_en[3] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[3] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[3] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[3] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[3] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[3] <= inst1_PR_dest;
                    AGU_IQ_source1[3] <= inst1_PR_source1;
                    AGU_IQ_source2[3] <= inst1_PR_source2;
                    AGU_IQ_op[3] <= inst1_AGU_op;
                    AGU_IQ_imm[3] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[3] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[3] <= 1'b1;
                    AGU_IQ_dest_en[3] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[3] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[3] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[3] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[3] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[3] <= inst2_PR_dest;
                    AGU_IQ_source1[3] <= inst2_PR_source1;
                    AGU_IQ_source2[3] <= inst2_PR_source2;
                    AGU_IQ_op[3] <= inst2_AGU_op;
                    AGU_IQ_imm[3] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[3] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[3] <= 1'b1;
                    AGU_IQ_dest_en[3] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[3] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[3] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[3] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[3] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[3] <= inst3_PR_dest;
                    AGU_IQ_source1[3] <= inst3_PR_source1;
                    AGU_IQ_source2[3] <= inst3_PR_source2;
                    AGU_IQ_op[3] <= inst3_AGU_op;
                    AGU_IQ_imm[3] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[3] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[3] <= AGU_IQ_vld[4];
            AGU_IQ_dest_en[3] <= AGU_IQ_dest_en[4];
            AGU_IQ_source1_en[3] <= AGU_IQ_source1_en[4];
            AGU_IQ_source2_en[3] <= AGU_IQ_source2_en[4];
            AGU_IQ_dest[3] <= AGU_IQ_dest[4];
            AGU_IQ_source1[3] <= AGU_IQ_source1[4];
            AGU_IQ_source2[3] <= AGU_IQ_source2[4];
            AGU_IQ_op[3] <= AGU_IQ_op[4];
            AGU_IQ_imm[3] <= AGU_IQ_imm[4];
            AGU_IQ_ROB_ID[3] <= AGU_IQ_ROB_ID[4];
            if((AGU_IQ_source1[4] == dest_ALU1) || (AGU_IQ_source1[4] == dest_ALU0) ||
               (AGU_IQ_source1[4] == dest_BRU)  || (AGU_IQ_source1[4] == dest_AGU))
                AGU_IQ_source1_rdy[3] <= 1'b1;
            if((AGU_IQ_source2[4] == dest_ALU1) || (AGU_IQ_source2[4] == dest_ALU0) ||
               (AGU_IQ_source2[4] == dest_BRU)  || (AGU_IQ_source2[4] == dest_AGU))
                AGU_IQ_source2_rdy[3] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[3] == dest_ALU1) || (AGU_IQ_source1[3] == dest_ALU0) ||
               (AGU_IQ_source1[3] == dest_BRU)  || (AGU_IQ_source1[3] == dest_AGU))
                AGU_IQ_source1_rdy[3] <= 1'b1;
            if((AGU_IQ_source2[3] == dest_ALU1) || (AGU_IQ_source2[3] == dest_ALU0) ||
               (AGU_IQ_source2[3] == dest_BRU)  || (AGU_IQ_source2[3] == dest_AGU))
                AGU_IQ_source2_rdy[3] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry4
        if((!rst_n) || flush)begin
            AGU_IQ_vld[4] <= 1'b0;
            AGU_IQ_dest_en[4] <= 1'b0;
            AGU_IQ_source1_en[4] <= 1'b0;
            AGU_IQ_source1_rdy[4] <= 1'b0;
            AGU_IQ_source2_en[4] <= 1'b0;
            AGU_IQ_source2_rdy[4] <= 1'b0;
        end
        else if(wr_en[4])begin
            case (wr_from[4])
                2'b00: begin
                    AGU_IQ_vld[4] <= 1'b1;
                    AGU_IQ_dest_en[4] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[4] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[4] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[4] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[4] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[4] <= inst0_PR_dest;
                    AGU_IQ_source1[4] <= inst0_PR_source1;
                    AGU_IQ_source2[4] <= inst0_PR_source2;
                    AGU_IQ_op[4] <= inst0_AGU_op;
                    AGU_IQ_imm[4] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[4] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[4] <= 1'b1;
                    AGU_IQ_dest_en[4] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[4] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[4] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[4] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[4] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[4] <= inst1_PR_dest;
                    AGU_IQ_source1[4] <= inst1_PR_source1;
                    AGU_IQ_source2[4] <= inst1_PR_source2;
                    AGU_IQ_op[4] <= inst1_AGU_op;
                    AGU_IQ_imm[4] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[4] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[4] <= 1'b1;
                    AGU_IQ_dest_en[4] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[4] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[4] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[4] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[4] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[4] <= inst2_PR_dest;
                    AGU_IQ_source1[4] <= inst2_PR_source1;
                    AGU_IQ_source2[4] <= inst2_PR_source2;
                    AGU_IQ_op[4] <= inst2_AGU_op;
                    AGU_IQ_imm[4] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[4] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[4] <= 1'b1;
                    AGU_IQ_dest_en[4] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[4] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[4] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[4] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[4] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[4] <= inst3_PR_dest;
                    AGU_IQ_source1[4] <= inst3_PR_source1;
                    AGU_IQ_source2[4] <= inst3_PR_source2;
                    AGU_IQ_op[4] <= inst3_AGU_op;
                    AGU_IQ_imm[4] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[4] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[4] <= AGU_IQ_vld[5];
            AGU_IQ_dest_en[4] <= AGU_IQ_dest_en[5];
            AGU_IQ_source1_en[4] <= AGU_IQ_source1_en[5];
            AGU_IQ_source2_en[4] <= AGU_IQ_source2_en[5];
            AGU_IQ_dest[4] <= AGU_IQ_dest[5];
            AGU_IQ_source1[4] <= AGU_IQ_source1[5];
            AGU_IQ_source2[4] <= AGU_IQ_source2[5];
            AGU_IQ_op[4] <= AGU_IQ_op[5];
            AGU_IQ_imm[4] <= AGU_IQ_imm[5];
            AGU_IQ_ROB_ID[4] <= AGU_IQ_ROB_ID[5];
            if((AGU_IQ_source1[5] == dest_ALU1) || (AGU_IQ_source1[5] == dest_ALU0) ||
               (AGU_IQ_source1[5] == dest_BRU)  || (AGU_IQ_source1[5] == dest_AGU))
                AGU_IQ_source1_rdy[4] <= 1'b1;
            if((AGU_IQ_source2[5] == dest_ALU1) || (AGU_IQ_source2[5] == dest_ALU0) ||
               (AGU_IQ_source2[5] == dest_BRU)  || (AGU_IQ_source2[5] == dest_AGU))
                AGU_IQ_source2_rdy[4] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[4] == dest_ALU1) || (AGU_IQ_source1[4] == dest_ALU0) ||
               (AGU_IQ_source1[4] == dest_BRU)  || (AGU_IQ_source1[4] == dest_AGU))
                AGU_IQ_source1_rdy[4] <= 1'b1;
            if((AGU_IQ_source2[4] == dest_ALU1) || (AGU_IQ_source2[4] == dest_ALU0) ||
               (AGU_IQ_source2[4] == dest_BRU)  || (AGU_IQ_source2[4] == dest_AGU))
                AGU_IQ_source2_rdy[4] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry5
        if((!rst_n) || flush)begin
            AGU_IQ_vld[5] <= 1'b0;
            AGU_IQ_dest_en[5] <= 1'b0;
            AGU_IQ_source1_en[5] <= 1'b0;
            AGU_IQ_source1_rdy[5] <= 1'b0;
            AGU_IQ_source2_en[5] <= 1'b0;
            AGU_IQ_source2_rdy[5] <= 1'b0;
        end
        else if(wr_en[5])begin
            case (wr_from[5])
                2'b00: begin
                    AGU_IQ_vld[5] <= 1'b1;
                    AGU_IQ_dest_en[5] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[5] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[5] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[5] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[5] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[5] <= inst0_PR_dest;
                    AGU_IQ_source1[5] <= inst0_PR_source1;
                    AGU_IQ_source2[5] <= inst0_PR_source2;
                    AGU_IQ_op[5] <= inst0_AGU_op;
                    AGU_IQ_imm[5] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[5] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[5] <= 1'b1;
                    AGU_IQ_dest_en[5] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[5] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[5] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[5] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[5] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[5] <= inst1_PR_dest;
                    AGU_IQ_source1[5] <= inst1_PR_source1;
                    AGU_IQ_source2[5] <= inst1_PR_source2;
                    AGU_IQ_op[5] <= inst1_AGU_op;
                    AGU_IQ_imm[5] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[5] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[5] <= 1'b1;
                    AGU_IQ_dest_en[5] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[5] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[5] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[5] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[5] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[5] <= inst2_PR_dest;
                    AGU_IQ_source1[5] <= inst2_PR_source1;
                    AGU_IQ_source2[5] <= inst2_PR_source2;
                    AGU_IQ_op[5] <= inst2_AGU_op;
                    AGU_IQ_imm[5] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[5] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[5] <= 1'b1;
                    AGU_IQ_dest_en[5] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[5] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[5] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[5] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[5] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[5] <= inst3_PR_dest;
                    AGU_IQ_source1[5] <= inst3_PR_source1;
                    AGU_IQ_source2[5] <= inst3_PR_source2;
                    AGU_IQ_op[5] <= inst3_AGU_op;
                    AGU_IQ_imm[5] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[5] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[5] <= AGU_IQ_vld[6];
            AGU_IQ_dest_en[5] <= AGU_IQ_dest_en[6];
            AGU_IQ_source1_en[5] <= AGU_IQ_source1_en[6];
            AGU_IQ_source2_en[5] <= AGU_IQ_source2_en[6];
            AGU_IQ_dest[5] <= AGU_IQ_dest[6];
            AGU_IQ_source1[5] <= AGU_IQ_source1[6];
            AGU_IQ_source2[5] <= AGU_IQ_source2[6];
            AGU_IQ_op[5] <= AGU_IQ_op[6];
            AGU_IQ_imm[5] <= AGU_IQ_imm[6];
            AGU_IQ_ROB_ID[5] <= AGU_IQ_ROB_ID[6];
            if((AGU_IQ_source1[6] == dest_ALU1) || (AGU_IQ_source1[6] == dest_ALU0) ||
               (AGU_IQ_source1[6] == dest_BRU)  || (AGU_IQ_source1[6] == dest_AGU))
                AGU_IQ_source1_rdy[5] <= 1'b1;
            if((AGU_IQ_source2[6] == dest_ALU1) || (AGU_IQ_source2[6] == dest_ALU0) ||
               (AGU_IQ_source2[6] == dest_BRU)  || (AGU_IQ_source2[6] == dest_AGU))
                AGU_IQ_source2_rdy[5] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[5] == dest_ALU1) || (AGU_IQ_source1[5] == dest_ALU0) ||
               (AGU_IQ_source1[5] == dest_BRU)  || (AGU_IQ_source1[5] == dest_AGU))
                AGU_IQ_source1_rdy[5] <= 1'b1;
            if((AGU_IQ_source2[5] == dest_ALU1) || (AGU_IQ_source2[5] == dest_ALU0) ||
               (AGU_IQ_source2[5] == dest_BRU)  || (AGU_IQ_source2[5] == dest_AGU))
                AGU_IQ_source2_rdy[5] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry6
        if((!rst_n) || flush)begin
            AGU_IQ_vld[6] <= 1'b0;
            AGU_IQ_dest_en[6] <= 1'b0;
            AGU_IQ_source1_en[6] <= 1'b0;
            AGU_IQ_source1_rdy[6] <= 1'b0;
            AGU_IQ_source2_en[6] <= 1'b0;
            AGU_IQ_source2_rdy[6] <= 1'b0;
        end
        else if(wr_en[6])begin
            case (wr_from[6])
                2'b00: begin
                    AGU_IQ_vld[6] <= 1'b1;
                    AGU_IQ_dest_en[6] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[6] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[6] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[6] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[6] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[6] <= inst0_PR_dest;
                    AGU_IQ_source1[6] <= inst0_PR_source1;
                    AGU_IQ_source2[6] <= inst0_PR_source2;
                    AGU_IQ_op[6] <= inst0_AGU_op;
                    AGU_IQ_imm[6] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[6] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[6] <= 1'b1;
                    AGU_IQ_dest_en[6] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[6] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[6] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[6] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[6] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[6] <= inst1_PR_dest;
                    AGU_IQ_source1[6] <= inst1_PR_source1;
                    AGU_IQ_source2[6] <= inst1_PR_source2;
                    AGU_IQ_op[6] <= inst1_AGU_op;
                    AGU_IQ_imm[6] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[6] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[6] <= 1'b1;
                    AGU_IQ_dest_en[6] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[6] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[6] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[6] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[6] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[6] <= inst2_PR_dest;
                    AGU_IQ_source1[6] <= inst2_PR_source1;
                    AGU_IQ_source2[6] <= inst2_PR_source2;
                    AGU_IQ_op[6] <= inst2_AGU_op;
                    AGU_IQ_imm[6] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[6] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[6] <= 1'b1;
                    AGU_IQ_dest_en[6] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[6] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[6] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[6] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[6] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[6] <= inst3_PR_dest;
                    AGU_IQ_source1[6] <= inst3_PR_source1;
                    AGU_IQ_source2[6] <= inst3_PR_source2;
                    AGU_IQ_op[6] <= inst3_AGU_op;
                    AGU_IQ_imm[6] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[6] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[6] <= AGU_IQ_vld[7];
            AGU_IQ_dest_en[6] <= AGU_IQ_dest_en[7];
            AGU_IQ_source1_en[6] <= AGU_IQ_source1_en[7];
            AGU_IQ_source2_en[6] <= AGU_IQ_source2_en[7];
            AGU_IQ_dest[6] <= AGU_IQ_dest[7];
            AGU_IQ_source1[6] <= AGU_IQ_source1[7];
            AGU_IQ_source2[6] <= AGU_IQ_source2[7];
            AGU_IQ_op[6] <= AGU_IQ_op[7];
            AGU_IQ_imm[6] <= AGU_IQ_imm[7];
            AGU_IQ_ROB_ID[6] <= AGU_IQ_ROB_ID[7];
            if((AGU_IQ_source1[7] == dest_ALU1) || (AGU_IQ_source1[7] == dest_ALU0) ||
               (AGU_IQ_source1[7] == dest_BRU)  || (AGU_IQ_source1[7] == dest_AGU))
                AGU_IQ_source1_rdy[6] <= 1'b1;
            if((AGU_IQ_source2[7] == dest_ALU1) || (AGU_IQ_source2[7] == dest_ALU0) ||
               (AGU_IQ_source2[7] == dest_BRU)  || (AGU_IQ_source2[7] == dest_AGU))
                AGU_IQ_source2_rdy[6] <= 1'b1;
        end
        else begin
            if((AGU_IQ_source1[6] == dest_ALU1) || (AGU_IQ_source1[6] == dest_ALU0) ||
               (AGU_IQ_source1[6] == dest_BRU)  || (AGU_IQ_source1[6] == dest_AGU))
                AGU_IQ_source1_rdy[6] <= 1'b1;
            if((AGU_IQ_source2[6] == dest_ALU1) || (AGU_IQ_source2[6] == dest_ALU0) ||
               (AGU_IQ_source2[6] == dest_BRU)  || (AGU_IQ_source2[6] == dest_AGU))
                AGU_IQ_source2_rdy[6] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin        // entry7
        if((!rst_n) || flush)begin
            AGU_IQ_vld[7] <= 1'b0;
            AGU_IQ_dest_en[7] <= 1'b0;
            AGU_IQ_source1_en[7] <= 1'b0;
            AGU_IQ_source1_rdy[7] <= 1'b0;
            AGU_IQ_source2_en[7] <= 1'b0;
            AGU_IQ_source2_rdy[7] <= 1'b0;
        end
        else if(wr_en[7])begin
            case (wr_from[7])
                2'b00: begin
                    AGU_IQ_vld[7] <= 1'b1;
                    AGU_IQ_dest_en[7] <= inst0_PR_dest_en;
                    AGU_IQ_source1_en[7] <= inst0_PR_source1_en;
                    AGU_IQ_source1_rdy[7] <= inst0_PR_source1_rdy;
                    AGU_IQ_source2_en[7] <= inst0_PR_source2_en;
                    AGU_IQ_source2_rdy[7] <= inst0_PR_source2_rdy;
                    AGU_IQ_dest[7] <= inst0_PR_dest;
                    AGU_IQ_source1[7] <= inst0_PR_source1;
                    AGU_IQ_source2[7] <= inst0_PR_source2;
                    AGU_IQ_op[7] <= inst0_AGU_op;
                    AGU_IQ_imm[7] <= inst0_AGU_imm;
                    AGU_IQ_ROB_ID[7] <= inst0_ROB_ID;
                end
                2'b01: begin
                    AGU_IQ_vld[7] <= 1'b1;
                    AGU_IQ_dest_en[7] <= inst1_PR_dest_en;
                    AGU_IQ_source1_en[7] <= inst1_PR_source1_en;
                    AGU_IQ_source1_rdy[7] <= inst1_PR_source1_rdy;
                    AGU_IQ_source2_en[7] <= inst1_PR_source2_en;
                    AGU_IQ_source2_rdy[7] <= inst1_PR_source2_rdy;
                    AGU_IQ_dest[7] <= inst1_PR_dest;
                    AGU_IQ_source1[7] <= inst1_PR_source1;
                    AGU_IQ_source2[7] <= inst1_PR_source2;
                    AGU_IQ_op[7] <= inst1_AGU_op;
                    AGU_IQ_imm[7] <= inst1_AGU_imm;
                    AGU_IQ_ROB_ID[7] <= inst1_ROB_ID;
                end
                2'b10: begin
                    AGU_IQ_vld[7] <= 1'b1;
                    AGU_IQ_dest_en[7] <= inst2_PR_dest_en;
                    AGU_IQ_source1_en[7] <= inst2_PR_source1_en;
                    AGU_IQ_source1_rdy[7] <= inst2_PR_source1_rdy;
                    AGU_IQ_source2_en[7] <= inst2_PR_source2_en;
                    AGU_IQ_source2_rdy[7] <= inst2_PR_source2_rdy;
                    AGU_IQ_dest[7] <= inst2_PR_dest;
                    AGU_IQ_source1[7] <= inst2_PR_source1;
                    AGU_IQ_source2[7] <= inst2_PR_source2;
                    AGU_IQ_op[7] <= inst2_AGU_op;
                    AGU_IQ_imm[7] <= inst2_AGU_imm;
                    AGU_IQ_ROB_ID[7] <= inst2_ROB_ID;
                end
                2'b11: begin
                    AGU_IQ_vld[7] <= 1'b1;
                    AGU_IQ_dest_en[7] <= inst3_PR_dest_en;
                    AGU_IQ_source1_en[7] <= inst3_PR_source1_en;
                    AGU_IQ_source1_rdy[7] <= inst3_PR_source1_rdy;
                    AGU_IQ_source2_en[7] <= inst3_PR_source2_en;
                    AGU_IQ_source2_rdy[7] <= inst3_PR_source2_rdy;
                    AGU_IQ_dest[7] <= inst3_PR_dest;
                    AGU_IQ_source1[7] <= inst3_PR_source1;
                    AGU_IQ_source2[7] <= inst3_PR_source2;
                    AGU_IQ_op[7] <= inst3_AGU_op;
                    AGU_IQ_imm[7] <= inst3_AGU_imm;
                    AGU_IQ_ROB_ID[7] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant)begin
            AGU_IQ_vld[7] <= 1'b0;
            AGU_IQ_dest_en[7] <= 1'b0;
            AGU_IQ_source1_en[7] <= 1'b0;
            AGU_IQ_source1_rdy[7] <= 1'b0;
            AGU_IQ_source2_en[7] <= 1'b0;
            AGU_IQ_source2_rdy[7] <= 1'b0;
            AGU_IQ_dest[7] <= 6'd0;
            AGU_IQ_source1[7] <= 6'd0;
            AGU_IQ_source2[7] <= 6'd0;
            AGU_IQ_op[7] <= 5'd0;
            AGU_IQ_imm[7] <= 20'd0;
            AGU_IQ_ROB_ID[7] <= 6'd0;
        end
        else begin
            if((AGU_IQ_source1[7] == dest_ALU1) || (AGU_IQ_source1[7] == dest_ALU0) ||
               (AGU_IQ_source1[7] == dest_BRU)  || (AGU_IQ_source1[7] == dest_AGU))
                AGU_IQ_source1_rdy[7] <= 1'b1;
            if((AGU_IQ_source2[7] == dest_ALU1) || (AGU_IQ_source2[7] == dest_ALU0) ||
               (AGU_IQ_source2[7] == dest_BRU)  || (AGU_IQ_source2[7] == dest_AGU))
                AGU_IQ_source2_rdy[7] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // out
        if((!rst_n) || flush)begin
            AGU_select_vld <= 1'b0;
            AGU_select_op <= 4'd0;
            AGU_select_imm <= 17'd0;
            AGU_select_dest_en <= 1'b0;
            AGU_select_dest <= 6'd0;
            AGU_select_source1 <= 6'd0;
            AGU_select_source2 <= 6'd0;
            AGU_select_ROB_ID <= 6'd0;
        end
        else if(grant)begin
            AGU_select_vld <= 1'b1;
            AGU_select_dest_en <= AGU_IQ_dest_en[0];
            AGU_select_op <= AGU_IQ_op[0];
            AGU_select_imm <= AGU_IQ_imm[0];
            AGU_select_dest <= AGU_IQ_dest[0];
            AGU_select_source1 <= AGU_IQ_source1[0];
            AGU_select_source2 <= AGU_IQ_source2[0];
            AGU_select_ROB_ID <= AGU_IQ_ROB_ID[0];
        end
        else
            AGU_select_vld <= 1'b0;
    end

endmodule