module  TLBELO0 (
    input               clk,
    input               rst_n,

    input               TLBRD_en,
    input       [27:8]  TLB_PPN_0,
    input       [5:0]   TLB_flags_0,  // TLB flags, 5-4:MAT, 3-2:PLV, 1-0:MESI  
    input               TLB_G_0,      // TLB Global

    output  reg [31:0]  TLBELO0
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBELO0 <= 32'b0;
        else if(TLBRD_en)
                TLBELO0[31:13] <= {4'b0, TLB_PPN_0, 1'b0, TLB_G_0, TLB_flags_0};
    end

endmodule