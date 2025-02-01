library ieee;
use ieee.std_logic_1164.all;

entity controller is
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

    debug_state : out string(1 to 255)
  );
end entity;
architecture fsm of controller is
  type state is (
    state_start,

    state_waiting_closed,
    state_waiting_open,

    state_start_open_door_timer,
    state_trigger_at_floor_alarm,

    state_opening_door,
    state_closing_door,

    state_moving_up,
    state_moving_down
  );

  signal curr_state : state := state_start;
  signal next_state : state;

  function string_pad(s: string; w : integer := debug_state'length) return string is
  begin
    return s & (1 to w - s'length => ' ');
  end function;
begin
  process (
    curr_state,

    was_called,
    called_floor_eq_current,
    called_floor_gt_current,

    open_door_timer_ended,

    door_is_obstructed_sensor,
    door_closed_end_of_travel_sensor,
    door_open_end_of_travel_sensor,

    hold_door_button,
    close_door_button
  )
  begin
    case curr_state is
      when state_start =>
        next_state <= state_waiting_closed;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_waiting_closed =>
        if was_called = '0' then
          if hold_door_button = '0' then
            next_state <= state_waiting_closed;
          else
            next_state <= state_opening_door;
          end if;
        else
          if called_floor_eq_current = '1' then
            next_state <= state_opening_door;
          elsif called_floor_gt_current = '1' then
            next_state <= state_moving_up;
          else
            next_state <= state_moving_down;
          end if;
        end if;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_waiting_open =>
        if open_door_timer_ended = '1' or close_door_button = '1' or was_called = '1' then
          next_state <= state_closing_door;
        else
          next_state <= state_waiting_open;
        end if;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '1';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_start_open_door_timer =>
        next_state <= state_waiting_open;

        open_door_timer_start  <= '1';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '1';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_trigger_at_floor_alarm =>
        next_state <= state_opening_door;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '1';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_opening_door =>
        if door_open_end_of_travel_sensor = '0' then
          next_state <= state_opening_door;
        else
          next_state <= state_start_open_door_timer;
        end if;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '1';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_closing_door =>
        if door_closed_end_of_travel_sensor = '0' then
          if door_is_obstructed_sensor = '1' or hold_door_button = '1' then
            next_state <= state_opening_door;
          else
            next_state <= state_closing_door;
          end if;
        else
          next_state <= state_waiting_closed;
        end if;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '1';
        at_floor_alarm_trigger <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_moving_up =>
        if called_floor_eq_current = '0' then
          next_state <= state_moving_up;
        else
          next_state <= state_trigger_at_floor_alarm;
        end if;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '0';
        motor_forward          <= '1';
        motor_reverse          <= '0';

      when state_moving_down =>
        if called_floor_eq_current = '0' then
          next_state <= state_moving_down;
        else
          next_state <= state_trigger_at_floor_alarm;
        end if;

        open_door_timer_start  <= '0';
        open_door_timer_reset  <= '0';
        at_floor_alarm_trigger <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '1';

    end case;
  end process;

  process (reset, clock)
  begin
    if reset = '0' then
      curr_state <= state_start;
    elsif rising_edge(clock) then
      curr_state <= next_state;
    end if;
  end process;

  process (curr_state)
  begin
    case curr_state is
      when state_start                  => debug_state <= string_pad("start");
      when state_waiting_closed         => debug_state <= string_pad("waiting_closed");
      when state_waiting_open           => debug_state <= string_pad("waiting_open");
      when state_start_open_door_timer  => debug_state <= string_pad("start_open_door_timer");
      when state_trigger_at_floor_alarm => debug_state <= string_pad("trigger_at_floor_alarm");
      when state_opening_door           => debug_state <= string_pad("opening_door");
      when state_closing_door           => debug_state <= string_pad("closing_door");
      when state_moving_up              => debug_state <= string_pad("moving_up");
      when state_moving_down            => debug_state <= string_pad("moving_down");
    end case;
  end process;
end architecture;