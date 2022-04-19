module          clock_div_tb();

parameter       PERIOD  = 20;

reg             clk_r ;
reg             rstn_r;
wire            clk_o ;

initial begin
    clk_r       =  1'b0;
    forever begin
        #(PERIOD/2) clk_r = 1'b0;
        #(PERIOD/2) clk_r = 1'b1;
    end
end

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "clock_div_tb");
end

initial begin
    rstn_r = 1'b0;
    #(PERIOD*10) 
    rstn_r = 1'b1;
    #(PERIOD*2001)
    rstn_r = 1'b0;
    #(12)
    rstn_r = 1'b1;
    #(PERIOD*312)
    $finish;
end

clock_div       #(
    .DLY        ( 1         ),
    .WIDTH      ( 8         )
    )
    u_clock_div_i
    (
    .clk_i      ( clk_r     ),
    .rst_n_i    ( rstn_r    ),
    .gen        ( 1'd1      ),
    .half_period( 8'd5      ),
    .clk_o      ( clk_o     )
    );


endmodule
