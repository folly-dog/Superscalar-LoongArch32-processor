module  TLBRENTRY(
    input               clk,
    input               rst_n,

    input               CSRWR_TLBRENTRY_en,
    input       [31:6]  CSRWR_TLBRENTRY_addr,  // TLB flags，0~5:Valid至MAT   

    output  reg [31:0]  TLBRENTRY
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBRENTRY <= 32'b0;
        else if(CSRWR_TLBRENTRY_en)
            TLBRENTRY[31:13] <= {CSRWR_TLBRENTRY_addr, 6'b0};
    end

endmodule