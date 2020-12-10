@echo off
setlocal enabledelayedexpansion

set input=%0\..\..\Input\10.input.txt

:: Store and count the values
:: Start with the value 0, to represent the charging outlet
set input0=0
set high=0
for /F %%f in (%input%) do call :AddInput %%f

:: Sort the input
call :Sort
:: Add the last one (rating = highest + 3)
call :AddInput "!input%high%! + 3"

:: Show what we have
::echo Sorted input:
::for /L %%i in (0, 1, %high%) do echo !input%%i!

:: Count ones and threes
:: Prepend the offset val
set low=0
set ones=0
set threes=0

for /L %%i in (1, 1, %high%) do (
  set /a prev=%%i - 1
  set prevvar=input!prev!
  set thisvar=input%%i
  call :Count !prevvar! !thisvar!
)
set /a answer=%ones% * %threes%
echo answer: %ones% ones * %threes% threes = %answer%

:: Day 2
:: Ok, so, it looks like, if I take the number of permutations in a range, and multiply all those permutations, I get the right total.
:: For example, 0,1,2,3,6,9,10,11,14, gives the ranges 0,1,2,3 and 9,10,11. 
:: The permutations of those are 0,1,2,3 ; 0,1,3 ; 0,2,3 ; 0,3 (4 permuations) and 9,10,11 ; 9,11 (2 permutations)
:: The total number of possibilities is 4 * 2 = 8.. That seams reasonable, and it checks out for the example.
:: Now, how to calculate how many permuations a range of N continuous numbers has? It seems that P(N) = P(N-1)+P(N-2)+P(N-3),
:: So, ranges of 1 are 1, 2 are 1, 3 are 2, 4 are 4, 5 are 7, 6 are 13 and so on.
:: Somehow it makes sense, but I'm lacking the math skills to explain it fully.

set rangelength=1
set lastvalue=0
set p0=1
set p1=0
set p2=0
set total=1
for /L %%i in (1, 1, %high%) do (
  set currvalue=!input%%i!
  set /a compvalue=!lastvalue! + 1
  set lastvalue=!currvalue!
  if !compvalue! equ !currvalue! (
    :: Live calculate the number of permutations for a range of this length, and store it in p0
    set p3=!p2!
    set p2=!p1!
    set p1=!p0!
    rem Number of permutations of a range of length N, P(n) = P(N-1)+P(N-2)+P(N-3), with P(1)=1 and P(less than 1)=0
    set /a p0=!p1! + !p2! + !p3!
    set /a rangelength=!rangelength! + 1
  ) else (
    :: Range ended, now multiply the total by the number of permutations in the range
    if !rangelength! gtr 1 (
      :: Built in arithmetics are 32 bits signed. We need moarr.
      if !p0! gtr 1 (
        rem set /a total=!total! * !p0!
        call :Mul total !total! !p0! 
        echo * !p0! = !total!
      )
      set p0=1
      set p1=0
      set p2=0
      set /a rangelength=1
    )
  )
)
echo Total arrangements: !total!
goto :eof

:AddInput
  :: %1: A number from the input file
  set /a high=%high% + 1
  set /a input%high%=%1
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

:Mul
setlocal
  :: %1 variable for result
  :: %2, %3 values to multiply
  set val1=%2
  set val2=%3
  call :length l1 %val1%
  call :length l2 %val2%
  set mulresult=0
  set tens=
  :: Good old long multiplication, digit by digit, pading with zeroes, carrying digits, etc.

  for /L %%a in (-1,-1,-%l1%) do (
    set carry=0
    set subresult=!tens!
    set d1=!val1:~%%a,1!
    for /L %%b in (-1,-1,-%l2%) do (
      set d2=!val2:~%%b,1!
      set /a muld=!d1! * !d2! + !carry!
      rem :: left pad with a 0. The value could become, say, 07, and carry will be 0. Without the padding, carry would 
      rem :: incorrectly become 7 too, due to some unexpected behavior on negative -from end- indexing beyond the start of the string.
      set muld=0!muld!
      set d=!muld:~-1,1!
      set /a carry=0!muld:~-2,1!

      set subresult=!d!!subresult!
    )
    :: Prepend the carry, if any
    if !carry! gtr 0 set subresult=!carry!!subresult!
    :: Add up the number to the total
    call :add mulresult !mulresult! !subresult!
    set tens=!tens!0
  )
endlocal & set %1=%mulresult%
goto :eof

:Add
  setlocal
  :: %1: result
  :: %2, %3 values
  set val1=%2
  set val2=%3
  :: Get the length of the longest number. Pad the shortest with a 0, otherwise the first digit is fetched multiple times, due 
  :: to quirky substr behavior
  call :length len %val1%
  call :length l2 %val2%
  if %len% lss %l2% (
    set len=%l2%
    set val1=0%val1%
  ) 
  if %len% gtr %l2% set val2=0%val2%

  set carry=0
  set add_result=
  for /L %%a in (-1,-1,-%len%) do (
    :: Adding is simply adding digits per column, carrying over the tens
    set /a d1=!val1:~%%a,1!
    set /a d2=!val2:~%%a,1!
    set /a addd=!d1! + !d2! + !carry!
    :: lpad with 0, to be able to always successfully extract the carry
    set addd=0!addd!
    set d=!addd:~-1,1!
    set /a carry=0!addd:~-2,1!
    set add_result=!d!!add_result!
  )
  if !carry! gtr 0 set add_result=!carry!!add_result!
  endlocal & set %1=%add_result%
goto :eof

:length
  setlocal
  set value=%2
  set pos=0
  :lengthloop
    if "!value:~%pos%,1!" NEQ "" (
      set /a pos=!pos!+1
      goto :lengthloop
    )
  endlocal & set %1=%pos%
goto :eof
