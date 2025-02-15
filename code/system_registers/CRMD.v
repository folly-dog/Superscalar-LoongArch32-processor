module  CRMD(
    input               clk,
    input               rst_n,

    input               CSRWR_CRMD_en,
    input       [31:0]  CSRWR_CRMD_data,  

    input               except_en,

    input               ERTN,
    input      [21:16]  ESTART_Ecode,
    input        [2:0]  PRMD_3,

    input               TLB_miss,

    output  reg [31:0]  CRMD
);

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            CRMD <= 32'b0;
        else begin 
            if(CSRWR_CRMD_en)
                CRMD[8:0] <= CSRWR_CRMD_data[8:0];
            if(except_en)
                CRMD[2:0] <= 3'b000;
            if(ERTN)begin
                CRMD[2:0] <= PRMD_3;
                if(ESTART_Ecode == 7'b1111111)begin
                    CRMD[3] <= 1'b0;
                    CRMD[4] <= 1'b1;
                end
            end
            if(TLB_miss)begin
                CRMD[3] <= 1'b1;
                CRMD[4] <= 1'b0;
            end
        end
    end

endmodule