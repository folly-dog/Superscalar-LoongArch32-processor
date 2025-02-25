module  freelist(
    input               clk,
    input               rst_n,

    input               flush_stage4,
    input               stage4_pause,

    input       [1:0]   PR_num_need,
    input       [1:0]   PR_num_wrback,
    input       [1:0]   AR_num_retire,

    output reg  [6:0]   rd_ptr,
    output      [6:0]   freelist_room
);

    reg  [6:0]  wr_ptr;
    reg  [6:0]  a_rd_ptr;

    always @(posedge clk or negedge rst_n) begin    // rd_ptr
        if(!rst_n)
            rd_ptr <= 7'd0;
        else if(flush_stage4)
            rd_ptr <= a_rd_ptr;
        else if(stage4_pause)
            rd_ptr <= rd_ptr;
        else
            rd_ptr <= rd_ptr + PR_num_need;
    end

    always @(posedge clk or negedge rst_n) begin    // wr_ptr
        if(!rst_n)
            wr_ptr <= 7'b1000000;
        else
            wr_ptr  <= wr_ptr + PR_num_wrback;
    end

    always @(posedge clk or negedge rst_n) begin    // a_rd_ptr
        if(!rst_n)
            a_rd_ptr <= 7'd0;
        else
            a_rd_ptr <= a_rd_ptr + AR_num_retire;
    end

    assign freelist_room = (wr_ptr - rd_ptr);

endmodule