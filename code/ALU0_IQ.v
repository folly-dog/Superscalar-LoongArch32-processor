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
    reg [6:0]   ALU0_IQ_dest    [7:0];
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

    assign grant_excute = req_excute & ((~req_excute) + 1);

    assign converse_vld = {ALU0_IQ_vld[0], ALU0_IQ_vld[1], ALU0_IQ_vld[2], ALU0_IQ_vld[3], 
                           ALU0_IQ_vld[4], ALU0_IQ_vld[5], ALU0_IQ_vld[6], ALU0_IQ_vld[7]};
    assign converse_last_vld = converse_vld & ((~converse_vld) + 1);
    assign last_vld = {converse_last_vld[0], converse_last_vld[1], converse_last_vld[2], converse_last_vld[3], 
                       converse_last_vld[4], converse_last_vld[5], converse_last_vld[6], converse_last_vld[7]};

    assign first_wr_onehot = (|grant_excute) ? last_vld : ((last_vld == 8'd0) ? 8'd1 : (last_vld << 1));

    always @(*) begin       // wr_en
        case (first_wr_onehot)
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

endmodule