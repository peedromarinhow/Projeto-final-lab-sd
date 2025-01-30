library ieee;
use ieee.std_logic_1164.all;

entity controller is
  port (
    reset : in std_logic;
    clock : in std_logic;

    was_called              : in std_logic;
    called_floor_eq_current : in std_logic;
    called_floor_gt_current : in std_logic;

    open_door_timer_timeout  : in  std_logic;
    open_door_timer_enable   : out std_logic;
    open_door_timer_reset    : out std_logic;

    door_closed_end_of_travel : in std_logic;
    door_open_end_of_travel   : in std_logic;

    open_door     : out std_logic;
    motor_forward : out std_logic;
    motor_reverse : out std_logic;

    debug_state : out integer
  );
end entity;
architecture fsm of controller is
  type state is (
    state_start,

    state_waiting_closed,
    state_waiting_open,

    state_opening_door,
    state_closing_door,

    state_deciding,

    state_arrived,

    state_moving_up,
    state_moving_down
  );

  signal curr_state : state := state_start;
  signal next_state : state;
begin
  process (
    curr_state,

    was_called,
    called_floor_eq_current,
    called_floor_gt_current,

    open_door_timer_timeout,

    door_closed_end_of_travel,
    door_open_end_of_travel
  )
  begin
    case curr_state is
      when state_start =>
        next_state <= state_waiting_closed;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_waiting_closed =>
        if was_called = '0' then
          next_state <= state_waiting_closed;
        else
          next_state <= state_deciding;
        end if;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_waiting_open =>
        if open_door_timer_timeout = '0' then
          next_state <= state_waiting_open;
        else
          next_state <= state_closing_door;
        end if;

        open_door_timer_enable <= '1';
        open_door_timer_reset  <= '0';
        open_door              <= '1';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_opening_door =>
        if door_open_end_of_travel = '0' then
          next_state <= state_opening_door;
        else
          next_state <= state_waiting_open;
        end if;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '1';
        open_door              <= '1';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_closing_door =>
        if door_closed_end_of_travel = '0' then
          next_state <= state_closing_door;
        else
          next_state <= state_waiting_closed;
        end if;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_deciding =>
        if called_floor_eq_current = '1' then
          next_state <= state_opening_door;
        elsif called_floor_gt_current = '1' then
          next_state <= state_moving_up;
        else
        next_state <= state_moving_down;
        end if;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_arrived =>
        next_state <= state_opening_door;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
        open_door              <= '0';
        motor_forward          <= '0';
        motor_reverse          <= '0';

      when state_moving_up =>
        if called_floor_eq_current = '0' then
          next_state <= state_moving_up;
        else
          next_state <= state_arrived;
        end if;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
        open_door              <= '0';
        motor_forward          <= '1';
        motor_reverse          <= '0';

      when state_moving_down =>
        if called_floor_eq_current = '0' then
          next_state <= state_moving_down;
        else
          next_state <= state_arrived;
        end if;

        open_door_timer_enable <= '0';
        open_door_timer_reset  <= '0';
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

  debug_state <= state'pos(curr_state);
end architecture;