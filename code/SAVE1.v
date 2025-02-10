module SAVE1 (
    input               clk,
    input               rst_n,

    input               CSRWR_SAVE1_en,
    input        [31:0] CSRWR_SAVE1_data,

    output  reg  [31:0] SAVE1
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            SAVE1 <= 32'b0;
        else if(CSRWR_SAVE1_en)
            SAVE1 <= CSRWR_SAVE1_data;
    end

endmodule