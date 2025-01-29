library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture test of tb is
  component priority_calc is
    port (
      reset : in std_logic;
  
      add_up       : in std_logic;
      add_down     : in std_logic;
      was_going_up : in std_logic;
  
      priority_up : out std_logic
    );
  end component;

  signal rst                : std_logic := '0';
  signal add_up_input       : std_logic := '0';
  signal add_down_input     : std_logic := '0';
  signal was_going_up_input : std_logic := '0';

  signal priority_up_output : std_logic;
begin
  priority_calc_instance : priority_calc
    port map (rst, add_up_input, add_down_input, was_going_up_input, priority_up_output);

  add_up_input <= '1' after 1 ns,
                  '0' after 2 ns,
                  '1' after 3 ns,
                  '0' after 4 ns,
                  '1' after 20 ns,
                  '0' after 21 ns;

  add_down_input <= '1' after 10 ns,
                    '0' after 12 ns,
                    '1' after 13 ns,
                    '1' after 15 ns,
                    '0' after 16 ns,
                    '1' after 17 ns,
                    '0' after 18 ns;

  was_going_up_input <= '1' after 4 ns,
                        '0' after 18 ns;
end test;
