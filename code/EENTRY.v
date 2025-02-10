module EENTRY (
    input               clk,   
    input               rst_n,

    input               CSRWR_EENTRY_en,
    input        [31:6] CSRWR_EENTRY_data,

    output  reg  [31:0] EENTRY
);
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            EENTRY <= 32'b0;
        else if(CSRWR_EENTRY_en)
            EENTRY[31:6] <= CSRWR_EENTRY_data;
    end

endmodule