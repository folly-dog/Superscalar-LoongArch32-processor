module  TLBIDX (
    input               clk,
    input               rst_n,

    input               TLBSRCH_hit,
    input       [5:0]   TLB_hit_idx,
    input               TLBRD_en,
    input       [5:0]   TLB_PS,     // Page size
    input               TLB_E,      // TLB Entry valid

    output  reg [31:0]  TLBIDX
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBIDX <= {1'b1, 31'b0};
        else begin
            if(TLBSRCH_hit)begin
                TLBIDX[5:0] <= TLB_hit_idx;
                TLBIDX[31] <= 1'b0;
            end
            else
                TLBIDX[31] <= 1'b1;
            if(TLBRD_en)begin
                TLBIDX[29:24] <= TLB_PS;
                TLBIDX[31] <= ~TLB_E;
            end
        end
    end

endmodule