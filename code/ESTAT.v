module  ESTAT(
    input               clk,
    input               rst_n,

    input               CSRWR_ESTAT_EN,
    input        [1:0]  CSRWR_ESTAT_data,

    input        [7:0]  HWI, 
    input               TI,
    input               IPI,

    input               except_PIL,             //load 操作页无效例外
    input               except_PIS,             //store 操作页无效例外
    input               except_PIF,             //取指操作页无效例外
    input               except_PME,             //页修改例外
    input               except_PPI,             //页特权等级不合规例外
    input               except_ADEF,            //取指地址错例外
    input               except_ADEM,            //访存指令地址错例外
    input               except_ALE,             //地址非对齐例外
    input               except_SYS,             //系统调用例外
    input               except_BRK,             //断点例外
    input               except_INE,             //指令不存在例外
    input               except_IPE,             //指令特权等级错例外
    input               except_FPD,             //浮点指令未使能例外
    input               except_FPE,             //基础浮点指令例外
    input               except_TLBR,            //TLB 重填例外

    output  reg  [31:0] ESTAT
);
    
    wire  [14:0] except_en;
    assign except_en = {except_PIL,except_PIS,except_PIF,except_PME,except_PPI 
                        ,except_ADEF,except_ADEM,except_ALE,except_SYS,except_BRK 
                        ,except_INE,except_IPE,except_FPD,except_FPE,except_TLBR};

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ESTAT <= 32'b0;
        else begin
            if(CSRWR_ESTAT_EN)
                ESTAT[1:0] <= CSRWR_ESTAT_data;

            ESTAT[15:2] <= {3'd0, IPI, TI, 1'b0, HWI};

            if((CSRWR_ESTAT_EN & (|CSRWR_ESTAT_data)) | TI | IPI | (|HWI))       //中断
                ESTAT[30:16] <= 15'b0;
            else begin                                                          //例外
                case (except_en)
                    15'b100000000000000: begin ESTAT[21:16] <= 6'h1;  ESTAT[30:22] <= 9'b0; end
                    15'b010000000000000: begin ESTAT[21:16] <= 6'h2;  ESTAT[30:22] <= 9'b0; end
                    15'b001000000000000: begin ESTAT[21:16] <= 6'h3;  ESTAT[30:22] <= 9'b0; end
                    15'b000100000000000: begin ESTAT[21:16] <= 6'h4;  ESTAT[30:22] <= 9'b0; end
                    15'b000010000000000: begin ESTAT[21:16] <= 6'h7;  ESTAT[30:22] <= 9'b0; end
                    15'b000001000000000: begin ESTAT[21:16] <= 6'h8;  ESTAT[30:22] <= 9'b0; end
                    15'b000000100000000: begin ESTAT[21:16] <= 6'h8;  ESTAT[30:22] <= 9'b1; end
                    15'b000000010000000: begin ESTAT[21:16] <= 6'h9;  ESTAT[30:22] <= 9'b0; end
                    15'b000000001000000: begin ESTAT[21:16] <= 6'hb;  ESTAT[30:22] <= 9'b0; end
                    15'b000000000100000: begin ESTAT[21:16] <= 6'hc;  ESTAT[30:22] <= 9'b0; end
                    15'b000000000010000: begin ESTAT[21:16] <= 6'hd;  ESTAT[30:22] <= 9'b0; end
                    15'b000000000001000: begin ESTAT[21:16] <= 6'he;  ESTAT[30:22] <= 9'b0; end
                    15'b000000000000100: begin ESTAT[21:16] <= 6'hf;  ESTAT[30:22] <= 9'b0; end
                    15'b000000000000010: begin ESTAT[21:16] <= 6'h12;  ESTAT[30:22] <= 9'b0; end
                    15'b000000000000001: begin ESTAT[21:16] <= 6'h3f;  ESTAT[30:22] <= 9'b0; end
                endcase
            end
        end
    end


endmodule