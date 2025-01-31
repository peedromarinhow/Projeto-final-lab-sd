library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port (
    reset : in std_logic;
    clock : in std_logic;

    was_called    : in std_logic;
    called_floor  : in std_logic_vector(7 downto 0);
    current_floor : in std_logic_vector(7 downto 0);

    door_is_obstructed_sensor        : in std_logic;
    door_closed_end_of_travel_sensor : in std_logic;
    door_open_end_of_travel_sensor   : in std_logic;

    hold_door_button  : in std_logic;
    close_door_button : in std_logic;

    at_floor_alarm_trigger : out std_logic;
    open_door              : out std_logic;
    motor_forward          : out std_logic;
    motor_reverse          : out std_logic;

    debug_controller_state : out integer
  );
end entity;
architecture rtl of datapath is
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
  signal timer_reset_inter : std_logic := '0';
  signal timer_start_inter : std_logic := '0';
  signal timer_ended_inter : std_logic := '0';

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

  component controller is
    port (
      reset : in std_logic;
      clock : in std_logic;
  
      was_called              : in std_logic;
      called_floor_eq_current : in std_logic;
      called_floor_gt_current : in std_logic;

      open_door_timer_ended  : in  std_logic;
      open_door_timer_start  : out std_logic;
      open_door_timer_reset  : out std_logic;

      door_is_obstructed_sensor        : in std_logic;
      door_closed_end_of_travel_sensor : in std_logic;
      door_open_end_of_travel_sensor   : in std_logic;

      hold_door_button  : in std_logic;
      close_door_button : in std_logic;

      at_floor_alarm_trigger : out std_logic;
      open_door              : out std_logic;
      motor_forward          : out std_logic;
      motor_reverse          : out std_logic;
  
      debug_state : out integer
    );
  end component;
  signal controller_called_eq_current_input : std_logic := '0';
  signal controller_called_gt_current_input : std_logic := '0';

  signal inv_reset : std_logic := '0';
begin
  inv_reset <= not reset;

  open_door_timer_instance : timer
    generic map (duration_sec => 30, frequency_hz => 10)
    port map (timer_reset_inter,
              clock,
              timer_start_inter,
              timer_ended_inter);

  comp_instance : comp
    generic map (8)
    port map (called_floor,
              current_floor,
              controller_called_eq_current_input,
              controller_called_gt_current_input);

  controller_instance : controller
    port map (reset,
              clock,

              was_called,
              controller_called_eq_current_input,
              controller_called_gt_current_input,

              timer_ended_inter,
              timer_start_inter,
              timer_reset_inter,

              door_is_obstructed_sensor,
              door_closed_end_of_travel_sensor,
              door_open_end_of_travel_sensor,

              hold_door_button,
              close_door_button,

              at_floor_alarm_trigger,
              open_door,
              motor_forward,
              motor_reverse,

              debug_controller_state);
end architecture;


