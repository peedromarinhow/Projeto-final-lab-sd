library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tb is
end tb;

architecture test of tb is
  constant frq : real      := 10.0;
  signal   run : boolean   := true;
  signal   rst : std_logic := '0';
  signal   clk : std_logic := '0';

  component reg is
    generic (
      data_width : natural := 8
    );
    port (
      reset    : in  std_logic;
      clock    : in  std_logic;
      load     : in  std_logic;
      data_in  : in  std_logic_vector(data_width-1 downto 0);
      data_out : out std_logic_vector(data_width-1 downto 0)
    );
  end component;

  signal load_input  : std_logic := '0';
  signal data_input  : std_logic_vector(3 downto 0);
  signal data_output : std_logic_vector(3 downto 0) := "0000";
begin
  run <= false after 100 sec;
  clk <= not clk after (0.5/frq) * 1 sec when run;
  rst <= '0' after 21 sec, '1' after 23 sec, '0' after 87 sec;

  reg_instance : reg
    generic map (4)
    port map (rst, clk, load_input, data_input, data_output);
  
  load_input <= '1' after 12 sec, '0' after 27 sec, '1' after 72 sec;
  data_input <= "0000", "0001" after 20 sec, "0010" after 40 sec, "0011" after 60 sec, "0100" after 80 sec;
end test;
