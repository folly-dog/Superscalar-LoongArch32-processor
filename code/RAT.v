module RAT (
    input               clk,
    input               rst_n,

    input               inst0_dest_en,
    input               inst1_dest_en,
    input               inst2_dest_en,
    input               inst3_dest_en,

    input       [4:0]   inst0_dest_AR,
    input       [4:0]   inst1_dest_AR,
    input       [4:0]   inst2_dest_AR,
    input       [4:0]   inst3_dest_AR,

    input       [6:0]   inst0_dest_PR,
    input       [6:0]   inst1_dest_PR,
    input       [6:0]   inst2_dest_PR,
    input       [6:0]   inst3_dest_PR,

    input               retire0_dest_en,
    input               retire1_dest_en,
    input               retire2_dest_en,
    input               retire3_dest_en,

    input       [4:0]   retire0_dest_AR,
    input       [4:0]   retire1_dest_AR,
    input       [4:0]   retire2_dest_AR,
    input       [4:0]   retire3_dest_AR,
    
    input       [6:0]   retire0_dest_PR,
    input       [6:0]   retire1_dest_PR,
    input       [6:0]   retire2_dest_PR,
    input       [6:0]   retire3_dest_PR,

    output reg  [31:0]  RAT_en,
    output reg  [6:0]   RAT [31:0]
);
    reg  [31:0] a_RAT_en;
    reg  [6:0]  a_RAT [31:0];
endmodule