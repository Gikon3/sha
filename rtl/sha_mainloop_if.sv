interface sha_mainloop_if (
    input   clk,
    input   rstn
);

logic                   enable;
sha::mode_t             mode;
sha::word_t             k;
sha::word_t             w;
sha::mainloop_word_t    raw;
sha::mainloop_word_t    ripe;

modport master (
    input   ripe,
    output  enable, mode, k, w, raw
);

modport slave (
    input   clk, rstn, enable, mode, k, w, raw,
    output  ripe
);

endinterface
