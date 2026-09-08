// Parallel direct-form FIR. Input-valid strobes advance sample history.
// Q1.15 samples and coefficients; truncate toward -infinity, saturate int16.
// 48-bit accumulator is sufficient for the default 63 signed 16x16 products.
module fir #(parameter integer TAPS=63, parameter COEFF_FILE="coeffs.hex") (
 input logic clk, rst, in_valid,
 input logic signed [15:0] sample_in,
 output logic out_valid,
 output logic signed [15:0] sample_out
);
 logic signed [15:0] coeff [0:TAPS-1];
 logic signed [15:0] history [0:TAPS-1];
 logic signed [47:0] acc, shifted;
 logic signed [31:0] product;
 integer k;
 initial $readmemh(COEFF_FILE,coeff);
 always_comb begin
   product=sample_in*coeff[0];
   acc={{16{product[31]}},product};
   for(integer j=1;j<TAPS;j=j+1) begin
     product=history[j-1]*coeff[j];
     acc=acc+{{16{product[31]}},product};
   end
   shifted=acc >>> 15;
 end
 always_ff @(posedge clk) begin
   if(rst) begin
     out_valid<=0; sample_out<=0;
     for(k=0;k<TAPS;k=k+1) history[k]<=0;
   end else begin
     out_valid<=in_valid;
     if(in_valid) begin
       for(k=TAPS-1;k>0;k=k-1) history[k]<=history[k-1];
       history[0]<=sample_in;
       if(shifted>32767) sample_out<=32767;
       else if(shifted < -32768) sample_out<=-32768;
       else sample_out<=shifted[15:0];
     end
   end
 end
endmodule
