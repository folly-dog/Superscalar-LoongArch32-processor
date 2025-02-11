module  TVAL(
    input               clk,
    input               rst_n,

    input               SUB_en,
    input               RST_en,
    input       [31:2]  RST_val,

    output  reg [31:0]  TVAL  
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            TVAL <= 32'b0;
        else if(SUB_en)begin
            if(TVAL != 32'b0)
                TVAL <= TVAL - 1;
            else if(RST_en)
                TVAL <= {RST_val, 2'b0};
        end
    end

endmodule