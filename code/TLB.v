module TLB (
    input                   clk,
    input                   rst_n,

    input                   TLBSRCH,
    input          [9:0]    ASID,
    input        [31:13]    TLBEHI_VPN,
    output                  TLBSRCH_hit,
    output         [5:0]    TLB_hit_idx,

    input                   TLBRD,
    input          [5:0]    TLBIDX_idx,
    input                   TLBIDX_NE,
    input        [29:24]    TLBIDX_PS,
    output                  TLBRD_en,
    output         [5:0]    TLB_PS,
    output                  TLB_E,

    output       [31:13]    TLB_VPN,

    output        [27:8]    TLB_PPN_0,
    output         [5:0]    TLB_flags_0,
    output                  TLB_G_0,

    output        [27:8]    TLB_PPN_1,
    output         [5:0]    TLB_flags_1,
    output                  TLB_G_1,

    input                   TLBWR,
    input        [27:13]    TLBEHI_VPN,
    input        [21:16]    ESTART_Ecode,
    input                   TLBELO0_G,      // 0与1的G位相同
    input                   TLBELO0_E,      // 0与1的E位相同
    input        [31:12]    PPN0,
    input          [1:0]    PLV0,
    input          [1:0]    MAT0,
    input          [1:0]    MESI0,
    input        [31:12]    PPN1,
    input          [1:0]    PLV1,
    input          [1:0]    MAT1,
    input          [1:0]    MESI1,

    input                   TLBFILL,

    input                   INVTLB,
    input          [4:0]    INVTLB_op,
    input          [9:0]    INVTLB_ASID,
    input        [31:13]    INVTLB_VA,
);

    reg  [31:13] ITLB_VPN  [63:0];
    reg    [5:0] ITLB_PS   [63:0];
    reg          ITLB_G    [63:0];
    reg    [9:0] ITLB_ASID [63:0];
    reg          ITLB_EN   [63:0];

    reg  [31:12] ITLB_PPN_0  [63:0];    //0表示偶数页
    reg    [1:0] ITLB_PLV_0  [63:0];
    reg    [1:0] ITLB_MAT_0  [63:0];
    reg    [1:0] ITLB_PLV_0  [63:0];
    reg    [1:0] ITLB_MESI_0 [63:0];

    reg  [31:12] ITLB_PPN_1  [63:0];    //1表示奇数页
    reg    [1:0] ITLB_PLV_1  [63:0];
    reg    [1:0] ITLB_MAT_1  [63:0];
    reg    [1:0] ITLB_PLV_1  [63:0];
    reg    [1:0] ITLB_MESI_1 [63:0];

endmodule