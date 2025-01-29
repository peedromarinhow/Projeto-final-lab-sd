library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  generic (
    data_width : integer := 8
  );
  port (
    reset : in std_logic;
    clock : in std_logic;
    count : out std_logic_vector(data_width-1 downto 0)
  );
end entity;
architecture behavioral of counter is
  signal count_reg : unsigned(data_width-1 downto 0) := (others => '0');
begin
  process (clock, reset)
  begin
    if rising_edge(clock) then
      count_reg <= count_reg + 1;
    end if;
    if reset = '1' then
      count_reg <= (others => '0');
    end if;
  end process;
  count <= std_logic_vector(count_reg);
end architecture;
