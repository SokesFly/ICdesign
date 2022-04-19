module                              clock_div #(
    parameter                       DLY      = 1,
    parameter                       WIDTH    = 8
    )(
    input  wire                     clk_i       ,  // input primary clock
    input  wire                     rst_n_i     ,  // reset
    input  wire                     gen         ,  // enable counter
    input  wire [WIDTH-1:0]         period      ,  // the division of primary
    output wire                     clk_o          // outptu clock.
    );

reg  [WIDTH-1   :0]                 cnt_r   ;    // declare conter register.
reg                                 clk_r   ;    // clock output resgiter

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        cnt_r  <= #DLY {WIDTH{1'b0}};
    end
    else if(cnt_r == (period >> 1) - 1) begin
        cnt_r  <= #DLY 'd0;
    end
    else if(gen) begin
        cnt_r  <= #DLY cnt_r + 'd1;
    end 
end

// This need to modify ,if spi copl & copa select others.
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        clk_r  <= #DLY 'd0;
    end
    else if(cnt_r == (period >> 1) - 1) begin
        clk_r  <= #DLY ~clk_r;
    end
end

assign                              clk_o  =  clk_r;

endmodule
