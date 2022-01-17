module tb_engine;
    localparam Tclk = 10;

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
        sha_engine_if_h.master.valid = 1'b0;
        sha_engine_if_h.master.msg = 'd0;
        #(Tclk+Tclk/4) sha_engine_if_h.master.rstn = 1'b1;
    end

    initial begin
        sha_engine_if_h.master.clk = 1'b0;
        forever #(Tclk/2) sha_engine_if_h.master.clk = ~sha_engine_if_h.master.clk;
    end

    sha_engine dut (
        .bus(sha_engine_if_h)
    );

    initial begin
        wait(sha_engine_if_h.master.rstn == 1'b1);
        @(posedge sha_engine_if_h.master.clk);
        #1;

        sha_engine_if_h.send(sha::sha512, 1024'h636F707320717565657273, 11);
        sha_engine_if_h.send(sha::sha256, 512'h636F707320717565657273, 11);
        wait(sha_engine_if_h.master.ready == 1'b1);
        @(posedge sha_engine_if_h.master.clk);
        #1;
        sha_engine_if_h.send(sha::sha256, 512'h68656C6C6F20776F726C64, 11);
        wait(sha_engine_if_h.master.ready == 1'b1);

        repeat(10) @(posedge sha_engine_if_h.master.clk);
        $finish;
    end

    logic[31:0] a;
    initial begin
        a = 32'h12345678;
        #10;
        a = a >>> 8;
        #10;
    end

endmodule
