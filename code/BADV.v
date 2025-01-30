module BADV (
    input               clk,
    input               rst_n,

    input               except_en,
    input       [31:0]  except_PC,

    output  reg [31:0]  BADV
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            BADV <= 32'b0;
        else if(except_en)
            BADV <= except_PC;
    end

endmodule