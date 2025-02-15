module  PGDL(
    input               clk,
    input               rst_n,

    input               CSRWR_PGDH_en,
    input       [31:12] CSRWR_PGDH_addr,  // 4KB对齐 

    output  reg [31:0]  PGDH
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            PGDH <= 32'b0;
        else if(CSRWR_PGDH_en)
            PGDH[31:12] <= CSRWR_PGDH_addr;
    end

endmodule