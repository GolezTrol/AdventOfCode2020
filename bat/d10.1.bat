@echo off
setlocal enabledelayedexpansion

set input=%0\..\..\Input\10.input.txt

:: Store and count the values
:: Start with the value 0, to represent the charging outlet
set input0=0
set index=0
for /F %%f in (%input%) do call :AddInput %%f
set high=%index%

:: Sort the input
call :Sort

:: Show what we have
:: echo Sorted input:
:: for /L %%i in (0, 1, %high%) do echo !input%%i!

:: Count ones and threes
:: Prepend the offset val
set low=0
set ones=0
:: Shortcut: rather than adding highest+3 to the list, just count one extra for the threes
set threes=1

for /L %%i in (1, 1, %high%) do (
  set /a prev=%%i - 1
  set prevvar=input!prev!
  set thisvar=input%%i
  call :Count !prevvar! !thisvar!
)
set /a answer=%ones% * %threes%
echo answer: %ones% ones * %threes% threes = %answer%

goto :eof

:AddInput
  :: %1: A number from the input file
  set /a index=%index% + 1
  set input%index%=%1
goto :eof

:Sort
  set end=%high%
  :SortLoop
  set /a end=%end% - 1
  for /L %%i in (0, 1, %end%) do call :SwapWithNext %%i

  if 0 lss %end% goto :SortLoop
goto :eof

:SwapWithNext
  :: %1: Index of item to check
  set /a next=%1 + 1
  set thisvar=input%1
  set nextvar=input%next%
  if !%thisvar%! gtr !%nextvar%! (
      set swap=!%nextvar%!
      set %nextvar%=!%thisvar%!
      set %thisvar%=!swap!
  )
goto :eof

:Count
  :: %1, %2: names of the input variables to compare
  set a=%1
  set b=%2
  set /a diff=!%b%! - !%a%!
  :: echo %b% (!%b%!) - %a% (!%a%!) = %diff%
  echo !%b%! (+%diff%)
  if %diff% equ 1 set /a ones=%ones% + 1
  if %diff% equ 3 set /a threes=%threes% + 1
goto :eof
