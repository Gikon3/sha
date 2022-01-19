interface sha_engine_if();

logic           clk;
logic           rstn;
sha::mode_t     mode;
logic           new_msg;
logic           valid;
sha::msg_t      msg;
sha::hash_t     hash;
logic           ready;

modport master (
    input   hash, ready,
    output  clk, rstn, mode, new_msg, valid, msg
);

modport slave (
    input   clk, rstn, mode, new_msg, valid, msg,
    output  hash, ready
);

endinterface
