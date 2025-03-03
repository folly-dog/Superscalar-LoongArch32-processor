module ALU0_IQ (
    input               clk,
    input               rst_n,

    input               flush,

    input               inst0_ALU0_en,
    input               inst0_PR_source1_en,
    input               inst0_PR_source2_en,
    input               inst0_PR_source1_rdy,
    input               inst0_PR_source2_rdy,
    input       [6:0]   inst0_PR_dest,
    input       [6:0]   inst0_PR_source1,
    input       [6:0]   inst0_PR_source2,
    input       [4:0]   inst0_ALU0_op,
    input       [19:0]  inst0_ALU0_imm,
    input       [5:0]   inst0_ROB_ID,

    input               inst1_ALU0_en,
    input               inst1_PR_source1_en,
    input               inst1_PR_source2_en,
    input               inst1_PR_source1_rdy,
    input               inst1_PR_source2_rdy,
    input       [6:0]   inst1_PR_dest,
    input       [6:0]   inst1_PR_source1,
    input       [6:0]   inst1_PR_source2,
    input       [4:0]   inst1_ALU0_op,
    input       [19:0]  inst1_ALU0_imm,
    input       [5:0]   inst1_ROB_ID,

    input               inst2_ALU0_en,
    input               inst2_PR_source1_en,
    input               inst2_PR_source2_en,
    input               inst2_PR_source1_rdy,
    input               inst2_PR_source2_rdy,
    input       [6:0]   inst2_PR_dest,
    input       [6:0]   inst2_PR_source1,
    input       [6:0]   inst2_PR_source2,
    input       [4:0]   inst2_ALU0_op,
    input       [19:0]  inst2_ALU0_imm,
    input       [5:0]   inst2_ROB_ID,

    input               inst3_ALU0_en,
    input               inst3_PR_source1_en,
    input               inst3_PR_source2_en,
    input               inst3_PR_source1_rdy,
    input               inst3_PR_source2_rdy,
    input       [6:0]   inst3_PR_dest,
    input       [6:0]   inst3_PR_source1,
    input       [6:0]   inst3_PR_source2,
    input       [4:0]   inst3_ALU0_op,
    input       [19:0]  inst3_ALU0_imm,
    input       [5:0]   inst3_ROB_ID,

    input       [6:0]   dest_ALU1,
    input       [6:0]   dest_AGU,
    input       [6:0]   dest_BRU,

    output              wr_pause,
    input               ALU0_IQ_pause,

    output  reg         ALU0_select_vld,
    output  reg [4:0]   ALU0_select_op,
    output  reg [19:0]  ALU0_select_imm,
    output  reg [6:0]   ALU0_select_dest,
    output  reg [6:0]   ALU0_select_source1,
    output  reg [6:0]   ALU0_select_source2,
    output  reg [5:0]   ALU0_select_ROB_ID
);
    reg [7:0]   ALU0_IQ_vld;
    reg [7:0]   ALU0_IQ_source1_en;
    reg [7:0]   ALU0_IQ_source1_rdy;
    reg [7:0]   ALU0_IQ_source2_en;
    reg [7:0]   ALU0_IQ_source2_rdy;
    reg [6:0]   ALU0_IQ_dest    [7:0];
    reg [6:0]   ALU0_IQ_source1 [7:0];
    reg [6:0]   ALU0_IQ_source2 [7:0];
    reg [5:0]   ALU0_IQ_ROB_ID  [7:0];
    reg [4:0]   ALU0_IQ_op      [7:0];
    reg [19:0]  ALU0_IQ_imm     [7:0];

    wire [7:0]  req_excute;
    wire [7:0]  grant_excute;

    wire [7:0]  converse_vld;
    wire [7:0]  converse_last_vld;
    wire [7:0]  last_vld;

    wire [7:0]  first_wr_onehot;
    
    reg  [7:0]  wr_en;
    reg  [1:0]  wr_from [7:0];

    wire [2:0]  room_need;
    wire [3:0]  room_have;

    assign room_need = inst0_ALU0_en + inst1_ALU0_en + inst2_ALU0_en + inst3_ALU0_en;
    assign room_have = (!ALU0_IQ_vld[0]) + (!ALU0_IQ_vld[1]) + (!ALU0_IQ_vld[2]) + (!ALU0_IQ_vld[3]) + 
                       (!ALU0_IQ_vld[4]) + (!ALU0_IQ_vld[5]) + (!ALU0_IQ_vld[6]) + (!ALU0_IQ_vld[7]) +
                       (|grant_excute);

    assign wr_pause = (room_need > room_have);

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin:get_req
            assign req_excute[i] = ALU0_IQ_vld[i] & 
                        ((!ALU0_IQ_source1_en) | (ALU0_IQ_source1_en & ALU0_IQ_source1_rdy)) & 
                        ((!ALU0_IQ_source2_en) | (ALU0_IQ_source2_en & ALU0_IQ_source2_rdy));
        end
    endgenerate

    assign grant_excute = ALU0_IQ_pause ? 8'd0 : 
                        (req_excute & ((~req_excute) + 1));

    assign converse_vld = {ALU0_IQ_vld[0], ALU0_IQ_vld[1], ALU0_IQ_vld[2], ALU0_IQ_vld[3], 
                           ALU0_IQ_vld[4], ALU0_IQ_vld[5], ALU0_IQ_vld[6], ALU0_IQ_vld[7]};
    assign converse_last_vld = converse_vld & ((~converse_vld) + 1);
    assign last_vld = {converse_last_vld[0], converse_last_vld[1], converse_last_vld[2], converse_last_vld[3], 
                       converse_last_vld[4], converse_last_vld[5], converse_last_vld[6], converse_last_vld[7]};

    assign first_wr_onehot = (|grant_excute) ? last_vld : ((last_vld == 8'd0) ? 8'd1 : (last_vld << 1));

    always @(*) begin       // wr_en
        if(ALU0_IQ_pause)
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
            8'b00000001: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000001: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000010: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000001: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[2] = 2'b10;
                4'b1110: wr_from[2] = 2'b10;
                4'b1101: wr_from[2] = 2'b11;
                4'b1011: wr_from[2] = 2'b11;
                4'b0111: wr_from[2] = 2'b11;
                default: wr_from[2] = 2'b00;
            endcase
            8'b00000010: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000100: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000001: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            8'b00000010: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[3] = 2'b10;
                4'b1110: wr_from[3] = 2'b10;
                4'b1101: wr_from[3] = 2'b11;
                4'b1011: wr_from[3] = 2'b11;
                4'b0111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            8'b00000100: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00001000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000010: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[4] = 2'b11;
                default: wr_from[4] = 2'b00;
            endcase
            8'b00000100: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[4] = 2'b10;
                4'b1110: wr_from[4] = 2'b10;
                4'b1101: wr_from[4] = 2'b11;
                4'b1011: wr_from[4] = 2'b11;
                4'b0111: wr_from[4] = 2'b11;
                default: wr_from[4] = 2'b00;
            endcase
            8'b00001000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00010000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00000100: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[5] = 2'b11;
                default: wr_from[5] = 2'b00;
            endcase
            8'b00001000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[5] = 2'b10;
                4'b1110: wr_from[5] = 2'b10;
                4'b1101: wr_from[5] = 2'b11;
                4'b1011: wr_from[5] = 2'b11;
                4'b0111: wr_from[5] = 2'b11;
                default: wr_from[5] = 2'b00;
            endcase
            8'b00010000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00100000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00001000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[6] = 2'b11;
                default: wr_from[6] = 2'b00;
            endcase
            8'b00010000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[6] = 2'b10;
                4'b1110: wr_from[6] = 2'b10;
                4'b1101: wr_from[6] = 2'b11;
                4'b1011: wr_from[6] = 2'b11;
                4'b0111: wr_from[6] = 2'b11;
                default: wr_from[6] = 2'b00;
            endcase
            8'b00100000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b01000000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b00010000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[7] = 2'b11;
                default: wr_from[7] = 2'b00;
            endcase
            8'b00100000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
                4'b1111: wr_from[7] = 2'b10;
                4'b1110: wr_from[7] = 2'b10;
                4'b1101: wr_from[7] = 2'b11;
                4'b1011: wr_from[7] = 2'b11;
                4'b0111: wr_from[7] = 2'b11;
                default: wr_from[7] = 2'b00;
            endcase
            8'b01000000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            8'b10000000: casez ({inst0_ALU0_en, inst1_ALU0_en, inst2_ALU0_en, inst3_ALU0_en})
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
            ALU0_IQ_vld[0] <= 1'b0;
            ALU0_IQ_source1_en[0] <= 1'b0;
            ALU0_IQ_source1_rdy[0] <= 1'b0;
            ALU0_IQ_source2_en[0] <= 1'b0;
            ALU0_IQ_source2_rdy[0] <= 1'b0;
        end
        else if(wr_en[0])begin
            case (wr_from[0])
                2'b00: begin
                    ALU0_IQ_vld[0] <= 1'b1;
                    ALU0_IQ_source1_en[0] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[0] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[0] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[0] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[0] <= inst0_PR_dest;
                    ALU0_IQ_source1[0] <= inst0_PR_source1;
                    ALU0_IQ_source2[0] <= inst0_PR_source2;
                    ALU0_IQ_op[0] <= inst0_ALU0_op;
                    ALU0_IQ_imm[0] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[0] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[0] <= 1'b1;
                    ALU0_IQ_source1_en[0] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[0] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[0] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[0] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[0] <= inst1_PR_dest;
                    ALU0_IQ_source1[0] <= inst1_PR_source1;
                    ALU0_IQ_source2[0] <= inst1_PR_source2;
                    ALU0_IQ_op[0] <= inst1_ALU0_op;
                    ALU0_IQ_imm[0] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[0] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[0] <= 1'b1;
                    ALU0_IQ_source1_en[0] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[0] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[0] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[0] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[0] <= inst2_PR_dest;
                    ALU0_IQ_source1[0] <= inst2_PR_source1;
                    ALU0_IQ_source2[0] <= inst2_PR_source2;
                    ALU0_IQ_op[0] <= inst2_ALU0_op;
                    ALU0_IQ_imm[0] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[0] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[0] <= 1'b1;
                    ALU0_IQ_source1_en[0] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[0] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[0] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[0] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[0] <= inst3_PR_dest;
                    ALU0_IQ_source1[0] <= inst3_PR_source1;
                    ALU0_IQ_source2[0] <= inst3_PR_source2;
                    ALU0_IQ_op[0] <= inst3_ALU0_op;
                    ALU0_IQ_imm[0] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[0] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[0])begin
            ALU0_IQ_vld[0] <= ALU0_IQ_vld[1];
            ALU0_IQ_source1_en[0] <= ALU0_IQ_source1_en[1];
            ALU0_IQ_source2_en[0] <= ALU0_IQ_source2_en[1];
            ALU0_IQ_dest[0] <= ALU0_IQ_dest[1];
            ALU0_IQ_source1[0] <= ALU0_IQ_source1[1];
            ALU0_IQ_source2[0] <= ALU0_IQ_source2[1];
            ALU0_IQ_op[0] <= ALU0_IQ_op[1];
            ALU0_IQ_imm[0] <= ALU0_IQ_imm[1];
            ALU0_IQ_ROB_ID[0] <= ALU0_IQ_ROB_ID[1];
            if((ALU0_IQ_source1[1] == dest_ALU1) || (ALU0_IQ_source1[1] == dest_AGU) ||
               (ALU0_IQ_source1[1] == dest_BRU))
                ALU0_IQ_source1_rdy[0] <= 1'b1;
            if((ALU0_IQ_source2[1] == dest_ALU1) || (ALU0_IQ_source2[1] == dest_AGU) ||
               (ALU0_IQ_source2[1] == dest_BRU))
                ALU0_IQ_source2_rdy[0] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[0] == dest_ALU1) || (ALU0_IQ_source1[0] == dest_AGU) ||
               (ALU0_IQ_source1[0] == dest_BRU))
                ALU0_IQ_source1_rdy[0] <= 1'b1;
            if((ALU0_IQ_source2[0] == dest_ALU1) || (ALU0_IQ_source2[0] == dest_AGU) ||
               (ALU0_IQ_source2[0] == dest_BRU))
                ALU0_IQ_source2_rdy[0] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry1
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[1] <= 1'b0;
            ALU0_IQ_source1_en[1] <= 1'b0;
            ALU0_IQ_source1_rdy[1] <= 1'b0;
            ALU0_IQ_source2_en[1] <= 1'b0;
            ALU0_IQ_source2_rdy[1] <= 1'b0;
        end
        else if(wr_en[1])begin
            case (wr_from[1])
                2'b00: begin
                    ALU0_IQ_vld[1] <= 1'b1;
                    ALU0_IQ_source1_en[1] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[1] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[1] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[1] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[1] <= inst0_PR_dest;
                    ALU0_IQ_source1[1] <= inst0_PR_source1;
                    ALU0_IQ_source2[1] <= inst0_PR_source2;
                    ALU0_IQ_op[1] <= inst0_ALU0_op;
                    ALU0_IQ_imm[1] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[1] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[1] <= 1'b1;
                    ALU0_IQ_source1_en[1] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[1] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[1] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[1] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[1] <= inst1_PR_dest;
                    ALU0_IQ_source1[1] <= inst1_PR_source1;
                    ALU0_IQ_source2[1] <= inst1_PR_source2;
                    ALU0_IQ_op[1] <= inst1_ALU0_op;
                    ALU0_IQ_imm[1] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[1] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[1] <= 1'b1;
                    ALU0_IQ_source1_en[1] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[1] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[1] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[1] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[1] <= inst2_PR_dest;
                    ALU0_IQ_source1[1] <= inst2_PR_source1;
                    ALU0_IQ_source2[1] <= inst2_PR_source2;
                    ALU0_IQ_op[1] <= inst2_ALU0_op;
                    ALU0_IQ_imm[1] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[1] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[1] <= 1'b1;
                    ALU0_IQ_source1_en[1] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[1] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[1] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[1] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[1] <= inst3_PR_dest;
                    ALU0_IQ_source1[1] <= inst3_PR_source1;
                    ALU0_IQ_source2[1] <= inst3_PR_source2;
                    ALU0_IQ_op[1] <= inst3_ALU0_op;
                    ALU0_IQ_imm[1] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[1] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[1] || grant_excute[0])begin
            ALU0_IQ_vld[1] <= ALU0_IQ_vld[2];
            ALU0_IQ_source1_en[1] <= ALU0_IQ_source1_en[2];
            ALU0_IQ_source2_en[1] <= ALU0_IQ_source2_en[2];
            ALU0_IQ_dest[1] <= ALU0_IQ_dest[2];
            ALU0_IQ_source1[1] <= ALU0_IQ_source1[2];
            ALU0_IQ_source2[1] <= ALU0_IQ_source2[2];
            ALU0_IQ_op[1] <= ALU0_IQ_op[2];
            ALU0_IQ_imm[1] <= ALU0_IQ_imm[2];
            ALU0_IQ_ROB_ID[1] <= ALU0_IQ_ROB_ID[2];
            if((ALU0_IQ_source1[2] == dest_ALU1) || (ALU0_IQ_source1[2] == dest_AGU) ||
               (ALU0_IQ_source1[2] == dest_BRU))
                ALU0_IQ_source1_rdy[1] <= 1'b1;
            if((ALU0_IQ_source2[2] == dest_ALU1) || (ALU0_IQ_source2[2] == dest_AGU) ||
               (ALU0_IQ_source2[2] == dest_BRU))
                ALU0_IQ_source2_rdy[1] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[1] == dest_ALU1) || (ALU0_IQ_source1[1] == dest_AGU) ||
               (ALU0_IQ_source1[1] == dest_BRU))
                ALU0_IQ_source1_rdy[1] <= 1'b1;
            if((ALU0_IQ_source2[1] == dest_ALU1) || (ALU0_IQ_source2[1] == dest_AGU) ||
               (ALU0_IQ_source2[1] == dest_BRU))
                ALU0_IQ_source2_rdy[1] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry2
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[2] <= 1'b0;
            ALU0_IQ_source1_en[2] <= 1'b0;
            ALU0_IQ_source1_rdy[2] <= 1'b0;
            ALU0_IQ_source2_en[2] <= 1'b0;
            ALU0_IQ_source2_rdy[2] <= 1'b0;
        end
        else if(wr_en[2])begin
            case (wr_from[2])
                2'b00: begin
                    ALU0_IQ_vld[2] <= 1'b1;
                    ALU0_IQ_source1_en[2] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[2] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[2] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[2] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[2] <= inst0_PR_dest;
                    ALU0_IQ_source1[2] <= inst0_PR_source1;
                    ALU0_IQ_source2[2] <= inst0_PR_source2;
                    ALU0_IQ_op[2] <= inst0_ALU0_op;
                    ALU0_IQ_imm[2] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[2] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[2] <= 1'b1;
                    ALU0_IQ_source1_en[2] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[2] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[2] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[2] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[2] <= inst1_PR_dest;
                    ALU0_IQ_source1[2] <= inst1_PR_source1;
                    ALU0_IQ_source2[2] <= inst1_PR_source2;
                    ALU0_IQ_op[2] <= inst1_ALU0_op;
                    ALU0_IQ_imm[2] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[2] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[2] <= 1'b1;
                    ALU0_IQ_source1_en[2] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[2] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[2] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[2] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[2] <= inst2_PR_dest;
                    ALU0_IQ_source1[2] <= inst2_PR_source1;
                    ALU0_IQ_source2[2] <= inst2_PR_source2;
                    ALU0_IQ_op[2] <= inst2_ALU0_op;
                    ALU0_IQ_imm[2] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[2] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[2] <= 1'b1;
                    ALU0_IQ_source1_en[2] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[2] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[2] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[2] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[2] <= inst3_PR_dest;
                    ALU0_IQ_source1[2] <= inst3_PR_source1;
                    ALU0_IQ_source2[2] <= inst3_PR_source2;
                    ALU0_IQ_op[2] <= inst3_ALU0_op;
                    ALU0_IQ_imm[2] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[2] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[2] || grant_excute[1] || grant_excute[0])begin
            ALU0_IQ_vld[2] <= ALU0_IQ_vld[3];
            ALU0_IQ_source1_en[2] <= ALU0_IQ_source1_en[3];
            ALU0_IQ_source2_en[2] <= ALU0_IQ_source2_en[3];
            ALU0_IQ_dest[2] <= ALU0_IQ_dest[3];
            ALU0_IQ_source1[2] <= ALU0_IQ_source1[3];
            ALU0_IQ_source2[2] <= ALU0_IQ_source2[3];
            ALU0_IQ_op[2] <= ALU0_IQ_op[3];
            ALU0_IQ_imm[2] <= ALU0_IQ_imm[3];
            ALU0_IQ_ROB_ID[2] <= ALU0_IQ_ROB_ID[3];
            if((ALU0_IQ_source1[3] == dest_ALU1) || (ALU0_IQ_source1[3] == dest_AGU) ||
               (ALU0_IQ_source1[3] == dest_BRU))
                ALU0_IQ_source1_rdy[2] <= 1'b1;
            if((ALU0_IQ_source2[3] == dest_ALU1) || (ALU0_IQ_source2[3] == dest_AGU) ||
               (ALU0_IQ_source2[3] == dest_BRU))
                ALU0_IQ_source2_rdy[2] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[2] == dest_ALU1) || (ALU0_IQ_source1[2] == dest_AGU) ||
               (ALU0_IQ_source1[2] == dest_BRU))
                ALU0_IQ_source1_rdy[2] <= 1'b1;
            if((ALU0_IQ_source2[2] == dest_ALU1) || (ALU0_IQ_source2[2] == dest_AGU) ||
               (ALU0_IQ_source2[2] == dest_BRU))
                ALU0_IQ_source2_rdy[2] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry3
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[3] <= 1'b0;
            ALU0_IQ_source1_en[3] <= 1'b0;
            ALU0_IQ_source1_rdy[3] <= 1'b0;
            ALU0_IQ_source2_en[3] <= 1'b0;
            ALU0_IQ_source2_rdy[3] <= 1'b0;
        end
        else if(wr_en[3])begin
            case (wr_from[3])
                2'b00: begin
                    ALU0_IQ_vld[3] <= 1'b1;
                    ALU0_IQ_source1_en[3] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[3] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[3] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[3] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[3] <= inst0_PR_dest;
                    ALU0_IQ_source1[3] <= inst0_PR_source1;
                    ALU0_IQ_source2[3] <= inst0_PR_source2;
                    ALU0_IQ_op[3] <= inst0_ALU0_op;
                    ALU0_IQ_imm[3] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[3] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[3] <= 1'b1;
                    ALU0_IQ_source1_en[3] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[3] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[3] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[3] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[3] <= inst1_PR_dest;
                    ALU0_IQ_source1[3] <= inst1_PR_source1;
                    ALU0_IQ_source2[3] <= inst1_PR_source2;
                    ALU0_IQ_op[3] <= inst1_ALU0_op;
                    ALU0_IQ_imm[3] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[3] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[3] <= 1'b1;
                    ALU0_IQ_source1_en[3] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[3] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[3] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[3] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[3] <= inst2_PR_dest;
                    ALU0_IQ_source1[3] <= inst2_PR_source1;
                    ALU0_IQ_source2[3] <= inst2_PR_source2;
                    ALU0_IQ_op[3] <= inst2_ALU0_op;
                    ALU0_IQ_imm[3] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[3] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[3] <= 1'b1;
                    ALU0_IQ_source1_en[3] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[3] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[3] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[3] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[3] <= inst3_PR_dest;
                    ALU0_IQ_source1[3] <= inst3_PR_source1;
                    ALU0_IQ_source2[3] <= inst3_PR_source2;
                    ALU0_IQ_op[3] <= inst3_ALU0_op;
                    ALU0_IQ_imm[3] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[3] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[3] || grant_excute[2] || grant_excute[1] || grant_excute[0])begin
            ALU0_IQ_vld[3] <= ALU0_IQ_vld[4];
            ALU0_IQ_source1_en[3] <= ALU0_IQ_source1_en[4];
            ALU0_IQ_source2_en[3] <= ALU0_IQ_source2_en[4];
            ALU0_IQ_dest[3] <= ALU0_IQ_dest[4];
            ALU0_IQ_source1[3] <= ALU0_IQ_source1[4];
            ALU0_IQ_source2[3] <= ALU0_IQ_source2[4];
            ALU0_IQ_op[3] <= ALU0_IQ_op[4];
            ALU0_IQ_imm[3] <= ALU0_IQ_imm[4];
            ALU0_IQ_ROB_ID[3] <= ALU0_IQ_ROB_ID[4];
            if((ALU0_IQ_source1[4] == dest_ALU1) || (ALU0_IQ_source1[4] == dest_AGU) ||
               (ALU0_IQ_source1[4] == dest_BRU))
                ALU0_IQ_source1_rdy[3] <= 1'b1;
            if((ALU0_IQ_source2[4] == dest_ALU1) || (ALU0_IQ_source2[4] == dest_AGU) ||
               (ALU0_IQ_source2[4] == dest_BRU))
                ALU0_IQ_source2_rdy[3] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[3] == dest_ALU1) || (ALU0_IQ_source1[3] == dest_AGU) ||
               (ALU0_IQ_source1[3] == dest_BRU))
                ALU0_IQ_source1_rdy[3] <= 1'b1;
            if((ALU0_IQ_source2[3] == dest_ALU1) || (ALU0_IQ_source2[3] == dest_AGU) ||
               (ALU0_IQ_source2[3] == dest_BRU))
                ALU0_IQ_source2_rdy[3] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry4
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[4] <= 1'b0;
            ALU0_IQ_source1_en[4] <= 1'b0;
            ALU0_IQ_source1_rdy[4] <= 1'b0;
            ALU0_IQ_source2_en[4] <= 1'b0;
            ALU0_IQ_source2_rdy[4] <= 1'b0;
        end
        else if(wr_en[4])begin
            case (wr_from[4])
                2'b00: begin
                    ALU0_IQ_vld[4] <= 1'b1;
                    ALU0_IQ_source1_en[4] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[4] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[4] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[4] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[4] <= inst0_PR_dest;
                    ALU0_IQ_source1[4] <= inst0_PR_source1;
                    ALU0_IQ_source2[4] <= inst0_PR_source2;
                    ALU0_IQ_op[4] <= inst0_ALU0_op;
                    ALU0_IQ_imm[4] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[4] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[4] <= 1'b1;
                    ALU0_IQ_source1_en[4] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[4] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[4] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[4] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[4] <= inst1_PR_dest;
                    ALU0_IQ_source1[4] <= inst1_PR_source1;
                    ALU0_IQ_source2[4] <= inst1_PR_source2;
                    ALU0_IQ_op[4] <= inst1_ALU0_op;
                    ALU0_IQ_imm[4] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[4] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[4] <= 1'b1;
                    ALU0_IQ_source1_en[4] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[4] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[4] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[4] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[4] <= inst2_PR_dest;
                    ALU0_IQ_source1[4] <= inst2_PR_source1;
                    ALU0_IQ_source2[4] <= inst2_PR_source2;
                    ALU0_IQ_op[4] <= inst2_ALU0_op;
                    ALU0_IQ_imm[4] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[4] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[4] <= 1'b1;
                    ALU0_IQ_source1_en[4] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[4] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[4] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[4] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[4] <= inst3_PR_dest;
                    ALU0_IQ_source1[4] <= inst3_PR_source1;
                    ALU0_IQ_source2[4] <= inst3_PR_source2;
                    ALU0_IQ_op[4] <= inst3_ALU0_op;
                    ALU0_IQ_imm[4] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[4] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[4] || grant_excute[3] || grant_excute[2] || grant_excute[1] 
                || grant_excute[0])begin
            ALU0_IQ_vld[4] <= ALU0_IQ_vld[5];
            ALU0_IQ_source1_en[4] <= ALU0_IQ_source1_en[5];
            ALU0_IQ_source2_en[4] <= ALU0_IQ_source2_en[5];
            ALU0_IQ_dest[4] <= ALU0_IQ_dest[5];
            ALU0_IQ_source1[4] <= ALU0_IQ_source1[5];
            ALU0_IQ_source2[4] <= ALU0_IQ_source2[5];
            ALU0_IQ_op[4] <= ALU0_IQ_op[5];
            ALU0_IQ_imm[4] <= ALU0_IQ_imm[5];
            ALU0_IQ_ROB_ID[4] <= ALU0_IQ_ROB_ID[5];
            if((ALU0_IQ_source1[5] == dest_ALU1) || (ALU0_IQ_source1[5] == dest_AGU) ||
               (ALU0_IQ_source1[5] == dest_BRU))
                ALU0_IQ_source1_rdy[4] <= 1'b1;
            if((ALU0_IQ_source2[5] == dest_ALU1) || (ALU0_IQ_source2[5] == dest_AGU) ||
               (ALU0_IQ_source2[5] == dest_BRU))
                ALU0_IQ_source2_rdy[4] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[4] == dest_ALU1) || (ALU0_IQ_source1[4] == dest_AGU) ||
               (ALU0_IQ_source1[4] == dest_BRU))
                ALU0_IQ_source1_rdy[4] <= 1'b1;
            if((ALU0_IQ_source2[4] == dest_ALU1) || (ALU0_IQ_source2[4] == dest_AGU) ||
               (ALU0_IQ_source2[4] == dest_BRU))
                ALU0_IQ_source2_rdy[4] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry5
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[5] <= 1'b0;
            ALU0_IQ_source1_en[5] <= 1'b0;
            ALU0_IQ_source1_rdy[5] <= 1'b0;
            ALU0_IQ_source2_en[5] <= 1'b0;
            ALU0_IQ_source2_rdy[5] <= 1'b0;
        end
        else if(wr_en[5])begin
            case (wr_from[5])
                2'b00: begin
                    ALU0_IQ_vld[5] <= 1'b1;
                    ALU0_IQ_source1_en[5] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[5] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[5] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[5] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[5] <= inst0_PR_dest;
                    ALU0_IQ_source1[5] <= inst0_PR_source1;
                    ALU0_IQ_source2[5] <= inst0_PR_source2;
                    ALU0_IQ_op[5] <= inst0_ALU0_op;
                    ALU0_IQ_imm[5] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[5] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[5] <= 1'b1;
                    ALU0_IQ_source1_en[5] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[5] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[5] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[5] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[5] <= inst1_PR_dest;
                    ALU0_IQ_source1[5] <= inst1_PR_source1;
                    ALU0_IQ_source2[5] <= inst1_PR_source2;
                    ALU0_IQ_op[5] <= inst1_ALU0_op;
                    ALU0_IQ_imm[5] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[5] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[5] <= 1'b1;
                    ALU0_IQ_source1_en[5] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[5] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[5] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[5] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[5] <= inst2_PR_dest;
                    ALU0_IQ_source1[5] <= inst2_PR_source1;
                    ALU0_IQ_source2[5] <= inst2_PR_source2;
                    ALU0_IQ_op[5] <= inst2_ALU0_op;
                    ALU0_IQ_imm[5] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[5] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[5] <= 1'b1;
                    ALU0_IQ_source1_en[5] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[5] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[5] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[5] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[5] <= inst3_PR_dest;
                    ALU0_IQ_source1[5] <= inst3_PR_source1;
                    ALU0_IQ_source2[5] <= inst3_PR_source2;
                    ALU0_IQ_op[5] <= inst3_ALU0_op;
                    ALU0_IQ_imm[5] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[5] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[5] || grant_excute[4] || 
                grant_excute[3] || grant_excute[2] || grant_excute[1] || grant_excute[0])begin
            ALU0_IQ_vld[5] <= ALU0_IQ_vld[6];
            ALU0_IQ_source1_en[5] <= ALU0_IQ_source1_en[6];
            ALU0_IQ_source2_en[5] <= ALU0_IQ_source2_en[6];
            ALU0_IQ_dest[5] <= ALU0_IQ_dest[6];
            ALU0_IQ_source1[5] <= ALU0_IQ_source1[6];
            ALU0_IQ_source2[5] <= ALU0_IQ_source2[6];
            ALU0_IQ_op[5] <= ALU0_IQ_op[6];
            ALU0_IQ_imm[5] <= ALU0_IQ_imm[6];
            ALU0_IQ_ROB_ID[5] <= ALU0_IQ_ROB_ID[6];
            if((ALU0_IQ_source1[6] == dest_ALU1) || (ALU0_IQ_source1[6] == dest_AGU) ||
               (ALU0_IQ_source1[6] == dest_BRU))
                ALU0_IQ_source1_rdy[5] <= 1'b1;
            if((ALU0_IQ_source2[6] == dest_ALU1) || (ALU0_IQ_source2[6] == dest_AGU) ||
               (ALU0_IQ_source2[6] == dest_BRU))
                ALU0_IQ_source2_rdy[5] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[5] == dest_ALU1) || (ALU0_IQ_source1[5] == dest_AGU) ||
               (ALU0_IQ_source1[5] == dest_BRU))
                ALU0_IQ_source1_rdy[5] <= 1'b1;
            if((ALU0_IQ_source2[5] == dest_ALU1) || (ALU0_IQ_source2[5] == dest_AGU) ||
               (ALU0_IQ_source2[5] == dest_BRU))
                ALU0_IQ_source2_rdy[5] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry6
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[6] <= 1'b0;
            ALU0_IQ_source1_en[6] <= 1'b0;
            ALU0_IQ_source1_rdy[6] <= 1'b0;
            ALU0_IQ_source2_en[6] <= 1'b0;
            ALU0_IQ_source2_rdy[6] <= 1'b0;
        end
        else if(wr_en[6])begin
            case (wr_from[6])
                2'b00: begin
                    ALU0_IQ_vld[6] <= 1'b1;
                    ALU0_IQ_source1_en[6] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[6] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[6] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[6] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[6] <= inst0_PR_dest;
                    ALU0_IQ_source1[6] <= inst0_PR_source1;
                    ALU0_IQ_source2[6] <= inst0_PR_source2;
                    ALU0_IQ_op[6] <= inst0_ALU0_op;
                    ALU0_IQ_imm[6] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[6] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[6] <= 1'b1;
                    ALU0_IQ_source1_en[6] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[6] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[6] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[6] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[6] <= inst1_PR_dest;
                    ALU0_IQ_source1[6] <= inst1_PR_source1;
                    ALU0_IQ_source2[6] <= inst1_PR_source2;
                    ALU0_IQ_op[6] <= inst1_ALU0_op;
                    ALU0_IQ_imm[6] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[6] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[6] <= 1'b1;
                    ALU0_IQ_source1_en[6] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[6] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[6] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[6] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[6] <= inst2_PR_dest;
                    ALU0_IQ_source1[6] <= inst2_PR_source1;
                    ALU0_IQ_source2[6] <= inst2_PR_source2;
                    ALU0_IQ_op[6] <= inst2_ALU0_op;
                    ALU0_IQ_imm[6] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[6] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[6] <= 1'b1;
                    ALU0_IQ_source1_en[6] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[6] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[6] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[6] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[6] <= inst3_PR_dest;
                    ALU0_IQ_source1[6] <= inst3_PR_source1;
                    ALU0_IQ_source2[6] <= inst3_PR_source2;
                    ALU0_IQ_op[6] <= inst3_ALU0_op;
                    ALU0_IQ_imm[6] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[6] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(grant_excute[6] || grant_excute[5] || grant_excute[4] ||
                grant_excute[3] || grant_excute[2] || grant_excute[1] || grant_excute[0])begin
            ALU0_IQ_vld[6] <= ALU0_IQ_vld[7];
            ALU0_IQ_source1_en[6] <= ALU0_IQ_source1_en[7];
            ALU0_IQ_source2_en[6] <= ALU0_IQ_source2_en[7];
            ALU0_IQ_dest[6] <= ALU0_IQ_dest[7];
            ALU0_IQ_source1[6] <= ALU0_IQ_source1[7];
            ALU0_IQ_source2[6] <= ALU0_IQ_source2[7];
            ALU0_IQ_op[6] <= ALU0_IQ_op[7];
            ALU0_IQ_imm[6] <= ALU0_IQ_imm[7];
            ALU0_IQ_ROB_ID[6] <= ALU0_IQ_ROB_ID[7];
            if((ALU0_IQ_source1[7] == dest_ALU1) || (ALU0_IQ_source1[7] == dest_AGU) ||
               (ALU0_IQ_source1[7] == dest_BRU))
                ALU0_IQ_source1_rdy[6] <= 1'b1;
            if((ALU0_IQ_source2[7] == dest_ALU1) || (ALU0_IQ_source2[7] == dest_AGU) ||
               (ALU0_IQ_source2[7] == dest_BRU))
                ALU0_IQ_source2_rdy[6] <= 1'b1;
        end
        else begin
            if((ALU0_IQ_source1[6] == dest_ALU1) || (ALU0_IQ_source1[6] == dest_AGU) ||
               (ALU0_IQ_source1[6] == dest_BRU))
                ALU0_IQ_source1_rdy[6] <= 1'b1;
            if((ALU0_IQ_source2[6] == dest_ALU1) || (ALU0_IQ_source2[6] == dest_AGU) ||
               (ALU0_IQ_source2[6] == dest_BRU))
                ALU0_IQ_source2_rdy[6] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // entry7
        if((!rst_n) || flush)begin
            ALU0_IQ_vld[7] <= 1'b0;
            ALU0_IQ_source1_en[7] <= 1'b0;
            ALU0_IQ_source1_rdy[7] <= 1'b0;
            ALU0_IQ_source2_en[7] <= 1'b0;
            ALU0_IQ_source2_rdy[7] <= 1'b0;
        end
        else if(wr_en[7])begin
            case (wr_from[7])
                2'b00: begin
                    ALU0_IQ_vld[7] <= 1'b1;
                    ALU0_IQ_source1_en[7] <= inst0_PR_source1_en;
                    ALU0_IQ_source1_rdy[7] <= inst0_PR_source1_rdy;
                    ALU0_IQ_source2_en[7] <= inst0_PR_source2_en;
                    ALU0_IQ_source2_rdy[7] <= inst0_PR_source2_rdy;
                    ALU0_IQ_dest[7] <= inst0_PR_dest;
                    ALU0_IQ_source1[7] <= inst0_PR_source1;
                    ALU0_IQ_source2[7] <= inst0_PR_source2;
                    ALU0_IQ_op[7] <= inst0_ALU0_op;
                    ALU0_IQ_imm[7] <= inst0_ALU0_imm;
                    ALU0_IQ_ROB_ID[7] <= inst0_ROB_ID;
                end
                2'b01: begin
                    ALU0_IQ_vld[7] <= 1'b1;
                    ALU0_IQ_source1_en[7] <= inst1_PR_source1_en;
                    ALU0_IQ_source1_rdy[7] <= inst1_PR_source1_rdy;
                    ALU0_IQ_source2_en[7] <= inst1_PR_source2_en;
                    ALU0_IQ_source2_rdy[7] <= inst1_PR_source2_rdy;
                    ALU0_IQ_dest[7] <= inst1_PR_dest;
                    ALU0_IQ_source1[7] <= inst1_PR_source1;
                    ALU0_IQ_source2[7] <= inst1_PR_source2;
                    ALU0_IQ_op[7] <= inst1_ALU0_op;
                    ALU0_IQ_imm[7] <= inst1_ALU0_imm;
                    ALU0_IQ_ROB_ID[7] <= inst1_ROB_ID;
                end
                2'b10: begin
                    ALU0_IQ_vld[7] <= 1'b1;
                    ALU0_IQ_source1_en[7] <= inst2_PR_source1_en;
                    ALU0_IQ_source1_rdy[7] <= inst2_PR_source1_rdy;
                    ALU0_IQ_source2_en[7] <= inst2_PR_source2_en;
                    ALU0_IQ_source2_rdy[7] <= inst2_PR_source2_rdy;
                    ALU0_IQ_dest[7] <= inst2_PR_dest;
                    ALU0_IQ_source1[7] <= inst2_PR_source1;
                    ALU0_IQ_source2[7] <= inst2_PR_source2;
                    ALU0_IQ_op[7] <= inst2_ALU0_op;
                    ALU0_IQ_imm[7] <= inst2_ALU0_imm;
                    ALU0_IQ_ROB_ID[7] <= inst2_ROB_ID;
                end
                2'b11: begin
                    ALU0_IQ_vld[7] <= 1'b1;
                    ALU0_IQ_source1_en[7] <= inst3_PR_source1_en;
                    ALU0_IQ_source1_rdy[7] <= inst3_PR_source1_rdy;
                    ALU0_IQ_source2_en[7] <= inst3_PR_source2_en;
                    ALU0_IQ_source2_rdy[7] <= inst3_PR_source2_rdy;
                    ALU0_IQ_dest[7] <= inst3_PR_dest;
                    ALU0_IQ_source1[7] <= inst3_PR_source1;
                    ALU0_IQ_source2[7] <= inst3_PR_source2;
                    ALU0_IQ_op[7] <= inst3_ALU0_op;
                    ALU0_IQ_imm[7] <= inst3_ALU0_imm;
                    ALU0_IQ_ROB_ID[7] <= inst3_ROB_ID;
                end
            endcase
        end
        else if(|grant_excute)begin
            ALU0_IQ_vld[7] <= 1'b0;
            ALU0_IQ_source1_en[7] <= 1'b0;
            ALU0_IQ_source1_rdy[7] <= 1'b0;
            ALU0_IQ_source2_en[7] <= 1'b0;
            ALU0_IQ_source2_rdy[7] <= 1'b0;
            ALU0_IQ_dest[7] <= 7'd0;
            ALU0_IQ_source1[7] <= 7'd0;
            ALU0_IQ_source2[7] <= 7'd0;
            ALU0_IQ_op[7] <= 5'd0;
            ALU0_IQ_imm[7] <= 20'd0;
            ALU0_IQ_ROB_ID[7] <= 20'd0;
        end
        else begin
            if((ALU0_IQ_source1[7] == dest_ALU1) || (ALU0_IQ_source1[7] == dest_AGU) ||
               (ALU0_IQ_source1[7] == dest_BRU))
                ALU0_IQ_source1_rdy[7] <= 1'b1;
            if((ALU0_IQ_source2[7] == dest_ALU1) || (ALU0_IQ_source2[7] == dest_AGU) ||
               (ALU0_IQ_source2[7] == dest_BRU))
                ALU0_IQ_source2_rdy[7] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // out
        if((!rst_n) || flush)begin
            ALU0_select_vld <= 1'b0;
            ALU0_select_op <= 5'd0;
            ALU0_select_imm <= 20'd0;
            ALU0_select_dest <= 7'd0;
            ALU0_select_source1 <= 7'd0;
            ALU0_select_source2 <= 7'd0;
            ALU0_select_ROB_ID <= 6'd0;
        end
        else case (grant_excute)
            8'b00000001: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[0];
                ALU0_select_imm <= ALU0_IQ_imm[0];
                ALU0_select_dest <= ALU0_IQ_dest[0];
                ALU0_select_source1 <= ALU0_IQ_source1[0];
                ALU0_select_source2 <= ALU0_IQ_source2[0];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[0];
            end
            8'b00000010: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[1];
                ALU0_select_imm <= ALU0_IQ_imm[1];
                ALU0_select_dest <= ALU0_IQ_dest[1];
                ALU0_select_source1 <= ALU0_IQ_source1[1];
                ALU0_select_source2 <= ALU0_IQ_source2[1];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[1];
            end
            8'b00000100: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[2];
                ALU0_select_imm <= ALU0_IQ_imm[2];
                ALU0_select_dest <= ALU0_IQ_dest[2];
                ALU0_select_source1 <= ALU0_IQ_source1[2];
                ALU0_select_source2 <= ALU0_IQ_source2[2];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[2];
            end
            8'b00001000: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[3];
                ALU0_select_imm <= ALU0_IQ_imm[3];
                ALU0_select_dest <= ALU0_IQ_dest[3];
                ALU0_select_source1 <= ALU0_IQ_source1[3];
                ALU0_select_source2 <= ALU0_IQ_source2[3];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[3];
            end
            8'b00010000: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[4];
                ALU0_select_imm <= ALU0_IQ_imm[4];
                ALU0_select_dest <= ALU0_IQ_dest[4];
                ALU0_select_source1 <= ALU0_IQ_source1[4];
                ALU0_select_source2 <= ALU0_IQ_source2[4];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[4];
            end
            8'b00100000: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[5];
                ALU0_select_imm <= ALU0_IQ_imm[5];
                ALU0_select_dest <= ALU0_IQ_dest[5];
                ALU0_select_source1 <= ALU0_IQ_source1[5];
                ALU0_select_source2 <= ALU0_IQ_source2[5];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[5];
            end
            8'b01000000: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[6];
                ALU0_select_imm <= ALU0_IQ_imm[6];
                ALU0_select_dest <= ALU0_IQ_dest[6];
                ALU0_select_source1 <= ALU0_IQ_source1[6];
                ALU0_select_source2 <= ALU0_IQ_source2[6];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[6];
            end
            8'b10000000: begin
                ALU0_select_vld <= 1'b1;
                ALU0_select_op <= ALU0_IQ_op[7];
                ALU0_select_imm <= ALU0_IQ_imm[7];
                ALU0_select_dest <= ALU0_IQ_dest[7];
                ALU0_select_source1 <= ALU0_IQ_source1[7];
                ALU0_select_source2 <= ALU0_IQ_source2[7];
                ALU0_select_ROB_ID <= ALU0_IQ_ROB_ID[7];
            end
            default: ALU0_select_vld <= 1'b0;
        endcase 
    end

endmodule