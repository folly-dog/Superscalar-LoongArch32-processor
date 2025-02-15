module SAVE0 (
    input               clk,
    input               rst_n,

    input               CSRWR_SAVE0_en,
    input        [31:0] CSRWR_SAVE0_data,

    output  reg  [31:0] SAVE0
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            SAVE0 <= 32'b0;
        else if(CSRWR_SAVE0_en)
            SAVE0 <= CSRWR_SAVE0_data;
    end

endmodule