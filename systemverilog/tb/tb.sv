module tb;
    reg clk_i;
    reg rstn_i;
    reg unsynced_i;
    reg synced_o;

    byte data_byte = "D";
    bit[7:0]    msg_bit_one = "C";

    bit [8*17:1]   msg_bit = "";
    string         msg_str = "String";

    reset_sync dut(
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .unsynced_i(unsynced_i),
        .synced_o(synced_o)
    );

    initial begin
        clk_i = 1'b1;
        forever begin
            #5 clk_i <= ~clk_i;
        end
    end

    initial begin
        #10 rstn_i = 1'b0;
        #10 rstn_i = 1'b1;
    end

    //End simulation
    initial begin
        $display(msg_str,"");
        #1000 $finish;
    end

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0,"+all");
    end


endmodule