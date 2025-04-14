module  rd_   File(
    input               clk,
    input               rst_n,

    input       [31:0]  regfile [63:0],     // Regfile

    input               ALU0_select_vld,
    input       [4:0]   ALU0_select_op,
    input       [19:0]  ALU0_select_imm,
    input       [5:0]   ALU0_select_dest,
    input       [5:0]   ALU0_select_source1,
    input       [5:0]   ALU0_select_source2,
    input       [5:0]   ALU0_select_ROB_ID,

    input       [5:0]   ALU0_PR_bypass,     // use bypass
    input       [31:0]  ALU0_data_bypass,

    output  reg         ALU0_vld,
    output  reg [4:0]   ALU0_op,
    output  reg [5:0]   ALU0_dest,
    output  reg [5:0]   ALU0_ROB_ID,
    output  reg [5:0]   ALU0_PR_source1,    // give next pipeline use for bypass
    output  reg [5:0]   ALU0_PR_source2,
    output  reg [31:0]  ALU0_data_source1,
    output  reg [31:0]  ALU0_data_source2
);

    always @(posedge clk or negedge rst_n) begin    // ALU0_vld
        if(!rst_n)
            ALU0_vld <= 1'b0;
        else
            ALU0_vld <= ALU0_select_vld;
    end

    always @(posedge clk) begin     // ALU0_op
        if(ALU0_select_vld)
            ALU0_op <= ALU0_select_op;
    end

    always @(posedge clk) begin     // ALU0_dest
        if(ALU0_select_vld)
            ALU0_dest <= ALU0_select_dest;
    end

    always @(posedge clk) begin     // ALU0_ROB_ID
        if(ALU0_select_vld)
            ALU0_ROB_ID <= ALU0_select_ROB_ID;
    end

endmodule