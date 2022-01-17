package sha;
    typedef enum logic[2:0] {
        sha1,
        sha224,
        sha256,
        sha384,
        sha512
    } mode_t;

    typedef logic[63:0]     word_t;

    typedef union packed
    {
        logic[15:0][63:0]   w64;
        logic[31:0][31:0]   w32;
    } msg_t;

    typedef logic[511:0]    hash_t;

    typedef union packed
    {
        struct packed
        {
            word_t  a;
            word_t  b;
            word_t  c;
            word_t  d;
            word_t  e;
            word_t  f;
            word_t  g;
            word_t  h;
        } ch;
        word_t[0:7] w;
    } mainloop_word_t;

    function logic[31:0] delta0_32(
        input logic[31:0]   x
    );
    begin
        delta0_32 = {x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ x >> 3;
    end
    endfunction
    function logic[63:0] delta0_64(
        input logic[63:0]   x
    );
    begin
        delta0_64 = {x[0:0], x[63:1]} ^ {x[7:0], x[63:8]} ^ x >> 7;
    end
    endfunction

    function logic[31:0] delta1_32(
        input logic[31:0]   x
    );
    begin
        delta1_32 = {x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ x >> 10;
    end
    endfunction
    function logic[63:0] delta1_64(
        input logic[63:0]   x
    );
    begin
        delta1_64 = {x[18:0], x[63:19]} ^ {x[60:0], x[63:61]} ^ x >> 6;
    end
    endfunction

endpackage
