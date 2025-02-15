module SAVE2 (
    input               clk,
    input               rst_n,

    input               CSRWR_SAVE2_en,
    input        [31:0] CSRWR_SAVE2_data,

    output  reg  [31:0] SAVE2
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            SAVE2 <= 32'b0;
        else if(CSRWR_SAVE2_en)
            SAVE2 <= CSRWR_SAVE2_data;
    end

endmodule