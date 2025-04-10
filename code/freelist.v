module  freelist(
    input               clk,
    input               rst_n,

    input               flush_stage4,
    input               stage4_pause,

    input       [2:0]   PR_num_need,
    input       [2:0]   PR_num_retire,

    input       [5:0]   retire_PR0,
    input       [5:0]   retire_PR1,
    input       [5:0]   retire_PR2,
    input       [5:0]   retire_PR3,

    output reg  [5:0]   freePR0,
    output reg  [5:0]   freePR1,
    output reg  [5:0]   freePR2,
    output reg  [5:0]   freePR3,
    output      [5:0]   freelist_room
);
    reg  [5:0]  freelist [31:0];
    reg  [5:0]  a_freelist [31:0];

    reg  [5:0]  wr_ptr_exp;
    wire [4:0]  wr_ptr;
    reg  [5:0]  rd_ptr_exp;
    wire [4:0]  rd_ptr;

    reg  [5:0]  a_wr_ptr_exp;
    wire [4:0]  a_wr_ptr;
    reg  [5:0]  a_rd_ptr_exp;


endmodule