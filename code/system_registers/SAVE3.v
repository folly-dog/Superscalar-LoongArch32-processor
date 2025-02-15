module SAVE3 (
    input               clk,
    input               rst_n,

    input               CSRWR_SAVE3_en,
    input        [31:0] CSRWR_SAVE3_data,

    output  reg  [31:0] SAVE3
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            SAVE3 <= 32'b0;
        else if(CSRWR_SAVE3_en)
            SAVE3 <= CSRWR_SAVE3_data;
    end

endmodule