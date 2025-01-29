library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture test of tb is
  signal Reset :  std_logic := '0';
  signal Clock :  std_logic := '0';

  component controller is
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
  end component;

  signal RequestedFloorIn    : integer                      := 0;
  signal CurrentFloorIn      : integer                      := 0;
  signal PriorityUpSignalIn  : std_logic                    := '0';
  signal RequestedSignalIn   : std_logic                    := '0';
  signal OpenTimeoutSignalIn : std_logic                    := '0';

  signal ButtonSignalsIn     : std_logic_vector(1 downto 0) := (others => '0');
  alias  OpenDoorButton      : std_logic is ButtonSignalsIn(0);
  alias  CloseDoorButton     : std_logic is ButtonSignalsIn(1);

  signal SensorSignalsIn         : std_logic_vector(3 downto 0) := (others => '0');
  alias  CloseToNextFloorIn      : std_logic is SensorSignalsIn(0);
  alias  StoppedIn               : std_logic is SensorSignalsIn(1);
  alias  OpenDoorEndOfTravelIn   : std_logic is SensorSignalsIn(2);
  alias  ClosedDoorEndOfTravelIn : std_logic is SensorSignalsIn(3);

  signal TimerControlOut : std_logic_vector(1 downto 0);
  alias  StartTimerOut   : std_logic is TimerControlOut(0);
  alias  ResetTimerOut   : std_logic is TimerControlOut(1);

  signal MotorControlOut : std_logic_vector(1 downto 0);
  alias  MotorUpOut      : std_logic is MotorControlOut(0);
  alias  MotorDownOut    : std_logic is MotorControlOut(1);
  
  signal OpenDoorsOut     : std_logic;
  signal ReleaseBreaksOut : std_logic;

  signal DEBUGState : integer;

  constant Freq    : integer := 10;
  signal   Running : boolean := true;
begin
  TheController : controller
    port map (
      Reset,
      Clock,
      RequestedFloorIn,
      CurrentFloorIn,
      PriorityUpSignalIn,
      RequestedSignalIn,
      OpenTimeoutSignalIn,
      ButtonSignalsIn,
      SensorSignalsIn,

      TimerControlOut,
      MotorControlOut,
      OpenDoorsOut,
      ReleaseBreaksOut,

      DEBUGState
    );

  -- Define tempo de simulação e clock
  Running <= false after 600 sec;
  Clock   <= not Clock after (0.5/real(Freq)) * 1 sec when Running;
  Reset   <= '1' after 1 sec;

  -- Sequencia de abertura da porta com pedido no mesmo andar
  RequestedSignalIn       <= '1' after 30 sec, '0' after 30 sec + 1 sec;
  RequestedFloorIn        <=  0  after 30 sec,  1  after 30 sec + 1 sec;
  PriorityUpSignalIn      <= '1' after 30 sec, '0' after 30 sec + 1 sec;
  OpenDoorEndOfTravelIn   <= '1' after 30 sec + 10 sec;
  OpenTimeoutSignalIn     <= '1' after 30 sec + 30 sec;
  ClosedDoorEndOfTravelIn <= '1' after 30 sec + 50 sec;

  -- Sequencia de abertura da porta com pedido no mesmo andar
  -- RequestedSignal   <= '1' after 30 sec, '0' after 30 sec + 1 sec;
  -- RequestedFloor    <=  0  after 30 sec,  1  after 30 sec + 1 sec;
  -- PriorityUpSignal  <= '1' after 30 sec, '0' after 30 sec + 1 sec;
  -- SensorSignals(2)  <= '1' after 30 sec + 10 sec;
  -- OpenTimeoutSignal <= '1' after 30 sec + 30 sec;
  -- SensorSignals(3)  <= '1' after 30 sec + 50 sec;
end test;
