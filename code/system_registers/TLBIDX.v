module  TLBIDX (
    input               clk,
    input               rst_n,

    input               CSRWR_TLBSRCH_en,
    input       [31:0]  CSRWR_TLBSRCH_data,

    input               TLBSRCH,
    input               TLBSRCH_hit,
    input        [5:0]  TLBSRCH_hit_idx,
    input               TLBRD_en,
    input        [5:0]  TLB_PS,     // Page size
    input               TLB_E,      // TLB Entry valid

    output  reg [31:0]  TLBIDX
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBIDX <= {1'b1, 31'b0};
        else begin
            if(CSRWR_TLBSRCH_en)begin
                TLBIDX[5:0] <= CSRWR_TLBSRCH_data[5:0];
                TLBIDX[29:24] <= CSRWR_TLBSRCH_data[29:24];
                TLBIDX[31] <= CSRWR_TLBSRCH_data[31];
            end
            if(TLBSRCH)begin
                if(TLBSRCH_hit)begin
                    TLBIDX[5:0] <= TLBSRCH_hit_idx;
                    TLBIDX[31] <= 1'b0;
                end
                else
                    TLBIDX[31] <= 1'b1;
            end
            if(TLBRD_en)begin
                TLBIDX[29:24] <= TLB_PS;
                TLBIDX[31] <= ~TLB_E;
            end
        end
    end

endmodule