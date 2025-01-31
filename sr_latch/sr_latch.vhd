library ieee;
use ieee.std_logic_1164.all;

entity sr_latch is
  port (
    s, r : in  std_logic;
    q    : out std_logic
  );
end sr_latch;
architecture rtl of sr_latch is
  signal p : std_logic := '0';
  signal n : std_logic := '0';
begin
  p <= r nor n;
  n <= s nor p;

  q <= p;
end rtl;