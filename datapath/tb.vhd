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
  
      door_closed_end_of_travel_sensor : in std_logic;
      door_open_end_of_travel_sensor   : in std_logic;
  
      hold_door_button  : in std_logic;
      close_door_button : in std_logic;
  
      open_door : out std_logic;
  
      motor_forward : out std_logic;
      motor_reverse : out std_logic;
  
      debug_controller_state : out integer
    );
  end component;

  signal called_floor_input  : std_logic_vector(7 downto 0) := (others => '0');
  signal current_floor_input : std_logic_vector(7 downto 0) := (others => '0');

  signal door_closed_end_of_travel_sensor_input : std_logic := '0';
  signal door_open_end_of_travel_sensor_input   : std_logic := '0';

  signal hold_door_button_input  : std_logic := '0';
  signal close_door_button_input : std_logic := '0';

  signal open_door_output : std_logic;

  signal motor_forward_output : std_logic;
  signal motor_reverse_output : std_logic;

  signal debug_controller_state_output : integer;

  signal current_floor_number : unsigned(7 downto 0) := "00000001";
begin
  run <= false after 600 sec;
  clk <= not clk after (0.5/frq) * 1 sec when run;
  rst <= '1' after 1 sec;

  datapath_instance : datapath
    port map (rst,
              clk,
              
              called_floor_input,
              current_floor_input,
            
              door_closed_end_of_travel_sensor_input,
              door_open_end_of_travel_sensor_input,
            
              hold_door_button_input,
              close_door_button_input,
            
              open_door_output,
            
              motor_forward_output,
              motor_reverse_output,
            
              debug_controller_state_output);

  called_floor_input <= "00000011" after 60  sec, "00000000" after 100 sec,
                        "00000001" after 150  sec, "00000000" after 190 sec;
  -- current_floor_input <= "00000001" after 120 sec;

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
    variable current_floor_altitude : real := 0.0;
  begin
    if rising_edge(clk) then
      if motor_forward_output = '1' then
        if current_floor_altitude < 0.9 then
          current_floor_altitude := current_floor_altitude + 0.01;
        else
          current_floor_altitude := 0.0;
          current_floor_number <= current_floor_number + 1;
        end if;
      elsif motor_reverse_output = '1' then
        if current_floor_altitude > 0.1 then
          current_floor_altitude := current_floor_altitude - 0.01;
        else
          current_floor_altitude := 1.0;
          current_floor_number <= current_floor_number - 1;
        end if;
      end if;

      current_floor_input <= std_logic_vector(current_floor_number);
    end if;
    
  end process;

end test;
