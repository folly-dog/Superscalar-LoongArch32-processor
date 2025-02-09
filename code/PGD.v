module  PGD(
    input               BADV_31,
    input       [31:12] PGDL_base,
    input       [31:12] PGDH_base,

    output       [31:0] PGD
);

    assign PGD = BADV_31 ? {PGDH_base,12'd0} : {PGDL_base,12'd0};

endmodule