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

    function logic[31:0] parity(
        input logic[31:0]   x,
        input logic[31:0]   y,
        input logic[31:0]   z
    );
    begin
        parity = x ^ y ^ z;
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

package sha_const;
    localparam int NUM_OF_LOOPS_SHA1_SHA256 = 'd64;
    localparam int NUM_OF_LOOPS_SHA512 = 'd80;

    localparam bit[0:4][31:0] H1 = {
        32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0
    };
    localparam bit[0:3][31:0] K1 = {
        32'h5A827999, 32'h6ED9EBA1, 32'h8F1BBCDC, 32'hCA62C1D6
    };

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
    localparam bit[0:7][63:0] H512_224 = {
        64'h8C3D37C819544DA2, 64'h73E1996689DCD4D6, 64'h1DFAB7AE32FF9C82, 64'h679DD514582F9FCF,
        64'h0F6D2B697BD44DA8, 64'h77E36F7304C48942, 64'h3F9D85A86A1D36C8, 64'h1112E6AD91D692A1
    };
    localparam bit[0:7][63:0] H512_256 = {
        64'h22312194FC2BF72C, 64'h9F555FA3C84C64C2, 64'h2393B86B6F53B151, 64'h963877195940EABD,
        64'h96283EE2A88EFFE3, 64'hBE5E1E2553863992, 64'h2B0199FC2C85B8AA, 64'h0EB72DDC81C52CA2
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

endpackage
