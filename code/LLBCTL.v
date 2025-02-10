module  LLBCTL(
    input               clk,
    input               rst_n,

    input               CSRWR_LLBCTL_en,
    input         [2:1] CSRWR_LLBCTL_data,

    input               LL,
    input               SC,
    input               ERTN,

    output  reg  [31:0] LLBCTL
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            LLBCTL <= 32'b0;
        else begin
            if(LL) 
                LLBCTL[0] <= 1'b1;
            if(SC | (CSRWR_LLBCTL_data[1]) | (ERTN & (!CSRWR_LLBCTL_data[2])))
                LLBCTL[0] <= 1'b0;
        end 
    end

    always @(posedge clk) begin
        if(CSRWR_LLBCTL_en & CSRWR_LLBCTL_data[1])
            LLBCTL[1] <= 1'b1;
        if(SC)
            LLBCTL[1] <= 1'b1;
    end

    always @(posedge clk) begin
        if(CSRWR_LLBCTL_en)
            LLBCTL[2] <= CSRWR_LLBCTL_data[2];
        else if(LLBCTL[2] & ERTN)
            LLBCTL[2] <= 1'b0;
    end

endmodule