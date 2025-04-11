module  source_activate(
    input                ALU0_selected_vld,     // once selected, than acticate
    input                ALU1_result_vld,       // time of div, not sure, wait result
    input                AGU_result_vld,        // use no-speculative-activate
    input                BRU_selected_vld,      // once selected, than acticate

    input        [5:0]   ALU0_result_PR,
    input        [5:0]   ALU1_result_PR,
    input        [5:0]   AGU_result_PR,
    input        [5:0]   BRU_result_PR,

    output       [5:0]   ALU0_dest,
    output       [5:0]   ALU1_dest,
    output       [5:0]   AGU_dest,
    output       [5:0]   BRU_dest
);

    assign ALU0_dest = ALU0_selected_vld ? ALU0_result_PR : 6'b0;
    assign ALU1_dest = ALU1_result_vld ? ALU1_result_PR : 6'b0;
    assign AGU_dest  = AGU_result_vld  ? AGU_result_PR  : 6'b0;
    assign BRU_dest  = BRU_selected_vld  ? BRU_result_PR  : 6'b0;

endmodule