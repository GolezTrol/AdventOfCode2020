program d5_1_seating_plan;

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
begin
  MaxSeat := 0;
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
    end;

    WriteLn(MaxSeat);

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;

end.
