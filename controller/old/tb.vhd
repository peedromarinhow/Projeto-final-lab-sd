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

  component controller is
    port (
      reset : in std_logic;
      clock : in std_logic;
  
      was_called              : in std_logic;
      called_floor_eq_current : in std_logic;
      close_to_destination    : in std_logic;
      is_at_destination       : in std_logic;
  
      open_door_timer_timeout  : in std_logic;
      door_closed_end_of_travel : in std_logic;
      door_open_end_of_travel   : in std_logic;
  
      hold_door_button  : in std_logic;
      close_door_button : in std_logic;
  
      debug_state : out integer
    );
  end component;
  
  signal was_called_input              : std_logic := '0';
  signal called_floor_eq_current_input : std_logic := '0';
  signal close_to_destination_input    : std_logic := '0';
  signal is_at_destination_input       : std_logic := '0';

  signal open_door_timer_timeout_input   : std_logic := '0';
  signal door_closed_end_of_travel_input : std_logic := '0';
  signal door_open_end_of_travel_input   : std_logic := '0';


  signal hold_door_button_input  : std_logic := '0';
  signal close_door_button_input : std_logic := '0';

  signal debug_state_output : integer;
begin
  run <= false after 600 sec;
  clk <= not clk after (0.5/frq) * 1 sec when run;
  rst <= '1' after 1 sec;

  controller_instance : controller
  port map (
    rst,
    clk,

    was_called_input,
    called_floor_eq_current_input,
    close_to_destination_input,
    is_at_destination_input,
  
    open_door_timer_timeout_input,
    door_closed_end_of_travel_input,
    door_open_end_of_travel_input,

    hold_door_button_input,
    close_door_button_input,
  
    debug_state_output
  );
end test;
