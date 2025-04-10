module ALU1_IQ (
    input               clk,
    input               rst_n,

    input               flush,

    input               inst0_ALU1_en,
    input               inst0_PR_source1_rdy,
    input               inst0_PR_source2_rdy,
    input       [6:0]   inst0_PR_dest,
    input       [6:0]   inst0_PR_source1,
    input       [6:0]   inst0_PR_source2,
    input       [2:0]   inst0_ALU1_op,
    input       [5:0]   inst0_ROB_ID,

    input               inst1_ALU1_en,
    input               inst1_PR_source1_rdy,
    input               inst1_PR_source2_rdy,
    input       [6:0]   inst1_PR_dest,
    input       [6:0]   inst1_PR_source1,
    input       [6:0]   inst1_PR_source2,
    input       [2:0]   inst1_ALU1_op,
    input       [5:0]   inst1_ROB_ID,

    input               inst2_ALU1_en,
    input               inst2_PR_source1_rdy,
    input               inst2_PR_source2_rdy,
    input       [6:0]   inst2_PR_dest,
    input       [6:0]   inst2_PR_source1,
    input       [6:0]   inst2_PR_source2,
    input       [2:0]   inst2_ALU1_op,
    input       [5:0]   inst2_ROB_ID,

    input               inst3_ALU1_en,
    input               inst3_PR_source1_rdy,
    input               inst3_PR_source2_rdy,
    input       [6:0]   inst3_PR_dest,
    input       [6:0]   inst3_PR_source1,
    input       [6:0]   inst3_PR_source2,
    input       [2:0]   inst3_ALU1_op,
    input       [5:0]   inst3_ROB_ID,

    output              wr_ALU1_IQ_pause,
    input               wr_pause,

    input       [6:0]   dest_ALU0,
    input       [6:0]   dest_ALU1,
    input       [6:0]   dest_AGU,
    input       [6:0]   dest_BRU,

    output  reg         ALU1_select_vld,
    output  reg [2:0]   ALU1_select_op,
    output  reg [6:0]   ALU1_select_dest,
    output  reg [6:0]   ALU1_select_source1,
    output  reg [6:0]   ALU1_select_source2,
    output  reg [5:0]   ALU1_select_ROB_ID
);
    reg [3:0]   ALU1_IQ_vld;
    reg [3:0]   ALU1_IQ_source1_rdy;
    reg [3:0]   ALU1_IQ_source2_rdy;
    reg [6:0]   ALU1_IQ_dest    [3:0];
    reg [6:0]   ALU1_IQ_source1 [3:0];
    reg [6:0]   ALU1_IQ_source2 [3:0];
    reg [5:0]   ALU1_IQ_ROB_ID  [3:0];
    reg [2:0]   ALU1_IQ_op      [3:0];

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

    assign room_need = inst0_ALU1_en + inst1_ALU1_en + inst2_ALU1_en + inst3_ALU1_en;
    assign room_have = (!ALU1_IQ_vld[0]) + (!ALU1_IQ_vld[1]) + (!ALU1_IQ_vld[2]) + (!ALU1_IQ_vld[3]) + 
                       (|grant_excute);

    assign wr_ALU1_IQ_pause = (room_need > room_have);

    assign req_excute[0] = ALU1_IQ_vld[0] & ALU1_IQ_source1_rdy[0] & ALU1_IQ_source2_rdy[0];
    assign req_excute[1] = ALU1_IQ_vld[1] & ALU1_IQ_source1_rdy[1] & ALU1_IQ_source2_rdy[1];
    assign req_excute[2] = ALU1_IQ_vld[2] & ALU1_IQ_source1_rdy[2] & ALU1_IQ_source2_rdy[2];
    assign req_excute[3] = ALU1_IQ_vld[3] & ALU1_IQ_source1_rdy[3] & ALU1_IQ_source2_rdy[3];

    assign grant_excute = wr_pause ? 4'd0 : ( req_excute & ((~req_excute) + 1));

    assign converse_vld  = {ALU1_IQ_vld[0], ALU1_IQ_vld[1], ALU1_IQ_vld[2], ALU1_IQ_vld[3]};
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
            4'b0001: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            4'b0001: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            4'b0010: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            4'b0001: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
                4'b1111: wr_from[2] = 2'b10;
                4'b1110: wr_from[2] = 2'b10;
                4'b1101: wr_from[2] = 2'b11;
                4'b1011: wr_from[2] = 2'b11;
                4'b0111: wr_from[2] = 2'b11;
                default: wr_from[2] = 2'b00;
            endcase
            4'b0010: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            4'b0100: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            4'b0001: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
                4'b1111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            4'b0010: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
                4'b1111: wr_from[3] = 2'b10;
                4'b1110: wr_from[3] = 2'b10;
                4'b1101: wr_from[3] = 2'b11;
                4'b1011: wr_from[3] = 2'b11;
                4'b0111: wr_from[3] = 2'b11;
                default: wr_from[3] = 2'b00;
            endcase
            4'b0100: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            4'b1000: casez ({inst0_ALU1_en, inst1_ALU1_en, inst2_ALU1_en, inst3_ALU1_en})
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
            ALU1_IQ_vld[0] <= 1'b0;
            ALU1_IQ_source1_rdy[0] <= 1'b0;
            ALU1_IQ_source2_rdy[0] <= 1'b0;
        end
        else if(wr_en[0])
            case (wr_from[0])
                2'b00:begin
                    ALU1_IQ_vld[0] <= 1'b1;
                    ALU1_IQ_source1_rdy[0] <= inst0_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[0] <= inst0_PR_source2_rdy;
                    ALU1_IQ_dest[0] <= inst0_PR_dest;
                    ALU1_IQ_source1[0] <= inst0_PR_source1;
                    ALU1_IQ_source2[0] <= inst0_PR_source2;
                    ALU1_IQ_op[0] <= inst0_ALU1_op;
                    ALU1_IQ_ROB_ID[0] <= inst0_ROB_ID;
                end
                2'b01:begin
                    ALU1_IQ_vld[0] <= 1'b1;
                    ALU1_IQ_source1_rdy[0] <=  inst1_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[0] <=  inst1_PR_source2_rdy;
                    ALU1_IQ_dest[0] <=  inst1_PR_dest;
                    ALU1_IQ_source1[0] <=  inst1_PR_source1;
                    ALU1_IQ_source2[0] <=  inst1_PR_source2;
                    ALU1_IQ_op[0] <=  inst1_ALU1_op;
                    ALU1_IQ_ROB_ID[0] <=  inst1_ROB_ID;
                end
                2'b10:begin
                    ALU1_IQ_vld[0] <= 1'b1;
                    ALU1_IQ_source1_rdy[0] <=  inst2_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[0] <=  inst2_PR_source2_rdy;
                    ALU1_IQ_dest[0] <=  inst2_PR_dest;
                    ALU1_IQ_source1[0] <=  inst2_PR_source1;
                    ALU1_IQ_source2[0] <=  inst2_PR_source2;
                    ALU1_IQ_op[0] <=  inst2_ALU1_op;
                    ALU1_IQ_ROB_ID[0] <=  inst2_ROB_ID;
                end
                2'b11:begin
                    ALU1_IQ_vld[0] <= 1'b1;
                    ALU1_IQ_source1_rdy[0] <=  inst3_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[0] <=  inst3_PR_source2_rdy;
                    ALU1_IQ_dest[0] <=  inst3_PR_dest;
                    ALU1_IQ_source1[0] <=  inst3_PR_source1;
                    ALU1_IQ_source2[0] <=  inst3_PR_source2;
                    ALU1_IQ_op[0] <=  inst3_ALU1_op;
                    ALU1_IQ_ROB_ID[0] <=  inst3_ROB_ID;
                end
            endcase
        else if(grant_excute[0])begin
             ALU1_IQ_vld[0] <=  ALU1_IQ_vld[1];
             ALU1_IQ_dest[0] <=  ALU1_IQ_dest[1];
             ALU1_IQ_source1[0] <=  ALU1_IQ_source1[1];
             ALU1_IQ_source2[0] <=  ALU1_IQ_source2[1];
             ALU1_IQ_op[0] <=  ALU1_IQ_op[1];
             ALU1_IQ_ROB_ID[0] <=  ALU1_IQ_ROB_ID[1];
            if(( ALU1_IQ_source1[1] == dest_ALU0) || ( ALU1_IQ_source1[1] == dest_AGU) ||
               ( ALU1_IQ_source1[1] == dest_BRU)  || ( ALU1_IQ_source1[1] == dest_ALU1))
                 ALU1_IQ_source1_rdy[0] <= 1'b1;
            if(( ALU1_IQ_source2[1] == dest_ALU0) || ( ALU1_IQ_source2[1] == dest_AGU) ||
               ( ALU1_IQ_source2[1] == dest_BRU)  || ( ALU1_IQ_source2[1] == dest_ALU1))
                 ALU1_IQ_source2_rdy[0] <= 1'b1;
        end
        else begin
            if(( ALU1_IQ_source1[0] == dest_ALU0) || ( ALU1_IQ_source1[0] == dest_AGU) ||
               ( ALU1_IQ_source1[0] == dest_BRU)  || ( ALU1_IQ_source1[0] == dest_ALU1))
                 ALU1_IQ_source1_rdy[0] <= 1'b1;
            if(( ALU1_IQ_source2[0] == dest_ALU0) || ( ALU1_IQ_source2[0] == dest_AGU) ||
               ( ALU1_IQ_source2[0] == dest_BRU)  || ( ALU1_IQ_source2[0] == dest_ALU1))
                 ALU1_IQ_source2_rdy[0] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin    // entry1
        if((!rst_n) || flush)begin
            ALU1_IQ_vld[1] <= 1'b0;
            ALU1_IQ_source1_rdy[1] <= 1'b0;
            ALU1_IQ_source2_rdy[1] <= 1'b0;
        end
        else if(wr_en[1])
            case (wr_from[1])
                2'b00:begin
                    ALU1_IQ_vld[1] <= 1'b1;
                    ALU1_IQ_source1_rdy[1] <= inst0_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[1] <= inst0_PR_source2_rdy;
                    ALU1_IQ_dest[1] <= inst0_PR_dest;
                    ALU1_IQ_source1[1] <= inst0_PR_source1;
                    ALU1_IQ_source2[1] <= inst0_PR_source2;
                    ALU1_IQ_op[1] <= inst0_ALU1_op;
                    ALU1_IQ_ROB_ID[1] <= inst0_ROB_ID;
                end
                2'b01:begin
                    ALU1_IQ_vld[1] <= 1'b1;
                    ALU1_IQ_source1_rdy[1] <= inst1_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[1] <= inst1_PR_source2_rdy;
                    ALU1_IQ_dest[1] <= inst1_PR_dest;
                    ALU1_IQ_source1[1] <= inst1_PR_source1;
                    ALU1_IQ_source2[1] <= inst1_PR_source2;
                    ALU1_IQ_op[1] <= inst1_ALU1_op;
                    ALU1_IQ_ROB_ID[1] <= inst1_ROB_ID;
                end
                2'b10:begin
                    ALU1_IQ_vld[1] <= 1'b1;
                    ALU1_IQ_source1_rdy[1] <= inst2_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[1] <= inst2_PR_source2_rdy;
                    ALU1_IQ_dest[1] <= inst2_PR_dest;
                    ALU1_IQ_source1[1] <= inst2_PR_source1;
                    ALU1_IQ_source2[1] <= inst2_PR_source2;
                    ALU1_IQ_op[1] <= inst2_ALU1_op;
                    ALU1_IQ_ROB_ID[1] <= inst2_ROB_ID;
                end
                2'b11:begin
                    ALU1_IQ_vld[1] <= 1'b1;
                    ALU1_IQ_source1_rdy[1] <= inst3_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[1] <= inst3_PR_source2_rdy;
                    ALU1_IQ_dest[1] <= inst3_PR_dest;
                    ALU1_IQ_source1[1] <= inst3_PR_source1;
                    ALU1_IQ_source2[1] <= inst3_PR_source2;
                    ALU1_IQ_op[1] <= inst3_ALU1_op;
                    ALU1_IQ_ROB_ID[1] <= inst3_ROB_ID;
                end
            endcase
        else if(grant_excute[1] | grant_excute[0])begin
             ALU1_IQ_vld[1] <= ALU1_IQ_vld[2];
             ALU1_IQ_dest[1] <= ALU1_IQ_dest[2];
             ALU1_IQ_source1[1] <= ALU1_IQ_source1[2];
             ALU1_IQ_source2[1] <= ALU1_IQ_source2[2];
             ALU1_IQ_op[1] <= ALU1_IQ_op[2];
             ALU1_IQ_ROB_ID[1] <= ALU1_IQ_ROB_ID[2];
            if(( ALU1_IQ_source1[2] == dest_ALU0) || ( ALU1_IQ_source1[2] == dest_AGU) ||
               ( ALU1_IQ_source1[2] == dest_BRU)  || ( ALU1_IQ_source1[2] == dest_ALU1))
                 ALU1_IQ_source1_rdy[1] <= 1'b1;
            if(( ALU1_IQ_source2[2] == dest_ALU0) || ( ALU1_IQ_source2[2] == dest_AGU) ||
               ( ALU1_IQ_source2[2] == dest_BRU)  || ( ALU1_IQ_source2[2] == dest_ALU1))
                 ALU1_IQ_source2_rdy[1] <= 1'b1;
        end
        else begin
            if(( ALU1_IQ_source1[1] == dest_ALU0) || ( ALU1_IQ_source1[1] == dest_AGU) ||
               ( ALU1_IQ_source1[1] == dest_BRU)  || ( ALU1_IQ_source1[1] == dest_ALU1))
                 ALU1_IQ_source1_rdy[1] <= 1'b1;
            if(( ALU1_IQ_source2[1] == dest_ALU0) || ( ALU1_IQ_source2[1] == dest_AGU) ||
               ( ALU1_IQ_source2[1] == dest_BRU)  || ( ALU1_IQ_source2[1] == dest_ALU1))
                 ALU1_IQ_source2_rdy[1] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin    // entry2
        if((!rst_n) || flush)begin
            ALU1_IQ_vld[2] <= 1'b0;
            ALU1_IQ_source1_rdy[2] <= 1'b0;
            ALU1_IQ_source2_rdy[2] <= 1'b0;
        end
        else if(wr_en[2])
            case (wr_from[2])
                2'b00:begin
                    ALU1_IQ_vld[2] <= 1'b1;
                    ALU1_IQ_source1_rdy[2] <= inst0_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[2] <= inst0_PR_source2_rdy;
                    ALU1_IQ_dest[2] <= inst0_PR_dest;
                    ALU1_IQ_source1[2] <= inst0_PR_source1;
                    ALU1_IQ_source2[2] <= inst0_PR_source2;
                    ALU1_IQ_op[2] <= inst0_ALU1_op;
                    ALU1_IQ_ROB_ID[2] <= inst0_ROB_ID;
                end
                2'b01:begin
                    ALU1_IQ_vld[2] <= 1'b1;
                    ALU1_IQ_source1_rdy[2] <= inst1_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[2] <= inst1_PR_source2_rdy;
                    ALU1_IQ_dest[2] <= inst1_PR_dest;
                    ALU1_IQ_source1[2] <= inst1_PR_source1;
                    ALU1_IQ_source2[2] <= inst1_PR_source2;
                    ALU1_IQ_op[2] <= inst1_ALU1_op;
                    ALU1_IQ_ROB_ID[2] <= inst1_ROB_ID;
                end
                2'b10:begin
                    ALU1_IQ_vld[2] <= 1'b1;
                    ALU1_IQ_source1_rdy[2] <= inst2_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[2] <= inst2_PR_source2_rdy;
                    ALU1_IQ_dest[2] <= inst2_PR_dest;
                    ALU1_IQ_source1[2] <= inst2_PR_source1;
                    ALU1_IQ_source2[2] <= inst2_PR_source2;
                    ALU1_IQ_op[2] <= inst2_ALU1_op;
                    ALU1_IQ_ROB_ID[2] <= inst2_ROB_ID;
                end
                2'b11:begin
                    ALU1_IQ_vld[2] <= 1'b1;
                    ALU1_IQ_source1_rdy[2] <= inst3_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[2] <= inst3_PR_source2_rdy;
                    ALU1_IQ_dest[2] <= inst3_PR_dest;
                    ALU1_IQ_source1[2] <= inst3_PR_source1;
                    ALU1_IQ_source2[2] <= inst3_PR_source2;
                    ALU1_IQ_op[2] <= inst3_ALU1_op;
                    ALU1_IQ_ROB_ID[2] <= inst3_ROB_ID;
                end
            endcase
        else if(grant_excute[2] | grant_excute[1] | grant_excute[0])begin
             ALU1_IQ_vld[2] <= ALU1_IQ_vld[3];
             ALU1_IQ_dest[2] <= ALU1_IQ_dest[3];
             ALU1_IQ_source1[2] <= ALU1_IQ_source1[3];
             ALU1_IQ_source2[2] <= ALU1_IQ_source2[3];
             ALU1_IQ_op[2] <= ALU1_IQ_op[3];
             ALU1_IQ_ROB_ID[2] <= ALU1_IQ_ROB_ID[3];
            if(( ALU1_IQ_source1[3] == dest_ALU0) || ( ALU1_IQ_source1[3] == dest_AGU) ||
               ( ALU1_IQ_source1[3] == dest_BRU)  || ( ALU1_IQ_source1[3] == dest_ALU1))
                 ALU1_IQ_source1_rdy[2] <= 1'b1;
            if(( ALU1_IQ_source2[3] == dest_ALU0) || ( ALU1_IQ_source2[3] == dest_AGU) ||
               ( ALU1_IQ_source2[3] == dest_BRU)  || ( ALU1_IQ_source2[3] == dest_ALU1))
                 ALU1_IQ_source2_rdy[2] <= 1'b1;
        end
        else begin
            if(( ALU1_IQ_source1[2] == dest_ALU0) || ( ALU1_IQ_source1[2] == dest_AGU) ||
               ( ALU1_IQ_source1[2] == dest_BRU)  || ( ALU1_IQ_source1[2] == dest_ALU1))
                 ALU1_IQ_source1_rdy[2] <= 1'b1;
            if(( ALU1_IQ_source2[2] == dest_ALU0) || ( ALU1_IQ_source2[2] == dest_AGU) ||
               ( ALU1_IQ_source2[2] == dest_BRU)  || ( ALU1_IQ_source2[2] == dest_ALU1))
                 ALU1_IQ_source2_rdy[2] <= 1'b1;
        end
    end
    always @(posedge clk or negedge rst_n) begin    // entry3
        if((!rst_n) || flush)begin
            ALU1_IQ_vld[3] <= 1'b0;
            ALU1_IQ_source1_rdy[3] <= 1'b0;
            ALU1_IQ_source2_rdy[3] <= 1'b0;
        end
        else if(wr_en[3])
            case (wr_from[3])
                2'b00:begin
                    ALU1_IQ_vld[3] <= 1'b1;
                    ALU1_IQ_source1_rdy[3] <= inst0_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[3] <= inst0_PR_source2_rdy;
                    ALU1_IQ_dest[3] <= inst0_PR_dest;
                    ALU1_IQ_source1[3] <= inst0_PR_source1;
                    ALU1_IQ_source2[3] <= inst0_PR_source2;
                    ALU1_IQ_op[3] <= inst0_ALU1_op;
                    ALU1_IQ_ROB_ID[3] <= inst0_ROB_ID;
                end
                2'b01:begin
                    ALU1_IQ_vld[3] <= 1'b1;
                    ALU1_IQ_source1_rdy[3] <= inst1_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[3] <= inst1_PR_source2_rdy;
                    ALU1_IQ_dest[3] <= inst1_PR_dest;
                    ALU1_IQ_source1[3] <= inst1_PR_source1;
                    ALU1_IQ_source2[3] <= inst1_PR_source2;
                    ALU1_IQ_op[3] <= inst1_ALU1_op;
                    ALU1_IQ_ROB_ID[3] <= inst1_ROB_ID;
                end
                2'b10:begin
                    ALU1_IQ_vld[3] <= 1'b1;
                    ALU1_IQ_source1_rdy[3] <= inst2_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[3] <= inst2_PR_source2_rdy;
                    ALU1_IQ_dest[3] <= inst2_PR_dest;
                    ALU1_IQ_source1[3] <= inst2_PR_source1;
                    ALU1_IQ_source2[3] <= inst2_PR_source2;
                    ALU1_IQ_op[3] <= inst2_ALU1_op;
                    ALU1_IQ_ROB_ID[3] <= inst2_ROB_ID;
                end
                2'b11:begin
                    ALU1_IQ_vld[3] <= 1'b1;
                    ALU1_IQ_source1_rdy[3] <= inst3_PR_source1_rdy;
                    ALU1_IQ_source2_rdy[3] <= inst3_PR_source2_rdy;
                    ALU1_IQ_dest[3] <= inst3_PR_dest;
                    ALU1_IQ_source1[3] <= inst3_PR_source1;
                    ALU1_IQ_source2[3] <= inst3_PR_source2;
                    ALU1_IQ_op[3] <= inst3_ALU1_op;
                    ALU1_IQ_ROB_ID[3] <= inst3_ROB_ID;
                end
            endcase
        else if(|grant_excute)begin
            ALU1_IQ_vld[3] <= 1'b0;
            ALU1_IQ_dest[3] <= 7'd0;
            ALU1_IQ_source1[3] <= 7'd0;
            ALU1_IQ_source2[3] <= 7'd0;
            ALU1_IQ_op[3] <= 3'd0;
            ALU1_IQ_ROB_ID[3] <= 6'd0;
            ALU1_IQ_source1_rdy[3] <= 1'b0;
            ALU1_IQ_source2_rdy[3] <= 1'b0;
        end
        else begin
            if(( ALU1_IQ_source1[3] == dest_ALU0) || ( ALU1_IQ_source1[3] == dest_AGU) ||
               ( ALU1_IQ_source1[3] == dest_BRU)  || ( ALU1_IQ_source1[3] == dest_ALU1))
                 ALU1_IQ_source1_rdy[3] <= 1'b1;
            if(( ALU1_IQ_source2[3] == dest_ALU0) || ( ALU1_IQ_source2[3] == dest_AGU) ||
               ( ALU1_IQ_source2[3] == dest_BRU)  || ( ALU1_IQ_source2[3] == dest_ALU1))
                 ALU1_IQ_source2_rdy[3] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // out
        if((!rst_n) || flush)begin
            ALU1_select_vld <= 1'b0;
            ALU1_select_op <= 3'd0;
            ALU1_select_dest <= 7'd0;
            ALU1_select_source1 <= 7'd0;
            ALU1_select_source2 <= 7'd0;
            ALU1_select_ROB_ID <= 6'd0;
        end
        else case (grant_excute)
            4'b0001: begin
                ALU1_select_vld <= 1'b1;
                ALU1_select_op <= ALU1_IQ_op[0];
                ALU1_select_dest <= ALU1_IQ_dest[0];
                ALU1_select_source1 <= ALU1_IQ_source1[0];
                ALU1_select_source2 <= ALU1_IQ_source2[0];
                ALU1_select_ROB_ID <= ALU1_IQ_ROB_ID[0];
            end
            4'b0010: begin
                ALU1_select_vld <= 1'b1;
                ALU1_select_op <= ALU1_IQ_op[1];
                ALU1_select_dest <= ALU1_IQ_dest[1];
                ALU1_select_source1 <= ALU1_IQ_source1[1];
                ALU1_select_source2 <= ALU1_IQ_source2[1];
                ALU1_select_ROB_ID <= ALU1_IQ_ROB_ID[1];
            end
            4'b0100: begin
                ALU1_select_vld <= 1'b1;
                ALU1_select_op <= ALU1_IQ_op[2];
                ALU1_select_dest <= ALU1_IQ_dest[2];
                ALU1_select_source1 <= ALU1_IQ_source1[2];
                ALU1_select_source2 <= ALU1_IQ_source2[2];
                ALU1_select_ROB_ID <= ALU1_IQ_ROB_ID[2];
            end
            4'b1000: begin
                ALU1_select_vld <= 1'b1;
                ALU1_select_op <= ALU1_IQ_op[3];
                ALU1_select_dest <= ALU1_IQ_dest[3];
                ALU1_select_source1 <= ALU1_IQ_source1[3];
                ALU1_select_source2 <= ALU1_IQ_source2[3];
                ALU1_select_ROB_ID <= ALU1_IQ_ROB_ID[3];
            end
            default: ALU1_select_vld <= 1'b0;
        endcase 
    end
    
endmodule