module  ERA(
    input               clk,
    input               rst_n,

    input               CSRWR_ERA_EN,
    input        [31:0] CSRWR_ERA_data,

    input               except_en,
    input        [31:0] except_PC,

    output  reg  [31:0] ERA
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ERA <= 32'b0;
        else if(CSRWR_ERA_EN)
            ERA <= CSRWR_ERA_data;
        else if(except_en)
            ERA <= except_PC;
    end

endmodule