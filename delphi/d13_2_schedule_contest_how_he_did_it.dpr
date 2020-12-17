program d13_2_schedule_contest_how_he_did_it;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics;

// Solved like Dylan did
// https://twitter.com/DylanMeeus/status/1338260007339626496

type
  TBus = Integer;
  TBusses = array of TBus;
  TTime = Int64;


function GetInput: TBusses;
var
  Input: TStringList;
  i: Integer;
begin
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    Input.CommaText := Input[1];
    SetLength(Result, Input.Count);
    for i := 0 to Input.Count - 1 do
      Result[i] := StrToIntDef(Input[i], 0);
  finally
    Input.Free;
  end;
end;

function CheckBusses(const Busses: TBusses; Start: TTime): Boolean;
var
  i: Integer;
begin
  for i := Low(Busses) to High(Busses) do
  begin
    if (Busses[i] > 0) and ((Start+i) mod Busses[i] > 0) then
      Exit(False);
  end;
  Exit(True);
end;

function Lcm(const Busses: TBusses): TTime;
var
  Bus: TBus;
begin
  Result := 1;
  for Bus in Busses do
    if Bus > 0 then
      Result := Result * Bus;
end;

function FindAllignmentTime(const Busses: TBusses; Bus: Integer; Start: TTime): TTime;
var
  Incr: TTime;
  c: TBusses;
begin
  Incr := Lcm(Busses);
  c := Copy(Busses, 0, Length(Busses));
  SetLength(c, Length(c) + 1);
  c[High(c)] := Bus;
  while not CheckBusses(c, Start) do
    inc(Start, Incr);

  Result := Start;
end;

function Solve: Int64;
var
  Busses: TBusses;
  Start: TTime;
  i: Integer;
  SoFar: TBusses;
  AlignmentTime: TTime;
  Stopwatch: TStopwatch;
begin
  Busses := GetInput;

  Stopwatch := TStopwatch.StartNew;
  SetLength(SoFar, 1);
  SoFar[0] := Busses[0];

  Start := Busses[0];
  for i := 1 to High(Busses) do
  begin
    AlignmentTime := FindAllignmentTime(SoFar, Busses[i], Start);
    SetLength(SoFar, Length(SoFar)+1);
    SoFar[High(SoFar)] := Busses[i];
    Start := AlignmentTime;
  end;

  Result := Start;

  WriteLn(Stopwatch.ElapsedTicks, '/', Stopwatch.Frequency, ' = ', Stopwatch.ElapsedTicks * 1000000 div Stopwatch.Frequency);
end;

begin
  WriteLn(Solve);

  if IsDebuggerPresent then ReadLn;
end.
