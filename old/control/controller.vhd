library ieee;
use ieee.std_logic_1164.all;

entity controller is
  port (
    Reset             : in std_logic;
    Clock             : in std_logic;
    RequestedFloor    : in integer;
    CurrentFloor      : in integer;
    PriorityUpSignal  : in std_logic;
    RequestedSignal   : in std_logic;
    OpenTimeoutSignal : in std_logic;
    ButtonSignals     : in std_logic_vector(1 downto 0);
    SensorSignals     : in std_logic_vector(3 downto 0);

    TimerControl  : out std_logic_vector(1 downto 0);
    MotorControl  : out std_logic_vector(1 downto 0);
    OpenDoors     : out std_logic;
    ReleaseBreaks : out std_logic;

    DEBUGState : out integer
  );
end entity;
architecture fsm of controller is
  type state is (
    Start,
    WaitingOpen,
    WaitingClosed,
    MovingUp,
    MovingDown,
    StoppingUp,
    StoppingDown,
    OpeningDoors,
    ClosingDoors
  );

  signal ThisState : state := Start;
  signal NextState : state;

  signal PriorityUp            : boolean;
  signal Requested             : boolean;
  signal OpenTimeout           : boolean;
  signal OpenDoorButton        : boolean;
  signal CloseDoorButton       : boolean;
  signal CloseToNextFloor      : boolean;
  signal Stopped               : boolean;
  signal OpenDoorEndOfTravel   : boolean;
  signal ClosedDoorEndOfTravel : boolean;

  signal StartTimer : std_logic;
  signal ResetTimer : std_logic;
  signal MotorUp    : std_logic;
  signal MotorDown  : std_logic;
begin

  PriorityUp            <= PriorityUpSignal  = '1';
  Requested             <= RequestedSignal   = '1';
  OpenTimeout           <= OpenTimeoutSignal = '1';
  OpenDoorButton        <= ButtonSignals(0)  = '1';
  CloseDoorButton       <= ButtonSignals(1)  = '1';
  CloseToNextFloor      <= SensorSignals(0)  = '1';
  Stopped               <= SensorSignals(1)  = '1';
  OpenDoorEndOfTravel   <= SensorSignals(2)  = '1';
  ClosedDoorEndOfTravel <= SensorSignals(3)  = '1';

  TimerControl(0) <= StartTimer;
  TimerControl(1) <= ResetTimer;
  MotorControl(0) <= MotorUp;
  MotorControl(1) <= MotorDown;

  DEBUGState <= state'pos(ThisState);

  Com : process (
    ThisState,
    RequestedFloor,
    CurrentFloor,
    PriorityUp,
    Requested,
    OpenTimeout,
    OpenDoorButton,
    CloseDoorButton,
    CloseToNextFloor,
    Stopped,
    OpenDoorEndOfTravel,
    ClosedDoorEndOfTravel
  )
  begin
    case ThisState is
      when Start =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '0';
        OpenDoors     <= '0';
        ReleaseBreaks <= '0';

        NextState <= WaitingClosed;

      when WaitingOpen =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '0';
        OpenDoors     <= '1';
        ReleaseBreaks <= '0';

        if OpenDoorButton then
          ResetTimer <= '1';
        end if;
        if OpenTimeout or CloseDoorButton then
          NextState <= ClosingDoors;
        else
          StartTimer <= '1';
          NextState <= WaitingOpen;
        end if;

      when WaitingClosed =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '0';
        OpenDoors     <= '0';
        ReleaseBreaks <= '0';

        if Requested then
          if RequestedFloor = CurrentFloor then
            NextState <= OpeningDoors;
          else
            if PriorityUp then
              NextState <= MovingUp;
            else
              NextState <= MovingDown;
            end if;
          end if;
        else
          NextState <= WaitingClosed;
        end if;

      when MovingUp =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '1';
        MotorDown     <= '0';
        OpenDoors     <= '0';
        ReleaseBreaks <= '1';

        if CloseToNextFloor then
          NextState <= StoppingUp;
        else
          NextState <= MovingUp;
        end if;

      when MovingDown =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '1';
        OpenDoors     <= '0';
        ReleaseBreaks <= '1';

        if CloseToNextFloor then
          NextState <= StoppingDown;
        else
          NextState <= MovingDown;
        end if;

      when StoppingUp =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '1';
        MotorDown     <= '0';
        OpenDoors     <= '0';
        ReleaseBreaks <= '1';

        if Stopped then
          NextState <= WaitingClosed;
        else
          NextState <= StoppingUp;
        end if;

      when StoppingDown =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '1';
        OpenDoors     <= '0';
        ReleaseBreaks <= '1';

        if Stopped then
          NextState <= WaitingClosed;
        else
          NextState <= StoppingDown;
        end if;

      when OpeningDoors =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '0';
        OpenDoors     <= '1';
        ReleaseBreaks <= '0';

        if OpenDoorEndOfTravel then
          StartTimer <= '1';
          NextState <= WaitingOpen;
        else
          NextState <= OpeningDoors;
        end if;

      when ClosingDoors =>
        StartTimer    <= '0';
        ResetTimer    <= '0';
        MotorUp       <= '0';
        MotorDown     <= '0';
        OpenDoors     <= '0';
        ReleaseBreaks <= '0';

        if ClosedDoorEndOfTravel then
          NextState <= WaitingClosed;
        elsif OpenDoorButton then
          NextState <= OpeningDoors;
        else
          NextState <= ClosingDoors;
        end if;
    end case;
  end process;

  Seq : process (Reset, Clock)
  begin
    if Reset = '0' then
      ThisState <= Start;
    elsif rising_edge(Clock) then
      ThisState <= NextState;
    end if;
  end process;
end architecture;