module I_TLB (
    input               clk,
    input               rst_n,

);

    reg  [31:12] ITLB_VPN  [31:0];
    reg    [5:0] ITLB_PS   [31:0];
    reg          ITLB_G    [31:0];
    reg    [9:0] ITLB_ASID [31:0];
    reg          ITLB_EN   [31:0];

    reg  [31:12] ITLB_PPN_0  [31:0];    //0表示奇数页
    reg    [1:0] ITLB_PLV_0  [31:0];
    reg    [1:0] ITLB_MAT_0  [31:0];
    reg    [1:0] ITLB_PLV_0  [31:0];
    reg    [1:0] ITLB_MESI_0 [31:0];

    reg  [31:12] ITLB_PPN_1  [31:0];    //1表示奇数页
    reg    [1:0] ITLB_PLV_1  [31:0];
    reg    [1:0] ITLB_MAT_1  [31:0];
    reg    [1:0] ITLB_PLV_1  [31:0];
    reg    [1:0] ITLB_MESI_1 [31:0];

endmodule