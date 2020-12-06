program d5_2_my_seat;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

var
  Input: TStringList;
  Count: Integer;
  Line: String;
  Step: Char;
  i, Seat, MaxSeat: Integer;
  FoundSeats: array[0..1023] of Boolean;
  FoundSeat: Boolean;
begin
  MaxSeat := 0;
  for i := Low(FoundSeats) to High(FoundSeats) do
    FoundSeats[i] := False;
    
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));

    for Line in Input do
    begin
      Seat := 0;
      for i := 1 to 10 do
        Seat := (Seat shl 1) or Ord(CharInSet(Line[i], ['B', 'R']));
      if Seat > MaxSeat then
        MaxSeat := Seat;
      FoundSeats[Seat] := True;
    end;

    FoundSeat := False;
    for i := Low(FoundSeats) to High(FoundSeats) do
    begin
      if FoundSeats[i] then FoundSeat := True
      else if FoundSeat then
      begin
        WriteLn('My seat is ', i);
        Break;
      end;
    end;


  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
