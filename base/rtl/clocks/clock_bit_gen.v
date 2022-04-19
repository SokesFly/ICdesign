module                                  clock_bit_gen #(
    parameter                           DLY    = 1,
    parameter                           WIDTH  = 8
    )(
    input  wire                         clk_i       ,
    input  wire                         rstn_i      ,
    input  wire [WIDTH-1    :0]         period      ,
    output wire                         bit_en      ,
    output wire                         bit_half_en
    );

reg  [WIDTH-1   :0]                     cnt_r   ;

always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        cnt_r  <= #DLY {WIDTH{1'b0}};
    end
    else if(period - 1 == cnt_r) begin
        cnt_r  <= #DLY 'd0;
    end
    else begin
        cnt_r  <= #DLY 'd1 + cnt_r;
    end
end


assign      bit_en = (period - 1 == cnt_r);
assign      bit_half_en = ((period -1) >> 1 == cnt_r);

endmodule
