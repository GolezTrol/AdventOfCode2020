program d1_1_expense_report;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, Classes;

type
  TStringListHelper = class helper for TStringList
    function AsInt(Index: Integer): Integer;
  end;

function TStringListHelper.AsInt(Index: Integer): Integer;
begin
  Result := StrToInt(Self[Index]);
end;

var
  Report: TStringList;
  i, j: Integer;
  a, b: Integer;
begin
  Report := TStringList.Create;
  try

    for i := 0 to Report.Count - 2 do
      for j := i + 1 to Report.Count - 1 do
      begin
        a := Report.AsInt(i);
        b := Report.AsInt(j);
        WriteLn(a, '+', b, '=', a+b);
        if a + b = 2020 then
        begin
          WriteLn(a*b);
          Exit;
        end;

      end;
  finally
    Report.Free;
  end;
end.
