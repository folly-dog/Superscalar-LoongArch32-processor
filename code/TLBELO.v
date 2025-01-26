module  TLBELO (
    input               clk,
    input               rst_n,

    input       [27:8]  TLB_PPN,
    input               TLBRD_en,
    input       [5:0]   TLB_flags,  // TLB flags，0~5:Valid至MAT   
    input               TLB_G,      // TLB Global

    output  reg [31:0]  TLBELO
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            TLBELO <= 32'b0;
        else if(TLBRD_en)
                TLBELO[31:13] <= {4'b0, TLB_PPN, 1'b0, TLB_G, TLB_flags};
    end

endmodule