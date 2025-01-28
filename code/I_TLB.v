module I_TLB (
    input               clk,
    input               rst_n,

    input               VPN_en,
    input  [31:12]      VPN,
    input  [23:12]      page_mask,

    input               I_TLB_VPN_invld,
    input   [31:0]      I_TLB_VPN_invld_reg,

    input               I_TLB_ASID_invld,
    input   [31:0]      I_TLB_ASID_invld_reg,
    
    input               I_TLB_locked_invld,

    input               I_TLB_rd_en,
    input               I_TLB_wr_en,
    input    [4:0]      I_TLB_wr_addr,
    input   [51:0]      I_TLB_wr_data,
    output  [51:0]      I_TLB_rd_data,

    output         reg  I_TLB_hit,
    output [31:12] reg  PPN,

    output         reg  I_TLB_2_MMU_en,
    output [31:12] reg  I_TLB_VPN_2_MMU,
    input               I_TLB_PPN_from_MMU_en,
    input  [31:12]      I_TLB_PPN_from_MMU,
    input               I_TLB_from_MMU_page_fault,
    output              I_TLB_page_fault
);

    reg  [31:12] VPN_reg  [31:0];
    reg  [31:12] PPN_reg  [31:0];
    reg    [7:0] ASID_reg [31:0];
    reg

endmodule