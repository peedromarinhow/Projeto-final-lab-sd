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
  ghdl -a ../../controller/controller.vhd
  ghdl -e tb
  ghdl -r tb --wave=%Src%.ghw
  if %ERRORLEVEL% equ 0 gtkwave %Src%.ghw
popd
