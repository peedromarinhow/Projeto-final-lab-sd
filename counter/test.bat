@echo off
SetLocal EnableDelayedExpansion

set Dir=../
set Src=counter

if not exist build mkdir build

pushd build
  ghdl -a %Dir%%Src%.vhd
  ghdl -a %Dir%tb.vhd
  ghdl -e tb
  ghdl -r tb --vcd=%Src%.vcd
  if %ERRORLEVEL% equ 0 gtkwave %Src%.vcd
popd
