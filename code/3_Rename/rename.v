module rename (
    input               clk,
    input               rst_n,

    input               flush_stage4,
    input               hold_stage4,

    input               decode0_vld,
    input               decode1_vld,
    input               decode2_vld,
    input               decode3_vld,

    input               decode0_dest_vld,
    input               decode1_dest_vld,
    input               decode2_dest_vld,
    input               decode3_dest_vld,

    input               decode0_source1_vld,
    input               decode1_source1_vld,
    input               decode2_source1_vld,
    input               decode3_source1_vld,
    input               decode0_source2_vld,
    input               decode1_source2_vld,
    input               decode2_source2_vld,
    input               decode3_source2_vld,

    input       [4:0]   decode0_dest_AR,
    input       [4:0]   decode1_dest_AR,
    input       [4:0]   decode2_dest_AR,
    input       [4:0]   decode3_dest_AR,

    input       [4:0]   decode0_source1_AR,
    input       [4:0]   decode1_source1_AR,
    input       [4:0]   decode2_source1_AR,
    input       [4:0]   decode3_source1_AR,

    input       [4:0]   decode0_source2_AR,
    input       [4:0]   decode1_source2_AR,
    input       [4:0]   decode2_source2_AR,
    input       [4:0]   decode3_source2_AR,

    input       [5:0]   freePR0,
    input       [5:0]   freePR1,
    input       [5:0]   freePR2,
    input       [5:0]   freePR3,
    input       [5:0]   freelist_room,

    input       [5:0]   RAT [31:0],

    output              stage4_pause,
    output  reg [2:0]   PR_num_need,

    output              inst0_dest_PR_STA_en,   // need pysical register
    output              inst1_dest_PR_STA_en,
    output              inst2_dest_PR_STA_en,
    output              inst3_dest_PR_STA_en,

    output  reg         inst0_dest_RAT_en,      // need rename
    output  reg         inst1_dest_RAT_en,
    output  reg         inst2_dest_RAT_en,
    output  reg         inst3_dest_RAT_en,

    output  reg [5:0]   inst0_dest_PR,
    output  reg [5:0]   inst1_dest_PR,
    output  reg [5:0]   inst2_dest_PR,
    output  reg [5:0]   inst3_dest_PR,

    output  reg [5:0]   inst0_dest_PR_stage4,
    output  reg [5:0]   inst1_dest_PR_stage4,
    output  reg [5:0]   inst2_dest_PR_stage4,
    output  reg [5:0]   inst3_dest_PR_stage4,

    output  reg [5:0]   inst0_dest_old_PR_stage4,
    output  reg [5:0]   inst1_dest_old_PR_stage4,
    output  reg [5:0]   inst2_dest_old_PR_stage4,
    output  reg [5:0]   inst3_dest_old_PR_stage4,
    
    output  reg [5:0]   inst0_source1_PR_stage4,
    output  reg [5:0]   inst1_source1_PR_stage4,
    output  reg [5:0]   inst2_source1_PR_stage4,
    output  reg [5:0]   inst3_source1_PR_stage4,

    output  reg [5:0]   inst0_source2_PR_stage4,
    output  reg [5:0]   inst1_source2_PR_stage4,
    output  reg [5:0]   inst2_source2_PR_stage4,
    output  reg [5:0]   inst3_source2_PR_stage4,

    output  reg         inst0_source1_en_stage4,
    output  reg         inst1_source1_en_stage4,
    output  reg         inst2_source1_en_stage4,
    output  reg         inst3_source1_en_stage4,
    output  reg         inst0_source2_en_stage4,
    output  reg         inst1_source2_en_stage4,
    output  reg         inst2_source2_en_stage4,
    output  reg         inst3_source2_en_stage4
);
    wire [5:0]  PR0_rd;
    wire [5:0]  PR1_rd;
    wire [5:0]  PR2_rd;
    wire [5:0]  PR3_rd;

    assign PR0_rd = freePR0;
    assign PR1_rd = freePR1;
    assign PR2_rd = freePR2;
    assign PR3_rd = freePR3;

    assign inst0_dest_PR_STA_en = decode0_vld && decode0_dest_vld && (decode0_dest_AR != 5'd0);
    assign inst1_dest_PR_STA_en = decode1_vld && decode1_dest_vld && (decode1_dest_AR != 5'd0);
    assign inst2_dest_PR_STA_en = decode2_vld && decode2_dest_vld && (decode2_dest_AR != 5'd0);
    assign inst3_dest_PR_STA_en = decode3_vld && decode3_dest_vld && (decode3_dest_AR != 5'd0);

    always @(*) begin       // PR_num_need
        if(flush_stage4 || hold_stage4)
            PR_num_need = 3'd0;
        else 
            PR_num_need = inst3_dest_PR_STA_en + inst2_dest_PR_STA_en +
                          inst1_dest_PR_STA_en + inst0_dest_PR_STA_en;
    end
    
    assign stage4_pause = (PR_num_need > freelist_room);    // stage4_pause

    always @(*) begin       // inst0_dest_RAT_en
        if(inst0_dest_PR_STA_en)begin
            if((decode0_dest_AR == decode1_dest_AR) || (decode0_dest_AR == decode2_dest_AR) ||
               (decode0_dest_AR == decode3_dest_AR))
               inst0_dest_RAT_en = 1'b0;
            else 
                inst0_dest_RAT_en = 1'b1;
        end
        else
            inst0_dest_RAT_en = 1'b0;
    end

    always @(*) begin       // inst1_dest_RAT_en
        if(inst1_dest_PR_STA_en)begin
            if((decode1_dest_AR == decode2_dest_AR) ||
               (decode1_dest_AR == decode3_dest_AR))
               inst1_dest_RAT_en = 1'b0;
            else 
                inst1_dest_RAT_en = 1'b1;
        end
        else
            inst1_dest_RAT_en = 1'b0;
    end

    always @(*) begin       // inst2_dest_RAT_en
        if(inst2_dest_PR_STA_en)begin
            if(decode2_dest_AR == decode3_dest_AR)
               inst2_dest_RAT_en = 1'b0;
            else 
                inst2_dest_RAT_en = 1'b1;
        end
        else
            inst2_dest_RAT_en = 1'b0;
    end

    always @(*) begin       // inst3_dest_RAT_en
        if(inst3_dest_PR_STA_en)
            inst2_dest_RAT_en = 1'b1;
        else
            inst2_dest_RAT_en = 1'b0;
    end

    always @(*) begin       // inst0_dest_PR
        if(inst0_dest_PR_STA_en)
            inst0_dest_PR = PR0_rd;
        else
            inst0_dest_PR = 6'd0;
    end

    always @(*) begin       // inst1_dest_PR
        if(inst1_dest_PR_STA_en)
            inst1_dest_PR = inst0_dest_PR_STA_en ? PR1_rd : PR0_rd;
        else
            inst1_dest_PR = 6'd0;
    end

    always @(*) begin       // inst2_dest_PR
        if(inst2_dest_PR_STA_en)
            case ({inst0_dest_PR_STA_en, inst1_dest_PR_STA_en})
                2'b11: inst2_dest_PR = PR2_rd;
                2'b10,
                2'b01: inst2_dest_PR = PR1_rd;
                2'b00: inst2_dest_PR = PR0_rd;
            endcase
        else
            inst2_dest_PR = 6'd0;
    end

    always @(*) begin       // inst3_dest_PR
        if(inst3_dest_PR_STA_en)
            case ({inst0_dest_PR_STA_en, inst1_dest_PR_STA_en, inst2_dest_PR_STA_en})
                3'b111: inst3_dest_PR = PR3_rd;
                3'b110,
                3'b101,
                3'b011: inst3_dest_PR = PR2_rd;
                3'b100,
                3'b010,
                3'b001: inst3_dest_PR = PR1_rd;
                3'b000: inst3_dest_PR = PR0_rd;
            endcase
        else
            inst3_dest_PR = 6'd0;
    end

    always @(posedge clk or negedge rst_n) begin        // inst0_dest_PR_stage4
        if(!rst_n)
            inst0_dest_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst0_dest_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst0_dest_PR_stage4 <= inst0_dest_PR_stage4;
        else if(decode0_dest_vld)
            inst0_dest_PR_stage4 <= inst0_dest_PR;
    end

    always @(posedge clk or negedge rst_n) begin        // inst1_dest_PR_stage4
        if(!rst_n)
            inst1_dest_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst1_dest_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst1_dest_PR_stage4 <= inst1_dest_PR_stage4;
        else if(decode1_dest_vld)
            inst1_dest_PR_stage4 <= inst1_dest_PR;
    end

    always @(posedge clk or negedge rst_n) begin        // inst2_dest_PR_stage4
        if(!rst_n)
            inst2_dest_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst2_dest_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst2_dest_PR_stage4 <= inst2_dest_PR_stage4;
        else if(decode2_dest_vld)
            inst2_dest_PR_stage4 <= inst2_dest_PR;
    end

    always @(posedge clk or negedge rst_n) begin        // inst3_dest_PR_stage4
        if(!rst_n)
            inst3_dest_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst3_dest_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst3_dest_PR_stage4 <= inst3_dest_PR_stage4;
        else if(decode3_dest_vld)
            inst3_dest_PR_stage4 <= inst3_dest_PR;
    end

    always @(posedge clk or negedge rst_n) begin        // inst0_dest_old_PR_stage4
        if(!rst_n)
            inst0_dest_old_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst0_dest_old_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst0_dest_old_PR_stage4 <= inst0_dest_old_PR_stage4;
        else if(decode0_dest_vld)
            inst0_dest_old_PR_stage4 <= RAT[decode0_dest_AR];
    end

    always @(posedge clk or negedge rst_n) begin        // inst1_dest_old_PR_stage4
        if(!rst_n)
            inst1_dest_old_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst1_dest_old_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst1_dest_old_PR_stage4 <= inst1_dest_old_PR_stage4;
        else if(decode0_dest_vld)
            inst1_dest_old_PR_stage4 <= RAT[decode0_dest_AR];
    end

    always @(posedge clk or negedge rst_n) begin        // inst2_dest_old_PR_stage4
        if(!rst_n)
            inst2_dest_old_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst2_dest_old_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst2_dest_old_PR_stage4 <= inst2_dest_old_PR_stage4;
        else if(decode0_dest_vld)
            inst2_dest_old_PR_stage4 <= RAT[decode0_dest_AR];
    end

    always @(posedge clk or negedge rst_n) begin        // inst3_dest_old_PR_stage4
        if(!rst_n)
            inst3_dest_old_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst3_dest_old_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst3_dest_old_PR_stage4 <= inst3_dest_old_PR_stage4;
        else if(decode0_dest_vld)
            inst3_dest_old_PR_stage4 <= RAT[decode0_dest_AR];
    end

    always @(posedge clk or negedge rst_n) begin        // inst0_source1_PR_stage4
        if(!rst_n)
            inst0_source1_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst0_source1_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst0_source1_PR_stage4 <= inst0_source1_PR_stage4;
        else if(decode0_vld && decode0_source1_vld)
            inst0_source1_PR_stage4 <= RAT[decode0_source1_AR];
    end

    always @(posedge clk or negedge rst_n) begin        // inst1_source1_PR_stage4
        if(!rst_n)
            inst1_source1_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst1_source1_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst1_source1_PR_stage4 <= inst1_source1_PR_stage4;
        else if(decode1_vld && decode1_source1_vld)begin
            if(decode1_source1_AR == decode0_dest_AR)
                inst1_source1_PR_stage4 <= inst0_dest_PR;
            else
                inst1_source1_PR_stage4 <= RAT[decode1_source1_AR];
        end
    end

    always @(posedge clk or negedge rst_n) begin        // inst2_source1_PR_stage4
        if(!rst_n)
            inst2_source1_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst2_source1_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst2_source1_PR_stage4 <= inst2_source1_PR_stage4;
        else if(decode2_vld && decode2_source1_vld)begin
            if(decode2_source1_AR == decode1_dest_AR)
                inst2_source1_PR_stage4 <= inst1_dest_PR;
            else if(decode2_source1_AR == decode0_dest_AR)
                inst2_source1_PR_stage4 <= inst0_dest_PR;
            else
                inst2_source1_PR_stage4 <= RAT[decode2_source1_AR];
        end
    end

    always @(posedge clk or negedge rst_n) begin        // inst3_source1_PR_stage4
        if(!rst_n)
            inst3_source1_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst3_source1_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst3_source1_PR_stage4 <= inst3_source1_PR_stage4;
        else if(decode3_vld && decode3_source1_vld)begin
            if(decode3_source1_AR == decode2_dest_AR)
                inst3_source1_PR_stage4 <= inst2_dest_PR;
            else if(decode3_source1_AR == decode1_dest_AR)
                inst3_source1_PR_stage4 <= inst1_dest_PR;
            else if(decode3_source1_AR == decode0_dest_AR)
                inst3_source1_PR_stage4 <= inst0_dest_PR;
            else
                inst3_source1_PR_stage4 <= RAT[decode3_source1_AR];
        end
    end

    always @(posedge clk or negedge rst_n) begin        // inst0_source2_PR_stage4
        if(!rst_n)
            inst0_source2_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst0_source2_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst0_source2_PR_stage4 <= inst0_source2_PR_stage4;
        else if(decode0_vld && decode0_source2_vld)
            inst0_source2_PR_stage4 <= RAT[decode0_source2_AR];
    end

    always @(posedge clk or negedge rst_n) begin        // inst1_source2_PR_stage4
        if(!rst_n)
            inst1_source2_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst1_source2_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst1_source2_PR_stage4 <= inst1_source2_PR_stage4;
        else if(decode1_vld && decode1_source2_vld)begin
            if(decode1_source2_AR == decode0_dest_AR)
                inst1_source2_PR_stage4 <= inst0_dest_PR;
            else
                inst1_source2_PR_stage4 <= RAT[decode1_source2_AR];
        end
    end

    always @(posedge clk or negedge rst_n) begin        // inst2_source2_PR_stage4
        if(!rst_n)
            inst2_source2_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst2_source2_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst2_source2_PR_stage4 <= inst2_source2_PR_stage4;
        else if(decode2_vld && decode2_source2_vld)begin
            if(decode2_source2_AR == decode1_dest_AR)
                inst2_source2_PR_stage4 <= inst1_dest_PR;
            else if(decode2_source2_AR == decode0_dest_AR)
                inst2_source2_PR_stage4 <= inst0_dest_PR;
            else
                inst2_source2_PR_stage4 <= RAT[decode2_source2_AR];
        end
    end

    always @(posedge clk or negedge rst_n) begin        // inst3_source2_PR_stage4
        if(!rst_n)
            inst3_source2_PR_stage4 <= 6'd0;
        else if(flush_stage4)
            inst3_source2_PR_stage4 <= 6'd0;
        else if(hold_stage4)
            inst3_source2_PR_stage4 <= inst3_source2_PR_stage4;
        else if(decode3_vld && decode3_source2_vld)begin
            if(decode3_source2_AR == decode2_dest_AR)
                inst3_source2_PR_stage4 <= inst2_dest_PR;
            else if(decode3_source2_AR == decode1_dest_AR)
                inst3_source2_PR_stage4 <= inst1_dest_PR;
            else if(decode3_source2_AR == decode0_dest_AR)
                inst3_source2_PR_stage4 <= inst0_dest_PR;
            else
                inst3_source2_PR_stage4 <= RAT[decode3_source2_AR];
        end
    end

    always @(posedge clk or negedge rst_n) begin    // inst0_source1_en_stage4
        if(!rst_n || flush_stage4)
            inst0_source1_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst0_source1_en_stage4 <= inst0_source1_en_stage4;
        else if(decode0_vld)
            inst0_source1_en_stage4 <= decode0_source1_vld;
        else 
            inst0_source1_en_stage4 <= 1'b0;
    end
    always @(posedge clk or negedge rst_n) begin    // inst1_source1_en_stage4
        if(!rst_n || flush_stage4)
            inst1_source1_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst1_source1_en_stage4 <= inst1_source1_en_stage4;
        else if(decode0_vld)
            inst1_source1_en_stage4 <= decode0_source1_vld;
        else 
            inst1_source1_en_stage4 <= 1'b0;
    end
    always @(posedge clk or negedge rst_n) begin    // inst2_source1_en_stage4
        if(!rst_n || flush_stage4)
            inst2_source1_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst2_source1_en_stage4 <= inst2_source1_en_stage4;
        else if(decode0_vld)
            inst2_source1_en_stage4 <= decode0_source1_vld;
        else 
            inst2_source1_en_stage4 <= 1'b0;
    end
    always @(posedge clk or negedge rst_n) begin    // inst3_source1_en_stage4
        if(!rst_n || flush_stage4)
            inst3_source1_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst3_source1_en_stage4 <= inst3_source1_en_stage4;
        else if(decode0_vld)
            inst3_source1_en_stage4 <= decode0_source1_vld;
        else 
            inst3_source1_en_stage4 <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin    // inst0_source2_en_stage4
        if(!rst_n || flush_stage4)
            inst0_source2_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst0_source2_en_stage4 <= inst0_source2_en_stage4;
        else if(decode0_vld)
            inst0_source2_en_stage4 <= decode0_source2_vld;
        else 
            inst0_source2_en_stage4 <= 1'b0;
    end
    always @(posedge clk or negedge rst_n) begin    // inst1_source2_en_stage4
        if(!rst_n || flush_stage4)
            inst1_source2_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst1_source2_en_stage4 <= inst1_source2_en_stage4;
        else if(decode0_vld)
            inst1_source2_en_stage4 <= decode0_source2_vld;
        else 
            inst1_source2_en_stage4 <= 1'b0;
    end
    always @(posedge clk or negedge rst_n) begin    // inst2_source2_en_stage4
        if(!rst_n || flush_stage4)
            inst2_source2_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst2_source2_en_stage4 <= inst2_source2_en_stage4;
        else if(decode0_vld)
            inst2_source2_en_stage4 <= decode0_source2_vld;
        else 
            inst2_source2_en_stage4 <= 1'b0;
    end
    always @(posedge clk or negedge rst_n) begin    // inst3_source2_en_stage4
        if(!rst_n || flush_stage4)
            inst3_source2_en_stage4 <= 1'b0;
        else if(hold_stage4)
            inst3_source2_en_stage4 <= inst3_source2_en_stage4;
        else if(decode0_vld)
            inst3_source2_en_stage4 <= decode0_source2_vld;
        else 
            inst3_source2_en_stage4 <= 1'b0;
    end

endmodule