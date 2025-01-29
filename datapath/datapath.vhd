library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
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
end entity;
architecture rtl of datapath is
  component timer is
    generic (
      duration_sec : integer;
      frequency_hz : integer
    );
    port (
      reset  : in std_logic;
      clock  : in std_logic;
      enable : in std_logic;
      ended  : out std_logic
    );
  end component;
  signal timer_enable_inter : std_logic := '0';
  signal timer_ended_inter  : std_logic := '0';

  component prio_calc is
    port (
      reset : in std_logic;
  
      add_up       : in std_logic;
      add_down     : in std_logic;
      was_going_up : in std_logic;
  
      prio_up : out std_logic
    );
  end component;
  signal prio_calc_add_up_inter   : std_logic := '0';
  signal prio_calc_add_down_inter : std_logic := '0';
  signal prio_calc_prio_up_inter  : std_logic := '0';

  component controller is
    port (
      reset : in std_logic;
      clock : in std_logic;
  
      was_called              : in std_logic;
      called_floor_eq_current : in std_logic;
      called_floor_gt_current : in std_logic;

      open_door_timer_timeout  : in  std_logic;
      open_door_timer_enable   : out std_logic;

      door_closed_end_of_travel : in std_logic;
      door_open_end_of_travel   : in std_logic;
  
      hold_door_button  : in std_logic;
      close_door_button : in std_logic;

      open_door     : out std_logic;
      motor_forward : out std_logic;
      motor_reverse : out std_logic;  
  
      debug_state : out integer
    );
  end component;
  signal controller_was_called_input        : std_logic := '0';
  signal controller_called_eq_current_input : std_logic := '0';
  signal controller_called_gt_current_input : std_logic := '0';

  signal controller_open_door_output     : std_logic;
  signal controller_motor_forward_output : std_logic;
  signal controller_motor_reverse_output : std_logic; 

  signal was_going_up : std_logic := '0';

  signal inv_reset : std_logic := '0';
begin
  inv_reset <= not reset;

  open_door_timer_instance : timer
    generic map (duration_sec => 30, frequency_hz => 10)
    port map (inv_reset,
              clock,
              timer_enable_inter,
              timer_ended_inter);
  
  prio_calc_instance : prio_calc
    port map (inv_reset,
              prio_calc_add_up_inter,
              prio_calc_add_down_inter,
              was_going_up,
              prio_calc_prio_up_inter);

  controller_instance : controller
    port map (reset,
              clock,

              controller_was_called_input,
              controller_called_eq_current_input,
              controller_called_gt_current_input,

              timer_ended_inter,
              timer_enable_inter,

              door_closed_end_of_travel_sensor,
              door_open_end_of_travel_sensor,

              hold_door_button,
              close_door_button,

              controller_open_door_output,
              controller_motor_forward_output,
              controller_motor_reverse_output,

              debug_controller_state);

  process (controller_motor_forward_output, controller_motor_reverse_output)
  begin
    if rising_edge(controller_motor_forward_output) then
      was_going_up <= '1';
    elsif rising_edge(controller_motor_reverse_output) then
      was_going_up <= '0';
    end if;
  end process;

  controller_was_called_input        <= '1' when unsigned(called_floor) /= 0 else '0';
  controller_called_eq_current_input <= '1' when unsigned(called_floor) = unsigned(current_floor) else '0';
  controller_called_gt_current_input <= '1' when unsigned(called_floor) > unsigned(current_floor) else '0';

  open_door     <= controller_open_door_output;
  motor_forward <= controller_motor_forward_output;
  motor_reverse <= controller_motor_reverse_output;
end architecture;