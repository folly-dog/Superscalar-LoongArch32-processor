module TICLR (
    input               clk,
    input               rst_n,
    
    input               CSRWR_TICLR_en,
    input               CSRWR_TICLR_data,
    
    input        [31:0] TVAL,

    output       [31:0] TICLR,
    output  reg         TI
);
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            TI <= 1'b0;
        else if(CSRWR_TICLR_en & CSRWR_TICLR_data)
            TI <= 1'b1;
        else
            TI <= (TVAL == 32'b0);
    end
    
endmodule