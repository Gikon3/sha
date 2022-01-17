module sha (i_clk, i_rstn);
    input   i_clk;
    input   i_rstn;

    sha_loop sha_loop (
        .i_clk(i_clk), .i_rstn(i_rstn)
    );

endmodule // sha
