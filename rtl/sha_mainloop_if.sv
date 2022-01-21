interface sha_mainloop_if (
    input   clk,
    input   rstn
);

logic                   enable;
sha::mode_t             mode;
logic[1:0]              ft;     //< Обозначение функции для текущего цикла sha1
sha::word_t             k;
sha::word_t             w;
sha::mainloop_word_t    raw;
sha::mainloop_word_t    ripe;

modport master (
    input   ripe,
    output  enable, mode, ft, k, w, raw
);

modport slave (
    input   clk, rstn, enable, mode, ft, k, w, raw,
    output  ripe
);

endinterface
