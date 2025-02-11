module DMW1 (
    input               clk,
    input               rst_n,

    input               CSRWR_DMW1_en,
    input       [31:0]  CSRWR_DMW1_data,  

    output  reg [31:0]  DMW1
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            DMW1 <= 32'b0;
        else if(CSRWR_DMW1_en)
            DMW1 <= {CSRWR_DMW1_data[31:29], 1'b0, CSRWR_DMW1_data[27:25], 19'b0, CSRWR_DMW1_data[5:3], 2'b0, CSRWR_DMW1_data[0]};
    end

endmodule