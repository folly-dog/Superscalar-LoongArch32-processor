module  freelist(
    input               clk,
    input               rst_n,

    input               flush_stage4,
    input               stage4_pause,

    input       [2:0]   PR_num_need,
    input       [2:0]   PR_num_retire,

    input       [5:0]   retire_PR0,     // already ordered by retire
    input       [5:0]   retire_PR1,
    input       [5:0]   retire_PR2,
    input       [5:0]   retire_PR3,

    output reg  [5:0]   freePR0,
    output reg  [5:0]   freePR1,
    output reg  [5:0]   freePR2,
    output reg  [5:0]   freePR3,
    output      [5:0]   freelist_room
);
    reg  [5:0]  freelist [31:0];
    reg  [5:0]  a_freelist [31:0];

    reg  [5:0]  wr_ptr_exp;
    wire [4:0]  wr_ptr;
    reg  [5:0]  rd_ptr_exp;
    wire [4:0]  rd_ptr;

    reg  [5:0]  a_wr_ptr_exp;
    wire [4:0]  a_wr_ptr;
    reg  [5:0]  a_rd_ptr_exp;

    integer i;

    always @(posedge clk or negedge rst_n) begin    // wr_ptr_exp
        if(!rst_n)
            wr_ptr_exp <= {1'b1, 5'b0};
        else if(flush_stage4)
            wr_ptr_exp <= a_wr_ptr_exp;
        else
            wr_ptr_exp <= wr_ptr_exp + PR_num_retire;
    end
    assign wr_ptr = wr_ptr_exp[4:0];

    always @(posedge clk or negedge rst_n) begin    // rd_ptr_exp
        if(!rst_n)
            rd_ptr_exp <= 6'd0;
        else if(flush_stage4)
            rd_ptr_exp <= a_rd_ptr_exp;
        else if(!stage4_pause)
            rd_ptr_exp <= rd_ptr_exp + PR_num_need;
    end
    assign rd_ptr = rd_ptr_exp[4:0];

    assign freelist_room = (wr_ptr_exp - rd_ptr_exp);

    always @(posedge clk or negedge rst_n) begin    // a_wr_ptr_exp
        if(!rst_n)
            a_wr_ptr_exp <= {1'b1, 5'b0};
        else
            a_wr_ptr_exp <= a_wr_ptr_exp + PR_num_retire;
    end
    assign a_wr_ptr = a_wr_ptr_exp[4:0];

    always @(posedge clk or negedge rst_n) begin    // a_rd_ptr_exp
        if(!rst_n)
            a_rd_ptr_exp <= 6'd0;
        else
            a_rd_ptr_exp <= a_rd_ptr_exp + PR_num_retire;
    end

    always @(posedge clk or negedge rst_n) begin    // freelist
        if(!rst_n)
            for (i = 0; i < 32; i = i + 1)
                freelist[i] <= {1'b1, 5'(i)};
        else 
            case (PR_num_retire)
                3'd1:  freelist[wr_ptr] <= retire_PR0;
                3'd2:  begin
                            freelist[wr_ptr] <= retire_PR0;
                            freelist[wr_ptr + 1] <= retire_PR1;
                        end
                3'd3:  begin
                            freelist[wr_ptr] <= retire_PR0;
                            freelist[wr_ptr + 1] <= retire_PR1;
                            freelist[wr_ptr + 2] <= retire_PR2;
                        end
                3'd4:  begin
                            freelist[wr_ptr] <= retire_PR0;
                            freelist[wr_ptr + 1] <= retire_PR1;
                            freelist[wr_ptr + 2] <= retire_PR2;
                            freelist[wr_ptr + 3] <= retire_PR3;
                        end
                default: ;
            endcase
    end

    always @(posedge clk or negedge rst_n) begin    // a_freelist
        if(!rst_n)
            for (i = 0; i < 32; i = i + 1)
                a_freelist[i] <= {1'b1, 5'(i)};
        else 
            case (PR_num_retire)
                3'd1:  a_freelist[a_wr_ptr] <= retire_PR0;
                3'd2:  begin
                            a_freelist[a_wr_ptr] <= retire_PR0;
                            a_freelist[a_wr_ptr + 1] <= retire_PR1;
                        end
                3'd3:  begin
                            a_freelist[a_wr_ptr] <= retire_PR0;
                            a_freelist[a_wr_ptr + 1] <= retire_PR1;
                            a_freelist[a_wr_ptr + 2] <= retire_PR2;
                        end
                3'd4:  begin
                            a_freelist[a_wr_ptr] <= retire_PR0;
                            a_freelist[a_wr_ptr + 1] <= retire_PR1;
                            a_freelist[a_wr_ptr + 2] <= retire_PR2;
                            a_freelist[a_wr_ptr + 3] <= retire_PR3;
                        end
                default: ;
            endcase
    end

    always @(posedge clk) begin   // freePR
        freePR0 <= freelist[rd_ptr];
        freePR1 <= freelist[rd_ptr + 1];
        freePR2 <= freelist[rd_ptr + 2];
        freePR3 <= freelist[rd_ptr + 3];
    end

endmodule
