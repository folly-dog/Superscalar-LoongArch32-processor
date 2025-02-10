module BADV (
    input               clk,
    input               rst_n,


    input               CSRWR_BADV_EN,
    input       [31:0]  CSRWR_BADV_data, 

    input               except_TLB_addr_en,
    input       [31:0]  except_TLB_addr_PC,

    output  reg [31:0]  BADV
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            BADV <= 32'b0;
        else if(CSRWR_BADV_EN)
            BADV <= CSRWR_BADV_data;
        else if(except_TLB_addr_en)
            BADV <= except_TLB_addr_PC;
    end

endmodule