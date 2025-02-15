module  PRMD(
    input               clk,
    input               rst_n,


    input               CSRWR_PRMD_en,
    input       [31:0]  CSRWR_PRMD_data,  

    input               except_en,
    input        [2:0]  CRMD_3,

    output   reg [31:0] PRMD
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            PRMD <= 32'b0;
        else begin
            if(except_en)
                PRMD[2:0] <= CRMD_3;
            if(CSRWR_PRMD_en)
                PRMD[2:0] <= CSRWR_PRMD_data[2:0];
        end
    end

endmodule