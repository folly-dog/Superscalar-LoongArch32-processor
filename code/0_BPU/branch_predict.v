module branch_predict (
    input               clk,
    input               rst_n,

    input       [31:0]  PC,
    input               PC_vld,

    input       [31:0]  PC_retire,
    input               retire_en,
    input               jump_retire,

    output              jump_predict
);
    
    reg  [3:0]  BHT [9:4];
    reg  [1:0]  PHT [6:0];

    wire [3:0]  BH;
    wire [3:0]  BH_retire;
    wire [6:0]  PH_idx;
    wire [6:0]  PH_idx_retire;

    assign  BH = PC_vld ? BHT[PC[9:4]] : 4'd0;
    assign  BH_retire = retire_en ? BHT[PC_retire[9:4]] : 4'd0;
    assign  PH_idx = PC_vld ? {BH, PC[4:2]} : 7'd0;
    assign  PH_idx_retire = retire_en ? {BH_retire, PC_retire[4:2]} : 7'd0;

    integer i;

    always @(posedge clk or negedge rst_n) begin            // BHT
        if(!rst_n)
            for(i = 0; i < 6'h3f; i = i + 1)
                BHT[i] <= 4'b0000;
        else if(retire_en)
            BHT[PC_retire[9:4]] <=  {BH_retire[3:1], jump_retire};
    end

    always @(posedge clk or negedge rst_n) begin            // PHT
        if(!rst_n)
            for(i = 0; i < 7'h7f; i = i + 1)
                PHT[i] <= 2'b01;
        else if(retire_en)
            case (PHT[PH_idx_retire])
                2'b00: PHT[PH_idx_retire] <= jump_retire ? 2'b01 : 2'b00;
                2'b01: PHT[PH_idx_retire] <= jump_retire ? 2'b10 : 2'b00;
                2'b10: PHT[PH_idx_retire] <= jump_retire ? 2'b11 : 2'b01;
                2'b11: PHT[PH_idx_retire] <= jump_retire ? 2'b11 : 2'b10;
            endcase
    end

    assign jump_predict = PC_vld && ((PHT[PH_idx] == 2'b10) || (PHT[PH_idx] == 2'b11));

endmodule