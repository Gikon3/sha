module sha_engine (
    sha_engine_if.slave bus
);

localparam int MAX_CNT_256 = sha_const::NUM_OF_LOOPS_SHA1_SHA256 - 1;
localparam int MAX_CNT_512 = sha_const::NUM_OF_LOOPS_SHA512 - 1;

enum logic[1:0] {st_idle, st_loop256, st_loop512, st_load} state, next_state;
sha_mainloop_if sha_mainloop_if_h(.clk(bus.clk), .rstn(bus.rstn));

logic               bus_request;
logic               req_mode_1;
logic               req_mode_2_32;
logic               req_mode_2_64;
sha::mode_t         mode;
logic               mode_1;
logic               mode_2_32;
logic               mode_2_64;
sha::word_t[0:7]    next_h_init;
sha::word_t[0:7]    next_h;
sha::word_t[0:7]    h;
sha::word_t[15:0]   next_w_init;
logic[31:0]         next_w_xor;
sha::word_t         next_w_plus;
sha::word_t         next_w;
sha::word_t[15:0]   w;
logic               cnt_en;
logic[6:0]          cnt;
logic[1:0]          sha1_f_number;
logic               done;
logic               load_hash;
sha::hash_t         hash;

assign bus_request = bus.valid & (bus.ready | load_hash);
assign req_mode_1 = bus.mode == sha::sha1;
assign req_mode_2_32 = bus.mode == sha::sha224 || bus.mode == sha::sha256;
assign req_mode_2_64 = bus.mode == sha::sha384 || bus.mode == sha::sha512 ||
        bus.mode == sha::sha512_224 || bus.mode == sha::sha512_256;

always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) mode <= sha::sha1;
    else if(bus_request) mode <= bus.mode;

assign mode_1 = mode == sha::sha1;
assign mode_2_32 = mode == sha::sha224 || mode == sha::sha256;
assign mode_2_64 = mode == sha::sha384 || mode == sha::sha512 ||
        mode == sha::sha512_224 || mode == sha::sha512_256;

always_comb begin : sha_h_vals_init
   for(int i = 0; i < 8; ++i) begin
        unique case(bus.mode)
            sha::sha1:
                if(i < 5)
                    next_h_init[i] = {32'd0, sha_const::H1[i]};
                else
                    next_h_init[i] = 64'd0;
            sha::sha224: next_h_init[i] = {32'd0, sha_const::H224[i]};
            sha::sha256: next_h_init[i] = {32'd0, sha_const::H256[i]};
            sha::sha384: next_h_init[i] = sha_const::H384[i];
            sha::sha512: next_h_init[i] = sha_const::H512[i];
            sha::sha512_224: next_h_init[i] = sha_const::H512_224[i];
            sha::sha512_256: next_h_init[i] = sha_const::H512_256[i];
        endcase
    end
end

always_comb begin : sha_h_vals_next
    next_h = 'd0;
    unique case(mode)
        sha::sha1,
        sha::sha224,
        sha::sha256:
            for(int i = 0; i < 8; ++i)
                next_h[i].w32[0] = h[i].w32[0] + sha_mainloop_if_h.master.ripe.w[i];
        sha::sha384,
        sha::sha512,
        sha::sha512_224,
        sha::sha512_256:
            for(int i = 0; i < 8; ++i)
                next_h[i] = h[i] + sha_mainloop_if_h.master.ripe.w[i];
    endcase
end

always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) h <= 'd0;
    else if(bus_request & bus.new_msg) h <= next_h_init;
    else if(load_hash) h <= next_h;

always_comb begin : sha_w_vals_init
   for(int i = 0; i < 16; ++i) begin
        if(bus_request & (req_mode_1 | req_mode_2_32))
            next_w_init[15-i] = {32'd0, bus.msg.w32[i]};
        else if(bus_request & req_mode_2_64)
            next_w_init[15-i] = bus.msg.w64[i];
        else
            next_w_init[15-i] = 'd0;
    end
end

always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) w <= 'd0;
    else if(bus_request) w <= next_w_init;
    else if(cnt >= 'd15) w <= {next_w, w[15:1]};

assign sha1_f_number = cnt / 20;

always_comb begin : sha_fsm_engine
    unique case(state)
        st_idle:
            if(bus.valid & req_mode_2_32)
                next_state = st_loop256;
            else if(bus.valid & (req_mode_1 | req_mode_2_64))
                next_state = st_loop512;
            else
                next_state = st_idle;
        st_loop256:
            if(done)
                next_state = st_load;
            else
                next_state = st_loop256;
        st_loop512:
            if(done)
                next_state = st_load;
            else
                next_state = st_loop512;
        st_load:
            if(bus.valid) begin
                if(req_mode_2_32)
                    next_state = st_loop256;
                else if(req_mode_1 | req_mode_2_64)
                    next_state = st_loop512;
            end
            else
                next_state = st_idle;
    endcase
end

assign done = (state == st_loop256 && cnt == MAX_CNT_256) || (state == st_loop512 && cnt == MAX_CNT_512);
assign load_hash = state == st_load;

always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) state <= st_idle;
    else state <= next_state;

assign cnt_en = state != st_idle && state != st_load;
always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) cnt <= 'd0;
    else if(done) cnt <= 'd0;
    else if(cnt_en) cnt <= cnt + 'd1;

always_comb begin : sha_calc_next_w
    next_w_xor = w[13] ^ w[8] ^ w[2] ^ w[0];
    next_w_plus =  w[0] + w[9];
    if(cnt >= 'd15 && mode_1) begin
        next_w.w32[1] = 'd0;
        next_w.w32[0] = {next_w_xor[30:0], next_w_xor[31:31]};
    end
    else if(cnt >= 'd15 && mode_2_32) begin
        next_w.w32[1] = 'd0;
        next_w.w32[0] = sha::delta0_32(w[1]) + sha::delta1_32(w[14]) + next_w_plus;
    end
    else if(cnt >= 'd15 && mode_2_64)
        next_w =sha::delta0_64(w[1]) + sha::delta1_64(w[14]) + next_w_plus;
    else
        next_w = 'd0;
end

always_comb begin : sha_mainloop_vars_init
    sha_mainloop_if_h.master.enable = state == st_loop256 || state == st_loop512;
    sha_mainloop_if_h.master.mode = mode;
    sha_mainloop_if_h.master.ft = sha1_f_number;
    if(cnt < 'd16)
        sha_mainloop_if_h.master.w = w[cnt];
    else
        sha_mainloop_if_h.master.w = w[15];
    unique case(mode)
        sha::sha1:
            sha_mainloop_if_h.master.k = {32'd0, sha_const::K1[sha1_f_number]};
        sha::sha224,
        sha::sha256:
            sha_mainloop_if_h.master.k = {32'd0, sha_const::K256[cnt]};
        sha::sha384,
        sha::sha512,
        sha::sha512_224,
        sha::sha512_256:
            sha_mainloop_if_h.master.k = sha_const::K512[cnt];
    endcase
    if(cnt == 'd0)
        sha_mainloop_if_h.master.raw.w = h;
    else
        sha_mainloop_if_h.master.raw = sha_mainloop_if_h.master.ripe;
end

sha_mainloop sha_mainloop (
    .bus(sha_mainloop_if_h)
);

always_comb begin : sha_hash_formation
    hash = 'd0;
    unique case(mode)
        sha::sha1:
            for(int i = 0; i < 5; ++i)
                hash.w32[4-i] = next_h[i];
        sha::sha224:
            for(int i = 0; i < 7; ++i)
                hash.w32[6-i] = next_h[i];
        sha::sha256:
            for(int i = 0; i < 8; ++i)
                hash.w32[7-i] = next_h[i];
        sha::sha384:
            for(int i = 0; i < 6; ++i)
                hash.w64[5-i] = next_h[i];
        sha::sha512:
            for(int i = 0; i < 8; ++i)
                hash.w64[7-i] = next_h[i];
        sha::sha512_224: begin
            for(int i = 0; i < 4; ++i)
                hash.w64[3-i] = next_h[i];
            hash = hash >> 32;
        end
        sha::sha512_256:
            for(int i = 0; i < 4; ++i)
                hash.w64[3-i] = next_h[i];
    endcase
end

always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) bus.hash <= 'd0;
    else if(load_hash) bus.hash <= hash;

always_ff @ (posedge bus.clk, negedge bus.rstn)
    if(~bus.rstn) bus.ready <= 1'b1;
    else if(load_hash) bus.ready <= 1'b1;
    else if(bus.valid) bus.ready <= 1'b0;

endmodule
