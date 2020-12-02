program d1_2_expense_report;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Classes, Spring.Collections;

type
  TStringListHelper = class helper for TStringList
    function AsInt(Index: Integer): Integer;
  end;

function TStringListHelper.AsInt(Index: Integer): Integer;
begin
  Result := StrToInt(Self[Index]);
end;

const
  Parts = 3;
  MaxPart = Parts-1;

type
  TPartsIntArray = array[-1..MaxPart] of Integer;

var
  Sorted: IList<Integer>;

function Detect(
  var Index: TPartsIntArray;
  Level: Integer;
  out Output: Int64): Boolean;
var
  i: Integer;
  n: Integer;
  s, p: Int64;
begin
  Result := False;
  s := 0;
  p := 1;
  if Level = MaxPart then
    for n := 0 to Level-1 do
    begin
      s := s + Sorted[Index[n]];
      p := p * Sorted[Index[n]];
    end;

  for i := Index[Level-1] + 1 to Sorted.Count - (Parts - Level) do
  begin
    if Level = MaxPart then
    begin
      n := Sorted[Index[Level]];
      if s + n = 2020 then
      begin
        Result := True;
        Output := p*n;
      end
      else if s+n > 2020 then
        Exit;
    end
    else
    begin
      Index[Level] := i;
      Result := Detect(Index, Level+1, Output);
      if Result then
        Exit;
    end;
  end;
end;

var
  Report: TStringList;
  Index: TPartsIntArray;
  n, Output: Int64;
begin
  Report := TStringList.Create;
  Sorted := TCollections.CreateList<Integer>(
    function (const Left, Right: Integer): Integer
    begin
      Exit(Left - Right);
    end);

  try
    Report.LoadFromFile(ParamStr(1));
    for n := 0 to Report.Count - 1 do
      Sorted.Add(Report.AsInt(n));
  finally
    Report.Free;
  end;

  Sorted.Sort;

  Index[-1] := -1;
  if Detect(Index, 0, Output) then
    WriteLn(Output);
end.
