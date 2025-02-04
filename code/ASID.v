module ASID (
    input               clk,
    input               rst_n,

    input       [9:0]   ASID_wr,
    input               ASID_wr_en,

    output  reg [31:0]  ASID
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ASID <= {8'b0, 8'b10, 6'b0, 10'b0};
        else if(ASID_wr_en)
            ASID[9:0] <= ASID_wr;
    end
endmodule