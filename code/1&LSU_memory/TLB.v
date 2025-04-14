module TLB (
    input                   clk,
    input                   rst_n,

    input        [31:12]    PC,
    input                   IF_stage_vld,
    output reg   [31:12]    PC_PPN,
    output reg              TLB_hit,        // 1: PC_PPN有效, 0: TLB-miss

    input                   TLBSRCH,
    input          [9:0]    ASID,
    input        [31:13]    TLBEHI_VPN,
    output                  TLBSRCH_hit,
    output         [5:0]    TLBSRCH_hit_idx,

    input                   TLBRD,
    input          [5:0]    TLBIDX_idx,
    input                   TLBIDX_NE,
    input        [29:24]    TLBIDX_PS,
    output                  TLBRD_en,
    output         [5:0]    TLB_PS_RD,
    output                  TLB_EN_RD,

    output       [31:13]    TLB_VPN_RD,

    output        [27:8]    TLB_PPN_0_RD,
    output         [5:0]    TLB_flags_0,
    output                  TLB_G_0_RD,

    output        [27:8]    TLB_PPN_1_RD,
    output         [5:0]    TLB_flags_1,
    output                  TLB_G_1_RD,

    input                   TLBWR,
    input        [21:16]    ESTART_Ecode,
    input                   TLBELO0_G,      // 0与1的G位相同
    input                   TLBELO0_E,      // 0与1的E位相同
    input        [31:12]    PPN0,
    input          [1:0]    MAT0,
    input          [1:0]    PLV0,
    input                   dirty0,
    input                   vld0,
    input        [31:12]    PPN1,
    input          [1:0]    MAT1,
    input          [1:0]    PLV1,
    input                   dirty1,
    input                   vld1,

    input                   TLBFILL,

    input                   INVTLB,
    input          [4:0]    INVTLB_op,
    input          [9:0]    INVTLB_ASID,
    input        [31:13]    INVTLB_VA,

    input        [31:12]    PC_store,
    input                   store_vld
);

    reg  [31:13] TLB_VPN  [63:0];
    reg    [5:0] TLB_PS   [63:0];
    reg          TLB_G    [63:0];
    reg    [9:0] TLB_ASID [63:0];
    reg          TLB_EN   [63:0];

    reg  [31:12] TLB_PPN_0  [63:0];    //0表示偶数页
    reg    [1:0] TLB_PLV_0  [63:0];
    reg    [1:0] TLB_MAT_0  [63:0];
    reg          TLB_dirty_0[63:0];
    reg          TLB_vld_0  [63:0];

    reg  [31:12] TLB_PPN_1  [63:0];    //1表示奇数页
    reg    [1:0] TLB_PLV_1  [63:0];
    reg    [1:0] TLB_MAT_1  [63:0];
    reg          TLB_dirty_1[63:0];
    reg          TLB_vld_1  [63:0];

    reg    [5:0] TLB_idx_cycle;

    wire  [63:0] ASID_hit_result;
    wire  [63:0] VPN_hit_result;
    wire  [63:0] TLBSRCH_hit_result;
    wire  [63:0] TLB_hit_result;

    wire [31:12] PPN0_sel;
    wire [31:12] PPN1_sel;

    // Function to convert one-hot to index
    function [5:0] onehot_to_index;
        input [63:0] onehot;
        integer i;
        begin
            onehot_to_index = 6'b0;
            for (i = 0; i < 64; i = i + 1) begin
                if (onehot[i]) begin
                    onehot_to_index = i[5:0];
                end
            end
        end
    endfunction

    genvar i;
    generate
        for(i=0; i<64; i=i+1)begin: TLB_entry_hit
            assign ASID_hit_result[i] = (ASID == TLB_ASID[i]);
            assign VPN_hit_result[i] = (TLBEHI_VPN == TLB_VPN[i]);
            assign TLB_hit_result[i] =  IF_stage_vld &
                                        TLB_EN[i] & 
                                        ((PC[12] & TLB_vld_1[i]) | (!PC[12] & TLB_vld_0[i])) & 
                                        ((TLB_G[i] | (!TLB_G[i] & ASID_hit_result[i])) & (PC[31:13] == TLB_VPN[i]));
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin                        // TLB_hit
        if(!rst_n)
            TLB_hit <= 1'b0;
        else 
            TLB_hit <= |(TLB_hit_result); 
    end

    assign PPN0_sel = TLB_PPN_0[onehot_to_index(TLB_hit_result)];       // PPN0_sel  
    assign PPN1_sel = TLB_PPN_1[onehot_to_index(TLB_hit_result)];       // PPN0_sel   

    always @(posedge clk or negedge rst_n) begin                        // PC_PPN
        if(!rst_n)
            PC_PPN <= 20'd0;
        else if(TLB_hit)
            PC_PPN <= (PC[12]) ? PPN1_sel : PPN0_sel;
    end                            

    assign TLBSRCH_hit_result = ASID_hit_result & VPN_hit_result;
    assign TLBSRCH_hit = |(TLBSRCH_hit_result);                         // TLBSRCH_hit
    
    assign TLBSRCH_hit_idx = onehot_to_index(TLBSRCH_hit_result);       // TLBSRCH_hit_idx

    assign TLBRD_en = TLBRD & (TLB_EN[TLBIDX_idx]);             // TLBRD_en

    assign TLB_PS_RD = TLB_PS[TLBIDX_idx];                         // TLB_PS_RD

    assign TLB_EN_RD = TLB_EN[TLBIDX_idx];                          // TLB_EN_RD

    assign TLB_VPN_RD = TLB_VPN[TLBIDX_idx];                       // TLB_VPN_RD

    assign TLB_PPN_0_RD = TLB_PPN_0[TLBIDX_idx];                   // TLB_PPN_0_RD
    assign TLB_flags_0 = {TLB_MAT_0[TLBIDX_idx], TLB_PLV_0[TLBIDX_idx], TLB_dirty_0[TLBIDX_idx], TLB_vld_0[TLBIDX_idx]}; // TLB_flags_0
    assign TLB_G_0_RD = TLB_G[TLBIDX_idx];                         // TLB_G_0_RD

    assign TLB_PPN_1_RD = TLB_PPN_1[TLBIDX_idx];                   // TLB_PPN_1_RD
    assign TLB_flags_1 = {TLB_MAT_1[TLBIDX_idx], TLB_PLV_1[TLBIDX_idx], TLB_dirty_1[TLBIDX_idx], TLB_vld_1[TLBIDX_idx]}; // TLB_flags_1
    assign TLB_G_1_RD = TLB_G[TLBIDX_idx];                         // TLB_G_1_RD

    always @(posedge clk or negedge rst_n) begin                // TLB_idx_cycle
        if(!rst_n)
            TLB_idx_cycle <= 6'b0;
        else 
            TLB_idx_cycle <= TLB_idx_cycle + 1;
    end

    integer ii;

    always @(posedge clk or negedge rst_n) begin               // TLB_VPN
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_VPN[ii] <= 19'b0;
        end
        else begin
            if(TLBWR)
                TLB_VPN[TLBIDX_idx] <= TLBEHI_VPN;
            if(TLBFILL)
                TLB_VPN[TLB_idx_cycle] <= TLBEHI_VPN;
        end
    end

    always @(posedge clk or negedge rst_n) begin               // TLB_PS
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_PS[ii] <= 6'b0;
        end
        else begin
            if(TLBWR)
                TLB_PS[TLBIDX_idx] <= TLBIDX_PS;
            if(TLBFILL)
                TLB_PS[TLB_idx_cycle] <= TLBIDX_PS;
        end
    end

    always @(posedge clk or negedge rst_n) begin               // TLB_G
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_G[ii] <= 1'b0;
        end
        else begin
            if(TLBWR)
                TLB_G[TLBIDX_idx] <= TLBELO0_G;
            if(TLBFILL)
                TLB_G[TLB_idx_cycle] <= TLBELO0_G;
        end
    end

    always @(posedge clk or negedge rst_n) begin               // TLB_ASID
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_ASID[ii] <= 10'b0;
        end
        else begin
            if(TLBWR)
                TLB_ASID[TLBIDX_idx] <= ASID;
            if(TLBFILL)
                TLB_ASID[TLB_idx_cycle] <= ASID;
        end
    end

    always @(posedge clk or negedge rst_n) begin               // TLB_EN
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_EN[ii] <= 1'b0;
        end
        else begin
            if(TLBWR)begin
                if(ESTART_Ecode == 6'b111111)
                    TLB_EN[TLBIDX_idx] <= 1'b1;
                else
                    TLB_EN[TLBIDX_idx] <= ~TLBIDX_NE;
            end
            if(TLBFILL)begin
                if(ESTART_Ecode == 6'b111111)
                    TLB_EN[TLB_idx_cycle] <= 1'b1;
                else
                    TLB_EN[TLB_idx_cycle] <= ~TLBIDX_NE;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin            // TLB_PPN_0,MAT0,PLV0,
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)begin
                TLB_PPN_0[ii] <= 20'b0;
                TLB_MAT_0[ii] <= 2'b0;
                TLB_PLV_0[ii] <= 2'b0;
            end
        end
        else begin
            if(TLBWR)begin
                TLB_PPN_0[TLBIDX_idx] <= PPN0;
                TLB_MAT_0[TLBIDX_idx] <= MAT0;
                TLB_PLV_0[TLBIDX_idx] <= PLV0;
            end
            if(TLBFILL)begin
                TLB_PPN_0[TLB_idx_cycle] <= PPN0;
                TLB_MAT_0[TLB_idx_cycle] <= MAT0;
                TLB_PLV_0[TLB_idx_cycle] <= PLV0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin            // TLB_dirty_0
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_dirty_0[ii] <= 1'b0;
        end
        else if(store_vld && (!PC_store[12])) begin
            for(ii=0; ii<64; ii=ii+1) begin
                if((TLB_G[ii] || (!TLB_G[ii] && (ASID == TLB_ASID[ii]))) && (TLB_VPN[ii] == PC_store[31:13]))
                    TLB_dirty_0[ii] <= dirty0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin            // TLB_vld_0
        if(!rst_n)begin
            for(ii=1; ii<64; ii=ii+1)
                TLB_vld_0[ii] <= 1'b0;
        end
        else begin
            if(TLBWR)
                TLB_vld_0[TLBIDX_idx] <= vld0;
            if(TLBFILL)
                TLB_vld_0[TLB_idx_cycle] <= vld0;
            if(INVTLB)begin
                if((INVTLB_op == 5'd0) || (INVTLB_op == 5'd1))begin
                    for(ii = 0; ii < 64; ii = ii + 1)
                        TLB_vld_0[ii] <= 1'b0;
                end
                if(INVTLB_op == 5'd2)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if(TLB_G[ii])
                            TLB_vld_0[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd3)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if(!TLB_G[ii])
                            TLB_vld_0[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd4)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if((TLB_ASID[ii] == ASID) && (!TLB_G[ii]))
                            TLB_vld_0[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd5)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if((TLB_ASID[ii] == ASID) && (!TLB_G[ii]) && (TLB_VPN[ii] == INVTLB_VA))
                            TLB_vld_0[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd6)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if((TLB_G[ii] || (!TLB_G[ii] && (ASID == TLB_ASID[ii]))) && (TLB_VPN[ii] == INVTLB_VA))
                            TLB_vld_0[ii] <= 1'b0;
                    end
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin            // TLB_PPN_1,MAT1,PLV1
        if(!rst_n)begin
            for(ii=1; ii<64; ii=ii+1)begin
                TLB_PPN_1[ii] <= 20'b0;
                TLB_MAT_1[ii] <= 2'b0;
                TLB_PLV_1[ii] <= 2'b0;
            end
        end
        else begin
            if(TLBWR)begin
                TLB_PPN_1[TLBIDX_idx] <= PPN1;
                TLB_MAT_1[TLBIDX_idx] <= MAT1;
                TLB_PLV_1[TLBIDX_idx] <= PLV1;
            end
            if(TLBFILL)begin
                TLB_PPN_1[TLB_idx_cycle] <= PPN1;
                TLB_MAT_1[TLB_idx_cycle] <= MAT1;
                TLB_PLV_1[TLB_idx_cycle] <= PLV1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin            // TLB_dirty_1
        if(!rst_n)begin
            for(ii=0; ii<64; ii=ii+1)
                TLB_dirty_1[ii] <= 1'b0;
        end
        else if(store_vld && PC_store[12]) begin
            for(ii=0; ii<64; ii=ii+1) begin
                if((TLB_G[ii] || (!TLB_G[ii] && (ASID == TLB_ASID[ii]))) && (TLB_VPN[ii] == PC_store[31:13]))
                    TLB_dirty_1[ii] <= dirty0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin            // TLB_vld_1
        if(!rst_n)begin
            for(ii=1; ii<64; ii=ii+1)
                TLB_vld_1[ii] <= 1'b0;
        end
        else begin
            if(TLBWR)
                TLB_vld_1[TLBIDX_idx] <= vld1;
            if(TLBFILL)
                TLB_vld_1[TLB_idx_cycle] <= vld1;
            if(INVTLB)begin
                if((INVTLB_op == 5'd0) || (INVTLB_op == 5'd1))begin
                    for(ii = 0; ii < 64; ii = ii + 1)
                        TLB_vld_1[ii] <= 1'b0;
                end
                if(INVTLB_op == 5'd2)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if(TLB_G[ii])
                            TLB_vld_1[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd3)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if(!TLB_G[ii])
                            TLB_vld_1[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd4)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if((TLB_ASID[ii] == ASID) && (!TLB_G[ii]))
                            TLB_vld_1[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd5)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if((TLB_ASID[ii] == ASID) && (!TLB_G[ii]) && (TLB_VPN[ii] == INVTLB_VA))
                            TLB_vld_1[ii] <= 1'b0;
                    end
                end
                if(INVTLB_op == 5'd6)begin
                    for(ii = 0; ii < 64; ii = ii + 1)begin
                        if((TLB_G[ii] || (!TLB_G[ii] && (ASID == TLB_ASID[ii]))) && (TLB_VPN[ii] == INVTLB_VA))
                            TLB_vld_1[ii] <= 1'b0;
                    end
                end
            end
        end
    end


endmodule