module PR_status (
    input               clk,
    input               rst_n,

    input               flush_stage4,

    input               inst0_dest_en,  // inst0_dest_PR_STA_en of "rename.v"
    input               inst1_dest_en,
    input               inst2_dest_en,
    input               inst3_dest_en,

    input       [6:0]   inst0_dest_PR,
    input       [6:0]   inst1_dest_PR,
    input       [6:0]   inst2_dest_PR,
    input       [6:0]   inst3_dest_PR,

    input               ALU0_dest_en,
    input               ALU1_dest_en,
    input               AGU_dest_en,
    input               BRU_dest_en,

    input       [6:0]   ALU0_dest_PR,
    input       [6:0]   ALU1_dest_PR,
    input       [6:0]   AGU_dest_PR,
    input       [6:0]   BRU_dest_PR,

    output reg  [64:0]  PR_status
);

    always @(posedge clk or negedge rst_n) begin    // PR_status
        if(!rst_n)
            PR_status <= 65'h1ffffffffffffffff;
        else if(flush_stage4)
            PR_status <= 65'h1ffffffffffffffff;
        else begin
            if(inst0_dest_en)
                PR_status[inst0_dest_PR] <= 1'b0;
            if(inst1_dest_en)
                PR_status[inst1_dest_PR] <= 1'b0;
            if(inst2_dest_en)
                PR_status[inst2_dest_PR] <= 1'b0;
            if(inst3_dest_en)
                PR_status[inst3_dest_PR] <= 1'b0;
            if(ALU0_dest_en)
                PR_status[ALU0_dest_PR] <= 1'b1;
            if(ALU1_dest_en)
                PR_status[ALU1_dest_PR] <= 1'b1;
            if(AGU_dest_en)
                PR_status[AGU_dest_PR] <= 1'b1;
            if(BRU_dest_en)
                PR_status[BRU_dest_PR] <= 1'b1;
        end
    end
    
endmodule