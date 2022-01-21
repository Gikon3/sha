module sha_mainloop (
    sha_mainloop_if.slave bus
);

logic[31:0]             temp_plus;
sha::word_t             temp1_plus;
sha::word_t             temp2_plus;
sha::word_t             temp1;
sha::word_t             temp2;
sha::mainloop_word_t    next_words;

always_comb begin
    unique case(bus.ft)
        2'd0: temp_plus = sha::ch(bus.raw.ch.b, bus.raw.ch.c, bus.raw.ch.d);
        2'd1,
        2'd3: temp_plus = sha::parity(bus.raw.ch.b, bus.raw.ch.c, bus.raw.ch.d);
        2'd2: temp_plus = sha::maj(bus.raw.ch.b, bus.raw.ch.c, bus.raw.ch.d);
    endcase
    temp1_plus = bus.raw.ch.h + sha::ch(bus.raw.ch.e, bus.raw.ch.f, bus.raw.ch.g) + bus.k + bus.w;
    temp2_plus = sha::maj(bus.raw.ch.a, bus.raw.ch.b, bus.raw.ch.c);
    unique case(bus.mode)
        sha::sha1: begin
            temp1 = {bus.raw.ch.a[26:0], bus.raw.ch.a[31:27]} + temp_plus + bus.raw.ch.e + bus.w + bus.k;
            temp2 = 0;
        end
        sha::sha224,
        sha::sha256: begin
            temp1 = sha::sigma1_32(bus.raw.ch.e) + temp1_plus;
            temp2 = sha::sigma0_32(bus.raw.ch.a) + temp2_plus;
        end
        sha::sha384,
        sha::sha512,
        sha::sha512_224,
        sha::sha512_256: begin
            temp1 = sha::sigma1_64(bus.raw.ch.e) + temp1_plus;
            temp2 = sha::sigma0_64(bus.raw.ch.a) + temp2_plus;
        end
    endcase
end

always_comb begin
    unique case(bus.mode)
        sha::sha1: begin
            next_words.ch.a = temp1;
            next_words.ch.b =  bus.raw.ch.a;
            next_words.ch.c = {32'd0,  bus.raw.ch.b[1:0],  bus.raw.ch.b[31:2]};
            next_words.ch.d =  bus.raw.ch.c;
            next_words.ch.e =  bus.raw.ch.d;
            next_words.ch.f = 64'd0;
            next_words.ch.g = 64'd0;
            next_words.ch.h = 64'd0;
        end
        sha::sha224,
        sha::sha256,
        sha::sha384,
        sha::sha512,
        sha::sha512_224,
        sha::sha512_256: begin
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
    if(~bus.rstn) bus.ripe <= 'd0;
    else if(bus.enable) bus.ripe.w <= next_words.w;

endmodule
