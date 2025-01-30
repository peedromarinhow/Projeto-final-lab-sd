library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture test of tb is
  component comp is 
    generic (
      data_width : natural := 16
    );
    port  (
      a, b  : in std_logic_vector((data_width-1) downto 0);
      eq : out std_logic;
      bt : out std_logic
    );
  end component;

  signal a_in, b_in: std_logic_vector(3 downto 0);
  signal bt_out, eq_out: std_logic;

begin
  com_instance: comp
    generic map (DATA_WIDTH => 4)
    port map(a_in, b_in, eq_out, bt_out);

  a_in <= x"0", x"8" after 20 ns, x"7" after 40 ns, x"4" after 60 ns;
  b_in <= x"0", x"7" after 10 ns, x"8" after 30 ns, x"1" after 50 ns;
end architecture;