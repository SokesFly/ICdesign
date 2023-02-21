`timescale 1ns/1ps

module reset_tb();

// generate clock
reg clk;

initial begin
    $fsdbDumpfile("reset_tb.fsdb");
    $fsdbDumpvars("+all");
end


endmodule
