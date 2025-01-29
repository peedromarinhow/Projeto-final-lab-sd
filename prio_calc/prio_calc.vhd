library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prio_calc is
  port (
    reset : in std_logic;

    add_up       : in std_logic;
    add_down     : in std_logic;
    was_going_up : in std_logic;

    prio_up : out std_logic
  );
end entity;
architecture behavioral of prio_calc is
  constant required_width : integer := 8;
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

  signal up_count   : std_logic_vector(required_width-1 downto 0);
  signal down_count : std_logic_vector(required_width-1 downto 0);
  
  signal cond : boolean;
begin
  up_counter_instance : counter
    generic map (required_width)
    port map (reset, add_up, up_count);

  down_counter_instance : counter
    generic map (required_width)
    port map (reset, add_down, down_count);
  
  cond <= (unsigned(up_count) > unsigned(down_count)) or (unsigned(up_count) = unsigned(down_count) and was_going_up = '1');

  prio_up <= '1' when cond else '0';
end architecture;