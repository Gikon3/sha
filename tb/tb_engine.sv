module tb_engine;

localparam Tclk = 10;

initial begin
    $shm_open(`TEST_NAME);
    $shm_probe(tb_engine, "ACM");
end

sha_engine_if sha_engine_if_h();

initial begin
    sha_engine_if_h.master.rstn = 1'b0;
    sha_engine_if_h.master.mode = sha::sha1;
    sha_engine_if_h.master.new_msg = 1'b0;
    sha_engine_if_h.master.valid = 1'b0;
    sha_engine_if_h.master.msg = 'd0;
    #(Tclk+Tclk/4) sha_engine_if_h.master.rstn = 1'b1;
end

initial begin
    sha_engine_if_h.master.clk = 1'b1;
    forever #(Tclk/2) sha_engine_if_h.master.clk = ~sha_engine_if_h.master.clk;
end

initial begin
    // Началные значения, чтобы не ругался uniaue case
    force dut.cnt = 'd0; release dut.cnt;
    force dut.state = dut.st_idle; release dut.state;
    force dut.mode = sha::sha1; release dut.mode;
end

sha_engine dut (
    .bus(sha_engine_if_h)
);

initial begin
    wait(sha_engine_if_h.master.rstn == 1'b1);
    @(posedge sha_engine_if_h.master.clk);

    send_msg("Hello World!", sha::sha1,
            160'h2ef7bde608ce5404e97d5f042f95f89f1c232871);
    send_msg("Hash functions play an important role in modern cryptography. This paper investigates optimisation techniques that have recently \
been proposed in the literature. A new VLSI architecture for the SHA-256 and SHA-512 hash functions is presented, which combines \
two popular hardware optimisation techniques, namely pipelining and unrolling. The SHA processors are developed for implementation \
on FPGAs, thereby allowing rapid prototyping of several designs. Speed/area results from these processors are analysed and are shown \
to compare favourably with other FPGA-based implementations, achieving the fastest data throughputs in the literature to date.",
            sha::sha224,
            224'h486381e936bcaf7e497b69cd68c7630429f58cd665d992fb9ee4fabd);
    send_msg("Hello World!", sha::sha512,
            512'h861844d6704e8573fec34d967e20bcfef3d424cf48be04e6dc08f2bd58c729743371015ead891cc3cf1c9d34b49264b510751b1ff9e537937bc46b5d6ff4ecc8);
    send_msg("Hello World!", sha::sha384,
            384'hbfd76c0ebbd006fee583410547c1887b0292be76d582d96c242d2a792723e3fd6fd061f9d5cfd13b8f961358e6adba4a);
    send_msg("Hash functions play an important role in modern cryptography. This paper investigates optimisation techniques that have recently \
been proposed in the literature. A new VLSI architecture for the SHA-256 and SHA-512 hash functions is presented, which combines \
two popular hardware optimisation techniques, namely pipelining and unrolling. The SHA processors are developed for implementation \
on FPGAs, thereby allowing rapid prototyping of several designs. Speed/area results from these processors are analysed and are shown \
to compare favourably with other FPGA-based implementations, achieving the fastest data throughputs in the literature to date.",
            sha::sha1,
            160'h3509aee67e9a991289d77d4631ef7c475d99c144);
    send_msg("Hello World!", sha::sha512_256,
            256'hf371319eee6b39b058ec262d4e723a26710e46761301c8b54c56fa722267581a);
    #1 wait(sha_engine_if_h.master.ready == 1'b1);
    repeat(6) @(posedge sha_engine_if_h.master.clk);
    send_msg("Hello World!", sha::sha512_224,
            224'hba0702dd8dd23280b617ef288bcc7e276060b8ebcddf28f8e4356eae);
    send_msg("Hello World!", sha::sha256,
            256'h7F83B1657FF1FC53B92DC18148A1D65DFC2D4B1FA3D677284ADDD200126D9069);
    send_msg("Hash functions play an important role in modern cryptography. This paper investigates optimisation techniques that have recently \
been proposed in the literature. A new VLSI architecture for the SHA-256 and SHA-512 hash functions is presented, which combines \
two popular hardware optimisation techniques, namely pipelining and unrolling. The SHA processors are developed for implementation \
on FPGAs, thereby allowing rapid prototyping of several designs. Speed/area results from these processors are analysed and are shown \
to compare favourably with other FPGA-based implementations, achieving the fastest data throughputs in the literature to date.",
            sha::sha512,
            512'hf5d2bbab8652ece1b2e5892ed1dbc97524ecdc40e9b04f69c3035a6c29db3d7b0028d34771b7d92d604d801f679c2822cc7105ba081b3637f3e5b4d55903a077);
    send_msg("Hello World!", sha::sha224,
            224'h4575bb4ec129df6380cedde6d71217fe0536f8ffc4e18bca530a7a1b);
    send_msg("Hash functions play an important role in modern cryptography. This paper investigates optimisation techniques that have recently \
been proposed in the literature. A new VLSI architecture for the SHA-256 and SHA-512 hash functions is presented, which combines \
two popular hardware optimisation techniques, namely pipelining and unrolling. The SHA processors are developed for implementation \
on FPGAs, thereby allowing rapid prototyping of several designs. Speed/area results from these processors are analysed and are shown \
to compare favourably with other FPGA-based implementations, achieving the fastest data throughputs in the literature to date.",
            sha::sha512_224,
            224'h5b2196499cb04ea7699c710ec8bd7b017bf73c33a9e5519d797baba0);
    send_msg("It is commonly known that cryptocurrencies, such as: bitcoin, ethereum and so on",
            sha::sha256,
            256'ha37941cd2d3184f237540451ac8e44ca12bba22f0288f68ee0f22df72955e0bc);
    send_msg("It is commonly known that cryptocurrencies, such as: bitcoin, ethereum and so on",
            sha::sha512,
            512'h24dc565aad2857bf7105d1d558cfb4ed2ce04dd89f489a0d194d574653e5a002c6cafe33e851cc0372c4c713b57558682f6735244e6501b6de0be4b915038730);

    #1 wait(sha_engine_if_h.master.ready == 1'b1);
    repeat(10) @(posedge sha_engine_if_h.master.clk);
    $finish;
end

localparam bit_in_block512 = 512;
localparam byte_in_block512 = bit_in_block512 / 8;
localparam bit_in_block1024 = 1024;
localparam byte_in_block1024 = bit_in_block1024 / 8;
bit             check_en;
sha::hash_t     check_hash;
int             check_cnt;
int unsigned    msg_len_tail;
int unsigned    less;
int unsigned    num_blocks;
int unsigned    byte_iter;

initial begin
    check_en = 0;
    check_hash = 'd0;
    check_cnt = 0;
    forever #(Tclk) begin
        #1 wait(sha_engine_if_h.master.ready == 1'b1);
        if(check_en) begin
            if(sha_engine_if_h.master.hash == check_hash)
                $display("%8d %2d OK", $time, check_cnt);
            else
                $display("%8d %2d ERROR", $time, check_cnt);
            check_en = 0;
            ++check_cnt;
        end
    end
end

task send_msg;
    input string        msg;
    input sha::mode_t   mode;
    input sha::hash_t   hash;
    begin
        bit[1023:0] block;
        block = 'd0;
        msg_len_tail = msg.len();
        case(mode)
            sha::sha1,
            sha::sha224,
            sha::sha256: begin
                num_blocks = msg.len() / byte_in_block512;
                if(msg.len() % byte_in_block512 != 0)
                    ++num_blocks;
                for(int unsigned block_iter = 0; block_iter < num_blocks; ++block_iter) begin
                    block = 'd0;
                    less = msg_len_tail < byte_in_block512 ? msg_len_tail : byte_in_block512;
                    for(byte_iter = 0; byte_iter < less; ++byte_iter) begin
                         block |= msg[msg.len()-msg_len_tail] << (bit_in_block512 - 8 - byte_iter * 8);
                         --msg_len_tail;
                    end
                    if(byte_iter == byte_in_block512)
                        send_block(block, mode, block_iter == 0);
                    else if(byte_iter >= (byte_in_block512 - 8)) begin
                        block |= 8'h80 << (bit_in_block512 - 8 - byte_iter * 8);
                        send_block(block, mode, block_iter == 0);
                        block = ((msg.len() * 8) % 64'hFFFF_FFFF_FFFF_FFFF) << (56 * 8);
                        send_block(block, mode, 0);
                    end
                    else if(byte_iter <= (byte_in_block512 - 9)) begin
                        block |= 8'h80 << (bit_in_block512 - 8 - byte_iter * 8);
                        block |= (msg.len() * 8) % 64'hFFFF_FFFF_FFFF_FFFF;
                        send_block(block, mode, block_iter == 0);
                    end
                end
            end
            sha::sha384,
            sha::sha512,
            sha::sha512_224,
            sha::sha512_256: begin
                num_blocks = msg.len() / byte_in_block1024;
                if(msg.len() % byte_in_block1024 != 0)
                    ++num_blocks;
                for(int unsigned block_iter = 0; block_iter < num_blocks; ++block_iter) begin
                    block = 'd0;
                    less = msg_len_tail < byte_in_block1024 ? msg_len_tail : byte_in_block1024;
                    for(byte_iter = 0; byte_iter < less; ++byte_iter) begin
                         block |= msg[msg.len()-msg_len_tail] << (bit_in_block1024 - 8 - byte_iter * 8);
                         --msg_len_tail;
                    end
                    if(byte_iter == byte_in_block1024)
                        send_block(block, mode, block_iter == 0);
                    else if(byte_iter >= (byte_in_block1024 - 16)) begin
                        block |= 8'h80 << (bit_in_block1024 - 8 - byte_iter * 8);
                        send_block(block, mode, block_iter == 0);
                        block = ((msg.len() * 8) % 64'hFFFF_FFFF_FFFF_FFFF) << (56 * 8);
                        send_block(block, mode, 0);
                    end
                    else if(byte_iter <= (byte_in_block1024 - 17)) begin
                        block |= 8'h80 << (bit_in_block1024 - 8 - byte_iter * 8);
                        block |= (msg.len() * 8) % 64'hFFFF_FFFF_FFFF_FFFF;
                        send_block(block, mode, block_iter == 0);
                    end
                end
            end
            default:
                $error("Invalid mode");
        endcase
        check_en = 1;
        check_hash = hash;
    end
endtask

task send_block;
    input bit[1023:0]   block;
    input sha::mode_t   mode;
    input bit           new_block;
    begin
        sha_engine_if_h.master.new_msg = new_block;
        sha_engine_if_h.master.valid = 1'b1;
        sha_engine_if_h.master.mode = mode;
        sha_engine_if_h.master.msg = 'd0;
        case(mode)
            sha::sha1,
            sha::sha224,
            sha::sha256:
                sha_engine_if_h.master.msg = {512'd0, block[511:0]};
            sha::sha384,
            sha::sha512,
            sha::sha512_224,
            sha::sha512_256:
                sha_engine_if_h.master.msg = block;
            default:
                $error("Invalid mode");
        endcase
        #1 wait(sha_engine_if_h.master.ready == 1'b1);

        @(posedge sha_engine_if_h.master.clk);
        sha_engine_if_h.master.new_msg = 1'b0;
        sha_engine_if_h.master.valid = 1'b0;
        sha_engine_if_h.master.mode = sha::sha1;
        sha_engine_if_h.master.msg = 'd0;
    end
endtask

endmodule
