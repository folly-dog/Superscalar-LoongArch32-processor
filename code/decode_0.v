module decode_0 (
    input               clk,
    input               rst_n,

    input               flush_stage3,
    input               hold_stage3,
    input        [1:0]  except_stage2,

    input       [31:0]  PC_stage2,

    input               instruction_vld,
    input       [31:0]  instruction,

    output  reg [31:0]  PC_stage3,
    output  reg [14:0]  except_code_stage3,

    output  reg         decode_vld,
    output  reg  [3:0]  IQ_choose,      // 0000无需写入IQ

    output  reg [4:0]   ALU0_op,
    output  reg [2:0]   ALU1_op,        // 乘除取余
    output  reg [3:0]   AGU_op,
    output  reg [3:0]   BRU_op,

    output  reg [3:0]   ROB_op,         // retire时，ROB需要进行一些操作，包括store指令和一些特权指令

    output  reg [19:0]  ALU0_imm,       // 正常为12 bit, 将load立即数功能加入其中
    output  reg [13:0]  AGU_imm,        
    output  reg [25:0]  BRU_imm,        // 正常为16/26 bit, 将PCADDU加入其中

    input       [31:0]  instruction_target_stage2,
    output  reg [31:0]  instruction_target_stage3,

    output  reg         destina_reg_en,
    output  reg [4:0]   destina_reg,
    output  reg         source1_reg_en,
    output  reg [4:0]   source1_reg,
    output  reg         source2_reg_en,
    output  reg [4:0]   source2_reg,

);  
    wire [31:0] PC_stage3_wire;

    reg  [14:0]  except_code_stage3_wire;

    wire        decode_vld_wire;
    reg  [3:0]  IQ_choose_wire;      // 0000无需写入IQ
    reg         PLV_wire;
    reg  [3:0]  ROB_op_wire;

    reg  [4:0]   ALU0_op_wire;
    reg  [2:0]   ALU1_op_wire;        // 乘除取余
    reg  [3:0]   AGU_op_wire;
    reg  [3:0]   BRU_op_wire;

    wire [19:0]  ALU0_imm_wire;      // 正常为12 bit_wire; 将load立即数功能加入其中
    wire [13:0]  AGU_imm_wire;        
    reg  [25:0]  BRU_imm_wire;        // 正常为16/26 bit_wire; 将PCADDU加入其中

    wire [31:0]  instruction_target_stage3_wire;

    reg          destina_reg_en_wire;
    reg  [4:0]   destina_reg_wire;
    reg          source1_reg_en_wire;
    reg  [4:0]   source1_reg_wire;
    reg          source2_reg_en_wire;
    reg  [4:0]   source2_reg_wire;

    wire ERTN;
    wire IDLE;
    wire BREAK;
    wire SYSCALL;
    wire DBAR;
    wire IBAR;

    assign ERTN = (instruction == 32'b00000110010010000011010000000000);
    assign IDLE = (instruction[31:15] == 17'b000001100100101);
    assign BREAK = (instruction[31:15] == 17'b00000000001010100);
    assign SYSCALL = (instruction[31:15] == 17'b00000000001010110);
    assign DBAR = (instruction[31:15] == 17'b00111000011100100);
    assign IBAR = (instruction[31:15] == 17'b00111000011100101);

    assign PC_stage3_wire = {PC_stage2[31:4], 2'b00, 2'b00};

    assign decode_vld_wire = (instruction_vld && 
                (BREAK || SYSCALL || PLV_wire || DBAR || IBAR || (|IQ_choose_wire)));  // decode_vld_wire

    always @(*) begin           // except_code_stage3_wire
        if(|except_stage2)
            except_code_stage3_wire = {13'd0,except_stage2};
        else if(BREAK | SYSCALL)
            except_code_stage3_wire = (instruction[14:0]);
        else
            except_code_stage3_wire = 15'd0;
    end

    always @(*) begin           // IQ_choose_wire
        if(!instruction_vld)
            IQ_choose_wire = 4'b0000;
        else
            case (instruction[30])
                1'b1: IQ_choose_wire = 4'b0001;
                1'b0:
                    case (instruction[29:28])
                        2'b10: IQ_choose_wire = 4'b0010;
                        2'b01: IQ_choose_wire = instruction[27] ? 4'b0001 : 4'b1000;
                        2'b11: IQ_choose_wire = 4'b0000;
                        2'b00:
                            case (instruction[27:26])
                                2'b01: 
                                    case (instruction[25:24])
                                    2'b00: IQ_choose_wire = 4'b0010;
                                    2'b10: begin
                                        if(instruction[23:22] == 2'b00)
                                            IQ_choose_wire = 4'b0010;
                                        else if (instruction[23:15] == 9'b010010011)
                                            IQ_choose_wire = 4'b0010;
                                        else
                                            IQ_choose_wire = 4'b0000;
                                    end
                                    default: IQ_choose_wire = 4'b0000;
                                endcase
                                default: IQ_choose_wire = 4'b0000;
                                2'b00:begin
                                    if(instruction[25])begin
                                        if((instruction[24:22] == 3'b011) || (instruction[24:22] == 3'b100))
                                            IQ_choose_wire = 4'b0000;
                                        else
                                            IQ_choose_wire = 4'b1000;
                                    end
                                    else if(instruction[24:22] = 3'b000) begin
                                        if(instruction[21])begin
                                            if(instruction[20:17] = 4'b0000)
                                                IQ_choose_wire = 4'b0100;
                                            else
                                                IQ_choose_wire = 4'b0000;
                                        end
                                        else
                                            case (instruction[20:17])
                                                4'b1110: IQ_choose_wire = 4'b0100;
                                                4'b1100: IQ_choose_wire = 4'b1000;
                                                4'b1011: IQ_choose_wire = 4'b1000;
                                                4'b1010: IQ_choose_wire = 4'b1000;
                                                4'b1100: IQ_choose_wire = 4'b1000;
                                                4'b1001: IQ_choose_wire = 4'b1000;
                                                4'b1000: IQ_choose_wire = 4'b1000;
                                                4'b0000: begin
                                                    if({instruction[16:10], instruction[4:0]} == 12'b001100000000)
                                                        IQ_choose_wire = 4'b1000;
                                                    else if(instruction[16:5] == 12'b001100000000)
                                                        IQ_choose_wire = 4'b1000;
                                                    else if(instruction[16:5] == 12'b001100100000)
                                                        IQ_choose_wire = 4'b1000;
                                                    else
                                                        IQ_choose_wire = 4'b0000;
                                                end
                                                default: IQ_choose_wire = 4'b0000;
                                            endcase
                                    end
                                    else if(instruction[22] && ({instruction[21:20],instruction[17:15]} == 5'b00001))begin
                                        case (instruction[19:18])
                                            2'b00: IQ_choose_wire = 4'b1000;
                                            2'b01: IQ_choose_wire = 4'b1000;
                                            2'b10: IQ_choose_wire = 4'b1000;
                                            default: IQ_choose_wire = 4'b0000;
                                        endcase
                                    end
                                    else
                                        IQ_choose_wire = 4'b0000;
                                end
                            endcase
                    endcase
                default: IQ_choose_wire = 4'b0000;
            endcase
    end

    always @(*) begin           // PLV_wire
        if(!instruction_vld)
            PLV_wire = 1'b0;
        else if (ERTN)
            PLV_wire = 1'b1;
        else if (IDLE)
            PLV_wire = 1'b1;
        else begin
            if(instruction[31:26] == 6'b000001)begin
                if(instruction[25:24] == 2'b00)
                    PLV_wire = 1'b1;
                else if(instruction[25:24] == 2'b10)begin
                    if(instruction[23:22] == 2'b00)
                        PLV_wire = 1'b1;
                    else if(instruction[23:22] == 2'b01)begin
                        if((instruction[21:13] == 9'b001000001) && (instruction[9:0] == 10'b0))begin
                            case (instruction[12:10])
                                3'b010: PLV_wire = 1'b1;
                                3'b011: PLV_wire = 1'b1;
                                3'b100: PLV_wire = 1'b1;
                                3'b101: PLV_wire = 1'b1;
                                3'b110: PLV_wire = 1'b1;
                                default: PLV_wire = 1'b0;
                            endcase
                        end
                        else
                            PLV_wire = 1'b0;
                    end
                    else
                        PLV_wire = 1'b0;
                end
                else
                    PLV_wire = 1'b0;
            end
            else
                PLV_wire = 1'b0;
        end
    end

    always @(*) begin           // ALU0_op_wire
        if(IQ_choose_wire == 4'b1000)begin
            if(instruction[28])
                ALU0_op_wire = 5'b00000;     // LU12I
            else if(instruction[25])
                case (instruction[24:22])
                    3'b000: ALU0_op_wire = 5'b00001;     // SLTI
                    3'b001: ALU0_op_wire = 5'b00010;     // SLTUI
                    3'b010: ALU0_op_wire = 5'b00011;     // ADDI.W
                    3'b101: ALU0_op_wire = 5'b00100;     // ANDI
                    3'b110: ALU0_op_wire = 5'b00101;     // ORI
                    3'b111: ALU0_op_wire = 5'b00110;     // XORI
                    default: ALU0_op_wire = 5'b00000;
                endcase
            else if(instruction[22])
                case (instruction[19:18])
                    2'b00: ALU0_op_wire = 5'b10101;     // SLLI.W
                    2'b01: ALU0_op_wire = 5'b10110;     // SRLI.W
                    2'b10: ALU0_op_wire = 5'b10111;     // SRAI.W
                    default: ALU0_op_wire = 5'b00000;
                endcase
            else if(instruction[20])
                case (instruction[19:15])
                    5'b00000: ALU0_op_wire = 5'b00111;     // ADD.W
                    5'b00010: ALU0_op_wire = 5'b01000;     // SUB.W
                    5'b00100: ALU0_op_wire = 5'b01001;     // SLT
                    5'b00101: ALU0_op_wire = 5'b01010;     // SLTU
                    5'b01000: ALU0_op_wire = 5'b01011;     // NOR
                    5'b01001: ALU0_op_wire = 5'b01100;     // AND
                    5'b01010: ALU0_op_wire = 5'b01101;     // OR
                    5'b01011: ALU0_op_wire = 5'b01110;     // XOR
                    5'b01110: ALU0_op_wire = 5'b01111;     // SLL.W
                    5'b01111: ALU0_op_wire = 5'b10000;     // SRL.W
                    5'b10000: ALU0_op_wire = 5'b10001;     // SRA.W
                    default: ALU0_op_wire = 5'b00000;
                endcase
            else begin
                if(instruction[10])
                    ALU0_op_wire = 5'b10010;     // RDCNTVH.W
                else if(instruction[4:0] == 5'b00000)
                    ALU0_op_wire = 5'b10100;     // RDCNTID
                else
                    ALU0_op_wire = 5'b10011;     // RDCNTVL.W
            end
        end
        else
            ALU0_op_wire = 5'b00000;
    end

    always @(*) begin           // ALU1_op_wire
        if(IQ_choose_wire == 4'b0100)begin
            if(instruction[21])
                case (instruction[16:15])
                    2'b00: ALU1_op_wire = 3'b000;   // DIV.W
                    2'b01: ALU1_op_wire = 3'b001;   // MOD.W
                    2'b10: ALU1_op_wire = 3'b010;   // DIVU.W
                    2'b11: ALU1_op_wire = 3'b011;   // MODU.W
                endcase
            else
                case (instruction[16:15])
                    2'b00: ALU1_op_wire = 3'b100;   // MUL.W
                    2'b01: ALU1_op_wire = 3'b101;   // MULH.W
                    2'b10: ALU1_op_wire = 3'b110;   // MULHU.W
                    2'b11: ALU1_op_wire = 3'b000;   // NOP
                endcase
        end
        else
            ALU1_op_wire = 3'b000;
    end

    always @(*) begin           // AGU_op_wire
        if(IQ_choose_wire == 4'b0010)begin
            if(PLV_wire)begin
                if(instruction[25])begin
                    if(instruction[22])
                        AGU_op_wire = 4'b0000;  // INVTLB
                    else
                        AGU_op_wire = 4'b0001;  // CACOP
                end
                else if(instruction[9:5] == 5'd0)
                    AGU_op_wire = 4'b0010;      // CSRRD
                else if(instruction[9:5] == 5'd1)
                    AGU_op_wire = 4'b0011;      // CSRWR
                else
                    AGU_op_wire = 4'b0100;      // CSRXCHG
            end
            if(!instruction[27])begin
                if(!instruction[25])
                    AGU_op_wire = 4'b0101;      // LL.W
                else
                    AGU_op_wire = 4'b0110;      // SC.W
            end
            else
                case (instruction[25:22])
                    4'b0000:    AGU_op_wire = 4'b0111;      // LD.B
                    4'b0001:    AGU_op_wire = 4'b1000;      // LD.H
                    4'b0010:    AGU_op_wire = 4'b1001;      // LD.W
                    4'b0100:    AGU_op_wire = 4'b1010;      // ST.B
                    4'b0101:    AGU_op_wire = 4'b1011;      // ST.H
                    4'b0110:    AGU_op_wire = 4'b1100;      // ST.W
                    4'b1000:    AGU_op_wire = 4'b1101;      // LD.BU
                    4'b1001:    AGU_op_wire = 4'b1110;      // LD.HU
                    4'b1011:    AGU_op_wire = 4'b1111;      // PRELD
                endcase
        end
        else
            AGU_op_wire = 4'b0000;
    end

    always @(*) begin           // BRU_op_wire
        if(IQ_choose_wire == 4'b0001)
            if(!instruction[30])
                BRU_op_wire = 4'b0000;  // PCADDU12I
            else
                case (instruction[29:26])
                    4'b0011:    AGU_op_wire = 4'b0001;      // JIRL
                    4'b0100:    AGU_op_wire = 4'b0010;      // B
                    4'b0101:    AGU_op_wire = 4'b0011;      // BL
                    4'b0110:    AGU_op_wire = 4'b0100;      // BEQ
                    4'b0111:    AGU_op_wire = 4'b0101;      // BNE
                    4'b1000:    AGU_op_wire = 4'b0110;      // BLT
                    4'b1001:    AGU_op_wire = 4'b0111;      // BGE
                    4'b1010:    AGU_op_wire = 4'b1000;      // BLTU
                    4'b1011:    AGU_op_wire = 4'b1001;      // BGU
                    default:    BRU_op_wire = 4'b0000;      // nop
                endcase
        else
            BRU_op_wire = 4'b0000;
    end

    assign ALU0_imm_wire = instruction[28] ? instruction[24:5] : {8'd0, instruction[21:10]};

    assign AGU_imm_wire = instruction[23:10];       // AGU_imm_wire

    always @(*) begin           // BRU_imm_wire
        if(IQ_choose_wire == 4'b0001)begin
            if(!instruction[30])
                BRU_imm_wire = {6'd0, instruction[24:5]};
            else if(instruction[29:27] = 3'b010)
                BRU_imm_wire = {instruction[9:0], instruction[25:10]};
            else
                BRU_imm_wire = {10'd0, instruction[25:10]};
        end
        else
            BRU_imm_wire = 26'd0;
    end

    assign instruction_target_stage3_wire = PC_stage2;

    always @(*) begin           // ROB_op
        if(BREAK)
            ROB_op = 4'd1;  // break
        else if(SYSCALL)
            ROB_op = 4'd2;  // syscall
        else 
            case (instruction[29:24])
                6'b101001: ROB_op = (instruction[23:22] == 2'b11) ? 4'd0 : 4'd3;    // store类
                6'b000100: 
                    case (instruction[9:5])
                        5'd0:   ROB_op = 4'd4;  // CSRRD
                        5'd1:   ROB_op = 4'd5;  // CSRWR
                        default: ROB_op = 4'd6; // CSRXCHG
                    endcase
                6'b000110:
                    case (instruction[23:22])
                        2'b00: ROB_op = 4'd7;   // CACOP
                        2'b01:begin
                            if(instruction[21:13], instruction[9:0] == 19'b0010000010000000000)
                                case (instruction[12:10])
                                    3'b010: ROB_op = 4'd8;   // TLBSRCH
                                    3'b011: ROB_op = 4'd9;   // TLBRD
                                    3'b100: ROB_op = 4'd10;   // TLBWR
                                    3'b101: ROB_op = 4'd11;   // TLBFILL
                                    3'b110: ROB_op = 4'd12;   // ERTN
                                    default: ROB_op = 4'd0;
                                endcase
                            else if(instruction[15])begin
                                if(!instruction[16])
                                    ROB_op = 4'd13;   // IDLE
                                else
                                    ROB_op = 4'd14;   // INVTLB
                            end
                            else
                                ROB_op = 4'd0;
                        end
                        default: ROB_op = 4'd0;
                    endcase
                default: ROB_op = 4'd0;
            endcase
    end



endmodule