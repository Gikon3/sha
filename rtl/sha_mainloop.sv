module sha_mainloop (sha_mainloop_if.slave bus);
    sha::word_t             sigma0;
    sha::word_t             sigma1;
    sha::word_t             maj;
    sha::word_t             ch;
    sha::word_t             temp1;
    sha::word_t             temp2;
    sha::mainloop_word_t    next_words;

    always_comb begin
        unique case(bus.mode)
            sha::sha1: begin
                sigma0 = 0;
                sigma1 = 0;
                maj = 0;
                ch = 0;
                temp1 = 0;
                temp2 = 0;
            end
            sha::sha224,
            sha::sha256: begin
                sigma0 = {bus.raw.ch.a[63:32], bus.raw.ch.a[1:0], bus.raw.ch.a[31:2]} ^
                        {bus.raw.ch.a[63:32], bus.raw.ch.a[12:0], bus.raw.ch.a[31:13]} ^
                        {bus.raw.ch.a[63:32], bus.raw.ch.a[21:0], bus.raw.ch.a[31:22]};
                sigma1 = {bus.raw.ch.e[63:32], bus.raw.ch.e[5:0], bus.raw.ch.e[31:6]} ^
                        {bus.raw.ch.e[63:32], bus.raw.ch.e[10:0], bus.raw.ch.e[31:11]} ^
                        {bus.raw.ch.e[63:32], bus.raw.ch.e[24:0], bus.raw.ch.e[31:25]};
                maj = (bus.raw.ch.a & bus.raw.ch.b) ^ (bus.raw.ch.a & bus.raw.ch.c) ^ (bus.raw.ch.b & bus.raw.ch.c);
                ch = (bus.raw.ch.e & bus.raw.ch.f) ^ (~bus.raw.ch.e & bus.raw.ch.g);
                temp1 = bus.raw.ch.h + sigma1[31:0] + ch[31:0] + bus.k + bus.w;
                temp2 = sigma0 + maj;
            end
            sha::sha384,
            sha::sha512: begin
                sigma0 = 0;
                sigma1 = 0;
                maj = 0;
                ch = 0;
                temp1 = 0;
                temp2 = 0;
            end
        endcase
    end

    always_comb begin
        unique case(bus.mode)
            sha::sha1: begin
                next_words.ch.a = 0;
                next_words.ch.b = 0;
                next_words.ch.c = 0;
                next_words.ch.d = 0;
                next_words.ch.e = 0;
                next_words.ch.f = 0;
                next_words.ch.g = 0;
                next_words.ch.h = 0;
            end
            sha::sha224,
            sha::sha256: begin
                next_words.ch.a = temp1 + temp2;
                next_words.ch.b = bus.raw.ch.a;
                next_words.ch.c = bus.raw.ch.b;
                next_words.ch.d = bus.raw.ch.c;
                next_words.ch.e = bus.raw.ch.d + temp1;
                next_words.ch.f = bus.raw.ch.e;
                next_words.ch.g = bus.raw.ch.f;
                next_words.ch.h = bus.raw.ch.g;
            end
            sha::sha384,
            sha::sha512: begin
                next_words.ch.a = temp1 + temp2;
                next_words.ch.b = bus.raw.ch.a;
                next_words.ch.c = bus.raw.ch.b;
                next_words.ch.d = bus.raw.ch.c;
                next_words.ch.e = bus.raw.ch.d + temp1;
                next_words.ch.f = bus.raw.ch.e;
                next_words.ch.g = bus.raw.ch.f;
                next_words.ch.h = bus.raw.ch.g;
            end
        endcase
    end

    always_ff @ (posedge bus.clk, negedge bus.rstn)
        if(~bus.rstn) begin
            for(int i = 0; i < 8; ++i)
                bus.ripe.w[i] <= 'd0;
        end
        else if(bus.enable && (bus.mode == sha::sha224 || bus.mode == sha::sha256)) begin
            for(int i = 0; i < 8; ++i)
                bus.ripe.w[i] <= {32'd0, next_words.w[i][31:0]};
        end

endmodule
