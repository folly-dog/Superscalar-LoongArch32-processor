module DMW0 (
    input               clk,
    input               rst_n,

    input               CSRWR_DMW0_en,
    input       [31:0]  CSRWR_DMW0_data,  

    output  reg [31:0]  DMW0
);
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            DMW0 <= 32'b0;
        else if(CSRWR_DMW0_en)
            DMW0 <= {CSRWR_DMW0_data[31:29], 1'b0, CSRWR_DMW0_data[27:25], 19'b0, CSRWR_DMW0_data[5:3], 2'b0, CSRWR_DMW0_data[0]};
    end

endmodule