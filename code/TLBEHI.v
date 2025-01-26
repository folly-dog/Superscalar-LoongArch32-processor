module  TLBEHI (
    input               clk,
    input               rst_n,

    input       [31:13] TLB_VPN,
    input               TLBRD_en,

    input       [31:13] EXC_VPN,    // Exception VPN
    input               EXC_vld,    // Exception valid

    output  reg [31:0]  TLBEHI
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBEHI <= 32'b0;
        else begin
            if(TLBRD_en)
                TLBEHI[31:13] <= TLB_VPN;
            if(EXC_vld)
                TLBEHI[31:13] <= EXC_VPN;
        end
    end

endmodule