module EUEN (
    input               clk,
    input               rst_n,

    input               CSRWR_EUEN_EN,
    input               CSRWR_EUEN_data,

    output  reg  [31:0] EUEN
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            EUEN <= 32'b0;
        else if(CSRWR_EUEN_EN)
                EUEN[0] <= CSRWR_EUEN_data;
    end

endmodule