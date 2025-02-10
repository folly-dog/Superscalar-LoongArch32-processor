module ASID (
    input               clk,
    input               rst_n,

    input       [9:0]   CSRWR_ASID_data,
    input               CSRWR_ASID_en,

    output  reg [31:0]  ASID
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ASID <= {8'b0, 8'b10, 6'b0, 10'b0};
        else if(CSRWR_ASID_en)
            ASID[9:0] <= CSRWR_ASID_data;
    end
endmodule