module  PGDH(
    input               CSRRD_PGD_en,
    input       [31:12] PGDL,
    input       [31:12] PGDH,
    input               BADV_high,

    output      [31:0]  PGD_rd
);

    assign PGD_rd = CSRRD_PGD_en ? (BADV_high ? PGDH : PGDL) : 32'b0;

endmodule