module sha_engine (
        sha_engine_if.slave bus
    );

    localparam bit[0:7][31:0] H224 = {
        32'hC1059ED8, 32'h367CD507, 32'h3070DD17, 32'hF70E5939, 32'hFFC00B31, 32'h68581511, 32'h64F98FA7, 32'hBEFA4FA4
    };
    localparam bit[0:7][31:0] H256 = {
        32'h6A09E667, 32'hBB67AE85, 32'h3C6EF372, 32'hA54FF53A, 32'h510E527F, 32'h9B05688C, 32'h1F83D9AB, 32'h5BE0CD19
    };
    localparam bit[0:63][31:0] K256 = {
        32'h428A2F98, 32'h71374491, 32'hB5C0FBCF, 32'hE9B5DBA5, 32'h3956C25B, 32'h59F111F1, 32'h923F82A4, 32'hAB1C5ED5,
        32'hD807AA98, 32'h12835B01, 32'h243185BE, 32'h550C7DC3, 32'h72BE5D74, 32'h80DEB1FE, 32'h9BDC06A7, 32'hC19BF174,
        32'hE49B69C1, 32'hEFBE4786, 32'h0FC19DC6, 32'h240CA1CC, 32'h2DE92C6F, 32'h4A7484AA, 32'h5CB0A9DC, 32'h76F988DA,
        32'h983E5152, 32'hA831C66D, 32'hB00327C8, 32'hBF597FC7, 32'hC6E00BF3, 32'hD5A79147, 32'h06CA6351, 32'h14292967,
        32'h27B70A85, 32'h2E1B2138, 32'h4D2C6DFC, 32'h53380D13, 32'h650A7354, 32'h766A0ABB, 32'h81C2C92E, 32'h92722C85,
        32'hA2BFE8A1, 32'hA81A664B, 32'hC24B8B70, 32'hC76C51A3, 32'hD192E819, 32'hD6990624, 32'hF40E3585, 32'h106AA070,
        32'h19A4C116, 32'h1E376C08, 32'h2748774C, 32'h34B0BCB5, 32'h391C0CB3, 32'h4ED8AA4A, 32'h5B9CCA4F, 32'h682E6FF3,
        32'h748F82EE, 32'h78A5636F, 32'h84C87814, 32'h8CC70208, 32'h90BEFFFA, 32'hA4506CEB, 32'hBEF9A3F7, 32'hC67178F2
    };

    localparam bit[0:7][63:0] H384 = {
        64'hCBBB9D5DC1059ED8, 64'h629A292A367CD507, 64'h9159015A3070DD17, 64'h152FECD8F70E5939,
        64'h67332667FFC00B31, 64'h8EB44A8768581511, 64'hDB0C2E0D64F98FA7, 64'h47B5481DBEFA4FA4
    };
    localparam bit[0:7][63:0] H512 = {
        64'h6A09E667F3BCC908, 64'hBB67AE8584CAA73B, 64'h3C6EF372FE94F82B, 64'hA54FF53A5F1D36F1,
        64'h510E527FADE682D1, 64'h9B05688C2B3E6C1F, 64'h1F83D9ABFB41BD6B, 64'h5BE0CD19137E2179
    };
    localparam bit[0:79][63:0] K512 = {
        64'h428A2F98D728AE22, 64'h7137449123EF65CD, 64'hB5C0FBCFEC4D3B2F, 64'hE9B5DBA58189DBBC,
        64'h3956C25BF348B538, 64'h59F111F1B605D019, 64'h923F82A4AF194F9B, 64'hAB1C5ED5DA6D8118,
        64'hD807AA98A3030242, 64'h12835B0145706FBE, 64'h243185BE4EE4B28C, 64'h550C7DC3D5FFB4E2,
        64'h72BE5D74F27B896F, 64'h80DEB1FE3B1696B1, 64'h9BDC06A725C71235, 64'hC19BF174CF692694,
        64'hE49B69C19EF14AD2, 64'hEFBE4786384F25E3, 64'h0FC19DC68B8CD5B5, 64'h240CA1CC77AC9C65,
        64'h2DE92C6F592B0275, 64'h4A7484AA6EA6E483, 64'h5CB0A9DCBD41FBD4, 64'h76F988DA831153B5,
        64'h983E5152EE66DFAB, 64'hA831C66D2DB43210, 64'hB00327C898FB213F, 64'hBF597FC7BEEF0EE4,
        64'hC6E00BF33DA88FC2, 64'hD5A79147930AA725, 64'h06CA6351E003826F, 64'h142929670A0E6E70,
        64'h27B70A8546D22FFC, 64'h2E1B21385C26C926, 64'h4D2C6DFC5AC42AED, 64'h53380D139D95B3DF,
        64'h650A73548BAF63DE, 64'h766A0ABB3C77B2A8, 64'h81C2C92E47EDAEE6, 64'h92722C851482353B,
        64'hA2BFE8A14CF10364, 64'hA81A664BBC423001, 64'hC24B8B70D0F89791, 64'hC76C51A30654BE30,
        64'hD192E819D6EF5218, 64'hD69906245565A910, 64'hF40E35855771202A, 64'h106AA07032BBD1B8,
        64'h19A4C116B8D2D0C8, 64'h1E376C085141AB53, 64'h2748774CDF8EEB99, 64'h34B0BCB5E19B48A8,
        64'h391C0CB3C5C95A63, 64'h4ED8AA4AE3418ACB, 64'h5B9CCA4F7763E373, 64'h682E6FF3D6B2B8A3,
        64'h748F82EE5DEFB2FC, 64'h78A5636F43172F60, 64'h84C87814A1F0AB72, 64'h8CC702081A6439EC,
        64'h90BEFFFA23631E28, 64'hA4506CEBDE82BDE9, 64'hBEF9A3F7B2C67915, 64'hC67178F2E372532B,
        64'hCA273ECEEA26619C, 64'hD186B8C721C0C207, 64'hEADA7DD6CDE0EB1E, 64'hF57D4F7FEE6ED178,
        64'h06F067AA72176FBA, 64'h0A637DC5A2C898A6, 64'h113F9804BEF90DAE, 64'h1B710B35131C471B,
        64'h28DB77F523047D84, 64'h32CAAB7B40C72493, 64'h3C9EBE0A15C9BEBC, 64'h431D67C49C100D4C,
        64'h4CC5D4BECB3E42B6, 64'h597F299CFC657E2A, 64'h5FCB6FAB3AD6FAEC, 64'h6C44198C4A475817
    };

    localparam int NUM_LOOPS256 = 'd63;
    localparam int NUM_LOOPS512 = 'd79;

    enum logic[1:0] {st_idle, st_loop256, st_loop512, st_load} state, next_state;
    sha_mainloop_if sha_mainloop_if_h(.clk(bus.clk), .rstn(bus.rstn));

    logic               request;
    sha::mode_t         mode;
    sha::word_t         next_w_plus;
    sha::word_t         next_w;
    sha::word_t[15:0]   w;
    logic               mode_2_32;
    logic               mode_2_64;
    logic               cnt_en;
    logic[6:0]          cnt;
    sha::hash_t         hash;
    logic               done;
    logic               load_hash;

    assign request = bus.valid & (bus.ready | load_hash);
    assign done = (state == st_loop256 && cnt == NUM_LOOPS256) || (state == st_loop512 && cnt == NUM_LOOPS512);
    assign load_hash = state == st_load;

    always_ff @ (posedge bus.clk, negedge bus.rstn)
        if(~bus.rstn) mode <= sha::sha1;
        else if(request) mode <= bus.mode;

    always_ff @ (posedge bus.clk, negedge bus.rstn)
        if(~bus.rstn) w <= 'd0;
        else if(request) begin
            for(int i = 0; i < 16; ++i) begin
                if(request & mode_2_32) w[15-i][31:0] <= bus.msg.w32[i];
                else if(request & mode_2_64) w[15-i] <= bus.msg.w64[i];
            end
        end
        else if(cnt >= 'd15) w <= {next_w, w[15:1]};

    assign mode_2_32 = bus.mode == sha::sha224 || bus.mode == sha::sha256;
    assign mode_2_64 = bus.mode == sha::sha384 || bus.mode == sha::sha512;
    always_comb begin
        unique case(state)
            st_idle:
                if(bus.valid & mode_2_32)
                    next_state = st_loop256;
                else if(bus.valid & mode_2_64)
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
                    if(mode_2_32)
                        next_state = st_loop256;
                    else if(mode_2_64)
                        next_state = st_loop512;
                end
                else
                    next_state = st_idle;
        endcase
    end

    always_ff @ (posedge bus.clk, negedge bus.rstn)
        if(~bus.rstn) state <= st_idle;
        else state <= next_state;

    assign cnt_en = state != st_idle && state != st_load;
    always_ff @ (posedge bus.clk, negedge bus.rstn)
        if(~bus.rstn) cnt <= 'd0;
        else if(done) cnt <= 'd0;
        else if(cnt_en) cnt <= cnt + 'd1;

    always_comb begin
        next_w_plus =  w[0] + w[9];
        if(cnt >= 'd15 && (mode == sha::sha224 || mode == sha::sha256)) begin
            next_w[63:32] = 'd0;
            next_w[31:0] = sha::delta0_32(w[1]) + sha::delta1_32(w[14]) + next_w_plus;
        end
        else if(cnt >= 'd15 && (mode == sha::sha384 || mode == sha::sha512))
            next_w[63:0] =sha::delta0_64(w[1]) + sha::delta1_64(w[14]) + next_w_plus;
        else
            next_w = 'd0;
    end

    always_comb begin
        sha_mainloop_if_h.master.enable = state == st_loop256 || state == st_loop512;
        sha_mainloop_if_h.master.mode = mode;
        if(cnt < 'd16)
            sha_mainloop_if_h.master.w = w[cnt];
        else
            sha_mainloop_if_h.master.w = w[15];
        unique case(mode)
            sha::sha1: begin
                 sha_mainloop_if_h.master.k = 'd0;
            end
            sha::sha224,
            sha::sha256: begin
                sha_mainloop_if_h.master.k = {32'd0, K256[cnt]};
            end
            sha::sha384,
            sha::sha512: begin
                sha_mainloop_if_h.master.k = K512[cnt];
            end
        endcase
        if(cnt == 'd0) begin
            for(int i = 0; i < 8; ++i) begin
                unique case(mode)
                    sha::sha1:
                        sha_mainloop_if_h.master.raw.w[i] = 'd0;
                    sha::sha224:
                        sha_mainloop_if_h.master.raw.w[i] = {32'd0, H224[i]};
                    sha::sha256:
                        sha_mainloop_if_h.master.raw.w[i] = {32'd0, H256[i]};
                    sha::sha384:
                        sha_mainloop_if_h.master.raw.w[i] = H384[i];
                    sha::sha512:
                        sha_mainloop_if_h.master.raw.w[i] = H512[i];
                endcase
            end
        end
        else begin
            sha_mainloop_if_h.master.raw = sha_mainloop_if_h.master.ripe;
        end
    end

    sha_mainloop sha_mainloop (
        .bus(sha_mainloop_if_h)
    );

    always_comb begin
        hash = 'd0;
        unique case(mode)
            sha::sha1:
                hash = 'd0;
            sha::sha224:
                for(int i = 0; i < 7; ++i)
                    hash.w32[6-i] = H224[i] + sha_mainloop_if_h.master.ripe.w[i];
            sha::sha256:
                for(int i = 0; i < 8; ++i)
                    hash.w32[7-i] = H256[i] + sha_mainloop_if_h.master.ripe.w[i];
            sha::sha384:
                for(int i = 0; i < 7; ++i)
                    hash.w64[6-i] = H384[i] + sha_mainloop_if_h.master.ripe.w[i];
            sha::sha512:
                for(int i = 0; i < 8; ++i)
                    hash.w64[7-i] = H512[i] + sha_mainloop_if_h.master.ripe.w[i];
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
