`timescale 1ns/1ps
module tb_fir;
 logic clk=0,rst=1,in_valid=0;
 logic signed [15:0] sample_in=0,sample_out;
 logic out_valid;
 logic signed [15:0] inputs[0:1124],expected[0:1124];
 integer i;
 fir dut(.*);
 always #5 clk=~clk;
 initial begin
   $readmemh("input.hex",inputs); $readmemh("expected.hex",expected);
   repeat(3) @(negedge clk);
   rst=0;
   for(i=0;i<1125;i=i+1) begin
     @(negedge clk);in_valid=1;sample_in=inputs[i];
     @(posedge clk);#1;
     if(out_valid!==1 || sample_out!==expected[i])
       $fatal(1,"Mismatch at %0d: got %0d expected %0d",i,sample_out,expected[i]);
     // Exercise invalid cycles: delay line must not advance.
     if(i%7==0) begin
       @(negedge clk);in_valid=0;
       @(posedge clk);#1;if(out_valid!==0)$fatal(1,"Invalid strobe");
     end
   end
   @(negedge clk);rst=1;in_valid=0;
   @(posedge clk);#1;if(sample_out!==0||out_valid!==0)$fatal(1,"Reset failed");
   $display("PASS: 1125 output comparisons, valid gaps, reset");$finish;
 end
endmodule
