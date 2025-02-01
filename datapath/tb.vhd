library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb is
end tb;

architecture test of tb is
  constant frq : real      := 10.0;
  signal   run : boolean   := true;
  signal   rst : std_logic := '0';
  signal   clk : std_logic := '0';

  component datapath is
    port (
      reset : in std_logic;
      clock : in std_logic;
  
      called_floor  : in std_logic_vector(7 downto 0);
      current_floor : in std_logic_vector(7 downto 0);
  
      sensor_inputs : in std_logic_vector(3 downto 0);
      button_inputs : in std_logic_vector(1 downto 0);
  
      outputs : out std_logic_vector(3 downto 0);
  
      debug_controller_state : out string(1 to 255)
    );
  end component;

  signal called_floor_input  : std_logic_vector(7 downto 0) := (others => '0');
  signal current_floor_input : std_logic_vector(7 downto 0) := (others => '0');

  signal sensor_inputs_vector : std_logic_vector(3 downto 0) := (others => '0');
  signal button_inputs_vector : std_logic_vector(1 downto 0) := (others => '0');

  signal outputs_vector : std_logic_vector(3 downto 0) := (others => '0');

  alias was_called_input                       : std_logic is sensor_inputs_vector(0);
  alias door_is_obstructed_sensor_input        : std_logic is sensor_inputs_vector(1);
  alias door_closed_end_of_travel_sensor_input : std_logic is sensor_inputs_vector(2);
  alias door_open_end_of_travel_sensor_input   : std_logic is sensor_inputs_vector(3);

  alias hold_door_button_input  : std_logic is button_inputs_vector(0);
  alias close_door_button_input : std_logic is button_inputs_vector(1);

  alias at_floor_alarm_trigger_output : std_logic is outputs_vector(0);
  alias open_door_output              : std_logic is outputs_vector(1);
  alias motor_forward_output          : std_logic is outputs_vector(2);
  alias motor_reverse_output          : std_logic is outputs_vector(3);

  signal debug_controller_state_output : string(1 to 255);
begin
  clk <= not clk after (0.5/frq) * 1 sec when run;
  rst <= '1' after 1 sec;

  door_is_obstructed_sensor_input <= '1' after 315 sec, '0' after 316 sec;
  
  hold_door_button_input  <= '1' after 125 sec, '0' after 126 sec,
                             '1' after 165 sec, '0' after 166 sec;
  close_door_button_input <= '1' after 120 sec, '0' after 121 sec;

  datapath_instance : datapath
    port map (rst,
              clk,

              called_floor_input,
              current_floor_input,

              sensor_inputs_vector,
              button_inputs_vector,

              outputs_vector,

              debug_controller_state_output);

  process
    type int_arr is array (integer range <>) of integer;

    constant num_reqs : integer := 10;
    constant the_reqs : int_arr(0 to num_reqs-1) := (1, 2, 1, 2, 7, 8, 5, 6, 9, 1);
  begin
    wait for 50 sec;
    for i in the_reqs'range loop
      was_called_input   <= '1' after 0 sec, '0' after 1 sec;
      called_floor_input <= std_logic_vector(to_unsigned(the_reqs(i), 8));

      wait until at_floor_alarm_trigger_output = '1';
      wait for 120 sec;
    end loop;
    wait for 60 sec;
    run <= false;
    wait;
  end process;

  door_process : process (clk)
    variable door_openness : real := 0.0;
  begin
    if rising_edge(clk) then
      if open_door_output = '1' then
        if door_openness < 100.0 then
          door_openness := door_openness + 1.0;
        end if;
      elsif door_openness > 0.0 then
        door_openness := door_openness - 1.0;
      end if;

      if door_openness > 99.0 then
        door_open_end_of_travel_sensor_input <= '1';
      else
        door_open_end_of_travel_sensor_input <= '0';
      end if;

      if door_openness < 1.0 then
        door_closed_end_of_travel_sensor_input <= '1';
      else
        door_closed_end_of_travel_sensor_input <= '0';
      end if;
    end if;
  end process;

  cabin_process : process (clk)
    constant increment_per_tick : real := 0.002;
    variable current_floor      : real := 0.0;
    variable current_altitude   : real := 0.0;
    variable current_delta      : real := 0.0;
  begin
    if rising_edge(clk) then
      current_altitude := current_altitude + current_delta;
      if motor_forward_output = '1' then
        current_delta := increment_per_tick;
      elsif motor_reverse_output = '1' then
        current_delta := -increment_per_tick;
      else
        current_delta := 0.0;
      end if;

      if (current_altitude - floor(current_altitude)) < 0.1 then
        current_floor := floor(current_altitude);
      end if;

      current_floor_input <= std_logic_vector(to_unsigned(integer(current_floor), 8));
    end if;

  end process;

end test;
