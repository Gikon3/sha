package sha;
    typedef enum logic[2:0] {
        sha1,
        sha224,
        sha256,
        sha384,
        sha512,
        sha512_224,
        sha512_256
    } mode_t;

    typedef struct packed
    {
        logic[1:0][31:0]    w32;
    } word_t;

    typedef union packed
    {
        logic[15:0][63:0]   w64;
        logic[31:0][31:0]   w32;
    } msg_t;

    typedef union packed
    {
        logic[7:0][63:0]    w64;
        logic[15:0][31:0]   w32;
    } hash_t;

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

    function logic[63:0] ch(
        input logic[63:0]   x,
        input logic[63:0]   y,
        input logic[63:0]   z
    );
    begin
        ch = (x & y) ^ (~x & z);
    end
    endfunction

    function logic[63:0] maj(
        input logic[63:0]   x,
        input logic[63:0]   y,
        input logic[63:0]   z
    );
    begin
        maj = (x & y) ^ (x & z) ^ (y & z);
    end
    endfunction

    function logic[31:0] sigma0_32(
        input logic[31:0]   x
    );
    begin
        sigma0_32 = {x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]};
    end
    endfunction
    function logic[63:0] sigma0_64(
        input logic[63:0]   x
    );
    begin
        sigma0_64 = {x[27:0], x[63:28]} ^ {x[33:0], x[63:34]} ^ {x[38:0], x[63:39]};
    end
    endfunction

    function logic[31:0] sigma1_32(
        input logic[31:0]   x
    );
    begin
        sigma1_32 = {x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]};
    end
    endfunction
    function logic[63:0] sigma1_64(
        input logic[63:0]   x
    );
    begin
        sigma1_64 = {x[13:0], x[63:14]} ^ {x[17:0], x[63:18]} ^ {x[40:0], x[63:41]};
    end
    endfunction

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
