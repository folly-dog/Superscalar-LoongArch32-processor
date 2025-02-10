module ECFG (
    input               clk,
    input               rst_n,

    input               CSRWR_ECFG_EN,
    input        [12:0] CSRWR_ECFG_data,

    output  reg  [31:0] ECFG
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ECFG <= 32'b0;
        else if(CSRWR_ECFG_EN)
                ECFG[12:0] <= {CSRWR_ECFG_data[12:11], 1'b0, CSRWR_ECFG_data[9:0]};
    end

endmodule