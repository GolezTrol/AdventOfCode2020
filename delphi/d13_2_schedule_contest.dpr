program d13_2_schedule_contest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions;

type
  TBus = record
    BusNr, Index: Integer;
    Tracker: Int64;
  end;

var
  Input: TStringList;
  Now, Later, Expected: Int64;
  BusNr: String;
  Index, Count: Integer;
  Busses: TArray<TBus>;
  Bus: TBus;
  Step, MStep: Int64;
  Success: Boolean;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));

    Now := Input[0].ToInteger;
    Input.CommaText := Input[1];
    SetLength(Busses, Input.Count);
    Index := 0; Count := 0; Step := 1;
    for BusNr in Input do
    begin
      if BusNr <> 'x' then
      begin
        Busses[Count].BusNr := BusNr.ToInteger();
        Busses[Count].Index := Index;
        Busses[Count].Tracker := 0;
        Step := Step * Busses[Count].BusNr;
        Inc(Count);
      end;
      Inc(Index);
    end;
    SetLength(Busses, Count);

    Expected := Busses[0].Tracker;
    Index := 0; Step := 1; MStep := 0;
    while Index < Count do
    begin
      while Busses[Index].Tracker < Expected do
        Inc(Busses[Index].Tracker, Busses[Index].BusNr);
      if Busses[Index].Tracker = Expected then
      begin
        Inc(Index);
        if Index < Count then
          Expected := Busses[0].Tracker + Busses[Index].Index;
      end
      else
      begin
        Index := 0;
        Expected := Busses[0].Tracker + Busses[0].BusNr;
      end;
      Inc(Step);
      if Step = 100000000 then
      begin
        Step := 0;
        Inc(MStep);
        WriteLn(MStep);
      end;
    end;

    WriteLn('Magic happens at timestamp ', Busses[0].Tracker);

  finally
    Input.Free;

    if IsDebuggerPresent then ReadLn;
  end;


end.
