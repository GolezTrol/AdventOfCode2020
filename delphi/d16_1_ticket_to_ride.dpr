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

  TValueCheck = Boolean;
  TValueChecks = array of TValueCheck;
  TType = record
    Name: String;
    Ranges: TRanges;
    CouldBe: TValueChecks;
    ValueIndex: Integer;
  end;
  TTypes = array of TType;

  TValue = type Int64;
  TValues = array of TValue;
  TTicket = record
    Values: TValues;
    Valid: Boolean;
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
    Result.ValueIndex := -1;
  finally
    u.Free;
  end;
end;

function ReadTicket(Line: string): TTicket;
var
  u: TStringList;
  i: Integer;
begin
  Result.Valid := True;
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
  i: Integer;
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

    SetLength(Result.Types, TypeIndex);
    SetLength(Result.Nearby, TicketIndex);

    for TypeIndex := Low(Result.Types) to High(Result.Types) do
    begin
      SetLength(Result.Types[TypeIndex].CouldBe, Length(Result.Mine.Values));
      for i := Low(Result.Mine.Values) to High(Result.Mine.Values) do
        Result.Types[TypeIndex].CouldBe[i] := True;
    end;
  finally
    Input.Free;
  end;
end;

procedure Solve1(var Input: TInput);
var
  t: TType;
  r: TRange;
  n: TTicket;
  v: TValue;
  f: Boolean;
  Total: Integer;
  ni: Integer;
begin
  Total := 0;
  for ni := Low(Input.Nearby) to High(Input.Nearby) do
  begin
    n := Input.Nearby[ni];
    for v in n.Values do
    begin
      f := False;
      for t in Input.Types do
        for r in t.Ranges do
          if (v >= r.Low) and (v <= r.High) then
            f := True;

      if not f then
      begin
        Inc(Total, v);
        Input.Nearby[ni].Valid := False;
      end;
    end;
  end;

  WriteLn(Total);
end;

procedure Solve2(var Input: TInput);
var
  Ticket: TTicket;
  Range: TRange;
  i, n, r, t, t2, v, vi: Integer;
  Found: Boolean;
  Total: Int64;
begin
  n := 0;
  for i := Low(Input.Nearby) to High(Input.Nearby) do
  begin
    if Input.Nearby[i].Valid then
    begin
      Input.Nearby[n] := Input.Nearby[i];
      Inc(n);
    end;
  end;
  Input.Nearby[n] := Input.Mine;
  SetLength(Input.Nearby, n+1);

  // Ye ye, some repeated code from 1.
  for Ticket in Input.Nearby do
    for v := Low(Ticket.Values) to High(Ticket.Values) do
      for t := Low(Input.Types) to High(Input.Types) do
      begin
        Found := False;
        for Range in Input.Types[t].Ranges do
          if (Ticket.Values[v] >= Range.Low) and (Ticket.Values[v] <= Range.High) then
            Found := True;

        if not Found  then
        begin
          Input.Types[t].CouldBe[v] := False;
        end;
      end;

  for i := Low(Input.Types) to High(Input.Types) do // So many times should be enough
  begin
    for t := Low(Input.Types) to High(Input.Types) do // The actual types
      if Input.Types[t].ValueIndex = -1 then // If this one wasn't finished yet
      begin
        n := 0;
        for v := Low(Input.Types[t].CouldBe) to High(Input.Types[t].CouldBe) do // Count how many value indexes it matches
        begin
          if Input.Types[t].CouldBe[v] then
          begin
            Inc(n);
            vi := v;
          end;
        end;
        WriteLn('Iteration ', i, '. Checking type ', Input.Types[t].Name, ' gives ', n, ' matches');
        if n = 1 then // It matches one value. This value (index) has this type
        begin
          Input.Types[t].ValueIndex := vi;
          WriteLn(Input.Types[t].Name, ' has value index ', vi);
          // Other types cannot have this value index. (sudoku solving)
          for t2 := Low(Input.Types) to High(Input.Types) do
            Input.Types[t2].CouldBe[vi] := False;
          Break;
        end;
      end;
  end;

  Total := 1;
  for t := Low(Input.Types) to High(Input.Types) do
    if Input.Types[t].Name.StartsWith('departure') then
      Total := Total * Input.Mine.Values[Input.Types[t].ValueIndex];

  WriteLn(Total);
end;

procedure Solve;
var
  Input: TInput;
begin
  Input := Load;

  Solve1(Input); // 1 modifies input, needed for 2
  Solve2(Input);

  WriteLn('done');
  if IsDebuggerPresent then ReadLn;
end;

begin
  Solve;
end.
