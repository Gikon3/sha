interface sha_engine_if();

logic           clk;
logic           rstn;
sha::mode_t     mode;
logic           valid;
sha::msg_t      msg;
sha::hash_t     hash;
logic           ready;

task send;
    input sha::mode_t   i_mode;
    input sha::msg_t    i_msg;
    input int unsigned  i_size;
    begin
        valid = 1'b1;
        mode = i_mode;
        if(i_mode == sha::sha224 || i_mode == sha::sha256)
            msg = (i_msg[511:0] << (512 - i_size * 8)) | (1 << 512 - i_size * 8 - 1) | (i_size * 8);
        else
            msg = (i_msg << (1024 - i_size * 8)) | (1 << 1024 - i_size * 8 - 1) | (i_size * 8);
        wait(ready == 1'b1);
        @(posedge clk);
        #1;
        valid = 1'b0;
        mode = sha::sha1;
        msg = 'd0;
    end
endtask

modport master (
    input   hash, ready,
    output  clk, rstn, mode, valid, msg
);

modport slave (
    input   clk, rstn, mode, valid, msg,
    output  hash, ready
);

endinterface
