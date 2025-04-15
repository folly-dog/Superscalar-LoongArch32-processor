module  excute_ALU0(
    input               clk,
    input               rst_n,       

    input               ALU0_vld,
    input       [4:0]   ALU0_op,
    input       [5:0]   ALU0_dest,
    input       [5:0]   ALU0_ROB_ID,
    input       [5:0]   ALU0_PR_source1,    // give next pipeline use for bypass
    input       [5:0]   ALU0_PR_source2,
    input       [31:0]  ALU0_data_source1,
    input       [31:0]  ALU0_data_source2,

    input       [63:0]  CNT,
    input       [31:0]  CNTID,

    input       [5:0]   ALU0_PR_bypass,     
    input       [31:0]  ALU0_data_bypass,  
    input       [5:0]   BRU_PR_bypass,     
    input       [31:0]  BRU_data_bypass,   

    output  reg         ALU0_result_vld,
    output  reg         ALU0_result_ROB_ID,
    output  reg [5:0]   ALU0_PR_result,
    output  reg [31:0]  ALU0_result
);

    wire [31:0] source1 = (ALU0_PR_source1 == ALU0_PR_bypass) ? ALU0_data_bypass :
                          (ALU0_PR_source1 == BRU_PR_bypass) ? BRU_data_bypass : ALU0_data_source1;

    wire [31:0] source2 = (ALU0_PR_source2 == ALU0_PR_bypass) ? ALU0_data_bypass :
                          (ALU0_PR_source2 == BRU_PR_bypass) ? BRU_data_bypass : ALU0_data_source2;

    wire [31:0] unsigned_imm32 = {20'd0, source2[11:0]};
    wire [31:0] signed_imm32 = {{20{source2[11]}}, source2[11:0]};
    wire [4:0]  unsigned_imm5 = source2[4:0];

    always@(posedge clk or negedge rst_n)begin      // ALU0_result_vld
        if(!rst_n)
            ALU0_result_vld <= 1'b0;
        else
            ALU0_result_vld <= ALU0_vld;
    end

    always@(posedge clk)begin      // ALU0_result_ROB_ID
        if(ALU0_vld)
            ALU0_result_ROB_ID <= ALU0_ROB_ID;
    end

    always@(posedge clk)begin      // ALU0_PR_result
        if(ALU0_vld)
            ALU0_PR_result <= ALU0_dest;
    end

    always@(posedge clk)begin       // ALU0_result
        if(ALU0_vld)begin
            case (ALU0_op)
                5'd0: ALU0_result <= {source2[19:0], 12'd0};
                5'd1: ALU0_result <= (source1[31] ^ signed_imm32[31]) ? {31'd0, source1[31]} : 
                                                                    (source1 < signed_imm32);
                5'd2: ALU0_result <= (source1 < unsigned_imm32);
                5'd3: ALU0_result <= source1 + signed_imm32;
                5'd4: ALU0_result <= (source1 & unsigned_imm32);
                5'd5: ALU0_result <= (source1 | unsigned_imm32);
                5'd6: ALU0_result <= (source1 ^ unsigned_imm32);
                5'd7: ALU0_result <= (source1 + source2);
                5'd8: ALU0_result <= (source1 - source2);
                5'd9: ALU0_result <= (source1[31] ^ source2[31]) ? {31'd0, source1[31]} : 
                                                                     (source1 < source2);
                5'd10:ALU0_result <= (source1 < source2);
                5'd11:ALU0_result <= ~(source1 | source2);
                5'd12:ALU0_result <= (source1 & source2);
                5'd13:ALU0_result <= (source1 | source2);
                5'd14:ALU0_result <= (source1 ^ source2);
                5'd15:ALU0_result <= (source1 << source2[4:0]);
                5'd16:ALU0_result <= (source1 >> source2[4:0]);
                5'd17:ALU0_result <= (source1 >>> source2[4:0]);
                5'd18:ALU0_result <= CNT[63:32];
                5'd19:ALU0_result <= CNT[31:0];
                5'd20:ALU0_result <= CNTID;
                5'd21:ALU0_result <= (source1 << unsigned_imm5);
                5'd22:ALU0_result <= (source1 >> unsigned_imm5);
                5'd23:ALU0_result <= (source1 >>> unsigned_imm5);
                default: ;
            endcase
        end
    end

endmodule