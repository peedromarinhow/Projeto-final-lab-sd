library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture test of tb is
  constant frq : real      := 10.0;
  signal   run : boolean   := true;
  signal   rst : std_logic := '0';
  signal   clk : std_logic := '0';

  component counter is
    generic (
      data_width : integer
    );
    port (
      reset : in std_logic;
      clock : in std_logic;
      count : out std_logic_vector(data_width-1 downto 0)
    );
  end component;

  signal count_output : std_logic_vector(15 downto 0) := (others => '0');
begin
  run <= false after 6000 sec;
  clk <= not clk after (0.5/frq) * 1 sec when run;
  rst <= '1' after 10 sec;

  counter_instance : counter
    generic map (16)
    port map (rst, clk, count_output);
end test;
