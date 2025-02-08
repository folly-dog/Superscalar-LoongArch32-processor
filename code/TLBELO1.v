module  TLBELO1 (
    input               clk,
    input               rst_n,

    input               TLBRD_en,
    input       [27:8]  TLB_PPN_1_RD,
    input       [5:0]   TLB_flags_1,  // TLB flags, 5-4:MAT, 3-2:PLV, 1-0:MESI   
    input               TLB_G_1,      // TLB Global

    output  reg [31:0]  TLBELO1
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBELO1 <= 32'b0;
        else if(TLBRD_en)
                TLBELO1[31:13] <= {4'b0, TLB_PPN_1, 1'b0, TLB_G_1, TLB_flags_1};
    end

endmodule