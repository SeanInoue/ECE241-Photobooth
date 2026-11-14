module halfSecondCounter (
    input clock,
    input resetn,  //reset on start
    output reg halfSec
);
  parameter clockFrequencyDelay = 25'd25_000_000 - 25'd1;

  reg [24:0] count;

  always @(posedge clock) begin
    if (!resetn) begin
      count <= 25'b0;
    end else begin
      if (count >= clockFrequencyDelay) begin
        count <= 25'b0;
      end else begin
        count <= count + 25'd1;
      end
    end
  end

  always @(*) begin
    if (count == clockFrequencyDelay) begin
      halfSec = 1'b1;
    end else begin
      halfSec = 1'b0;
    end
  end

endmodule
