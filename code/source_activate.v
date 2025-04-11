module  source_activate(
    input                ALU0_result_vld,
    input                ALU1_result_vld,
    input                AGU_result_vld,
    input                BRU_result_vld,

    input        [5:0]   ALU0_result_PR,
    input        [5:0]   ALU1_result_PR,
    input        [5:0]   AGU_result_PR,
    input        [5:0]   BRU_result_PR,

    output       [5:0]   ALU0_dest,
    output       [5:0]   ALU1_dest,
    output       [5:0]   AGU_dest,
    output       [5:0]   BRU_dest
);

    assign ALU0_dest = ALU0_result_vld ? ALU0_result_PR : 6'b0;
    assign ALU1_dest = ALU1_result_vld ? ALU1_result_PR : 6'b0;
    assign AGU_dest  = AGU_result_vld  ? AGU_result_PR  : 6'b0;
    assign BRU_dest  = BRU_result_vld  ? BRU_result_PR  : 6'b0;

endmodule