module reset_sync(
    input wire clk_i,
    input wire rstn_i,
    input wire unsynced_i,
    output wire synced_o
);
reg delay;
reg synced_reg;

assign synced_o = synced_reg;

always @(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        delay <= 1'b0;
    end 
    else begin
        delay <= unsynced_i;
    end
end

always @(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        synced_reg <= 1'b0;
    end
    else begin
        synced_reg <= delay;
    end
end

endmodule