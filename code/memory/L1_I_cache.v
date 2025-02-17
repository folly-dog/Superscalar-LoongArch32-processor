module I_cache (
    input                clk,
    input                rst_n,

    input                flush_stage1_2,
    input                hold_stage1_2,

    input                except_stage0,
    input                except_TLB,

    input        [31:0]  IF_PC,
    input                IF_PC_vld,

    input       [31:12]  IF_PC_PPN,

    input                CACOP_vld,
    input        [31:0]  CACOP_VA,
    input         [4:3]  CACOP_op,      // 0: tag_initial, 1: coherence_direct, 2: coherence_load

    output  reg  [31:0]  PC_stage2,
    output  reg   [1:0]  except_stage2,

    output  reg          instruction0_vld,
    output  reg  [31:0]  instruction0,
    output  reg          instruction1_vld,
    output  reg  [31:0]  instruction1,
    output  reg          instruction2_vld,
    output  reg  [31:0]  instruction2,
    output  reg          instruction3_vld,
    output  reg  [31:0]  instruction3,

    output               I_cache_req,
    output               I_cache_req_op,        // 0: read
    output       [31:0]  I_cache_req_addr,

    input                L2_cache_ack_I_cache,
    input       [511:0]  I_cache_rd_data,

    output reg           stage1_pause
);

    reg [31:0]  PC_stage1;
    reg         except_stage1;

    reg         vld_line0 [11:6];
    reg [31:12] tag_line0 [11:6];
    reg [127:0]   data0_line0 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line0 [11:6];
    reg [383:256] data2_line0 [11:6];
    reg [511:384] data3_line0 [11:6];

    reg         vld_line1 [11:6];
    reg [31:12] tag_line1 [11:6];
    reg [127:0]   data0_line1 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line1 [11:6];
    reg [383:256] data2_line1 [11:6];
    reg [511:384] data3_line1 [11:6];

    reg         vld_line2 [11:6];
    reg [31:12] tag_line2 [11:6];
    reg [127:0]   data0_line2 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line2 [11:6];
    reg [383:256] data2_line2 [11:6];
    reg [511:384] data3_line2 [11:6];

    reg         vld_line3 [11:6];
    reg [31:12] tag_line3 [11:6];
    reg [127:0]   data0_line3 [11:6];       // 将512bit的data分为了4个128bit的BANK，因为每次只会取4条指令
    reg [255:128] data1_line3 [11:6];
    reg [383:256] data2_line3 [11:6];
    reg [511:384] data3_line3 [11:6];
    
    reg vld_line0_stage1;
    reg vld_line1_stage1;
    reg vld_line2_stage1;
    reg vld_line3_stage1;
    reg [31:12] tag_line0_stage1;
    reg [31:12] tag_line1_stage1;
    reg [31:12] tag_line2_stage1;
    reg [31:12] tag_line3_stage1;

    reg vld_line0_CACOP;
    reg vld_line1_CACOP;
    reg vld_line2_CACOP;
    reg vld_line3_CACOP;
    reg [31:12] tag_line0_CACOP;
    reg [31:12] tag_line1_CACOP;
    reg [31:12] tag_line2_CACOP;
    reg [31:12] tag_line3_CACOP;

    reg [1:0]   cnt_cycle;  //用于循环计数，挑选替代的cacheline

    wire line0_hit;
    wire line1_hit;
    wire line2_hit;
    wire line3_hit;

    wire line0_hit_CACOP;
    wire line1_hit_CACOP;
    wire line2_hit_CACOP;
    wire line3_hit_CACOP;

    wire stage1_vld;
    wire way_full;
    wire IF_miss;
    wire IF_hit;

    reg [1:0]  idx_cacheline_wr;

    reg [127:0]  instructions_ready;

    parameter Default_pipeline   = 2'b00;
    parameter rd_L2              = 2'b01;
    parameter cacop_mode         = 2'b10;

    reg [1:0]   current_state;
    reg [1:0]   next_state;

    assign line0_hit = vld_line0_stage1 && (tag_line0_stage1 == IF_PC_PPN);
    assign line1_hit = vld_line1_stage1 && (tag_line1_stage1 == IF_PC_PPN);
    assign line2_hit = vld_line2_stage1 && (tag_line2_stage1 == IF_PC_PPN);
    assign line3_hit = vld_line3_stage1 && (tag_line3_stage1 == IF_PC_PPN);

    assign stage1_vld = (vld_line0_stage1 | vld_line1_stage1 | vld_line2_stage1 | vld_line3_stage1);
    assign way_full = (vld_line0_stage1 & vld_line1_stage1 & vld_line2_stage1 & vld_line3_stage1);
    assign IF_miss = !(line0_hit || line1_hit || line2_hit || line3_hit);  
    assign IF_hit = !IF_miss; 


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state <= Default_pipeline;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            Default_pipeline: begin
                if(IF_miss & stage1_vld)
                    next_state = rd_L2;
                else if(CACOP_vld && (CACOP_op == 2'b10))
                    next_state = cacop_mode;
                else 
                    next_state = Default_pipeline;
            end
            rd_L2: next_state = (L2_cache_ack_I_cache) ? Default_pipeline : rd_L2;
            cacop_mode: next_state = Default_pipeline;
            default: next_state = Default_pipeline;
        endcase
    end

    always @(*) begin        // stage1_pause
        case (current_state)
            Default_pipeline: stage1_pause = CACOP_vld;
            default: stage1_pause = 1'b1;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin        // PC_stage1
        if(!rst_n)
            PC_stage1 <= 32'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!stage1_pause) && (IF_PC_vld || except_stage0))
            PC_stage1 <= IF_PC;
    end
        

    always @(posedge clk or negedge rst_n) begin        // except_stage1
        if(!rst_n)
            except_stage1 <= 1'b0;
        else begin
            if(flush_stage1_2)
                except_stage1 <= 1'b0;
            else if(hold_stage1_2)
                except_stage1 <= except_stage1;
            else if(stage1_pause)
                except_stage1 <= except_stage1;
            else if(except_stage0)
                except_stage1 <= 1'b1;
            else
                except_stage1 <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        // PC_stage2
        if(!rst_n)
            PC_stage2 <= 32'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && 
                      (stage1_vld || except_stage1 || except_TLB || L2_cache_ack_I_cache))
            PC_stage1 <= PC_stage1;
    end
        

    always @(posedge clk or negedge rst_n) begin        // except_stage2
        if(!rst_n)
            except_stage2 <= 2'b0;
        else begin
            if(flush_stage1_2)
                except_stage2 <= 2'b0;
            else if(hold_stage1_2)
                except_stage2 <= except_stage2;
            else if(except_stage1 || except_TLB)
                except_stage1 <= {except_TLB, except_stage1};
            else
                except_stage1 <= 2'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //vld_line0_stage1
        if(!rst_n)
            vld_line0_stage1 <= 1'b0;
        else begin
            if(flush_stage1_2)
                vld_line0_stage1 <= 1'b0;
            else if(hold_stage1_2)
                vld_line0_stage1 <= vld_line0_stage1;
            else if(except_stage0)
                vld_line0_stage1 <= 1'b0;
            else if(stage1_pause)
                vld_line0_stage1 <= 1'b0;
            else if(IF_PC_vld && (IF_PC[3:2] == 2'b00))
                vld_line0_stage1 <= vld_line0[IF_PC[11:6]];
            else
                vld_line0_stage1 <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //vld_line1_stage1
        if(!rst_n)
            vld_line1_stage1 <= 1'b0;
        else begin
            if(flush_stage1_2)
                vld_line1_stage1 <= 1'b0;
            else if(hold_stage1_2)
                vld_line1_stage1 <= vld_line1_stage1;
            else if(except_stage0)
                vld_line1_stage1 <= 1'b0;
            else if(stage1_pause)
                vld_line1_stage1 <= 1'b0;
            else if(IF_PC_vld && (IF_PC[3:2] < 2'b10))
                vld_line1_stage1 <= vld_line1[IF_PC[11:6]];
            else
                vld_line1_stage1 <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //vld_line2_stage1
        if(!rst_n)
            vld_line2_stage1 <= 1'b0;
        else begin
            if(flush_stage1_2)
                vld_line2_stage1 <= 1'b0;
            else if(hold_stage1_2)
                vld_line2_stage1 <= vld_line2_stage1;
            else if(except_stage0)
                vld_line2_stage1 <= 1'b0;
            else if(stage1_pause)
                vld_line2_stage1 <= 1'b0;
            else if(IF_PC_vld && (IF_PC[3:2] < 2'b11))
                vld_line2_stage1 <= vld_line2[IF_PC[11:6]];
            else
                vld_line2_stage1 <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //vld_line3_stage1
        if(!rst_n)
            vld_line3_stage1 <= 1'b0;
        else begin
            if(flush_stage1_2)
                vld_line3_stage1 <= 1'b0;
            else if(hold_stage1_2)
                vld_line3_stage1 <= vld_line3_stage1;
            else if(except_stage0)
                vld_line3_stage1 <= 1'b0;
            else if(stage1_pause)
                vld_line3_stage1 <= 1'b0;
            else if(IF_PC_vld)
                vld_line3_stage1 <= vld_line3[IF_PC[11:6]];
            else
                vld_line3_stage1 <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //tag_line0_stage1
        if(!rst_n)
            tag_line0_stage1 <= 20'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage0) && (!stage1_pause) 
                                  && (IF_PC_vld && (IF_PC[3:2] == 2'b00)))
                tag_line0_stage1 <= tag_line0[IF_PC[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin        //tag_line1_stage1
        if(!rst_n)
            tag_line1_stage1 <= 20'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage0) && (!stage1_pause) 
                                  && (IF_PC_vld && (IF_PC[3:2] < 2'b10)))
                tag_line1_stage1 <= tag_line1[IF_PC[11:6]];
    end
    
    always @(posedge clk or negedge rst_n) begin        //tag_line2_stage1
        if(!rst_n)
            tag_line2_stage1 <= 20'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage0) && (!stage1_pause) 
                                  && (IF_PC_vld && (IF_PC[3:2] < 2'b11)))
                tag_line2_stage1 <= tag_line2[IF_PC[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin        //tag_line3_stage1
        if(!rst_n)
            tag_line3_stage1 <= 20'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage0) && (!stage1_pause) 
                                  && (IF_PC_vld))
                tag_line3_stage1 <= tag_line3[IF_PC[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin        //instruction0_vld
        if(!rst_n)
            instruction0_vld <= 1'b0;
        else begin
            if(flush_stage1_2)
                instruction0_vld <= 1'b0;
            else if(hold_stage1_2)
                instruction0_vld <= instruction0_vld;
            else if(except_stage1 || except_TLB)
                instruction0_vld <= 1'b0;
            else if(IF_hit && (IF_PC[3:2] == 2'b00))
                instruction0_vld <= 1'b1;
            else if(L2_cache_ack_I_cache && (IF_PC[3:2] == 2'b00))
                vld_line0_stage1 <= 1'b1;
            else
                instruction0_vld <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //instruction1_vld
        if(!rst_n)
            instruction1_vld <= 1'b0;
        else begin
            if(flush_stage1_2)
                instruction1_vld <= 1'b0;
            else if(hold_stage1_2)
                instruction1_vld <= instruction1_vld;
            else if(except_stage1 || except_TLB)
                instruction1_vld <= 1'b0;
            else if(IF_hit && (IF_PC[3:2] < 2'b10))
                instruction1_vld <= 1'b1;
            else if(L2_cache_ack_I_cache && (IF_PC[3:2] < 2'b10))
                vld_line0_stage1 <= 1'b1;
            else
                instruction1_vld <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //instruction2_vld
        if(!rst_n)
            instruction2_vld <= 1'b0;
        else begin
            if(flush_stage1_2)
                instruction2_vld <= 1'b0;
            else if(hold_stage1_2)
                instruction2_vld <= instruction2_vld;
            else if(except_stage1 || except_TLB)
                instruction2_vld <= 1'b0;
            else if(IF_hit && (IF_PC[3:2] < 2'b11))
                instruction2_vld <= 1'b1;
            else if(L2_cache_ack_I_cache && (IF_PC[3:2] < 2'b11))
                vld_line0_stage1 <= 1'b1;
            else
                instruction2_vld <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin        //instruction3_vld
        if(!rst_n)
            instruction3_vld <= 1'b0;
        else begin
            if(flush_stage1_2)
                instruction3_vld <= 1'b0;
            else if(hold_stage1_2)
                instruction3_vld <= instruction3_vld;
            else if(except_stage1 || except_TLB)
                instruction3_vld <= 1'b0;
            else if(IF_hit)
                instruction3_vld <= 1'b1;
            else if(L2_cache_ack_I_cache)
                vld_line0_stage1 <= 1'b1;
            else
                instruction3_vld <= 1'b0;
        end
    end

    always @(*) begin           //instructions_ready
        if(L2_cache_ack_I_cache)
            case (PC_stage1[5:4])
                2'b00: instructions_ready = I_cache_rd_data[127:0];
                2'b01: instructions_ready = I_cache_rd_data[255:128];
                2'b10: instructions_ready = I_cache_rd_data[383:256];
                2'b11: instructions_ready = I_cache_rd_data[511:384];
            endcase
        else 
            case ({vld_line0_stage1, vld_line1_stage1, vld_line2_stage1, vld_line3_stage1})
                4'b1000: case (PC_stage1[5:4])
                    2'b00: instructions_ready = data0_line0[PC_stage1[11:6]];
                    2'b01: instructions_ready = data1_line0[PC_stage1[11:6]];
                    2'b10: instructions_ready = data2_line0[PC_stage1[11:6]];
                    2'b11: instructions_ready = data3_line0[PC_stage1[11:6]];
                endcase
                4'b0100: case (PC_stage1[5:4])
                    2'b00: instructions_ready = data0_line1[PC_stage1[11:6]];
                    2'b01: instructions_ready = data1_line1[PC_stage1[11:6]];
                    2'b10: instructions_ready = data2_line1[PC_stage1[11:6]];
                    2'b11: instructions_ready = data3_line1[PC_stage1[11:6]];
                endcase
                4'b0010: case (PC_stage1[5:4])
                    2'b00: instructions_ready = data0_line2[PC_stage1[11:6]];
                    2'b01: instructions_ready = data1_line2[PC_stage1[11:6]];
                    2'b10: instructions_ready = data2_line2[PC_stage1[11:6]];
                    2'b11: instructions_ready = data3_line2[PC_stage1[11:6]];
                endcase
                4'b0001: case (PC_stage1[5:4])
                    2'b00: instructions_ready = data0_line3[PC_stage1[11:6]];
                    2'b01: instructions_ready = data1_line3[PC_stage1[11:6]];
                    2'b10: instructions_ready = data2_line3[PC_stage1[11:6]];
                    2'b11: instructions_ready = data3_line3[PC_stage1[11:6]];
                endcase
            endcase
    end

    always @(posedge clk or negedge rst_n) begin        //instruction0
        if(!rst_n)
            instruction0 <= 32'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage1) && (!except_TLB) &&
                                     (IF_hit && (PC_stage1[3:2] == 2'b00)))
            instruction0 <= instructions_ready[31:0];
    end

    always @(posedge clk or negedge rst_n) begin        //instruction1
        if(!rst_n)
            instruction1 <= 32'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage1) && (!except_TLB) &&
                                     (IF_hit && (PC_stage1[3:2] < 2'b10)))
            instruction1 <= instructions_ready[63:32];
    end

    always @(posedge clk or negedge rst_n) begin        //instruction2
        if(!rst_n)
            instruction2 <= 32'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage1) && (!except_TLB) &&
                                     (IF_hit && (PC_stage1[3:2] < 2'b11)))
            instruction2 <= instructions_ready[95:64];
    end

    always @(posedge clk or negedge rst_n) begin        //instruction3
        if(!rst_n)
            instruction3 <= 32'd0;
        else if((!flush_stage1_2) && (!hold_stage1_2) && (!except_stage1) && (!except_TLB) &&
                                     (IF_hit))
            instruction3 <= instructions_ready[127:96];
    end

    always @(posedge clk or negedge rst_n) begin        //cnt_cycle
       if(!rst_n)
            cnt_cycle <= 2'b00;
        else
            cnt_cycle <= (cnt_cycle == 2'b11) ? 2'b00 : cnt_cycle + 2'b01;
    end

    always @(posedge clk or negedge rst_n) begin            //vld_line0_CACOP
        if(!rst_n)
            vld_line0_CACOP <= 1'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            vld_line0_CACOP <= vld_line0[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //vld_line1_CACOP
        if(!rst_n)
            vld_line1_CACOP <= 1'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            vld_line1_CACOP <= vld_line1[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //vld_line2_CACOP
        if(!rst_n)
            vld_line2_CACOP <= 1'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            vld_line2_CACOP <= vld_line2[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //vld_line3_CACOP
        if(!rst_n)
            vld_line3_CACOP <= 1'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            vld_line3_CACOP <= vld_line3[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //tag_line0_CACOP
        if(!rst_n)
            tag_line0_CACOP <= 20'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            tag_line0_CACOP <= tag_line0[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //tag_line1_CACOP
        if(!rst_n)
            tag_line1_CACOP <= 20'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            tag_line1_CACOP <= tag_line1[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //tag_line2_CACOP
        if(!rst_n)
            tag_line2_CACOP <= 20'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            tag_line2_CACOP <= tag_line2[CACOP_VA[11:6]];
    end

    always @(posedge clk or negedge rst_n) begin            //tag_line3_CACOP
        if(!rst_n)
            tag_line3_CACOP <= 20'b0;
        else if(CACOP_vld && (CACOP_op == 2'b10))
            tag_line3_CACOP <= tag_line3[CACOP_VA[11:6]];
    end

    assign line0_hit_CACOP = vld_line0_CACOP && (tag_line0_CACOP == CACOP_VA[31:12]);
    assign line1_hit_CACOP = vld_line1_CACOP && (tag_line1_CACOP == CACOP_VA[31:12]);
    assign line2_hit_CACOP = vld_line2_CACOP && (tag_line2_CACOP == CACOP_VA[31:12]);
    assign line3_hit_CACOP = vld_line3_CACOP && (tag_line3_CACOP == CACOP_VA[31:12]);

    always @(*) begin           //idx_cacheline_wr
        if(way_full)
            idx_cacheline_wr = cnt_cycle;
        else if(!line0_hit)
            idx_cacheline_wr = 2'b00;
        else if(!line1_hit)
            idx_cacheline_wr = 2'b01;
        else if(!line2_hit)
            idx_cacheline_wr = 2'b10;
        else if(!line3_hit)
            idx_cacheline_wr = 2'b11;
    end

    always @(posedge clk) begin         //vld_linex
        if(CACOP_vld && (CACOP_op == 2'b1))
            case (CACOP_VA[1:0])
                2'b00: vld_line0[CACOP_VA[11:6]] <= 1'b0;
                2'b01: vld_line1[CACOP_VA[11:6]] <= 1'b0;
                2'b10: vld_line2[CACOP_VA[11:6]] <= 1'b0;
                2'b11: vld_line3[CACOP_VA[11:6]] <= 1'b0;
            endcase
        if(current_state == cacop_mode)begin
            if(line0_hit_CACOP)
                vld_line0[CACOP_VA[11:6]] <= 1'b0;
            else if(line1_hit_CACOP)
                vld_line1[CACOP_VA[11:6]] <= 1'b0;
            else if(line2_hit_CACOP)
                vld_line2[CACOP_VA[11:6]] <= 1'b0;
            else if(line3_hit_CACOP)
                vld_line3[CACOP_VA[11:6]] <= 1'b0;
        end
        if(L2_cache_ack_I_cache)
            case (idx_cacheline_wr)
                2'b00: vld_line0[PC_stage1[11:6]] <= 1'b1;
                2'b01: vld_line1[PC_stage1[11:6]] <= 1'b1;
                2'b10: vld_line2[PC_stage1[11:6]] <= 1'b1;
                2'b11: vld_line3[PC_stage1[11:6]] <= 1'b1;
            endcase
    end

    always @(posedge clk) begin         //tag_linex
        if(CACOP_vld && (CACOP_op == 2'b00))
            case (CACOP_op)
                2'b00: tag_line0[CACOP_VA[11:6]] <= IF_PC_PPN[31:12];
                2'b01: tag_line1[CACOP_VA[11:6]] <= IF_PC_PPN[31:12];
                2'b10: tag_line2[CACOP_VA[11:6]] <= IF_PC_PPN[31:12];
                2'b11: tag_line3[CACOP_VA[11:6]] <= IF_PC_PPN[31:12];
            endcase
        if(L2_cache_ack_I_cache)
            case (idx_cacheline_wr)
                2'b00: tag_line0[PC_stage1[11:6]] <= IF_PC_PPN[31:12];
                2'b01: tag_line1[PC_stage1[11:6]] <= IF_PC_PPN[31:12];
                2'b10: tag_line2[PC_stage1[11:6]] <= IF_PC_PPN[31:12];
                2'b11: tag_line3[PC_stage1[11:6]] <= IF_PC_PPN[31:12];
            endcase
    end

    always @(posedge clk) begin         //data_linex
        if(L2_cache_ack_I_cache)
            case (idx_cacheline_wr)
                2'b00: begin
                    data0_line0[PC_stage1[11:6]] <= I_cache_rd_data[127:0];
                    data1_line0[PC_stage1[11:6]] <= I_cache_rd_data[255:128];
                    data2_line0[PC_stage1[11:6]] <= I_cache_rd_data[383:256];
                    data3_line0[PC_stage1[11:6]] <= I_cache_rd_data[511:384];
                end
                2'b01: begin
                    data0_line1[PC_stage1[11:6]] <= I_cache_rd_data[127:0];
                    data1_line1[PC_stage1[11:6]] <= I_cache_rd_data[255:128];
                    data2_line1[PC_stage1[11:6]] <= I_cache_rd_data[383:256];
                    data3_line1[PC_stage1[11:6]] <= I_cache_rd_data[511:384];
                end
                2'b10: begin
                    data0_line2[PC_stage1[11:6]] <= I_cache_rd_data[127:0];
                    data1_line2[PC_stage1[11:6]] <= I_cache_rd_data[255:128];
                    data2_line2[PC_stage1[11:6]] <= I_cache_rd_data[383:256];
                    data3_line2[PC_stage1[11:6]] <= I_cache_rd_data[511:384];
                end
                2'b11: begin
                    data0_line3[PC_stage1[11:6]] <= I_cache_rd_data[127:0];
                    data1_line3[PC_stage1[11:6]] <= I_cache_rd_data[255:128];
                    data2_line3[PC_stage1[11:6]] <= I_cache_rd_data[383:256];
                    data3_line3[PC_stage1[11:6]] <= I_cache_rd_data[511:384];
                end
            endcase
    end

    assign I_cache_req = (current_state == cacop_mode) && (!L2_cache_ack_I_cache);
    assign I_cache_req_op = 1'b0;
    assign I_cache_req_addr = {IF_PC_PPN, PC_stage1[11:0]};

endmodule