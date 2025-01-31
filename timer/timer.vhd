library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
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
end entity;
architecture behavioral of timer is
  constant required_width : integer := 32;

  component counter is
    generic (
      data_width : integer := 8
    );
    port (
      reset : in std_logic;
      clock : in std_logic;
      count : out std_logic_vector(data_width-1 downto 0)
    );
  end component;

  signal anded_clock : std_logic := '0';
  signal running     : std_logic := '0';
  signal count_reg   : std_logic_vector(required_width-1 downto 0) := (others => '0');
begin
  running_latch : process (start, reset)
  begin
    if rising_edge(start) then
      running <= '1';
    end if;
    if reset = '1'   then
      running <= '0';
    end if;
  end process;

  anded_clock <= clock and running;
  ended       <= '1' when unsigned(count_reg) > (duration_sec*frequency_hz) else '0';
  
  counter_instance : counter
    generic map (required_width)
    port map (reset, anded_clock, count_reg);
end architecture;
