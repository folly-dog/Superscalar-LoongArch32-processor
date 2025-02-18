module  D_cache(
    input               clk,
    input               rst_n,

    input               load_req,
    input       [31:0]  load_addr,
    input      [31:12]  load_PPN,
    output reg          load_ack,
    output reg  [31:0]  load_data,

    input               store_req,
    input        [1:0]  store_op,   // store 10:W, 01:H, 00:B
    input       [31:0]  store_addr,
    input      [31:12]  store_PPN,
    input       [31:0]  store_data,
    output              store_ack,

    input               CACOP_req,
    input        [1:0]  CACOP_op,   // 0, 1, 2
    input       [31:0]  CACOP_addr,
    input      [31:12]  CACOP_PPN,
    output              CACOP_ack

    output reg           D_cache_req,
    output               D_cache_req_op,        // 0: read, 1: write
    output reg   [31:0]  D_cache_req_addr,
    output reg  [511:0]  D_cache_wr_data,

    input                L2_cache_ack_D_cache,
    input       [511:0]  D_cache_rd_data
);

    reg  way_replace;   // 2way, replace which one
    reg [1:0] mode;     // 01: load, 10: store, 11: CACOP

    reg         vld_line0 [11:6];
    reg         dirty_line0 [11:6];
    reg [31:12] tag_line0 [11:6];
    reg [63:0]    data0_line0 [11:6];       // 将512bit的data分为了8个64bit的BANK
    reg [127:64]  data1_line0 [11:6];
    reg [191:128] data2_line0 [11:6];
    reg [255:192] data3_line0 [11:6];
    reg [319:256] data4_line0 [11:6];   
    reg [383:320] data5_line0 [11:6];
    reg [447:384] data6_line0 [11:6];
    reg [511:448] data7_line0 [11:6];

    reg         vld_line1 [11:6];
    reg         dirty_line1 [11:6];
    reg [31:12] tag_line1 [11:6];
    reg [63:0]    data0_line1 [11:6];       // 将512bit的data分为了8个64bit的BANK
    reg [127:64]  data1_line1 [11:6];
    reg [191:128] data2_line1 [11:6];
    reg [255:192] data3_line1 [11:6];
    reg [319:256] data4_line1 [11:6];   
    reg [383:320] data5_line1 [11:6];
    reg [447:384] data6_line1 [11:6];
    reg [511:448] data7_line1 [11:6];

    reg         vld_line0_rd;
    reg         dirty_line0_rd;
    reg [31:12] tag_line0_rd;

    reg         vld_line1_rd;
    reg         dirty_line1_rd;
    reg [31:12] tag_line1_rd;

    wire way_full;
    wire dirty_cnt_way;     //被计数器选中的way,dirty情况
    reg idx_way_wr;
    reg [11:6] addr_choose;       // load store CACOP, choose one to wr D-cache

    wire load_line0_hit;
    wire load_line1_hit;
    wire load_hit;

    wire store_line0_hit;
    wire store_line1_hit;
    wire store_hit;

    wire CACOP_line0_hit;
    wire CACOP_line1_hit;
    wire CACOP_hit;

    assign way_full = vld_line0_rd & vld_line1_rd;      // way_full
    assign dirty_cnt_way = way_replace ? dirty_line1_rd : dirty_line0_rd;   // dirty_cnt_way

    always @(*) begin       // idx_way_wr
        if(!way_full)begin
            if (dirty_line0_rd)
                idx_way_wr = 1'b1;
            else
                idx_way_wr = 1'b0;
        end
        else
            idx_way_wr = way_replace;
    end

    assign load_line0_hit = vld_line0_rd && (tag_line0_rd == load_PPN);
    assign load_line1_hit = vld_line1_rd && (tag_line1_rd == load_PPN);
    assign load_hit = load_line0_hit | load_line1_hit;

    assign store_line0_hit = vld_line0_rd && (tag_line0_rd == store_PPN);
    assign store_line1_hit = vld_line1_rd && (tag_line1_rd == store_PPN);
    assign store_hit = store_line0_hit | store_line1_hit;

    assign CACOP_line0_hit = vld_line0_rd && (tag_line0_rd == CACOP_PPN);
    assign CACOP_line1_hit = vld_line1_rd && (tag_line1_rd == CACOP_PPN);
    assign CACOP_hit = CACOP_line0_hit | CACOP_line1_hit;

    parameter   IDLE        = 3'b000;
    parameter   load_mode   = 3'b001;
    parameter   wr_L2       = 3'b010;
    parameter   rd_L2       = 3'b011;
    parameter   store_mode  = 3'b100;
    parameter   CACOP_mode  = 3'b101;

    reg [2:0]   current_state;
    reg [2:0]   next_state;

    always @(posedge clk or negedge rst_n) begin    
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if(CACOP_req)
                    next_state = CACOP_mode;
                else if (store_req)
                    next_state = store_mode;
                else if (load_req)
                    next_state = load_mode;
                else 
                    next_state = IDLE;
            end
            CACOP_mode:begin
                case (CACOP_op)
                    2'b00: next_state = IDLE;
                    2'b01: begin
                        if(CACOP_addr[0])
                            next_state = dirty_line1_rd ? wr_L2 : IDLE;
                        else
                            next_state = dirty_line0_rd ? wr_L2 : IDLE; 
                    end
                    2'b10:begin
                        if((CACOP_line0_hit && dirty_line0_rd) || (CACOP_line1_hit && dirty_line1_rd))
                            next_state = wr_L2;
                        else
                            next_state = IDLE;
                    end
                    default: next_state = IDLE;
                endcase
            end
            store_mode:begin
                if((store_line0_hit && dirty_line0_rd) || (store_line1_hit && dirty_line1_rd) ||
            (!store_hit && way_full && ((way_replace && dirty_line1_rd) || (!way_replace && dirty_line0_rd))))
                    next_state = wr_L2;
                else
                    next_state = IDLE;
            end
            load_mode:begin
                if(load_hit)
                    next_state = IDLE;
                else begin
                    if(!way_full)
                        next_state = rd_L2;
                    else if ((way_replace && dirty_line1_rd) || (!way_replace && dirty_line0_rd))
                        next_state = wr_L2;
                    else
                        next_state = rd_L2;     
                end
            end
            wr_L2:begin
                if(L2_cache_ack_D_cache)begin
                    if(mode == 2'b01)
                        next_state = rd_L2;
                    else 
                        next_state = IDLE; 
                end
                else
                    next_state = wr_L2;
            end
            rd_L2: next_state = L2_cache_ack_D_cache ? IDLE : rd_L2;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin            // way_replace
        if(!rst_n)
            way_replace <= 1'b0;
        else if (current_state == IDLE)
            way_replace <= ~way_replace;
    end

    always @(posedge clk or negedge rst_n) begin            // mode
        if(!rst_n)
            mode <= 2'b00;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                mode <= 2'b11;
            else if (store_req)
                mode <= 2'b10;
            else if (load_req)
                mode <= 2'b01;
            else
                mode <= 2'b00;
        end
    end

    always @(*) begin           // addr_choose
        case (mode)
            2'b01: addr_choose = load_addr[11:6];
            2'b10: addr_choose = store_addr[11:6];
            2'b11: addr_choose = CACOP_addr[11:6];
            default: addr_choose = 6'd0;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin            // vld_line0_rd
        if(!rst_n)
            vld_line0_rd <= 1'b0;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                vld_line0_rd <= vld_line0[CACOP_addr[11:6]];
            else if (store_req)
                vld_line0_rd <= vld_line0[store_addr[11:6]];
            else if (load_req)
                vld_line0_rd <= vld_line0[load_addr[11:6]];
        end
    end

    always @(posedge clk or negedge rst_n) begin            // vld_line1_rd
        if(!rst_n)
            vld_line1_rd <= 1'b0;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                vld_line1_rd <= vld_line1[CACOP_addr[11:6]];
            else if (store_req)
                vld_line1_rd <= vld_line1[store_addr[11:6]];
            else if (load_req)
                vld_line1_rd <= vld_line1[load_addr[11:6]];
        end
    end

    always @(posedge clk or negedge rst_n) begin            // dirty_line0_rd
        if(!rst_n)
            dirty_line0_rd <= 1'b0;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                dirty_line0_rd <= dirty_line0[CACOP_addr[11:6]];
            else if (store_req)
                dirty_line0_rd <= dirty_line0[store_addr[11:6]];
            else if (load_req)
                dirty_line0_rd <= dirty_line0[load_addr[11:6]];
        end
    end

    always @(posedge clk or negedge rst_n) begin            // dirty_line1_rd
        if(!rst_n)
            dirty_line1_rd <= 1'b0;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                dirty_line1_rd <= dirty_line1[CACOP_addr[11:6]];
            else if (store_req)
                dirty_line1_rd <= dirty_line1[store_addr[11:6]];
            else if (load_req)
                dirty_line1_rd <= dirty_line1[load_addr[11:6]];
        end
    end
    
    always @(posedge clk or negedge rst_n) begin            // tag_line0_rd
        if(!rst_n)
            tag_line0_rd <= 1'b0;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                tag_line0_rd <= tag_line0[CACOP_addr[11:6]];
            else if (store_req)
                tag_line0_rd <= tag_line0[store_addr[11:6]];
            else if (load_req)
                tag_line0_rd <= tag_line0[load_addr[11:6]];
        end
    end

    always @(posedge clk or negedge rst_n) begin            // tag_line1_rd
        if(!rst_n)
            tag_line1_rd <= 1'b0;
        else if(current_state == IDLE)begin
            if(CACOP_req)
                tag_line1_rd <= tag_line1[CACOP_addr[11:6]];
            else if (store_req)
                tag_line1_rd <= tag_line1[store_addr[11:6]];
            else if (load_req)
                tag_line1_rd <= tag_line1[load_addr[11:6]];
        end
    end

    always @(posedge clk) begin
        if((current_state == IDLE) && CACOP_req && (CACOP_op == 2'b00))begin
            if(CACOP_addr[0])
                tag_line1[CACOP_addr[11:6]] <= 20'd0;
            else
                tag_line0[CACOP_addr[11:6]] <= 20'd0; 
        end
    end

    always @(posedge clk) begin
        if((current_state == IDLE) && CACOP_req && (CACOP_op == 2'b01))begin
            if(CACOP_addr[0])
                vld_line1[CACOP_addr[11:6]] <= 1'b0;
            else
                vld_line0[CACOP_addr[11:6]] <= 1'b0; 
        end
        if(current_state == CACOP_mode && (CACOP_op == 2'b10))begin
            if(CACOP_line1_hit)
                vld_line1[CACOP_addr[11:6]] <= 1'b0;
            if(CACOP_line0_hit)
                vld_line0[CACOP_addr[11:6]] <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin            // load_ack
        if(!rst_n)
            load_ack <= 1'b0;
        else
            load_ack <= (((current_state == load_mode) && (next_state == IDLE)) ||
                         ((current_state == rd_L2) && (next_state == IDLE)));
    end

    always @(posedge clk or negedge rst_n) begin            // load_data
        if(!rst_n)
            load_data <= 32'd0;
        else begin
            if(((current_state == load_mode) && (next_state == IDLE)))begin
                if(load_line0_hit)
                    case (load_addr[5:3])
                        3'b000: load_data <= data0_line0[load_addr[11:6]];
                        3'b001: load_data <= data1_line0[load_addr[11:6]];
                        3'b010: load_data <= data2_line0[load_addr[11:6]];
                        3'b011: load_data <= data3_line0[load_addr[11:6]];
                        3'b100: load_data <= data4_line0[load_addr[11:6]];
                        3'b101: load_data <= data5_line0[load_addr[11:6]];
                        3'b110: load_data <= data6_line0[load_addr[11:6]];
                        3'b111: load_data <= data7_line0[load_addr[11:6]];
                    endcase
                else
                    case (load_addr[5:3])
                        3'b000: load_data <= data0_line1[load_addr[11:6]];
                        3'b001: load_data <= data1_line1[load_addr[11:6]];
                        3'b010: load_data <= data2_line1[load_addr[11:6]];
                        3'b011: load_data <= data3_line1[load_addr[11:6]];
                        3'b100: load_data <= data4_line1[load_addr[11:6]];
                        3'b101: load_data <= data5_line1[load_addr[11:6]];
                        3'b110: load_data <= data6_line1[load_addr[11:6]];
                        3'b111: load_data <= data7_line1[load_addr[11:6]];
                    endcase
            end
        end
    end

    assign store_ack = (((current_state == store_mode) && (next_state == IDLE)) ||
                        ((current_state == wr_L2) && (next_state == IDLE) && (mode == 2'b10)));

    assign CACOP_ack = (((current_state == CACOP_mode) && (next_state == IDLE)) ||
                        ((current_state == wr_L2) && (next_state == IDLE) && (mode == 2'b11)));

    always @(*) begin           // D_cache_req
        if((current_state == wr_L2) || (current_state == rd_L2))
            D_cache_req = L2_cache_ack_D_cache ? 1'b0 : 1'b1;
        else
            D_cache_req = 1'b0;
    end

    assign D_cache_req_op = (current_state == wr_L2);       //D_cache_req_op

    always @(posedge clk or negedge rst_n) begin           // D_cache_req_addr
        if(!rst_n)
            D_cache_req_addr <= 32'd0;
        else 
            case (mode)
                2'b01: D_cache_req_addr <= {load_PPN, load_addr[11:0]};
                2'b10: D_cache_req_addr <= {store_PPN, store_addr[11:0]};
                2'b11: D_cache_req_addr <= {CACOP_PPN, CACOP_addr[11:0]};
            endcase
    end

    always @(posedge clk or negedge rst_n) begin           // D_cache_wr_data
        if(!rst_n)
            D_cache_wr_data <= 512'd0;
        else if(next_state == wr_L2)
            if(idx_way_wr)
                D_cache_wr_data <= {data7_line1[addr_choose], data6_line1[addr_choose], data5_line1[addr_choose], data4_line1[addr_choose],
                                    data3_line1[addr_choose], data2_line1[addr_choose], data1_line1[addr_choose], data0_line1[addr_choose]};
            else
                D_cache_wr_data <= {data7_line0[addr_choose], data6_line0[addr_choose], data5_line0[addr_choose], data4_line0[addr_choose],
                                    data3_line0[addr_choose], data2_line0[addr_choose], data1_line0[addr_choose], data0_line0[addr_choose]};
    end



endmodule