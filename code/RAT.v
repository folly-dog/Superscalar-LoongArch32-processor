module RAT (
    input               clk,
    input               rst_n,

    input               flush_stage4,

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

    always @(posedge clk or negedge rst_n) begin    // RAT_en
        if(!rst_n)
            RAT_en <= 32'd0;
        else if(flush_stage4)
            RAT_en <= a_RAT_en;
        else begin
            if(inst0_dest_en)
                RAT_en[inst0_dest_AR] <= 1'b1;
            if(inst1_dest_en)
                RAT_en[inst1_dest_AR] <= 1'b1;
            if(inst2_dest_en)
                RAT_en[inst2_dest_AR] <= 1'b1;
            if(inst3_dest_en)
                RAT_en[inst3_dest_AR] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // a_RAT_en
        if(!rst_n)
            a_RAT_en <= 32'd0;
        else begin
            if(retire0_dest_en)
                RAT_en[retire0_dest_AR] <= 1'b1;
            if(retire1_dest_en)
                RAT_en[retire1_dest_AR] <= 1'b1;
            if(retire2_dest_en)
                RAT_en[retire2_dest_AR] <= 1'b1;
            if(retire3_dest_en)
                RAT_en[retire3_dest_AR] <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // RAT
        if(!rst_n)
            for(integer i = 0; i < 32; i = i + 1)
                RAT[i] <= 7'd0;
        else if(flush_stage4)
            for(integer i = 0; i < 32; i = i + 1)
                RAT[i] <= a_RAT[i];
        else begin
            if(inst0_dest_en)
                RAT[inst0_dest_AR] <= inst0_dest_PR;
            if(inst1_dest_en)
                RAT[inst1_dest_AR] <= inst1_dest_PR;
            if(inst2_dest_en)
                RAT[inst2_dest_AR] <= inst2_dest_PR;
            if(inst3_dest_en)
                RAT[inst3_dest_AR] <= inst3_dest_PR;
        end
    end

    always @(posedge clk or negedge rst_n) begin    // a_RAT
        if(!rst_n)
            for(integer i = 0; i < 32; i = i + 1)
                a_RAT[i] <= 7'd0;
        else begin
            if(inst0_dest_en)
                a_RAT[inst0_dest_AR] <= inst0_dest_PR;
            if(inst1_dest_en)
                a_RAT[inst1_dest_AR] <= inst1_dest_PR;
            if(inst2_dest_en)
                a_RAT[inst2_dest_AR] <= inst2_dest_PR;
            if(inst3_dest_en)
                a_RAT[inst3_dest_AR] <= inst3_dest_PR;
        end
    end

endmodule