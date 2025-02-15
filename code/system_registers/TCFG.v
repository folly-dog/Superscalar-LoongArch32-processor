module  TCFG(
    input               clk,
    input               rst_n,
    
    input               CSRWR_TCFG_en,
    input        [31:0] CSRWR_TCFG_data,
    
    output  reg  [31:0] TCFG
);
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            TCFG <= 32'b0;
        else if(CSRWR_TCFG_en)
            TCFG <= CSRWR_TCFG_data;
    end

endmodule