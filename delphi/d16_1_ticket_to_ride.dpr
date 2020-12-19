program d16_1_ticket_to_ride;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics, System.Generics.Collections;

type
  TRange = record
    Low, High: Integer;
  end;
  TRanges = array[0..1] of TRange;

  TType = record
    Name: String;
    Ranges: TRanges;
  end;
  TTypes = array of TType;

  TValue = type Int64;
  TValues = array of TValue;
  TTicket = record
    Values: TValues;
  end;
  TTickets = array of TTicket;

  TLineType = (ltType, ltMine, ltNearby);

  TInput = record
    Types: TTypes;
    Mine: TTicket;
    Nearby: TTickets;
  end;

function ReadType(Line: String): TType;
var
  p: Integer;
  u: TStringList;
begin
  u := TStringList.Create;
  try
    p := Pos(':', Line);
    Result.Name := Copy(Line, 1, p - 1);
    Delete(Line, 1, p + 1);
    Line := StringReplace(Line, ' or ', ',', [rfReplaceAll]);
    Line := StringReplace(Line, '-', ',', [rfReplaceAll]);
    u.CommaText := Line;
    Result.Ranges[0].Low := u[0].ToInteger;
    Result.Ranges[0].High := u[1].ToInteger;
    Result.Ranges[1].Low := u[2].ToInteger;
    Result.Ranges[1].High := u[3].ToInteger;
  finally
    u.Free;
  end;
end;

function ReadTicket(Line: string): TTicket;
var
  u: TStringList;
  i: Integer;
begin
  u := TStringList.Create;
  try
    u.CommaText := Line;
    SetLength(Result.Values, u.Count);
    for i := 0 to u.Count - 1 do
      Result.Values[i] := u[i].ToInteger;
  finally
    u.Free;
  end;
end;

function Load: TInput;
var
  Input: TStringList;
  Line: String;
  LineType: TLineType;
  TypeIndex, TicketIndex: Integer;
begin
  TypeIndex := 0; TicketIndex := 0;
  LineType := ltType;
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    SetLength(Result.Types, Input.Count);
    SetLength(Result.Nearby, Input.Count);
    for Line in Input do
    begin
      if Line = '' then
        // LineType := ltNone
      else if Line = 'your ticket:' then
        LineType := ltMine
      else if Line = 'nearby tickets:' then
        LineType := ltNearby
      else if LineType = ltType then
      begin
        Result.Types[TypeIndex] := ReadType(Line);
        Inc(TypeIndex);
      end
      else if LineType = ltMine then
      begin
        Result.Mine := ReadTicket(Line);
      end
      else if LineType = ltNearby then
      begin
        Result.Nearby[TicketIndex] := ReadTicket(Line);
        Inc(TicketIndex);
      end;
    end;

  finally
    Input.Free;
  end;
end;

procedure Solve1(Input: TInput);
var
  t: TType;
  r: TRange;
  n: TTicket;
  v: TValue;
  f: Boolean;
  Total: Integer;
begin
  Total := 0;
  for n in Input.Nearby do
  begin
    for v in n.Values do
    begin
      f := False;
      for t in Input.Types do
        for r in t.Ranges do
          if (v >= r.Low) and (v <= r.High) then
            f := True;

      if not f then
        Inc(Total, v);
    end;
  end;

  WriteLn(Total);
end;

procedure Solve;
var
  Input: TInput;
begin
  Input := Load;

  Solve1(Input);

  if IsDebuggerPresent then ReadLn;
end;

begin
  Solve;
end.
