module  PGDL(
    input               clk,
    input               rst_n,

    input               CSRWR_PGDL_en,
    input       [31:12] CSRWR_PGDL_addr,  // 4KB对齐 

    output  reg [31:0]  PGDL
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            PGDL <= 32'b0;
        else if(CSRWR_PGDL_en)
            PGDL[31:12] <= {CSRWR_PGDL_addr, 12'b0};
    end

endmodule