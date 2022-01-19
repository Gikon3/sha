module tb_engine;

localparam Tclk = 10;

bit         check_en;
sha::hash_t check_hash;
int         check_cnt;

initial begin
    #(Tclk*1000);
    $finish;
end

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
    force dut.state = dut.st_idle; release  dut.state;
    force dut.mode = sha::sha1; release  dut.mode;
end

sha_engine dut (
    .bus(sha_engine_if_h)
);

initial begin
    wait(sha_engine_if_h.master.rstn == 1'b1);
    @(posedge sha_engine_if_h.master.clk);

    send_msg("Hello World!", sha::sha512,
            512'h861844d6704e8573fec34d967e20bcfef3d424cf48be04e6dc08f2bd58c729743371015ead891cc3cf1c9d34b49264b510751b1ff9e537937bc46b5d6ff4ecc8);
    send_msg("Hello World!", sha::sha384,
            384'hbfd76c0ebbd006fee583410547c1887b0292be76d582d96c242d2a792723e3fd6fd061f9d5cfd13b8f961358e6adba4a);
    send_msg("Hello World!", sha::sha512_256,
            256'hf371319eee6b39b058ec262d4e723a26710e46761301c8b54c56fa722267581a);
    send_msg("Hello World!", sha::sha512_224,
            224'hba0702dd8dd23280b617ef288bcc7e276060b8ebcddf28f8e4356eae);
    send_msg("Hello World!", sha::sha256,
            256'h7F83B1657FF1FC53B92DC18148A1D65DFC2D4B1FA3D677284ADDD200126D9069);
    send_msg("Hello World!", sha::sha224,
            224'h4575bb4ec129df6380cedde6d71217fe0536f8ffc4e18bca530a7a1b);

    #1 wait(sha_engine_if_h.master.ready == 1'b1);
    repeat(10) @(posedge sha_engine_if_h.master.clk);
    $finish;
end

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
        case(mode)
            sha::sha224,
            sha::sha256: begin
                for(int unsigned i = 0; i < msg.len(); ++i)
                    block |= msg[i] << (512 - 8 - i * 8);
                block |= 1 << (512 - 8 - msg.len() * 8 + 7);
                block |= (msg.len() * 8) % 64'hFFFF_FFFF_FFFF_FFFF;
                send_block(block, mode);
            end
            sha::sha384,
            sha::sha512,
            sha::sha512_224,
            sha::sha512_256: begin
                for(int unsigned i = 0; i < msg.len(); ++i)
                    block |= msg[i] << (1024 - 8 - i * 8);
                block |= 1 << (1024 - 8 - msg.len() * 8 + 7);
                block |= (msg.len() * 8) % 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
                send_block(block, mode);
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
    begin
        sha_engine_if_h.master.new_msg = 1'b1;
        sha_engine_if_h.master.valid = 1'b1;
        sha_engine_if_h.master.mode = mode;
        sha_engine_if_h.master.msg = 'd0;
        case(mode)
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
