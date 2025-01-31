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

  component timer is
    generic (
      duration_sec : integer;
      frequency_hz : integer
    );
    port (
      reset : in std_logic;
      clock : in std_logic;
      start : in std_logic;
      ended : out std_logic
    );
  end component;

  signal start_input  : std_logic := '0';
  signal ended_output : std_logic;
begin
  run <= false after 100 sec;
  clk <= not clk after (0.5/frq) * 1 sec when run;
  rst <= '1' after 55 sec, '0' after 56 sec;

  start_input <= '1' after 20 sec, '0' after 20.00001 sec,
                 '1' after 60 sec, '0' after 61 sec;

  timer_instance : timer
    generic map (30, integer(frq))
    port map(rst, clk, start_input, ended_output);
end test;
