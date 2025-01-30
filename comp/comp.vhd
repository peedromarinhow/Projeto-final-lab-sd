library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp is 
  generic (
    data_width : natural := 16
  );
  port  (
    a, b  : in std_logic_vector((data_width-1) downto 0);
    eq : out std_logic;
    bt : out std_logic
  );
end entity;
architecture rtl of comp is
begin
  eq <= '1' when (unsigned(a) = unsigned(b)) else '0';
  bt <= '1' when (unsigned(a) > unsigned(b)) else '0';
end architecture;
