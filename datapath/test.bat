@echo off
SetLocal EnableDelayedExpansion

set Dir=../
set Src=datapath

if not exist build mkdir build

pushd build
  ghdl -a %Dir%%Src%.vhd
  ghdl -a %Dir%tb.vhd
  ghdl -a ../../counter/counter.vhd
  ghdl -a ../../timer/timer.vhd
  ghdl -a ../../comp/comp.vhd
  ghdl -a ../../sr_latch/sr_latch.vhd
  ghdl -a ../../controller/controller.vhd
  ghdl -e tb
  ghdl -r tb --vcd=%Src%.vcd
  if %ERRORLEVEL% equ 0 gtkwave %Src%.vcd
popd
